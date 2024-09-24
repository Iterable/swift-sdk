//
//  Copyright © 2019 Iterable. All rights reserved.
//

import Foundation

struct DeviceMetadata: Codable {
    let deviceId: String
    let platform: String
    let appPackageName: String
}

// MARK: - API CLIENT FUNCTIONS

class ApiClient {
    init(apiKey: String,
         authProvider: AuthProvider?,
         endpoint: String,
         networkSession: NetworkSessionProtocol,
         deviceMetadata: DeviceMetadata,
         dateProvider: DateProviderProtocol) {
        self.apiKey = apiKey
        self.authProvider = authProvider
        self.endpoint = endpoint
        self.networkSession = networkSession
        self.deviceMetadata = deviceMetadata
        self.dateProvider = dateProvider
    }
    
    func convertToURLRequest(iterableRequest: IterableRequest) -> URLRequest? {
        guard let authProvider = authProvider else {
            return nil
        }
        
        let currentDate = dateProvider.currentDate
        let apiCallRequest = IterableAPICallRequest(apiKey: apiKey,
                                                    endpoint: endpoint,
                                                    authToken: authProvider.auth.authToken,
                                                    deviceMetadata: deviceMetadata,
                                                    iterableRequest: iterableRequest).addingCreatedAt(currentDate)
        return apiCallRequest.convertToURLRequest(sentAt: currentDate)
    }
    
    func send(iterableRequestResult result: Result<IterableRequest, IterableError>) -> Pending<SendRequestValue, SendRequestError> {
        switch result {
        case let .success(iterableRequest):
            return send(iterableRequest: iterableRequest)
        case let .failure(iterableError):
            return SendRequestError.createErroredFuture(reason: iterableError.localizedDescription)
        }
    }
    
    func send<T>(iterableRequestResult result: Result<IterableRequest, IterableError>) -> Pending<T, SendRequestError> where T: Decodable {
        switch result {
        case let .success(iterableRequest):
            return send(iterableRequest: iterableRequest)
        case let .failure(iterableError):
            return SendRequestError.createErroredFuture(reason: iterableError.localizedDescription)
        }
    }
    
    func send(iterableRequest: IterableRequest) -> Pending<SendRequestValue, SendRequestError> {
        guard let urlRequest = convertToURLRequest(iterableRequest: iterableRequest) else {
            return SendRequestError.createErroredFuture()
        }
        
        return RequestSender.sendRequest(urlRequest, usingSession: networkSession)
    }
    
    func send<T>(iterableRequest: IterableRequest) -> Pending<T, SendRequestError> where T: Decodable {
        guard let urlRequest = convertToURLRequest(iterableRequest: iterableRequest) else {
            return SendRequestError.createErroredFuture()
        }
        
        return RequestSender.sendRequest(urlRequest, usingSession: networkSession)
    }
    
    // MARK: - Private
    
    private func createRequestCreator() -> Result<RequestCreator, IterableError> {
        guard let authProvider = authProvider else {
            return .failure(IterableError.general(description: "authProvider is missing"))
        }
        
        return .success(RequestCreator(auth: authProvider.auth, deviceMetadata: deviceMetadata))
    }
    
    private let apiKey: String
    private weak var authProvider: AuthProvider?
    private let endpoint: String
    private let networkSession: NetworkSessionProtocol
    private let deviceMetadata: DeviceMetadata
    private let dateProvider: DateProviderProtocol
}

// MARK: - API REQUEST CALLS

