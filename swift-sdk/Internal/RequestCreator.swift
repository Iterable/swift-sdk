//
//  Copyright © 2019 Iterable. All rights reserved.
//

import Foundation
import UIKit

/// This is a stateless pure functional class
/// This will create IterableRequest
/// The API Endpoint and request endpoint is not defined yet
struct RequestCreator {
    let auth: Auth
    let deviceMetadata: DeviceMetadata
    
    // MARK: - API REQUEST CALLS
    
    func createUpdateEmailRequest(newEmail: String, merge: Bool?) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var body = [String: Any]()
        
        if let email = auth.email {
            body[JsonKey.currentEmail] = email
        } else if let userId = auth.userId {
            body[JsonKey.currentUserId] = userId
        }
        if let accountMerge = merge {
            body[JsonKey.merge] = accountMerge
        }
        body[JsonKey.newEmail] = newEmail
        
        return .success(.post(createPostRequest(path: Const.Path.updateEmail, body: body)))
    }
    
    func createRegisterTokenRequest(registerTokenInfo: RegisterTokenInfo,
                                    notificationsEnabled: Bool) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        let dataFields = DataFieldsHelper.createDataFields(sdkVersion: registerTokenInfo.sdkVersion,
                                                           deviceId: registerTokenInfo.deviceId,
                                                           device: UIDevice.current,
                                                           bundle: Bundle.main,
                                                           notificationsEnabled: notificationsEnabled,
                                                           deviceAttributes: registerTokenInfo.deviceAttributes)
        
        let deviceDictionary: [String: Any] = [
            JsonKey.token: registerTokenInfo.hexToken,
            JsonKey.platform: RequestCreator.pushServicePlatformToString(registerTokenInfo.pushServicePlatform,
                                                                         apnsType: registerTokenInfo.apnsType),
            JsonKey.applicationName: registerTokenInfo.appName,
            JsonKey.dataFields: dataFields,
        ]
        
        var body = [AnyHashable: Any]()
        
        body[JsonKey.device] = deviceDictionary
        
        setCurrentUser(inDict: &body)
        
        if auth.email == nil, auth.userId != nil {
            body[JsonKey.preferUserId] = true
        }
        
        return .success(.post(createPostRequest(path: Const.Path.registerDeviceToken, body: body)))
    }
    
    func createUpdateUserRequest(dataFields: [AnyHashable: Any], mergeNestedObjects: Bool) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var body = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &body)
        
        if auth.email == nil, auth.userId != nil {
            body[JsonKey.preferUserId] = true
        }
        
        body[JsonKey.mergeNestedObjects] = NSNumber(value: mergeNestedObjects)
        
        body[JsonKey.dataFields] = dataFields
        
        return .success(.post(createPostRequest(path: Const.Path.updateUser, body: body)))
    }
    
    func createUpdateCartRequest(items: [CommerceItem]) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var apiUserDict = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &apiUserDict)
        
        let itemsToSerialize = items.map { $0.toDictionary() }
        
        let body: [String: Any] = [JsonKey.Commerce.user: apiUserDict,
                                   JsonKey.Commerce.items: itemsToSerialize]
        
        return .success(.post(createPostRequest(path: Const.Path.updateCart, body: body)))
    }
    
    func createTrackPurchaseRequest(_ total: NSNumber,
                                    items: [CommerceItem],
                                    dataFields: [AnyHashable: Any]?,
                                    campaignId: NSNumber?,
                                    templateId: NSNumber?) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var apiUserDict = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &apiUserDict)
        
        let itemsToSerialize = items.map { $0.toDictionary() }
        
        var body: [String: Any] = [JsonKey.Commerce.user: apiUserDict,
                                   JsonKey.Commerce.items: itemsToSerialize,
                                   JsonKey.Commerce.total: total]
        
        if let dataFields = dataFields {
            body[JsonKey.dataFields] = dataFields
        }

        if let campaignId = campaignId {
            body[JsonKey.campaignId] = campaignId
        }
        if let templateId = templateId {
            body[JsonKey.templateId] = templateId
        }

        return .success(.post(createPostRequest(path: Const.Path.trackPurchase, body: body)))
    }
    
    func createTrackPushOpenRequest(_ campaignId: NSNumber, templateId: NSNumber?, messageId: String, appAlreadyRunning: Bool, dataFields: [AnyHashable: Any]?) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var body = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &body)
        
        body[JsonKey.campaignId] = campaignId
        
        if let templateId = templateId {
            body[JsonKey.templateId] = templateId
        }
        
        body.setValue(for: JsonKey.messageId, value: messageId)
        
        var compositeDataFields = [AnyHashable: Any]()
        
        if let dataFields = dataFields {
            compositeDataFields = dataFields
        }
        
        compositeDataFields[JsonKey.appAlreadyRunning] = appAlreadyRunning
        
        body[JsonKey.dataFields] = compositeDataFields
        
        return .success(.post(createPostRequest(path: Const.Path.trackPushOpen, body: body)))
    }
    
    func createTrackEventRequest(_ eventName: String, dataFields: [AnyHashable: Any]?) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var body = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &body)
        
        body.setValue(for: JsonKey.eventName, value: eventName)
        
        if let dataFields = dataFields {
            body[JsonKey.dataFields] = dataFields
        }
        
        return .success(.post(createPostRequest(path: Const.Path.trackEvent, body: body)))
    }
    
    func createUpdateSubscriptionsRequest(_ emailListIds: [NSNumber]? = nil,
                                          unsubscribedChannelIds: [NSNumber]? = nil,
                                          unsubscribedMessageTypeIds: [NSNumber]? = nil,
                                          subscribedMessageTypeIds: [NSNumber]? = nil,
                                          campaignId: NSNumber? = nil,
                                          templateId: NSNumber? = nil) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var body = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &body)
        
        if let emailListIds = emailListIds {
            body[JsonKey.emailListIds] = emailListIds
        }
        
        if let unsubscribedChannelIds = unsubscribedChannelIds {
            body[JsonKey.unsubscribedChannelIds] = unsubscribedChannelIds
        }
        
        if let unsubscribedMessageTypeIds = unsubscribedMessageTypeIds {
            body[JsonKey.unsubscribedMessageTypeIds] = unsubscribedMessageTypeIds
        }
        
        if let subscribedMessageTypeIds = subscribedMessageTypeIds {
            body[JsonKey.subscribedMessageTypeIds] = subscribedMessageTypeIds
        }
        
        if let campaignId = campaignId?.intValue {
            body[JsonKey.campaignId] = campaignId
        }
        
        if let templateId = templateId?.intValue {
            body[JsonKey.templateId] = templateId
        }
        
        return .success(.post(createPostRequest(path: Const.Path.updateSubscriptions, body: body)))
    }
    
    // MARK: - In-App Messaging Request Calls
    
    func createGetInAppMessagesRequest(_ count: NSNumber) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var args: [AnyHashable: Any] = [JsonKey.InApp.count: count.description,
                                        JsonKey.platform: JsonValue.iOS,
                                        JsonKey.systemVersion: UIDevice.current.systemVersion,
                                        JsonKey.InApp.sdkVersion: IterableAPI.sdkVersion]
        
        if let packageName = Bundle.main.appPackageName {
            args[JsonKey.InApp.packageName] = packageName
        }
        
        setCurrentUser(inDict: &args)
        
        return .success(.get(createGetRequest(forPath: Const.Path.getInAppMessages, withArgs: args as! [String: String])))
    }
    
    func createTrackInAppOpenRequest(inAppMessageContext: InAppMessageContext) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var body = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &body)
        
        body.setValue(for: JsonKey.messageId, value: inAppMessageContext.messageId)
        body.setValue(for: JsonKey.inAppMessageContext, value: inAppMessageContext.toMessageContextDictionary())
        body.setValue(for: JsonKey.deviceInfo, value: deviceMetadata.asDictionary())
        
        if let inboxSessionId = inAppMessageContext.inboxSessionId {
            body.setValue(for: JsonKey.inboxSessionId, value: inboxSessionId)
        }
        
        return .success(.post(createPostRequest(path: Const.Path.trackInAppOpen, body: body)))
    }
    
    func createTrackInAppClickRequest(inAppMessageContext: InAppMessageContext, clickedUrl: String) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var body = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &body)
        
        body.setValue(for: JsonKey.messageId, value: inAppMessageContext.messageId)
        body.setValue(for: JsonKey.clickedUrl, value: clickedUrl)
        body.setValue(for: JsonKey.inAppMessageContext, value: inAppMessageContext.toMessageContextDictionary())
        body.setValue(for: JsonKey.deviceInfo, value: deviceMetadata.asDictionary())
        
        if let inboxSessionId = inAppMessageContext.inboxSessionId {
            body.setValue(for: JsonKey.inboxSessionId, value: inboxSessionId)
        }
        
        return .success(.post(createPostRequest(path: Const.Path.trackInAppClick, body: body)))
    }
    
    func createTrackInAppCloseRequest(inAppMessageContext: InAppMessageContext, source: InAppCloseSource?, clickedUrl: String?) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var body = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &body)
        
        body.setValue(for: JsonKey.messageId, value: inAppMessageContext.messageId)
        body.setValue(for: JsonKey.inAppMessageContext, value: inAppMessageContext.toMessageContextDictionary())
        body.setValue(for: JsonKey.deviceInfo, value: deviceMetadata.asDictionary())
        
        if let source = source {
            body.setValue(for: JsonKey.closeAction, value: source)
        }
        
        if let clickedUrl = clickedUrl {
            body.setValue(for: JsonKey.clickedUrl, value: clickedUrl)
        }
        
        if let inboxSessionId = inAppMessageContext.inboxSessionId {
            body.setValue(for: JsonKey.inboxSessionId, value: inboxSessionId)
        }
        
        return .success(.post(createPostRequest(path: Const.Path.trackInAppClose, body: body)))
    }
    
    func createTrackInAppDeliveryRequest(inAppMessageContext: InAppMessageContext) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var body = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &body)
        
        body.setValue(for: JsonKey.messageId, value: inAppMessageContext.messageId)
        body.setValue(for: JsonKey.inAppMessageContext, value: inAppMessageContext.toMessageContextDictionary())
        body.setValue(for: JsonKey.deviceInfo, value: deviceMetadata.asDictionary())
        
        return .success(.post(createPostRequest(path: Const.Path.trackInAppDelivery, body: body)))
    }
    
    func createInAppConsumeRequest(_ messageId: String) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var body = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &body)
        
        body.setValue(for: JsonKey.messageId, value: messageId)
        
        return .success(.post(createPostRequest(path: Const.Path.inAppConsume, body: body)))
    }
    
    func createTrackInAppConsumeRequest(inAppMessageContext: InAppMessageContext, source: InAppDeleteSource?) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var body = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &body)
        
        body.setValue(for: JsonKey.messageId, value: inAppMessageContext.messageId)
        body.setValue(for: JsonKey.inAppMessageContext, value: inAppMessageContext.toMessageContextDictionary())
        body.setValue(for: JsonKey.deviceInfo, value: deviceMetadata.asDictionary())
        
        if let source = source {
            body.setValue(for: JsonKey.deleteAction, value: source)
        }
        
        if let inboxSessionId = inAppMessageContext.inboxSessionId {
            body.setValue(for: JsonKey.inboxSessionId, value: inboxSessionId)
        }
        
        return .success(.post(createPostRequest(path: Const.Path.inAppConsume, body: body)))
    }
    
    func createTrackInboxSessionRequest(inboxSession: IterableInboxSession) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        guard let inboxSessionId = inboxSession.id else {
            return .failure(IterableError.general(description: "expecting session UUID"))
        }
        
        guard let sessionStartTime = inboxSession.sessionStartTime else {
            return .failure(IterableError.general(description: "expecting session start time"))
        }
        
        guard let sessionEndTime = inboxSession.sessionEndTime else {
            return .failure(IterableError.general(description: "expecting session end time"))
        }
        
        var body = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &body)
        
        body.setValue(for: JsonKey.inboxSessionId, value: inboxSessionId)
        body.setValue(for: JsonKey.inboxSessionStart, value: IterableUtil.int(fromDate: sessionStartTime))
        body.setValue(for: JsonKey.inboxSessionEnd, value: IterableUtil.int(fromDate: sessionEndTime))
        body.setValue(for: JsonKey.startTotalMessageCount, value: inboxSession.startTotalMessageCount)
        body.setValue(for: JsonKey.endTotalMessageCount, value: inboxSession.endTotalMessageCount)
        body.setValue(for: JsonKey.startUnreadMessageCount, value: inboxSession.startUnreadMessageCount)
        body.setValue(for: JsonKey.endUnreadMessageCount, value: inboxSession.endUnreadMessageCount)
        body.setValue(for: JsonKey.impressions, value: inboxSession.impressions.compactMap { $0.asDictionary() })
        
        body.setValue(for: JsonKey.deviceInfo, value: deviceMetadata.asDictionary())
        
        return .success(.post(createPostRequest(path: Const.Path.trackInboxSession, body: body)))
    }
    
    // MARK: - Embedded Messaging Request Calls
    
    func createGetEmbeddedMessagesRequest() -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var args: [AnyHashable: Any] = [JsonKey.platform: JsonValue.iOS,
                                        JsonKey.systemVersion: UIDevice.current.systemVersion,
                                        JsonKey.Embedded.sdkVersion: IterableAPI.sdkVersion]
        
        if let packageName = Bundle.main.appPackageName {
            args[JsonKey.Embedded.packageName] = packageName
        }
        
        setCurrentUser(inDict: &args)
        
        return .success(.get(createGetRequest(forPath: Const.Path.getEmbeddedMessages, withArgs: args as! [String: String])))
    }
    
    func createEmbeddedMessageReceivedRequest(_ message: IterableEmbeddedMessage) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var body = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &body)
        
        body.setValue(for: JsonKey.messageId, value: message.metadata.messageId)
        body.setValue(for: JsonKey.deviceInfo, value: deviceMetadata.asDictionary())
        
        return .success(.post(createPostRequest(path: Const.Path.embeddedMessageReceived, body: body)))
    }
    
    func createEmbeddedMessageClickRequest(_ message: IterableEmbeddedMessage, _ buttonIdentifier: String?, _ clickedUrl: String) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var body = [AnyHashable: Any]()
        setCurrentUser(inDict: &body)
        
        if let buttonIdentifier = buttonIdentifier, !buttonIdentifier.isEmpty {
            body.setValue(for: JsonKey.embeddedButtonId, value: buttonIdentifier)
        }
        
        body.setValue(for: JsonKey.embeddedTargetUrl, value: clickedUrl)
        
        body.setValue(for: JsonKey.messageId, value: message.metadata.messageId)

        body.setValue(for: JsonKey.deviceInfo, value: deviceMetadata.asDictionary())
        
        return .success(.post(createPostRequest(path: Const.Path.embeddedMessageClick, body: body)))
    }
    
    func createEmbeddedMessageDismissRequest(_ message: IterableEmbeddedMessage) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }
        
        var body: [AnyHashable: Any] = [JsonKey.platform: JsonValue.iOS,
                                        JsonKey.systemVersion: UIDevice.current.systemVersion,
                                        JsonKey.Embedded.sdkVersion: IterableAPI.sdkVersion]
        
        if let packageName = Bundle.main.appPackageName {
            body[JsonKey.Embedded.packageName] = packageName
        }
        
        setCurrentUser(inDict: &body)
        
        // TODO: find/create proper key for the value of the embedded message ID
        
        return .success(.post(createPostRequest(path: Const.Path.embeddedMessageDismiss, body: body as! [String: String])))
    }
    
    func createEmbeddedMessageImpressionRequest(_ message: IterableEmbeddedMessage) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }

        
        var body = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &body)
        
        body.setValue(for: JsonKey.messageId, value: message.metadata.messageId)
        body.setValue(for: JsonKey.deviceInfo, value: deviceMetadata.asDictionary())
        
        return .success(.post(createPostRequest(path: Const.Path.embeddedMessageImpression, body: body)))
    }
    
    func createTrackEmbeddedSessionRequest(embeddedSession: IterableEmbeddedSession) -> Result<IterableRequest, IterableError> {
        if case .none = auth.emailOrUserId {
            ITBError(Self.authMissingMessage)
            return .failure(IterableError.general(description: Self.authMissingMessage))
        }

        guard !embeddedSession.embeddedSessionId.isEmpty else {
            return .failure(IterableError.general(description: "expecting session id"))
        }
        let embeddedSessionId = embeddedSession.embeddedSessionId

        guard let sessionStartTime = embeddedSession.embeddedSessionStart else {
            return .failure(IterableError.general(description: "expecting session start time"))
        }

        guard let sessionEndTime = embeddedSession.embeddedSessionEnd else {
            return .failure(IterableError.general(description: "expecting session end time"))
        }

        var body = [AnyHashable: Any]()
        
        setCurrentUser(inDict: &body)

        body.setValue(for: JsonKey.embeddedSessionId, value: [
            "id": embeddedSessionId,
            "start": IterableUtil.int(fromDate: sessionStartTime),
            "end": IterableUtil.int(fromDate: sessionEndTime)
        ])

        body.setValue(for: JsonKey.impressions, value: embeddedSession.impressions.compactMap { $0.asDictionary() })
        body.setValue(for: JsonKey.deviceInfo, value: deviceMetadata.asDictionary())        
        return .success(.post(createPostRequest(path: Const.Path.trackEmbeddedSession, body: body)))
    }


    
    // MARK: - Misc Request Calls
    
    func createDisableDeviceRequest(forAllUsers allUsers: Bool, hexToken: String) -> Result<IterableRequest, IterableError> {
        var body = [AnyHashable: Any]()
        
        body.setValue(for: JsonKey.token, value: hexToken)
        
        if !allUsers {
            setCurrentUser(inDict: &body)
        }
        
        return .success(.post(createPostRequest(path: Const.Path.disableDevice, body: body)))
    }
    
    func createGetRemoteConfigurationRequest() -> Result<IterableRequest, IterableError> {
        var args: [AnyHashable: Any] = [JsonKey.platform: JsonValue.iOS,
                                        JsonKey.systemVersion: UIDevice.current.systemVersion,
                                        JsonKey.InApp.sdkVersion: IterableAPI.sdkVersion]
        
        if let packageName = Bundle.main.appPackageName {
            args[JsonKey.InApp.packageName] = packageName
        }
        
        return .success(.get(createGetRequest(forPath: Const.Path.getRemoteConfiguration, withArgs: args as! [String: String])))
    }
    
    // MARK: - PRIVATE
    
    private static let authMissingMessage = "Both email and userId are nil"
    
    private func createPostRequest(path: String, body: [AnyHashable: Any]? = nil) -> PostRequest {
        PostRequest(path: path,
                    args: nil,
                    body: body)
    }
    
    private func createGetRequest(forPath path: String, withArgs args: [String: String]) -> GetRequest {
        GetRequest(path: path,
                   args: args)
    }
    
    private static func pushServicePlatformToString(_ pushServicePlatform: PushServicePlatform, apnsType: APNSType) -> String {
        switch pushServicePlatform {
        case .production:
            return JsonValue.apnsProduction
        case .sandbox:
            return JsonValue.apnsSandbox
        case .auto:
            return apnsType == .sandbox ? JsonValue.apnsSandbox : JsonValue.apnsProduction
        }
    }
    
    private func setCurrentUser(inDict dict: inout [AnyHashable: Any]) {
        switch auth.emailOrUserId {
        case let .email(email):
            dict.setValue(for: JsonKey.email, value: email)
        case let .userId(userId):
            dict.setValue(for: JsonKey.userId, value: userId)
        case .none:
            ITBInfo("Current user is unavailable")
        }
    }
    
    private func addUserKey(intoDict dict: inout [AnyHashable: Any]) {
        switch auth.emailOrUserId {
        case let .email(email):
            dict.setValue(for: JsonKey.userKey, value: email)
        case let .userId(userId):
            dict.setValue(for: JsonKey.userKey, value: userId)
        case .none:
            ITBInfo("Current user is unavailable")
        }
    }
}
