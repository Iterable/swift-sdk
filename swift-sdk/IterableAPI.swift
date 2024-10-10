//
//  Copyright © 2018 Iterable. All rights reserved.
//

import Foundation
import UIKit

@objcMembers public final class IterableAPI: NSObject {
    /// The current SDK version
    public static let sdkVersion = "6.5.7"
    
    /// The email of the logged in user that this IterableAPI is using
    public static var email: String? {
        get {
            implementation?.email
        } set {
            implementation?.email = newValue
        }
    }
    
    /// The user ID of the logged in user that this IterableAPI is using
    public static var userId: String? {
        get {
            implementation?.userId
        } set {
            implementation?.userId = newValue
        }
    }
    
    /// The current authentication token
    public static var authToken: String? {
        get {
            implementation?.authToken
        }
    }
    
    /// The `userInfo` dictionary which came with last push
    public static var lastPushPayload: [AnyHashable: Any]? {
        implementation?.lastPushPayload
    }
    
    /// Attribution info (`campaignId`, `messageId`, etc.) for last push open or app link click from an email
    public static var attributionInfo: IterableAttributionInfo? {
        get {
            implementation?.attributionInfo
        } set {
            implementation?.attributionInfo = newValue
        }
    }
    
    // MARK: - Initialization
    
    /// An SDK initializer taking in the Iterable Mobile API key to be utilized, and using default SDK settings
    ///
    /// - Parameters:
    ///     - apiKey: The Iterable Mobile API key to be used with the SDK
    ///
    /// - SeeAlso: IterableConfig
    @available(iOSApplicationExtension, unavailable)
    public static func initialize(apiKey: String) {
        initialize(apiKey: apiKey, launchOptions: nil)
    }
    
    /// An SDK initializer taking in the Iterable Mobile API key to be utilized, and a config object for the
    /// SDK's settings
    ///
    /// - Parameters:
    ///     - apiKey: The Iterable Mobile API key to be used with the SDK
    ///     - config: The `IterableConfig` object with the settings to be used
    ///
    /// - SeeAlso: IterableConfig
    @available(iOSApplicationExtension, unavailable)
    public static func initialize(apiKey: String,
                                  config: IterableConfig) {
        initialize(apiKey: apiKey, launchOptions: nil, config: config)
    }
    
    /// An SDK initializer taking in the Iterable Mobile API key to be utilized and the
    /// `launchOptions` passed on from the app delegate, using default SDK settings
    ///
    /// - Parameters:
    ///    - apiKey: The Iterable Mobile API key to be used with the SDK
    ///    - launchOptions: The `launchOptions` coming from `application(_:didFinishLaunchingWithOptions:)`
    ///
    /// - SeeAlso: IterableConfig
    @available(iOSApplicationExtension, unavailable)
    public static func initialize(apiKey: String,
                                  launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        initialize(apiKey: apiKey, launchOptions: launchOptions, config: IterableConfig())
    }
    
    /// An SDK initializer taking in the Iterable Mobile API key to be utilized as well as the
    /// `launchOptions` passed on from the Apple app delegate, and a config object for the SDK
    ///
    /// - Parameters:
    ///    - apiKey: The Iterable Mobile API key to be used with the SDK
    ///    - launchOptions: The `launchOptions` coming from `application(_:didFinishLaunchingWithOptions:)`
    ///    - config: The `IterableConfig` object with the settings to be used
    ///
    /// - SeeAlso: IterableConfig
    @available(iOSApplicationExtension, unavailable)
    public static func initialize(apiKey: String,
                                  launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                                  config: IterableConfig = IterableConfig()) {
        initialize2(apiKey: apiKey,
                    launchOptions: launchOptions,
                    config: config)
    }

