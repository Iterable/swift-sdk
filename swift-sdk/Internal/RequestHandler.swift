//
//  Copyright © 2020 Iterable. All rights reserved.
//

import Foundation

class RequestHandler: RequestHandlerProtocol {
    init(onlineProcessor: OnlineRequestProcessor,
         offlineProcessor: OfflineRequestProcessor?,
         healthMonitor: HealthMonitor?,
         offlineMode: Bool = false) {
        ITBInfo()
        self.onlineProcessor = onlineProcessor
        self.offlineProcessor = offlineProcessor
        self.healthMonitor = healthMonitor
        self.offlineMode = offlineMode
        self.healthMonitor?.delegate = self
    }
    
    deinit {
        ITBInfo()
    }
    
    var offlineMode: Bool
    
    func start() {
        ITBInfo()
        if offlineMode {
            offlineProcessor?.start()
        }
    }
    
    func stop() {
        ITBInfo()
        if offlineMode {
            offlineProcessor?.stop()
        }
    }
    
    func register(registerTokenInfo: RegisterTokenInfo,
                  notificationStateProvider: NotificationStateProviderProtocol,
                  onSuccess: OnSuccessHandler?,
                  onFailure: OnFailureHandler?) {
        onlineProcessor.register(registerTokenInfo: registerTokenInfo,
                                 notificationStateProvider: notificationStateProvider,
                                 onSuccess: onSuccess,
                                 onFailure: onFailure)
    }
    
    @discardableResult
    func disableDeviceForCurrentUser(hexToken: String,
                                     withOnSuccess onSuccess: OnSuccessHandler?,
                                     onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        onlineProcessor.disableDeviceForCurrentUser(hexToken: hexToken,
                                                    withOnSuccess: onSuccess,
                                                    onFailure: onFailure)
    }
    
    @discardableResult
    func disableDeviceForAllUsers(hexToken: String,
                                  withOnSuccess onSuccess: OnSuccessHandler?,
                                  onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        onlineProcessor.disableDeviceForAllUsers(hexToken: hexToken,
                                                 withOnSuccess: onSuccess,
                                                 onFailure: onFailure)
    }
    
    @discardableResult
    func updateUser(_ dataFields: [AnyHashable: Any],
                    mergeNestedObjects: Bool,
                    onSuccess: OnSuccessHandler?,
                    onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        onlineProcessor.updateUser(dataFields,
                                   mergeNestedObjects: mergeNestedObjects,
                                   onSuccess: onSuccess,
                                   onFailure: onFailure)
    }
    
    @discardableResult
    func updateEmail(_ newEmail: String,
                     merge: Bool?,
                     onSuccess: OnSuccessHandler?,
                     onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        onlineProcessor.updateEmail(newEmail,
                                    merge: merge,
                                    onSuccess: onSuccess,
                                    onFailure: onFailure)
    }
    
