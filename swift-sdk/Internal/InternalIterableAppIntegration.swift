//
//  Copyright © 2018 Iterable. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

// Returns whether notifications are enabled
protocol NotificationStateProviderProtocol {
    func isNotificationsEnabled(withCallback callback: @escaping (Bool) -> Void)
    
    func registerForRemoteNotifications()
}

struct SystemNotificationStateProvider: NotificationStateProviderProtocol {
    func isNotificationsEnabled(withCallback callback: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { setttings in
            let notificationsDisabled = setttings.authorizationStatus == .notDetermined || setttings.authorizationStatus == .denied
            callback(!notificationsDisabled)
        }
    }
    
    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            AppExtensionHelper.application?.registerForRemoteNotifications()
        }
    }
}

public protocol NotificationResponseProtocol {
    var userInfo: [AnyHashable: Any] { get }
    
    var actionIdentifier: String { get }
    
    var userText: String? { get }
}

struct UserNotificationResponse: NotificationResponseProtocol {
    var userInfo: [AnyHashable: Any] {
        response.notification.request.content.userInfo
    }
    
    var actionIdentifier: String {
        response.actionIdentifier
    }
    
    var userText: String? {
        guard let textInputResponse = response as? UNTextInputNotificationResponse else {
            return nil
        }

        return textInputResponse.userText
    }
    
    private let response: UNNotificationResponse
    
    init(response: UNNotificationResponse) {
        self.response = response
    }
}

/// Abstraction of push tracking
protocol PushTrackerProtocol: AnyObject {
    var lastPushPayload: [AnyHashable: Any]? { get }
    