    /// DO NOT USE THIS.
    /// This method is used internally to connect to staging and test environments.
    @available(iOSApplicationExtension, unavailable)
    public static func initialize2(apiKey: String,
                                   launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                                   config: IterableConfig = IterableConfig(),
                                   apiEndPointOverride: String? = nil,
                                   callback: ((Bool) -> Void)? = nil) {
        AppExtensionHelper.initialize()
        implementation = InternalIterableAPI(apiKey: apiKey,
                                                     launchOptions: launchOptions,
                                                     config: config,
                                                     apiEndPointOverride: apiEndPointOverride)
        _ = implementation?.start().onSuccess { _ in
            callback?(true)
        }.onError { _ in
            callback?(false)
        }
        
        if let _implementation = implementation, config.enableAnonTracking, !_implementation.isEitherUserIdOrEmailSet(), _implementation.getAnonymousUsageTracked() {
            _implementation.anonymousUserManager.getAnonCriteria()
            _implementation.anonymousUserManager.updateAnonSession()
        }
    }

    public static func setAnonymousUsageTracked(isAnonymousUsageTracked: Bool) {
        if let _implementation = implementation {
            _implementation.setAnonymousUsageTracked(isAnonymousUsageTracked: isAnonymousUsageTracked)
        }
    }

    public static func getAnonymousUsageTracked() -> Bool {
        return implementation?.getAnonymousUsageTracked() ?? false
    }
    // MARK: - SDK
    
    public static func setEmail(_ email: String?, _ authToken: String? = nil,  _ identityResolution: IterableIdentityResolution? = nil, _ successHandler: OnSuccessHandler? = nil, _ failureHandler: OnFailureHandler? = nil) {
        implementation?.setEmail(email, authToken: authToken, successHandler: successHandler, failureHandler: failureHandler, identityResolution: identityResolution)
    }
    
    public static func setUserId(_ userId: String?, _ authToken: String? = nil,  _ identityResolution: IterableIdentityResolution? = nil, _ successHandler: OnSuccessHandler? = nil, _ failureHandler: OnFailureHandler? = nil) {
        implementation?.setUserId(userId, authToken: authToken, successHandler: successHandler, failureHandler: failureHandler, identityResolution: identityResolution)
    }
    
    /// Handle a Universal Link
    ///
    /// For Iterable links, it will track the click and retrieve the original URL,
    /// pass it to `IterableURLDelegate` for handling. If it's not an Iterable link,
    /// it just passes the same URL to `IterableURLDelegate`
    ///
    /// - Parameters:
    ///    - url: The URL obtained from `UserActivity.webpageURL`
    ///
    /// - Returns: `true` if it is an Iterable link, or the value returned from `IterableURLDelegate` otherwise
    @objc(handleUniversalLink:)
    @discardableResult
    public static func handle(universalLink url: URL) -> Bool {
        if let implementation = implementation {
            return implementation.handleUniversalLink(url)
        } else {
            InternalIterableAPI.pendingUniversalLink = url
            return false
        }
    }
    
    /// Add an entry in the device attributes
    ///
    /// - Parameters:
    ///     - name: The device attribute name
    ///     - value: The device attribute value
    ///
    /// - Remark: This is used by our React Native SDK to properly attribute SDK usage
    @objc(setDeviceAttribute:value:)
    public static func setDeviceAttribute(name: String, value: String) {
        implementation?.setDeviceAttribute(name: name, value: value)
    }
    
    /// Remove an entry in the device attributes
    ///
    /// - Parameters:
    ///    - name: The device attribute name
    ///
    /// - Remark: This is used by our React Native SDK to properly attribute SDK usage
    @objc(removeDeviceAttribute:)
    public static func removeDeviceAttribute(name: String) {
        implementation?.removeDeviceAttribute(name: name)
    }
    
    /// Logs out the current user from the SDK instance
    ///
    /// - Remark: This will empty out user specific authentication data and reset the in-app manager.
    ///           If `autoPushRegistration` is `true` (which is the default value), this will also
    ///           disable the current push token.
    public static func logoutUser() {
        implementation?.logoutUser()
    }
    