    @discardableResult
    func updateCart(items: [CommerceItem],
                    onSuccess: OnSuccessHandler?,
                    onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.updateCart(items: items,
                                 onSuccess: onSuccess,
                                 onFailure: onFailure)
        }
    }
    
    @discardableResult
    func trackPurchase(_ total: NSNumber,
                       items: [CommerceItem],
                       dataFields: [AnyHashable: Any]?,
                       campaignId: NSNumber?,
                       templateId: NSNumber?,
                       onSuccess: OnSuccessHandler?,
                       onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.trackPurchase(total,
                                    items: items,
                                    dataFields: dataFields,
                                    campaignId: campaignId,
                                    templateId: templateId,
                                    onSuccess: onSuccess,
                                    onFailure: onFailure)
        }
    }
    
    @discardableResult
    func trackPushOpen(_ campaignId: NSNumber,
                       templateId: NSNumber?,
                       messageId: String,
                       appAlreadyRunning: Bool,
                       dataFields: [AnyHashable: Any]?,
                       onSuccess: OnSuccessHandler?,
                       onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.trackPushOpen(campaignId,
                                    templateId: templateId,
                                    messageId: messageId,
                                    appAlreadyRunning: appAlreadyRunning,
                                    dataFields: dataFields,
                                    onSuccess: onSuccess,
                                    onFailure: onFailure)
        }
    }
    
    @discardableResult
    func track(event: String,
               dataFields: [AnyHashable: Any]?,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.track(event: event,
                            dataFields: dataFields,
                            onSuccess: onSuccess,
                            onFailure: onFailure)
        }
    }
    
    @discardableResult
    func updateSubscriptions(info: UpdateSubscriptionsInfo,
                             onSuccess: OnSuccessHandler?,
                             onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        onlineProcessor.updateSubscriptions(info: info,
                                            onSuccess: onSuccess,
                                            onFailure: onFailure)
    }
    
    @discardableResult
    func trackInAppOpen(_ message: IterableInAppMessage,
                        location: InAppLocation,
                        inboxSessionId: String?,
                        onSuccess: OnSuccessHandler?,
                        onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.trackInAppOpen(message,
                                     location: location,
                                     inboxSessionId: inboxSessionId,
                                     onSuccess: onSuccess,
                                     onFailure: onFailure)
        }
    }
    
    @discardableResult
    func trackInAppClick(_ message: IterableInAppMessage,
                         location: InAppLocation,
                         inboxSessionId: String?,
                         clickedUrl: String,
                         onSuccess: OnSuccessHandler?,
                         onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.trackInAppClick(message,
                                      location: location,
                                      inboxSessionId: inboxSessionId,
                                      clickedUrl: clickedUrl,
                                      onSuccess: onSuccess,
                                      onFailure: onFailure)
        }
    }
    
    @discardableResult
    func trackInAppClose(_ message: IterableInAppMessage,
                         location: InAppLocation,
                         inboxSessionId: String?,
                         source: InAppCloseSource?,
                         clickedUrl: String?,
                         onSuccess: OnSuccessHandler?,
                         onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.trackInAppClose(message,
                                      location: location,
                                      inboxSessionId: inboxSessionId,
                                      source: source,
                                      clickedUrl: clickedUrl,
                                      onSuccess: onSuccess,
                                      onFailure: onFailure)
        }
    }
    
    @discardableResult
    func track(inboxSession: IterableInboxSession,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.track(inboxSession: inboxSession,
                            onSuccess: onSuccess,
                            onFailure: onFailure)
        }
    }

    @discardableResult
    func track(inAppDelivery message: IterableInAppMessage,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.track(inAppDelivery: message,
                            onSuccess: onSuccess,
                            onFailure: onFailure)
        }
    }
    
    @discardableResult
    func inAppConsume(_ messageId: String,
                      onSuccess: OnSuccessHandler?,
                      onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.inAppConsume(messageId,
                                   onSuccess: onSuccess,
                                   onFailure: onFailure)
        }
    }
    
    @discardableResult
    func inAppConsume(message: IterableInAppMessage,
                      location: InAppLocation,
                      source: InAppDeleteSource?,
                      inboxSessionId: String?,
                      onSuccess: OnSuccessHandler?,
                      onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.inAppConsume(message: message,
                                   location: location,
                                   source: source,
                                   inboxSessionId: inboxSessionId,
                                   onSuccess: onSuccess,
                                   onFailure: onFailure)
        }
    }
    
    @discardableResult
    func track(embeddedMessageReceived message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.track(embeddedMessageReceived: message,
                            onSuccess: onSuccess,
                            onFailure: onFailure)
        }
    }
    
    @discardableResult
    func track(embeddedMessageClick message: IterableEmbeddedMessage, buttonIdentifier: String?, clickedUrl: String,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.track(embeddedMessageClick: message,
                            buttonIdentifier: buttonIdentifier,
                            clickedUrl: clickedUrl,
                            onSuccess: onSuccess,
                            onFailure: onFailure)
        }
    }
    
    @discardableResult
    func track(embeddedMessageDismiss message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.track(embeddedMessageDismiss: message,
                            onSuccess: onSuccess,
                            onFailure: onFailure)
        }
    }
    
    @discardableResult
    func track(embeddedMessageImpression message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.track(embeddedMessageImpression: message,
                            onSuccess: onSuccess,
                            onFailure: onFailure)
        }
    }
    
    @discardableResult
    func track(embeddedSession: IterableEmbeddedSession,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        sendUsingRequestProcessor { processor in
            processor.track(embeddedSession: embeddedSession,
                            onSuccess: onSuccess,
                            onFailure: onFailure)
        }
    }
    
    func getRemoteConfiguration() -> Pending<RemoteConfiguration, SendRequestError> {
        onlineProcessor.getRemoteConfiguration()
    }
    
    func handleLogout() throws {
        if offlineMode {
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.offlineProcessor?.deleteAllTasks()
            }
        }
    }

    private let offlineProcessor: OfflineRequestProcessor?
    private let healthMonitor: HealthMonitor?
    private let onlineProcessor: OnlineRequestProcessor

    private func sendUsingRequestProcessor(closure: @escaping (RequestProcessorProtocol) -> Pending<SendRequestValue, SendRequestError>) -> Pending<SendRequestValue, SendRequestError> {
        chooseRequestProcessor().flatMap { processor in
            closure(processor)
        }
    }

    private func chooseRequestProcessor() -> Pending<RequestProcessorProtocol, Never> {
        guard offlineMode else {
            return Fulfill<RequestProcessorProtocol, Never>(value: onlineProcessor)
        }
        guard
            let offlineProcessor = offlineProcessor,
            let healthMonitor = healthMonitor
        else {
            return Fulfill<RequestProcessorProtocol, Never>(value: onlineProcessor)
        }
        
        return healthMonitor.canSchedule().map { value -> RequestProcessorProtocol in
            value ? offlineProcessor : self.onlineProcessor
        }
    }
}

extension RequestHandler: HealthMonitorDelegate {
    func onDBError() {
        self.offlineMode = false
    }
}