    @discardableResult
    func trackPushOpen(_ userInfo: [AnyHashable: Any],
                       dataFields: [AnyHashable: Any]?,
                       onSuccess: OnSuccessHandler?,
                       onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func trackPushOpen(_ campaignId: NSNumber,
                       templateId: NSNumber?,
                       messageId: String,
                       appAlreadyRunning: Bool,
                       dataFields: [AnyHashable: Any]?,
                       onSuccess: OnSuccessHandler?,
                       onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
}

extension PushTrackerProtocol {
    func trackPushOpen(_ userInfo: [AnyHashable: Any],
                       dataFields: [AnyHashable: Any]? = nil) {
        trackPushOpen(userInfo,
                      dataFields: dataFields,
                      onSuccess: nil,
                      onFailure: nil)
    }
    
    func trackPushOpen(_ campaignId: NSNumber,
                       templateId: NSNumber? = nil,
                       messageId: String,
                       appAlreadyRunning: Bool = false,
                       dataFields: [AnyHashable: Any]? = nil) {
        trackPushOpen(campaignId,
                      templateId: templateId,
                      messageId: messageId,
                      appAlreadyRunning: appAlreadyRunning,
                      dataFields: dataFields,
                      onSuccess: nil,
                      onFailure: nil)
    }
}

/// Abstraction of applicationState
@objc public protocol ApplicationStateProviderProtocol: AnyObject {
    @objc var applicationState: UIApplication.State { get }
}

extension UIApplication: ApplicationStateProviderProtocol {}

struct InternalIterableAppIntegration {
    private weak var tracker: PushTrackerProtocol?
    private let urlDelegate: IterableURLDelegate?
    private let customActionDelegate: IterableCustomActionDelegate?
    private let urlOpener: UrlOpenerProtocol?
    private let allowedProtocols: [String]
    private weak var inAppNotifiable: InAppNotifiable?
    private weak var embeddedNotifiable: EmbeddedNotifiable?
    
    init(tracker: PushTrackerProtocol,
         urlDelegate: IterableURLDelegate? = nil,
         customActionDelegate: IterableCustomActionDelegate? = nil,
         urlOpener: UrlOpenerProtocol? = nil,
         allowedProtocols: [String] = [],
         inAppNotifiable: InAppNotifiable,
         embeddedNotifiable: EmbeddedNotifiable) {
        self.tracker = tracker
        self.urlDelegate = urlDelegate
        self.customActionDelegate = customActionDelegate
        self.urlOpener = urlOpener
        self.allowedProtocols = allowedProtocols
        self.inAppNotifiable = inAppNotifiable
        self.embeddedNotifiable = embeddedNotifiable
    }
    
    /**
     * This method handles'silent push' notifications
     *
     * - parameter application: UIApplication singleton object
     * - parameter userInfo: Dictionary containing the notification data
     * - parameter completionHandler: Completion handler passed from the original call. Iterable will call the completion handler
     * automatically if you pass one. If you handle completionHandler in the app code, pass a nil value to this argument.
     */
    func application(_ application: ApplicationStateProviderProtocol, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)?) {
        ITBInfo()
        
        if case let NotificationInfo.silentPush(silentPush) = NotificationHelper.inspect(notification: userInfo) {
            switch silentPush.notificationType {
            case .update:
                _ = inAppNotifiable?.scheduleSync()
            case .updateEmbedded:
                embeddedNotifiable?.syncMessages {}
            case .remove:
                if let messageId = silentPush.messageId {
                    inAppNotifiable?.onInAppRemoved(messageId: messageId)
                } else {
                    ITBError("messageId not found in 'remove' silent push")
                }
            }
        }
        
        completionHandler?(.noData)
    }
    
    /**
     * This method handles user actions on incoming Iterable notifications
     *
     * - parameter center: `UNUserNotificationCenter` singleton object
     * - parameter response: Notification response containing the user action and notification data. Passed from the original call.
     * - parameter completionHandler: Completion handler passed from the original call. Iterable will call the completion handler
     * automatically if you pass one. If you handle completionHandler in the app code, pass a nil value to this argument.
     */
    func userNotificationCenter(_: UNUserNotificationCenter?, didReceive response: NotificationResponseProtocol, withCompletionHandler completionHandler: (() -> Void)?) {
        ITBInfo()
        
        let userInfo = response.userInfo
        
        // Ignore the notification if we've already processed it from launchOptions while initializing SDK
        guard !alreadyTracked(userInfo: userInfo) else {
            completionHandler?()
            return
        }
        
        guard let itbl = InternalIterableAppIntegration.itblValue(fromUserInfo: userInfo) else {
            completionHandler?()
            return
        }
        
        let dataFields = InternalIterableAppIntegration.createIterableDataFields(actionIdentifier: response.actionIdentifier, userText: response.userText)
        let action = InternalIterableAppIntegration.createIterableAction(actionIdentifier: response.actionIdentifier, userText: response.userText, userInfo: userInfo, iterableElement: itbl)
        
        // Track push open
        if let _ = dataFields[JsonKey.actionIdentifier] { // i.e., if action is not dismiss
            tracker?.trackPushOpen(userInfo, dataFields: dataFields)
        }
        
        // Execute the action
        if let action = action {
            let context = IterableActionContext(action: action, source: .push)
            ActionRunner.execute(action: action,
                                         context: context,
                                         urlHandler: IterableUtil.urlHandler(fromUrlDelegate: urlDelegate, inContext: context),
                                         customActionHandler: IterableUtil.customActionHandler(fromCustomActionDelegate: customActionDelegate, inContext: context),
                                         urlOpener: urlOpener,
                                         allowedProtocols: allowedProtocols)
        }
        
        completionHandler?()
    }
    
    private static func createIterableAction(actionIdentifier: String,
                                             userText: String?,
                                             userInfo: [AnyHashable: Any],
                                             iterableElement itbl: [AnyHashable: Any]) -> IterableAction? {
        var action: IterableAction?
        
        if actionIdentifier == UNNotificationDefaultActionIdentifier {
            action = createDefaultAction(userInfo: userInfo, iterableElement: itbl)
        } else if actionIdentifier == UNNotificationDismissActionIdentifier {
            // We don't track dismiss actions yet
        } else {
            // Action Buttons
            if let actionConfig = findButtonActionConfig(actionIdentifier: actionIdentifier, iterableElement: itbl) {
                action = IterableAction.action(fromDictionary: actionConfig)
            }
        }
        
        if let userText = userText {
            action?.userInput = userText
        }
        
        return action
    }
    
    private static func createDefaultAction(userInfo: [AnyHashable: Any], iterableElement itbl: [AnyHashable: Any]) -> IterableAction? {
        if let defaultActionConfig = itbl[JsonKey.Payload.defaultAction] as? [AnyHashable: Any] {
            return IterableAction.action(fromDictionary: defaultActionConfig)
        } else {
            return InternalIterableAppIntegration.legacyDefaultActionFromPayload(userInfo: userInfo)
        }
    }
    
    private static func findButtonActionConfig(actionIdentifier: String, iterableElement itbl: [AnyHashable: Any]) -> [AnyHashable: Any]? {
        guard let buttons = itbl[JsonKey.Payload.actionButtons] as? [[AnyHashable: Any]] else {
            return nil
        }
        
        let foundButton = buttons.first { (button) -> Bool in
            guard let buttonIdentifier = button[JsonKey.ActionButton.identifier] as? String else {
                return false
            }
            
            return buttonIdentifier == actionIdentifier
        }
        
        return foundButton?[JsonKey.ActionButton.action] as? [AnyHashable: Any]
    }
    
    private static func createIterableDataFields(actionIdentifier: String, userText: String?) -> [AnyHashable: Any] {
        var dataFields = [AnyHashable: Any]()
        
        if actionIdentifier == UNNotificationDefaultActionIdentifier {
            dataFields[JsonKey.actionIdentifier] = JsonValue.ActionIdentifier.pushOpenDefault
        } else if actionIdentifier == UNNotificationDismissActionIdentifier {
            // We don't track dismiss actions yet
        } else {
            dataFields[JsonKey.actionIdentifier] = actionIdentifier
        }
        
        if let userText = userText {
            dataFields[JsonKey.userText] = userText
        }
        
        return dataFields
    }
    
    func performDefaultNotificationAction(_ userInfo: [AnyHashable: Any]) {
        // Ignore the notification if we've already processed it from launchOptions while initializing SDK
        guard !alreadyTracked(userInfo: userInfo) else {
            return
        }
        
        // Track push open
        let dataFields = [JsonKey.actionIdentifier: JsonValue.ActionIdentifier.pushOpenDefault]
        tracker?.trackPushOpen(userInfo, dataFields: dataFields)
        
        guard let itbl = InternalIterableAppIntegration.itblValue(fromUserInfo: userInfo) else {
            return
        }
        
        // Execute the action
        if let action = InternalIterableAppIntegration.createDefaultAction(userInfo: userInfo, iterableElement: itbl) {
            let context = IterableActionContext(action: action, source: .push)
            
            ActionRunner.execute(action: action,
                                         context: context,
                                         urlHandler: IterableUtil.urlHandler(fromUrlDelegate: urlDelegate, inContext: context),
                                         customActionHandler: IterableUtil.customActionHandler(fromCustomActionDelegate: customActionDelegate, inContext: context),
                                         urlOpener: urlOpener,
                                         allowedProtocols: allowedProtocols)
        }
    }
    
    private func alreadyTracked(userInfo: [AnyHashable: Any]) -> Bool {
        guard let lastPushPayload = tracker?.lastPushPayload else {
            return false
        }
        
        return NSDictionary(dictionary: lastPushPayload).isEqual(to: userInfo)
    }
    
    // Normally itblValue would be the value stored in "itbl" key inside of userInfo.
    // But it is possible to save them at root level for debugging purpose.
    private static func itblValue(fromUserInfo userInfo: [AnyHashable: Any]) -> [AnyHashable: Any]? {
        let itbl = userInfo[JsonKey.Payload.metadata] as? [AnyHashable: Any]
        
        #if DEBUG
            guard let value = itbl else {
                return nil
            }
            
            if value[JsonKey.Payload.defaultAction] == nil, value[JsonKey.Payload.actionButtons] == nil {
                return userInfo
            }
        #endif
        
        return itbl
    }
    
    // Normally default action would be stored in key "itbl/"defaultAction"
    // In legacy templates it gets saved in the key "url"
    private static func legacyDefaultActionFromPayload(userInfo: [AnyHashable: Any]) -> IterableAction? {
        if let deepLinkUrl = userInfo[JsonKey.url] as? String {
            return IterableAction.actionOpenUrl(fromUrlString: deepLinkUrl)
        }
        
        return nil
    }
}