    /// The instance that manages getting and showing in-app messages
    ///
    /// ```
    /// IterableAPI.inAppManager.getMessages()
    /// IterableAPI.inAppManager.show(message: message, consume: true)
    /// ```
    ///
    /// - Remark: This variable will do nothing if the SDK has not been initialized yet
    ///
    /// - SeeAlso: IterableInAppManagerProtocol
    public static var inAppManager: IterableInAppManagerProtocol {
        guard let implementation = implementation else {
            ITBError("IterableAPI is not initialized yet. In-apps will not work now.")
            assertionFailure("IterableAPI is not initialized yet. In-apps will not work now.")
            return EmptyInAppManager()
        }
        
        return implementation.inAppManager
    }
    
    public static var embeddedManager: IterableEmbeddedManagerProtocol {
        guard let implementation = implementation else {
            ITBError("The Iterable SDK is not initialized yet. Embedded Messaging will not function.")
            assertionFailure("The Iterable SDK is not initialized yet. Embedded Messaging will not function.")
            return EmptyEmbeddedManager()
        }
        
        return implementation.embeddedManager
    }
    
    // MARK: - API Request Calls
    
    /// Register this device's token with Iterable
    ///
    /// Push integration name and platform are read from `IterableConfig`. If platform is set to `auto`, it will
    /// read APNS environment from the provisioning profile and use an integration name specified in `IterableConfig`.
    ///
    /// - Parameters:
    ///    - token: The token representing this device/application pair, obtained from
    ///             `application:didRegisterForRemoteNotificationsWithDeviceToken`
    ///             after registering for remote notifications
    ///
    /// - SeeAlso: IterableConfig
    @objc(registerToken:)
    public static func register(token: Data) {
        implementation?.register(token: token)
    }
    
