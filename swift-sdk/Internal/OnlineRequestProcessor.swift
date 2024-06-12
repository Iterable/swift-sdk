//
//  Copyright © 2020 Iterable. All rights reserved.
//

import Foundation

/// `InternalIterableAPI` will delegate all network related calls to this struct.
struct OnlineRequestProcessor: RequestProcessorProtocol {
    init(apiKey: String,
         authProvider: AuthProvider?,
         authManager: IterableAuthManagerProtocol?,
         endpoint: String,
         networkSession: NetworkSessionProtocol,
         deviceMetadata: DeviceMetadata,
         dateProvider: DateProviderProtocol) {
        self.authManager = authManager
        apiClient = ApiClient(apiKey: apiKey,
                              authProvider: authProvider,
                              endpoint: endpoint,
                              networkSession: networkSession,
                              deviceMetadata: deviceMetadata,
                              dateProvider: dateProvider)
    }
    
    func register(registerTokenInfo: RegisterTokenInfo,
                  notificationStateProvider: NotificationStateProviderProtocol,
                  onSuccess: OnSuccessHandler? = nil,
                  onFailure: OnFailureHandler? = nil) {
        notificationStateProvider.isNotificationsEnabled { enabled in
            self.register(registerTokenInfo: registerTokenInfo,
                          notificationsEnabled: enabled,
                          onSuccess: onSuccess,
                          onFailure: onFailure)
        }
    }
    
    @discardableResult
    func disableDeviceForCurrentUser(hexToken: String,
                                     withOnSuccess onSuccess: OnSuccessHandler? = nil,
                                     onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        disableDevice(forAllUsers: false,
                      hexToken: hexToken,
                      onSuccess: onSuccess,
                      onFailure: onFailure)
    }
    
    @discardableResult
    func disableDeviceForAllUsers(hexToken: String,
                                  withOnSuccess onSuccess: OnSuccessHandler? = nil,
                                  onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        disableDevice(forAllUsers: true,
                      hexToken: hexToken,
                      onSuccess: onSuccess,
                      onFailure: onFailure)
    }
    