extension ApiClient: ApiClientProtocol {
    func register(registerTokenInfo: RegisterTokenInfo, notificationsEnabled: Bool) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createRegisterTokenRequest(registerTokenInfo: registerTokenInfo,
                                                                                    notificationsEnabled: notificationsEnabled) }
        return send(iterableRequestResult: result)
    }
    
    func updateUser(_ dataFields: [AnyHashable: Any], mergeNestedObjects: Bool) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createUpdateUserRequest(dataFields: dataFields,
                                                                                 mergeNestedObjects: mergeNestedObjects) }
        return send(iterableRequestResult: result)
    }
    
    func updateEmail(newEmail: String, merge: Bool?) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createUpdateEmailRequest(newEmail: newEmail, merge: merge) }
        return send(iterableRequestResult: result)
    }
    
    func getInAppMessages(_ count: NSNumber) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createGetInAppMessagesRequest(count) }
        return send(iterableRequestResult: result)
    }
    
    func disableDevice(forAllUsers allUsers: Bool, hexToken: String) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createDisableDeviceRequest(forAllUsers: allUsers,
                                                                                    hexToken: hexToken) }
        return send(iterableRequestResult: result)
    }
    
    func updateCart(items: [CommerceItem]) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createUpdateCartRequest(items: items) }
        
        return send(iterableRequestResult: result)
    }
    
    func track(purchase total: NSNumber,
               items: [CommerceItem],
               dataFields: [AnyHashable: Any]?,
               campaignId: NSNumber?,
               templateId: NSNumber?) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createTrackPurchaseRequest(total,
                                                                                    items: items,
                                                                                    dataFields: dataFields,
                                                                                    campaignId: campaignId,
                                                                                    templateId: templateId) }
        return send(iterableRequestResult: result)
    }
    
    func track(pushOpen campaignId: NSNumber, templateId: NSNumber?, messageId: String, appAlreadyRunning: Bool, dataFields: [AnyHashable: Any]?) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createTrackPushOpenRequest(campaignId,
                                                                                    templateId: templateId,
                                                                                    messageId: messageId,
                                                                                    appAlreadyRunning: appAlreadyRunning,
                                                                                    dataFields: dataFields) }
        return send(iterableRequestResult: result)
    }
    
    func track(event eventName: String, dataFields: [AnyHashable: Any]?) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createTrackEventRequest(eventName,
                                                                                 dataFields: dataFields) }
        return send(iterableRequestResult: result)
    }
    
    func updateSubscriptions(_ emailListIds: [NSNumber]? = nil,
                             unsubscribedChannelIds: [NSNumber]? = nil,
                             unsubscribedMessageTypeIds: [NSNumber]? = nil,
                             subscribedMessageTypeIds: [NSNumber]? = nil,
                             campaignId: NSNumber? = nil,
                             templateId: NSNumber? = nil) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createUpdateSubscriptionsRequest(emailListIds,
                                                                                          unsubscribedChannelIds: unsubscribedChannelIds,
                                                                                          unsubscribedMessageTypeIds: unsubscribedMessageTypeIds,
                                                                                          subscribedMessageTypeIds: subscribedMessageTypeIds,
                                                                                          campaignId: campaignId,
                                                                                          templateId: templateId) }
        return send(iterableRequestResult: result)
    }
    
    func track(inAppOpen inAppMessageContext: InAppMessageContext) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createTrackInAppOpenRequest(inAppMessageContext: inAppMessageContext) }
        return send(iterableRequestResult: result)
    }
    
    func track(inAppClick inAppMessageContext: InAppMessageContext, clickedUrl: String) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createTrackInAppClickRequest(inAppMessageContext: inAppMessageContext,
                                                                                      clickedUrl: clickedUrl) }
        return send(iterableRequestResult: result)
    }
    
    func track(inAppClose inAppMessageContext: InAppMessageContext, source: InAppCloseSource?, clickedUrl: String?) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createTrackInAppCloseRequest(inAppMessageContext: inAppMessageContext,
                                                                                      source: source,
                                                                                      clickedUrl: clickedUrl) }
        return send(iterableRequestResult: result)
    }
    
    func track(inAppDelivery inAppMessageContext: InAppMessageContext) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createTrackInAppDeliveryRequest(inAppMessageContext: inAppMessageContext) }
        return send(iterableRequestResult: result)
    }
    
    func track(inboxSession: IterableInboxSession) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createTrackInboxSessionRequest(inboxSession: inboxSession) }
        return send(iterableRequestResult:  result)
    }
    
    func inAppConsume(messageId: String) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createInAppConsumeRequest(messageId) }
        return send(iterableRequestResult: result)
    }
    
    func inAppConsume(inAppMessageContext: InAppMessageContext, source: InAppDeleteSource?) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createTrackInAppConsumeRequest(inAppMessageContext: inAppMessageContext,
                                                                                        source: source) }
        return send(iterableRequestResult: result)
    }
    
    func getRemoteConfiguration() -> Pending<RemoteConfiguration, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createGetRemoteConfigurationRequest() }
        return send(iterableRequestResult: result)
    }
    
    // MARK: - Embedded Messaging
    
    func getEmbeddedMessages() -> Pending<PlacementsPayload, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createGetEmbeddedMessagesRequest() }
        return send(iterableRequestResult: result)
    }
    
    @discardableResult
    func track(embeddedMessageReceived message: IterableEmbeddedMessage) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createEmbeddedMessageReceivedRequest(message) }
        return send(iterableRequestResult: result)
    }
    
    @discardableResult
    func track(embeddedMessageClick message: IterableEmbeddedMessage, buttonIdentifier: String?, clickedUrl: String) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createEmbeddedMessageClickRequest(message, buttonIdentifier, clickedUrl) }
        return send(iterableRequestResult: result)
    }
    
    func track(embeddedMessageDismiss message: IterableEmbeddedMessage) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createEmbeddedMessageDismissRequest(message) }
        return send(iterableRequestResult: result)
    }
    
    func track(embeddedMessageImpression message: IterableEmbeddedMessage) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createEmbeddedMessageImpressionRequest(message) }
        return send(iterableRequestResult: result)
    }
    
    func track(embeddedSession: IterableEmbeddedSession) -> Pending<SendRequestValue, SendRequestError> {
        let result = createRequestCreator().flatMap { $0.createTrackEmbeddedSessionRequest(embeddedSession: embeddedSession) }
        return send(iterableRequestResult:  result)
    }
}