    /// Register this device's token with Iterable
    ///
    /// Push integration name and platform are read from `IterableConfig`. If platform is set to `auto`, it will
    /// read APNS environment from the provisioning profile and use an integration name specified in `IterableConfig`.
    ///
    /// - Parameters:
    ///    - token: The token representing this device/application pair, obtained from
    ///             `application:didRegisterForRemoteNotificationsWithDeviceToken`
    ///             after registering for remote notifications
    ///    - onSuccess: `OnSuccessHandler` to invoke if token registration is successful
    ///    - onFailure: `OnFailureHandler` to invoke if token registration fails
    ///
    /// - SeeAlso: IterableConfig, OnSuccessHandler, OnFailureHandler
    @objc(registerToken:onSuccess:OnFailure:)
    public static func register(token: Data, onSuccess: OnSuccessHandler? = nil, onFailure: OnFailureHandler? = nil) {
        implementation?.register(token: token, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    @objc(pauseAuthRetries:)
    public static func pauseAuthRetries(_ pauseRetry: Bool) {
        implementation?.authManager.pauseAuthRetries(pauseRetry)
        if !pauseRetry { // request new auth token as soon as unpause
            implementation?.authManager.requestNewAuthToken(hasFailedPriorAuth: false, onSuccess: nil, shouldIgnoreRetryPolicy: true)
        }
    }
    
    /// Disable this device's token in Iterable, for the current user.
    ///
    /// - Remark: By default, the SDK calls this upon user logout automatically. If a different or manually controlled
    ///           behavior is desired, set `autoPushRegistration` to `false` in the `IterableConfig` object when
    ///           initializing the SDK.
    ///
    /// - SeeAlso: IterableConfig
    public static func disableDeviceForCurrentUser() {
        implementation?.disableDeviceForCurrentUser()
    }
    
    /// Disable this device's token in Iterable, for all users on this device.
    public static func disableDeviceForAllUsers() {
        implementation?.disableDeviceForAllUsers()
    }
    
    /// Disable this device's token in Iterable, for the current user, with custom completion blocks
    ///
    /// - Parameters:
    ///    - onSuccess: `OnSuccessHandler` to invoke if disabling the token is successful
    ///    - onFailure: `OnFailureHandler` to invoke if disabling the token fails
    ///
    /// - SeeAlso: OnSuccessHandler, OnFailureHandler
    public static func disableDeviceForCurrentUser(withOnSuccess onSuccess: OnSuccessHandler?, onFailure: OnFailureHandler?) {
        implementation?.disableDeviceForCurrentUser(withOnSuccess: onSuccess, onFailure: onFailure)
    }
    
    /// Disable this device's token in Iterable, for all users of this device, with custom completion blocks.
    ///
    /// - Parameters:
    ///    - onSuccess: `OnSuccessHandler` to invoke if disabling the token is successful
    ///    - onFailure: `OnFailureHandler` to invoke if disabling the token fails
    ///
    /// - SeeAlso: OnSuccessHandler, OnFailureHandler
    public static func disableDeviceForAllUsers(withOnSuccess onSuccess: OnSuccessHandler?, onFailure: OnFailureHandler?) {
        implementation?.disableDeviceForAllUsers(withOnSuccess: onSuccess, onFailure: onFailure)
    }
    
    /// Updates the available user fields
    ///
    /// - Parameters:
    ///    - dataFields: Data fields to store in the user profile
    ///    - mergeNestedObjects: Merge top level objects instead of overwriting
    ///    - onSuccess: `OnSuccessHandler` to invoke if update is successful
    ///    - onFailure: `OnFailureHandler` to invoke if update fails
    ///
    /// - SeeAlso: OnSuccessHandler, OnFailureHandler
    @objc(updateUser:mergeNestedObjects:onSuccess:onFailure:)
    public static func updateUser(_ dataFields: [AnyHashable: Any],
                                  mergeNestedObjects: Bool,
                                  onSuccess: OnSuccessHandler? = nil,
                                  onFailure: OnFailureHandler? = nil) {
        implementation?.updateUser(dataFields,
                                           mergeNestedObjects: mergeNestedObjects,
                                           onSuccess: onSuccess,
                                           onFailure: onFailure)
    }
    
    /// Updates the current user's email
    ///
    /// - Parameters:
    ///    - newEmail: The new email address
    ///    - onSuccess: `OnSuccessHandler` to invoke if update is successful
    ///    - onFailure: `OnFailureHandler` to invoke if update fails
    ///
    /// - Remark: Also updates the current email in this IterableAPIImplementation instance if the API call was successful.
    ///
    /// - SeeAlso: OnSuccessHandler, OnFailureHandler
    @objc(updateEmail:onSuccess:onFailure:)
    public static func updateEmail(_ newEmail: String, onSuccess: OnSuccessHandler?, onFailure: OnFailureHandler?) {
        implementation?.updateEmail(newEmail, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    /// Updates the current user's email, and set the new authentication token
    ///
    /// - Parameters:
    ///    - newEmail: The new email of this user
    ///    - token: The new authentication token for this user, if left out, the SDK will not update the token in any way
    ///    - onSuccess: `OnSuccessHandler` to invoke if update is successful
    ///    - onFailure: `OnFailureHandler` to invoke if update fails
    ///
    /// - Remark: Also updates the current email in this internal instance if the API call was successful.
    ///
    /// - SeeAlso: OnSuccessHandler, OnFailureHandler
    @objc(updateEmail:withToken:onSuccess:onFailure:)
    public static func updateEmail(_ newEmail: String,
                                   withToken token: String,
                                   onSuccess: OnSuccessHandler?,
                                   onFailure: OnFailureHandler?) {
        implementation?.updateEmail(newEmail, withToken: token, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    /// Tracks what's in the shopping cart (or equivalent) at this point in time
    ///
    /// - Parameters:
    ///     - items: The list of items in the shopping cart to track
    ///
    /// - SeeAlso: CommerceItem
    @objc(updateCart:)
    public static func updateCart(items: [CommerceItem]) {
        implementation?.updateCart(items: items)
    }
    
    /// Tracks what's in the shopping cart (or equivalent) at this point in time
    ///
    /// - Parameters:
    ///     - items: The list of items in the shopping cart to track
    ///     - onSuccess: `OnSuccessHandler` to invoke if cart is updated successfully
    ///     - onFailure: `OnFailureHandler` to invoke if cart updating fails
    ///
    /// - SeeAlso: CommerceItem
    @objc(updateCart:onSuccess:onFailure:)
    public static func updateCart(items: [CommerceItem],
                                  onSuccess: OnSuccessHandler?,
                                  onFailure: OnFailureHandler?) {
        implementation?.updateCart(items: items, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    /// Tracks a purchase
    ///
    /// - Parameters:
    ///    - withTotal: The total purchase amount
    ///    - items: The list of purchased items
    ///
    /// - SeeAlso: CommerceItem
    @objc(trackPurchase:items:)
    public static func track(purchase withTotal: NSNumber, items: [CommerceItem]) {
        implementation?.trackPurchase(withTotal, items: items)
    }
    
    /// Tracks a purchase with additional data
    ///
    /// - Parameters:
    ///    - withTotal: The total purchase amount
    ///    - items: The list of purchased items
    ///    - dataFields: A `Dictionary` containing any additional information to save along with the event
    ///
    /// - SeeAlso: CommerceItem
    @objc(trackPurchase:items:dataFields:)
    public static func track(purchase withTotal: NSNumber, items: [CommerceItem], dataFields: [AnyHashable: Any]?) {
        implementation?.trackPurchase(withTotal, items: items, dataFields: dataFields)
    }
    
    /// Tracks a purchase with additional data and custom completion blocks.
    ///
    /// - Parameters:
    ///     - withTotal: The total purchase amount
    ///     - items: The list of purchased items
    ///     - dataFields: A `Dictionary` containing any additional information to save along with the event
    ///     - onSuccess: `OnSuccessHandler` to invoke if the purchase is tracked successfully
    ///     - onFailure: `OnFailureHandler` to invoke if tracking the purchase fails
    ///
    /// - SeeAlso: CommerceItem, OnSuccessHandler, OnFailureHandler
    @objc(trackPurchase:items:dataFields:onSuccess:onFailure:)
    public static func track(purchase withTotal: NSNumber,
                             items: [CommerceItem],
                             dataFields: [AnyHashable: Any]?,
                             onSuccess: OnSuccessHandler?,
                             onFailure: OnFailureHandler?) {
        implementation?.trackPurchase(withTotal,
                                              items: items,
                                              dataFields: dataFields,
                                              onSuccess: onSuccess,
                                              onFailure: onFailure)
    }

    /// Tracks a purchase with additional data and custom completion blocks.
    ///
    /// - Parameters:
    ///     - withTotal: The total purchase amount
    ///     - items: The list of purchased items
    ///     - dataFields: A `Dictionary` containing any additional information to save along with the event
    ///     - campaignId: The `campaignId` of the push notification that caused this open event
    ///     - templateId: The `templateId` of the push notification that caused this open event
    ///     - onSuccess: `OnSuccessHandler` to invoke if the purchase is tracked successfully
    ///     - onFailure: `OnFailureHandler` to invoke if tracking the purchase fails
    ///
    /// - SeeAlso: CommerceItem, OnSuccessHandler, OnFailureHandler
    @objc(trackPurchase:items:dataFields:campaignId:templateId:onSuccess:onFailure:)
    public static func track(purchase withTotal: NSNumber,
                             items: [CommerceItem],
                             dataFields: [AnyHashable: Any]?,
                             campaignId: NSNumber?,
                             templateId: NSNumber?,
                             onSuccess: OnSuccessHandler?,
                             onFailure: OnFailureHandler?) {
        implementation?.trackPurchase(withTotal,
                                              items: items,
                                              dataFields: dataFields,
                                              campaignId: campaignId,
                                              templateId: templateId,
                                              onSuccess: onSuccess,
                                              onFailure: onFailure)
    }

    
    /// Tracks a `pushOpen` event with a push notification payload
    ///
    /// - Parameters:
    ///    - userInfo: the `userInfo` parameter from the push notification payload
    @objc(trackPushOpen:)
    public static func track(pushOpen userInfo: [AnyHashable: Any]) {
        implementation?.trackPushOpen(userInfo)
    }
    
    /// Tracks a `pushOpen` event with a push notification and optional additional data
    ///
    /// - Parameters:
    ///     - userInfo: The `userInfo` parameter from the push notification payload
    ///     - dataFields: A `Dictionary` containing any additional information to save along with the event
    @objc(trackPushOpen:dataFields:)
    public static func track(pushOpen userInfo: [AnyHashable: Any], dataFields: [AnyHashable: Any]?) {
        implementation?.trackPushOpen(userInfo, dataFields: dataFields)
    }
    
    /// Tracks a `pushOpen` event with a push notification, optional additional data, and custom completion blocks
    ///
    /// - Parameters:
    ///     - userInfo: The `userInfo` parameter from the push notification payload
    ///     - dataFields: A `Dictionary` containing any additional information to save along with the event
    ///     - onSuccess: `OnSuccessHandler` to invoke if the open is tracked successfully
    ///     - onFailure: `OnFailureHandler` to invoke if tracking the open fails
    ///
    /// - SeeAlso: OnSuccessHandler, OnFailureHandler
    @objc(trackPushOpen:dataFields:onSuccess:onFailure:)
    public static func track(pushOpen userInfo: [AnyHashable: Any],
                             dataFields: [AnyHashable: Any]?,
                             onSuccess: OnSuccessHandler?,
                             onFailure: OnFailureHandler?) {
        implementation?.trackPushOpen(userInfo,
                                              dataFields: dataFields,
                                              onSuccess: onSuccess,
                                              onFailure: onFailure)
    }
    
    /// Tracks a `pushOpen` event for the specified campaign and template IDs, whether the app was already
    /// running when the push was received, and optional additional data
    ///
    /// - Parameters:
    ///     - campaignId: The `campaignId` of the push notification that caused this open event
    ///     - templateId: The `templateId` of the push notification that caused this open event
    ///     - messageId: The `messageId` of the the push notification that caused this open event
    ///     - appAlreadyRunning: This will get merged into `dataFields`, and it specifies whether
    ///                          the app is already running when the notification was received
    ///     - dataFields: A `Dictionary` containing any additional information to save along with the event
    ///
    /// - Remark: Pass in the the relevant campaign data
    @objc(trackPushOpen:templateId:messageId:appAlreadyRunning:dataFields:)
    public static func track(pushOpen campaignId: NSNumber,
                             templateId: NSNumber?,
                             messageId: String,
                             appAlreadyRunning: Bool,
                             dataFields: [AnyHashable: Any]?) {
        implementation?.trackPushOpen(campaignId,
                                              templateId: templateId,
                                              messageId: messageId,
                                              appAlreadyRunning: appAlreadyRunning,
                                              dataFields: dataFields)
    }
    
    /// Tracks a `pushOpen` event for the specified campaign and template IDs, whether the app was already
    /// running when the push was received, and optional additional data
    ///
    /// - Parameters:
    ///     - campaignId: The `campaignId` of the push notification that caused this open event
    ///     - templateId: The `templateId` of the the push notification that caused this open event
    ///     - messageId: The `messageId` of the the push notification that caused this open event
    ///     - appAlreadyRunning: This will get merged into `dataFields`, and it specifies whether
    ///                          the app is already running when the notification was received
    ///     - dataFields: A `Dictionary` containing any additional information to save along with the event
    ///
    /// - Remark: Pass in the the relevant campaign data
    ///
    /// - SeeAlso: OnSuccessHandler, OnFailureHandler
    @objc(trackPushOpen:templateId:messageId:appAlreadyRunning:dataFields:onSuccess:onFailure:)
    public static func track(pushOpen campaignId: NSNumber,
                             templateId: NSNumber?,
                             messageId: String,
                             appAlreadyRunning: Bool,
                             dataFields: [AnyHashable: Any]?,
                             onSuccess: OnSuccessHandler?,
                             onFailure: OnFailureHandler?) {
        implementation?.trackPushOpen(campaignId,
                                              templateId: templateId,
                                              messageId: messageId,
                                              appAlreadyRunning: appAlreadyRunning,
                                              dataFields: dataFields,
                                              onSuccess: onSuccess,
                                              onFailure: onFailure)
    }
    
    /// Tracks a custom event
    ///
    /// - Parameters:
    ///    - eventName: Name of the event
    ///
    /// - Remark: Pass in the custom event data.
    @objc(track:)
    public static func track(event eventName: String) {
        implementation?.track(eventName)
    }
    
    /// Tracks a custom event
    ///
    /// - Parameters:
    ///    - eventName: Name of the event
    ///    - dataFields: A `Dictionary` containing any additional information to save along with the event
    ///
    /// - Remark: Pass in the custom event data.
    @objc(track:dataFields:)
    public static func track(event eventName: String, dataFields: [AnyHashable: Any]?) {
        implementation?.track(eventName, dataFields: dataFields)
    }
    
    /// Tracks a custom event
    ///
    /// - Parameters:
    ///     - eventName: Name of the event
    ///     - dataFields: A `Dictionary` containing any additional information to save along with the event
    ///     - onSuccess: `OnSuccessHandler` to invoke if the open is tracked successfully
    ///     - onFailure: `OnFailureHandler` to invoke if tracking the open fails
    ///
    /// - Remark: Pass in the custom event data.
    @objc(track:dataFields:onSuccess:onFailure:)
    public static func track(event eventName: String,
                             dataFields: [AnyHashable: Any]?,
                             onSuccess: OnSuccessHandler?,
                             onFailure: OnFailureHandler?) {
        implementation?.track(eventName,
                                      dataFields: dataFields,
                                      onSuccess: onSuccess,
                                      onFailure: onFailure)
    }
    
    /// Updates a user's subscription preferences
    ///
    /// - Parameters:
    ///     - emailListIds: Email lists to subscribe to
    ///     - unsubscribedChannelIds: List of channels to unsubscribe from
    ///     - unsubscribedMessageTypeIds: List of message types to unsubscribe from
    ///
    /// - Remark: passing in an empty array will clear subscription list, passing in `nil` will not modify the list
    @objc(updateSubscriptions:unsubscribedChannelIds:unsubscribedMessageTypeIds:subscribedMessageTypeIds:campaignId:templateId:)
    public static func updateSubscriptions(_ emailListIds: [NSNumber]?,
                                           unsubscribedChannelIds: [NSNumber]?,
                                           unsubscribedMessageTypeIds: [NSNumber]?,
                                           subscribedMessageTypeIds: [NSNumber]?,
                                           campaignId: NSNumber?,
                                           templateId: NSNumber?) {
        implementation?.updateSubscriptions(emailListIds,
                                            unsubscribedChannelIds: unsubscribedChannelIds,
                                            unsubscribedMessageTypeIds: unsubscribedMessageTypeIds,
                                            subscribedMessageTypeIds: subscribedMessageTypeIds,
                                            campaignId: campaignId,
                                            templateId: templateId)
    }
    
    // MARK: Embedded Notifications
    
    /// Tracks analytics data from a session of using an inbox UI
    /// NOTE: this is not normally used publicly, but is needed for our React Native SDK implementation
    ///
    /// - Parameters:
    ///     - embeddedSession: the embedded session data type to track
    @objc(embeddedSession:)
    public static func track(embeddedSession: IterableEmbeddedSession) {
        implementation?.track(embeddedSession: embeddedSession)
    }
    
    @objc(embeddedMessageClick:buttonIdentifier:clickedUrl:)
    public static func track(embeddedMessageClick: IterableEmbeddedMessage, buttonIdentifier: String?, clickedUrl: String) {
        implementation?.track(embeddedMessageClick: embeddedMessageClick, buttonIdentifier: buttonIdentifier, clickedUrl: clickedUrl)
    }
    
    @objc(embeddedMessageReceived:)
    public static func track(embeddedMessageReceived: IterableEmbeddedMessage) {
        implementation?.track(embeddedMessageReceived: embeddedMessageReceived)
    }
    
    // MARK: In-App Notifications
    
    /// Tracks an `InAppOpen` event
    ///
    /// By default, the SDK will call this automatically. This is available in case a custom view controller
    /// is used for rendering `IterableInAppMessage`s.
    ///
    /// - Parameters:
    ///    - message: The Iterable in-app message
    ///    - location: The location from where this message was shown. `inbox` or `inApp`.
    ///
    /// - SeeAlso: IterableInAppDelegate
    @objc(trackInAppOpen:location:)
    public static func track(inAppOpen message: IterableInAppMessage, location: InAppLocation = .inApp) {
        implementation?.trackInAppOpen(message, location: location)
    }
    
    /// Tracks an `InAppClick` event
    ///
    /// By default, the SDK will call this automatically. This is available in case a custom view controller
    /// is used for rendering `IterableInAppMessage`s.
    ///
    /// - Parameters:
    ///     - message: The message of the notification
    ///     - location: The location from where this message was shown. `inbox` or `inApp`.
    ///     - clickedUrl: The URL of the button or link that was clicked
    @objc(trackInAppClick:location:clickedUrl:)
    public static func track(inAppClick message: IterableInAppMessage, location: InAppLocation = .inApp, clickedUrl: String) {
        implementation?.trackInAppClick(message, location: location, clickedUrl: clickedUrl)
    }
    
    /// Tracks an `InAppClose` event
    ///
    /// - Parameters:
    ///     - message: The in-app message
    ///     - clickedUrl: The url that was clicked to close the in-app. It will be `nil` when the message is closed by clicking `back`.
    @objc(trackInAppClose:clickedUrl:)
    public static func track(inAppClose message: IterableInAppMessage, clickedUrl: String?) {
        implementation?.trackInAppClose(message, clickedUrl: clickedUrl)
    }
    
    /// Tracks an `InAppClose` event
    ///
    /// - Parameters:
    ///     - message: The in-app message
    ///     - location: The location from where this message was shown. `inbox` or `inApp`.
    ///     - clickedUrl: The URL that was clicked to close the in-app. It will be `nil` when the message is closed by clicking `back`.
    @objc(trackInAppClose:location:clickedUrl:)
    public static func track(inAppClose message: IterableInAppMessage, location: InAppLocation, clickedUrl: String?) {
        implementation?.trackInAppClose(message, location: location, clickedUrl: clickedUrl)
    }
    
    /// Tracks an `InAppClose` event
    ///
    /// - Parameters:
    ///     - message: The in-app message that is being closed
    ///     - location: The location from where this message was shown. `inbox` or `inApp`.
    ///     - source: Source is `back` if back button was clicked to dismiss in-app message. Otherwise source is `link`.
    ///     - clickedUrl: The url that was clicked to close the in-app. It will be `nil` when the message is closed by clicking `back`.
    @objc(trackInAppClose:location:source:clickedUrl:)
    public static func track(inAppClose message: IterableInAppMessage, location: InAppLocation, source: InAppCloseSource, clickedUrl: String?) {
        implementation?.trackInAppClose(message, location: location, source: source, clickedUrl: clickedUrl)
    }
    
    /// Consumes the notification and removes it from the list of in-app messages
    ///
    /// - Parameters:
    ///    - message: The in-app message that is being consumed
    ///    - location: The location from where this message was shown. `inbox` or `inApp`.
    @objc(inAppConsume:location:)
    public static func inAppConsume(message: IterableInAppMessage, location: InAppLocation = .inApp) {
        implementation?.inAppConsume(message: message, location: location)
    }
    
    /// Consumes the notification and removes it from the list of in-app messages
    ///
    /// - Parameters:
    ///     - message: The in-app message that is being consumed
    ///     - location: The location from where this message was shown. `inbox` or `inApp`.
    ///     - source: The source of deletion `inboxSwipe` or `deleteButton`.
    @objc(inAppConsume:location:source:)
    public static func inAppConsume(message: IterableInAppMessage, location: InAppLocation = .inApp, source: InAppDeleteSource) {
        implementation?.inAppConsume(message: message, location: location, source: source)
    }
    
    /// Tracks analytics data from a session of using an inbox UI
    /// NOTE: this is not normally used publicly, but is needed for our React Native SDK implementation
    ///
    /// - Parameters:
    ///     - inboxSession: the inbox session data type to track
    @objc(trackInboxSession:)
    public static func track(inboxSession: IterableInboxSession) {
        implementation?.track(inboxSession: inboxSession)
    }
    
    // MARK: - Private/Internal
    
    static var implementation: InternalIterableAPI?
    
    override private init() { super.init() }
}
