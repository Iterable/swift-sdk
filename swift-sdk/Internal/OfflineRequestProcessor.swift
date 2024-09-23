//
//  Copyright © 2020 Iterable. All rights reserved.
//

import Foundation

struct OfflineRequestProcessor: RequestProcessorProtocol {
    init(apiKey: String,
         authProvider: AuthProvider?,
         authManager: IterableAuthManagerProtocol?,
         endpoint: String,
         deviceMetadata: DeviceMetadata,
         taskScheduler: IterableTaskScheduler,
         taskRunner: IterableTaskRunner,
         notificationCenter: NotificationCenterProtocol
         ) {
        ITBInfo()
        self.apiKey = apiKey
        self.authProvider = authProvider
        self.authManager = authManager
        self.endpoint = endpoint
        self.deviceMetadata = deviceMetadata
        self.taskScheduler = taskScheduler
        self.taskRunner = taskRunner
        notificationListener = NotificationListener(notificationCenter: notificationCenter)
    }
    
    func start() {
        ITBInfo()
        taskRunner.start()
    }
    
    func stop(){
        ITBInfo()
        taskRunner.stop()
    }
    
    @discardableResult
    func updateCart(items: [CommerceItem],
                    onSuccess: OnSuccessHandler?,
                    onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createUpdateCartRequest(items: items)
        }
        
        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func trackPurchase(_ total: NSNumber,
                       items: [CommerceItem],
                       dataFields: [AnyHashable: Any]?,
                       campaignId: NSNumber?,
                       templateId: NSNumber?,
                       onSuccess: OnSuccessHandler?,
                       onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackPurchaseRequest(total,
                                                      items: items,
                                                      dataFields: dataFields,
                                                      campaignId: campaignId,
                                                      templateId: templateId)
        }
        
        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func trackPushOpen(_ campaignId: NSNumber,
                       templateId: NSNumber?,
                       messageId: String,
                       appAlreadyRunning: Bool,
                       dataFields: [AnyHashable: Any]?,
                       onSuccess: OnSuccessHandler?,
                       onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackPushOpenRequest(campaignId,
                                                      templateId: templateId,
                                                      messageId: messageId,
                                                      appAlreadyRunning: appAlreadyRunning,
                                                      dataFields: dataFields)
        }
        
        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func track(event: String,
               dataFields: [AnyHashable: Any]?,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        ITBInfo()
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackEventRequest(event,
                                                   dataFields: dataFields)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func trackInAppOpen(_ message: IterableInAppMessage,
                        location: InAppLocation,
                        inboxSessionId: String?,
                        onSuccess: OnSuccessHandler?,
                        onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackInAppOpenRequest(inAppMessageContext: InAppMessageContext.from(message: message,
                                                                                                     location: location,
                                                                                                     inboxSessionId: inboxSessionId))
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func trackInAppClick(_ message: IterableInAppMessage,
                         location: InAppLocation,
                         inboxSessionId: String?,
                         clickedUrl: String,
                         onSuccess: OnSuccessHandler?,
                         onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackInAppClickRequest(inAppMessageContext: InAppMessageContext.from(message: message,
                                                                                                      location: location,
                                                                                                      inboxSessionId: inboxSessionId),
                                                        clickedUrl: clickedUrl)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func trackInAppClose(_ message: IterableInAppMessage,
                         location: InAppLocation,
                         inboxSessionId: String?,
                         source: InAppCloseSource?,
                         clickedUrl: String?,
                         onSuccess: OnSuccessHandler?,
                         onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackInAppCloseRequest(inAppMessageContext: InAppMessageContext.from(message: message,
                                                                                                      location: location,
                                                                                                      inboxSessionId: inboxSessionId),
                                                        source: source,
                                                        clickedUrl: clickedUrl)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func track(inboxSession: IterableInboxSession,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackInboxSessionRequest(inboxSession: inboxSession)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func track(inAppDelivery message: IterableInAppMessage,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackInAppDeliveryRequest(inAppMessageContext: InAppMessageContext.from(message: message,
                                                                                                         location: nil))
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func inAppConsume(_ messageId: String,
                      onSuccess: OnSuccessHandler?,
                      onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createInAppConsumeRequest(messageId)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func inAppConsume(message: IterableInAppMessage,
                      location: InAppLocation,
                      source: InAppDeleteSource?,
                      inboxSessionId: String?,
                      onSuccess: OnSuccessHandler?,
                      onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackInAppConsumeRequest(inAppMessageContext: InAppMessageContext.from(message: message, location: location, inboxSessionId: inboxSessionId),
                                                          source: source)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func track(embeddedMessageReceived message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createEmbeddedMessageReceivedRequest(message)
        }
        
        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func track(embeddedMessageClick message: IterableEmbeddedMessage, buttonIdentifier: String?, clickedUrl: String,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createEmbeddedMessageClickRequest(message, buttonIdentifier, clickedUrl)
        }
        
        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func track(embeddedMessageDismiss message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createEmbeddedMessageDismissRequest(message)
        }
        
        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func track(embeddedMessageImpression message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createEmbeddedMessageImpressionRequest(message)
        }
        
        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    @discardableResult
    func track(embeddedSession: IterableEmbeddedSession,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError> {
        let requestGenerator = { (requestCreator: RequestCreator) in
            requestCreator.createTrackEmbeddedSessionRequest(embeddedSession: embeddedSession)
        }

        return sendIterableRequest(requestGenerator: requestGenerator,
                                   successHandler: onSuccess,
                                   failureHandler: onFailure,
                                   identifier: #function)
    }
    
    func deleteAllTasks() {
        ITBInfo()
        taskScheduler.deleteAllTasks()
    }
    
    private let apiKey: String
    private weak var authProvider: AuthProvider?
    private weak var authManager: IterableAuthManagerProtocol?
    private let endpoint: String
    private let deviceMetadata: DeviceMetadata
    private let notificationListener: NotificationListener
    private let taskScheduler: IterableTaskScheduler
    private let taskRunner: IterableTaskRunner
    
    private func createRequestCreator(authProvider: AuthProvider) -> RequestCreator {
        return RequestCreator(auth: authProvider.auth, deviceMetadata: deviceMetadata)
    }
    
    private func sendIterableRequest(requestGenerator: @escaping (RequestCreator) -> Result<IterableRequest, IterableError>,
                                     successHandler onSuccess: OnSuccessHandler?,
                                     failureHandler onFailure: OnFailureHandler?,
                                     identifier: String) -> Pending<SendRequestValue, SendRequestError> {
        guard let authProvider = authProvider else {
            return SendRequestError.createErroredFuture(reason: "AuthProvider is missing")
        }
        
        let requestCreator = createRequestCreator(authProvider: authProvider)
        guard case let Result.success(iterableRequest) = requestGenerator(requestCreator) else {
                return SendRequestError.createErroredFuture(reason: "Could not create request")
        }
        
        let apiCallRequest = IterableAPICallRequest(apiKey: apiKey,
                                                    endpoint: endpoint,
                                                    authToken: authManager?.getAuthToken(),
                                                    deviceMetadata: deviceMetadata,
                                                    iterableRequest: iterableRequest)
        
        return taskScheduler.schedule(apiCallRequest: apiCallRequest,
                                      context: IterableTaskContext(blocking: true)).mapFailure { error in
            SendRequestError.from(error: error)
        }.flatMap { taskId -> Pending<SendRequestValue, SendRequestError> in
            let pendingTask = notificationListener.futureFromTask(withTaskId: taskId)
            let result = RequestProcessorUtil.apply(successHandler: onSuccess,
                                              andFailureHandler: onFailure,
                                              andAuthManager: authManager,
                                              toResult: pendingTask,
                                              withIdentifier: identifier)
            result.onError { error in
                if error.httpStatusCode == 401, RequestProcessorUtil.matchesJWTErrorCode(error.iterableCode) {
                    authManager?.handleAuthFailure(failedAuthToken: authManager?.getAuthToken(), reason: RequestProcessorUtil.getMappedErrorCodeForMessage(error.reason ?? ""))
                    authManager?.setIsLastAuthTokenValid(false)
                    let retryInterval = authManager?.getNextRetryInterval() ?? 1
                    DispatchQueue.main.async {
                        authManager?.scheduleAuthTokenRefreshTimer(interval: retryInterval, isScheduledRefresh: false, successCallback: { _ in
                            _ = sendIterableRequest(requestGenerator: requestGenerator, successHandler: onSuccess, failureHandler: onFailure, identifier: identifier)
                        })
                    }

                }
            }
            return result
        }
    }

    private class NotificationListener: NSObject {
        init(notificationCenter: NotificationCenterProtocol) {
            ITBInfo("OfflineRequestProcessor.NotificationListener.init()")
            self.notificationCenter = notificationCenter
            super.init()
            self.notificationCenter.addObserver(self,
                                                selector: #selector(onTaskFinishedWithSuccess(notification:)),
                                                name: .iterableTaskFinishedWithSuccess, object: nil)
            self.notificationCenter.addObserver(self,
                                                selector: #selector(onTaskFinishedWithNoRetry(notification:)),
                                                name: .iterableTaskFinishedWithNoRetry, object: nil)
        }
        
        deinit {
            ITBInfo("OfflineRequestProcessor.NotificationListener.deinit()")
            self.notificationCenter.removeObserver(self)
        }
        
        func futureFromTask(withTaskId taskId: String) -> Pending<SendRequestValue, SendRequestError> {
            ITBInfo()
            return addPendingTask(taskId: taskId)
        }

        @objc
        private func onTaskFinishedWithSuccess(notification: Notification) {
            ITBInfo()
            if let taskSendRequestValue = IterableNotificationUtil.notificationToTaskSendRequestValue(notification) {
                resolveTask(value: taskSendRequestValue)
            } else {
                ITBError("Could not find taskId for notification")
            }
        }

        @objc
        private func onTaskFinishedWithNoRetry(notification: Notification) {
            ITBInfo()
            if let taskSendRequestError = IterableNotificationUtil.notificationToTaskSendRequestError(notification) {
                rejectTask(error: taskSendRequestError)
            } else {
                ITBError("Could not find taskId for notification")
            }
        }
        
        private func addPendingTask(taskId: String) -> Pending<SendRequestValue, SendRequestError> {
            let result = Fulfill<SendRequestValue, SendRequestError>()
            pendingTasksQueue.async { [weak self] in
                ITBInfo("adding pending task: \(taskId)")
                self?.pendingTasksMap[taskId] = result
            }
            return result
        }
        
        private func resolveTask(value: TaskSendRequestValue) {
            pendingTasksQueue.async { [weak self] in
                let taskId = value.taskId
                ITBInfo("task: \(taskId) finished with success")
                if let fulfill = self?.pendingTasksMap[taskId] {
                    fulfill.resolve(with: value.sendRequestValue)
                    self?.pendingTasksMap.removeValue(forKey: taskId)
                } else {
                    ITBError("could not find fulfill for taskId: \(taskId)")
                }
            }
        }
        
        private func rejectTask(error: TaskSendRequestError) {
            pendingTasksQueue.async { [weak self] in
                let taskId = error.taskId
                ITBInfo("task: \(taskId) finished with no retry")
                if let fulfill = self?.pendingTasksMap[taskId] {
                    fulfill.reject(with: error.sendRequestError)
                    self?.pendingTasksMap.removeValue(forKey: taskId)
                } else {
                    ITBError("could not find fulfill for taskId: \(taskId)")
                }
            }
        }

        private let notificationCenter: NotificationCenterProtocol
        private var pendingTasksMap = [String: Fulfill<SendRequestValue, SendRequestError>]()
        private var pendingTasksQueue = DispatchQueue(label: "pendingTasks")
    }
}