    @discardableResult
    func updateUser(_ dataFields: [AnyHashable: Any],
                    mergeNestedObjects: Bool,
                    onSuccess: OnSuccessHandler? = nil,
                    onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.updateUser(dataFields, mergeNestedObjects: mergeNestedObjects) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "updateUser")
    }
    
    @discardableResult
    func updateEmail(_ newEmail: String,
                     merge: Bool? = nil,
                     onSuccess: OnSuccessHandler? = nil,
                     onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.updateEmail(newEmail: newEmail, merge: merge) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "updateEmail")
    }
    
    @discardableResult
    func updateCart(items: [CommerceItem],
                    onSuccess: OnSuccessHandler? = nil,
                    onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.updateCart(items: items) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "updateCart")
    }
    
    @discardableResult
    func trackPurchase(_ total: NSNumber,
                       items: [CommerceItem],
                       dataFields: [AnyHashable: Any]? = nil,
                       campaignId: NSNumber?,
                       templateId: NSNumber?,
                       onSuccess: OnSuccessHandler? = nil,
                       onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.track(purchase: total,
                                                       items: items,
                                                       dataFields: dataFields,
                                                       campaignId: campaignId,
                                                       templateId: templateId) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "trackPurchase")
    }
    
    @discardableResult
    func trackPushOpen(_ campaignId: NSNumber,
                       templateId: NSNumber?,
                       messageId: String,
                       appAlreadyRunning: Bool,
                       dataFields: [AnyHashable: Any]? = nil,
                       onSuccess: OnSuccessHandler? = nil,
                       onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.track(pushOpen: campaignId,
                                                       templateId: templateId,
                                                       messageId: messageId,
                                                       appAlreadyRunning: appAlreadyRunning,
                                                       dataFields: dataFields) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "trackPushOpen")
    }
    
    @discardableResult
    func track(event: String,
               dataFields: [AnyHashable: Any]? = nil,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.track(event: event, dataFields: dataFields) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "trackEvent")
    }
    
    @discardableResult
    func updateSubscriptions(info: UpdateSubscriptionsInfo,
                             onSuccess: OnSuccessHandler? = nil,
                             onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.updateSubscriptions(info.emailListIds,
                                                                     unsubscribedChannelIds: info.unsubscribedChannelIds,
                                                                     unsubscribedMessageTypeIds: info.unsubscribedMessageTypeIds,
                                                                     subscribedMessageTypeIds: info.subscribedMessageTypeIds,
                                                                     campaignId: info.campaignId,
                                                                     templateId: info.templateId) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "updateSubscriptions")
    }
    
    @discardableResult
    func trackInAppOpen(_ message: IterableInAppMessage,
                        location: InAppLocation,
                        inboxSessionId: String? = nil,
                        onSuccess: OnSuccessHandler? = nil,
                        onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.track(inAppOpen: InAppMessageContext.from(message: message, location: location, inboxSessionId: inboxSessionId)) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "trackInAppOpen")
    }
    
    @discardableResult
    func trackInAppClick(_ message: IterableInAppMessage,
                         location: InAppLocation = .inApp,
                         inboxSessionId: String? = nil,
                         clickedUrl: String,
                         onSuccess: OnSuccessHandler? = nil,
                         onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.track(inAppClick: InAppMessageContext.from(message: message, location: location, inboxSessionId: inboxSessionId),
                                                       clickedUrl: clickedUrl) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "trackInAppClick")
    }
    
    @discardableResult
    func trackInAppClose(_ message: IterableInAppMessage,
                         location: InAppLocation = .inApp,
                         inboxSessionId: String? = nil,
                         source: InAppCloseSource? = nil,
                         clickedUrl: String? = nil,
                         onSuccess: OnSuccessHandler? = nil,
                         onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.track(inAppClose: InAppMessageContext.from(message: message, location: location, inboxSessionId: inboxSessionId),
                                                       source: source,
                                                       clickedUrl: clickedUrl) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "trackInAppClose")
    }
    
    @discardableResult
    func track(inboxSession: IterableInboxSession,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.track(inboxSession: inboxSession) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "trackInboxSession")
    }
    
    @discardableResult
    func track(inAppDelivery message: IterableInAppMessage,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.track(inAppDelivery: InAppMessageContext.from(message: message, location: nil)) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "trackInAppDelivery")
    }
    
    @discardableResult
    func inAppConsume(_ messageId: String,
                      onSuccess: OnSuccessHandler? = nil,
                      onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.inAppConsume(messageId: messageId) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "inAppConsume")
    }
    
    @discardableResult
    func inAppConsume(message: IterableInAppMessage,
                      location: InAppLocation = .inApp,
                      source: InAppDeleteSource? = nil,
                      inboxSessionId: String? = nil,
                      onSuccess: OnSuccessHandler? = nil,
                      onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.inAppConsume(inAppMessageContext: InAppMessageContext.from(message: message, location: location, inboxSessionId: inboxSessionId),
                                                              source: source) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "inAppConsumeWithSource")
    }
    
    @discardableResult
    func track(embeddedMessageReceived message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.track(embeddedMessageReceived: message) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "trackEmbeddedMessageReceived")
    }
    
    @discardableResult
    func track(embeddedMessageClick message: IterableEmbeddedMessage, buttonIdentifier: String?, clickedUrl: String,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.track(embeddedMessageClick: message, buttonIdentifier: buttonIdentifier, clickedUrl: clickedUrl) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "trackEmbeddedMessageClick")
    }
    
    @discardableResult
    func track(embeddedMessageDismiss message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.track(embeddedMessageDismiss: message) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "trackEmbeddedMessageDismiss")
    }
    
    @discardableResult
    func track(embeddedMessageImpression message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.track(embeddedMessageImpression: message) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "trackEmbeddedMessageImpression")
    }
    
    @discardableResult
    func track(embeddedSession: IterableEmbeddedSession,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.track(embeddedSession: embeddedSession) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "trackEmbeddedSession")
    }
    
    func getRemoteConfiguration() -> Pending<RemoteConfiguration, SendRequestError> {
        apiClient.getRemoteConfiguration()
    }
    
    private let apiClient: ApiClientProtocol
    private weak var authManager: IterableAuthManagerProtocol?
    
    @discardableResult
    private func register(registerTokenInfo: RegisterTokenInfo,
                          notificationsEnabled: Bool,
                          onSuccess: OnSuccessHandler? = nil,
                          onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.register(registerTokenInfo: registerTokenInfo,
                                                          notificationsEnabled: notificationsEnabled) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "registerToken")
    }
    
    @discardableResult
    private func disableDevice(forAllUsers allUsers: Bool,
                               hexToken: String,
                               onSuccess: OnSuccessHandler? = nil,
                               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        sendRequest(requestProvider: { apiClient.disableDevice(forAllUsers: allUsers, hexToken: hexToken) },
                    successHandler: onSuccess,
                    failureHandler: onFailure,
                    requestIdentifier: "disableDevice")
    }

    private func sendRequest(requestProvider: @escaping () -> Pending<SendRequestValue, SendRequestError>,
                             successHandler onSuccess: OnSuccessHandler? = nil,
                             failureHandler onFailure: OnFailureHandler? = nil,
                             requestIdentifier identifier: String) -> Pending<SendRequestValue, SendRequestError> {
        RequestProcessorUtil.sendRequest(requestProvider: requestProvider,
                                         successHandler: onSuccess,
                                         failureHandler: onFailure,
                                         authManager: authManager,
                                         requestIdentifier: identifier)
    }
}
