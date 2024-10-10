//
//  Copyright © 2020 Iterable. All rights reserved.
//

import XCTest

@testable import IterableSDK

class TaskRunnerTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        IterableLogUtil.sharedInstance = IterableLogUtil(dateProvider: SystemDateProvider(),
                                                         logDelegate: DefaultLogDelegate())
        try! persistenceContextProvider.mainQueueContext().deleteAllTasks()
        try! persistenceContextProvider.mainQueueContext().save()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    func testMultipleTasksInSequence() throws {
        let expectation1 = expectation(description: #function)
        expectation1.expectedFulfillmentCount = 3
        
        var scheduledTaskIds = [String]()
        var taskIds = [String]()
        let notificationCenter = MockNotificationCenter()
        let reference = notificationCenter.addCallback(forNotification: .iterableTaskFinishedWithSuccess) { notification in
            let taskSendRequestValue = IterableNotificationUtil.notificationToTaskSendRequestValue(notification)!
            taskIds.append(taskSendRequestValue.taskId)
            expectation1.fulfill()
        }
        XCTAssertNotNil(reference)
        let networkSession = MockNetworkSession()
        let healthMonitor = HealthMonitor(dataProvider: HealthMonitorDataProvider(maxTasks: 1000,
                                                                                  persistenceContextProvider: persistenceContextProvider),
                                          dateProvider: SystemDateProvider(),
                                          networkSession: networkSession)
        let taskRunner = IterableTaskRunner(networkSession: networkSession,
                                            persistenceContextProvider: persistenceContextProvider,
                                            healthMonitor: healthMonitor,
                                            notificationCenter: notificationCenter,
                                            timeInterval: 0.5)
        taskRunner.start()
        
        let scheduler = IterableTaskScheduler(persistenceContextProvider: persistenceContextProvider,
                                              notificationCenter: notificationCenter,
                                              healthMonitor: healthMonitor)
        
        try scheduleSampleTasks(scheduler: scheduler, times: 3, scheduledTaskIds: []).onSuccess(block: { values in
            scheduledTaskIds = values
        })
        
        wait(for: [expectation1], timeout: 15.0)
        XCTAssertEqual(taskIds, scheduledTaskIds)
        
        waitForZeroTasks()
        
        taskRunner.stop()
    }
    
    func testFailureWithRetry() throws {
        let networkError = IterableError.general(description: "The Internet connection appears to be offline.")
        let networkSession = MockNetworkSession(statusCode: 0, data: nil, error: networkError)

        var scheduledTaskIds = [String]()
        var retryTaskIds = [String]()
        let notificationCenter = MockNotificationCenter()
        let reference = notificationCenter.addCallback(forNotification: .iterableTaskFinishedWithRetry) { notification in
            let taskSendRequestError = IterableNotificationUtil.notificationToTaskSendRequestError(notification)!
            if !retryTaskIds.contains(taskSendRequestError.taskId) {
                retryTaskIds.append(taskSendRequestError.taskId)
            }
        }
        XCTAssertNotNil(reference)

        let healthMonitor = HealthMonitor(dataProvider: HealthMonitorDataProvider(maxTasks: 1000,
                                                                                  persistenceContextProvider: persistenceContextProvider),
                                          dateProvider: SystemDateProvider(),
                                          networkSession: networkSession)
        let taskRunner = IterableTaskRunner(networkSession: networkSession,
                                            persistenceContextProvider: persistenceContextProvider,
                                            healthMonitor: healthMonitor,
                                            notificationCenter: notificationCenter,
                                            timeInterval: 1.0)
        taskRunner.start()

        let scheduler = IterableTaskScheduler(persistenceContextProvider: persistenceContextProvider,
                                              notificationCenter: notificationCenter,
                                              healthMonitor: healthMonitor)
        try scheduleSampleTasks(scheduler: scheduler, times: 3, scheduledTaskIds: []).onSuccess(block: { values in
            scheduledTaskIds = values
        })

        let predicate = NSPredicate { _, _ in
            return retryTaskIds.count == 1
        }
        let expectation2 = expectation(for: predicate, evaluatedWith: nil, handler: nil)
        wait(for: [expectation2], timeout: 5.0)
        XCTAssertEqual(scheduledTaskIds[0], retryTaskIds[0])
        
        XCTAssertEqual(try persistenceContextProvider.mainQueueContext().findAllTasks().count, 3)
        taskRunner.stop()
    }

    func testFailureWithNoRetry() throws {
        let networkSession = MockNetworkSession(statusCode: 401, data: nil, error: nil)

        let expectation1 = expectation(description: #function)
        expectation1.expectedFulfillmentCount = 3

        var scheduledTaskIds = [String]()
        var failedTaskIds = [String]()
        let notificationCenter = MockNotificationCenter()
        let reference = notificationCenter.addCallback(forNotification: .iterableTaskFinishedWithNoRetry) { notification in
            let taskSendRequestError = IterableNotificationUtil.notificationToTaskSendRequestError(notification)!
            failedTaskIds.append(taskSendRequestError.taskId)
            expectation1.fulfill()
        }
        XCTAssertNotNil(reference)

        let healthMonitor = HealthMonitor(dataProvider: HealthMonitorDataProvider(maxTasks: 1000,
                                                                                  persistenceContextProvider: persistenceContextProvider),
                                          dateProvider: SystemDateProvider(),
                                          networkSession: networkSession)
        let taskRunner = IterableTaskRunner(networkSession: networkSession,
                                            persistenceContextProvider: persistenceContextProvider,
                                            healthMonitor: healthMonitor,
                                            notificationCenter: notificationCenter,
                                            timeInterval: 0.5)
        taskRunner.start()

        let scheduler = IterableTaskScheduler(persistenceContextProvider: persistenceContextProvider,
                                              notificationCenter: notificationCenter,
                                              healthMonitor: healthMonitor)
        try scheduleSampleTasks(scheduler: scheduler, times: 3, scheduledTaskIds: []).onSuccess(block: { values in
            scheduledTaskIds = values
        })

        wait(for: [expectation1], timeout: 15.0)
        XCTAssertEqual(failedTaskIds, scheduledTaskIds)

        waitForZeroTasks()
        
        taskRunner.stop()
    }

    func testDoNotRunWhenNetworkIsOffline() throws {
        let networkSession = MockNetworkSession(statusCode: 401, data: nil, error: IterableError.general(description: "Mock error"))
        let checker = NetworkConnectivityChecker(networkSession: networkSession)
        let monitor = NetworkMonitor()
        let notificationCenter = MockNotificationCenter()
        let manager = NetworkConnectivityManager(networkMonitor: monitor,
                                                 connectivityChecker: checker,
                                                 notificationCenter: notificationCenter)

        let healthMonitor = HealthMonitor(dataProvider: HealthMonitorDataProvider(maxTasks: 1000,
                                                                                  persistenceContextProvider: persistenceContextProvider),
                                          dateProvider: SystemDateProvider(),
                                          networkSession: networkSession)
        let taskRunner = IterableTaskRunner(networkSession: networkSession,
                                            persistenceContextProvider: persistenceContextProvider,
                                            healthMonitor: healthMonitor,
                                            notificationCenter: notificationCenter,
                                            connectivityManager: manager)
        taskRunner.start()

        let scheduler = IterableTaskScheduler(persistenceContextProvider: persistenceContextProvider,
                                              notificationCenter: notificationCenter,
                                              healthMonitor: healthMonitor)
        // Now schedule a task, giving it some time for task runner to be updated with
        // offliine network status
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let _ = try! self.scheduleSampleTask(scheduler: scheduler)
        }

        verifyNoTaskIsExecuted(notificationCenter, forInterval: 1.0)

        XCTAssertEqual(try persistenceContextProvider.mainQueueContext().findAllTasks().count, 1)
        taskRunner.stop()
    }

    func testResumeWhenNetworkIsBackOnline() throws {
        let networkSession = MockNetworkSession(statusCode: 401, json: [:], error: IterableError.general(description: "Mock error"))
        let checker = NetworkConnectivityChecker(networkSession: networkSession)
        let monitor = NetworkMonitor()
        monitor.start()
        let notificationCenter = MockNotificationCenter()
        let manager = NetworkConnectivityManager(networkMonitor: monitor,
                                                 connectivityChecker: checker,
                                                 notificationCenter: notificationCenter)

        let healthMonitor = HealthMonitor(dataProvider: HealthMonitorDataProvider(maxTasks: 1000,
                                                                                  persistenceContextProvider: persistenceContextProvider),
                                          dateProvider: SystemDateProvider(),
                                          networkSession: networkSession)
        let taskRunner = IterableTaskRunner(networkSession: networkSession,
                                            persistenceContextProvider: persistenceContextProvider,
                                            healthMonitor: healthMonitor,
                                            notificationCenter: notificationCenter,
                                            connectivityManager: manager)
        taskRunner.start()

        let scheduler = IterableTaskScheduler(persistenceContextProvider: persistenceContextProvider,
                                              notificationCenter: notificationCenter,
                                              healthMonitor: healthMonitor)

        // Now schedule a task, giving it some time for task runner to be updated with
        // offliine network status
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let _ = try! self.scheduleSampleTask(scheduler: scheduler)
        }

        verifyNoTaskIsExecuted(notificationCenter, forInterval: 1.0)
        
        // set network status back to normal
        networkSession.responseCallback = nil
        
        verifyTaskIsExecuted(notificationCenter, withinInterval: 10.0)

        waitForZeroTasks()

        taskRunner.stop()
    }
    
    func testForegroundBackgroundChange() throws {
        let networkSession = MockNetworkSession()
        let checker = NetworkConnectivityChecker(networkSession: networkSession)
        let monitor = NetworkMonitor()
        let notificationCenter = MockNotificationCenter()
        let manager = NetworkConnectivityManager(networkMonitor: monitor,
                                                 connectivityChecker: checker,
                                                 notificationCenter: notificationCenter)
        
        let healthMonitor = HealthMonitor(dataProvider: HealthMonitorDataProvider(maxTasks: 1000,
                                                                                  persistenceContextProvider: persistenceContextProvider),
                                          dateProvider: SystemDateProvider(),
                                          networkSession: networkSession)
        let taskRunner = IterableTaskRunner(networkSession: networkSession,
                                            persistenceContextProvider: persistenceContextProvider,
                                            healthMonitor: healthMonitor,
                                            notificationCenter: notificationCenter,
                                            timeInterval: 0.5,
                                            connectivityManager: manager)
        taskRunner.start()
        
        let scheduler = IterableTaskScheduler(persistenceContextProvider: persistenceContextProvider,
                                              notificationCenter: notificationCenter,
                                              healthMonitor: healthMonitor)

        let _ = try! self.scheduleSampleTask(scheduler: scheduler)
        verifyTaskIsExecuted(notificationCenter, withinInterval: 1.0)

        // Now move app to background
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil, userInfo: nil)
        // Now schedule a task, giving it some time for task runner to be updated with
        // app background status
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let _ = try! self.scheduleSampleTask(scheduler: scheduler)
        }

        verifyNoTaskIsExecuted(notificationCenter, forInterval: 1.0)

        // Now move app to foreground
        notificationCenter.post(name: UIApplication.willEnterForegroundNotification, object: nil, userInfo: nil)
        verifyTaskIsExecuted(notificationCenter, withinInterval: 10.0)
        taskRunner.stop()
    }
    
    func testSentAtInHeader() throws {
        let date = Date()
        let sentAtTime = "\(Int(date.timeIntervalSince1970))"
        let dateProvider = MockDateProvider()
        dateProvider.currentDate = date
        let expectation1 = expectation(description: #function)
        let networkSession = MockNetworkSession()
        networkSession.requestCallback = { request in
            if request.allHTTPHeaderFields!.contains(where: { $0.key == "Sent-At" && $0.value == sentAtTime }) {
                expectation1.fulfill()
            }
        }
        let notificationCenter = MockNotificationCenter()
        
        let healthMonitor = HealthMonitor(dataProvider: HealthMonitorDataProvider(maxTasks: 1000,
                                                                                  persistenceContextProvider: persistenceContextProvider),
                                          dateProvider: dateProvider,
                                          networkSession: networkSession)
        let taskRunner = IterableTaskRunner(networkSession: networkSession,
                           persistenceContextProvider: persistenceContextProvider,
                           healthMonitor: healthMonitor,
                           notificationCenter: notificationCenter,
                           timeInterval: 0.5,
                           dateProvider: dateProvider)
        taskRunner.start()

        let scheduler = IterableTaskScheduler(persistenceContextProvider: persistenceContextProvider,
                                              notificationCenter: notificationCenter,
                                              healthMonitor: healthMonitor)
        let _ = try! self.scheduleSampleTask(scheduler: scheduler)
        verifyTaskIsExecuted(notificationCenter, withinInterval: 1.0)

        taskRunner.stop()
        wait(for: [expectation1], timeout: 5.0)
    }
    
    func testCreatedAtInBody() throws {
        let date = Date()
        let createdAtTime = Int(date.timeIntervalSince1970)
        let dateProvider = MockDateProvider()
        dateProvider.currentDate = date
        let expectation1 = expectation(description: #function)
        let networkSession = MockNetworkSession()
        networkSession.requestCallback = { request in
            if request.bodyDict.contains(where: { $0.key == "createdAt" && ($0.value as! Int) == createdAtTime }) {
                expectation1.fulfill()
            }
        }
        let notificationCenter = MockNotificationCenter()
        
        let healthMonitor = HealthMonitor(dataProvider: HealthMonitorDataProvider(maxTasks: 1000,
                                                                                  persistenceContextProvider: persistenceContextProvider),
                                          dateProvider: dateProvider,
                                          networkSession: networkSession)
        let taskRunner = IterableTaskRunner(networkSession: networkSession,
                           persistenceContextProvider: persistenceContextProvider,
                           healthMonitor: healthMonitor,
                           notificationCenter: notificationCenter,
                           timeInterval: 0.5)
        taskRunner.start()

        let scheduler = IterableTaskScheduler(persistenceContextProvider: persistenceContextProvider,
                                              notificationCenter: notificationCenter,
                                              healthMonitor: healthMonitor)
        let _ = try! self.scheduleSampleTask(scheduler: scheduler)
        verifyTaskIsExecuted(notificationCenter, withinInterval: 1.0)

        taskRunner.stop()
        wait(for: [expectation1], timeout: 5.0)
    }
    
    private func waitForZeroTasks() {
        let predicate = NSPredicate { (_, _) -> Bool in
            try! self.persistenceContextProvider.mainQueueContext().findAllTasks().count == 0
        }
        
        let expectation1 = expectation(for: predicate, evaluatedWith: nil, handler: nil)
        wait(for: [expectation1], timeout: 5.0)
    }

    private func scheduleSampleTasks(scheduler: IterableTaskScheduler,
                                     times: Int,
                                     scheduledTaskIds: [String]) throws -> Pending<[String], IterableTaskError> {
        guard times > 0 else {
            return Fulfill<[String], IterableTaskError>(value: scheduledTaskIds)
        }
        return try scheduleSampleTask(scheduler: scheduler).flatMap { [self] taskId -> Pending<[String], IterableTaskError> in
            var newTaskIds = scheduledTaskIds
            newTaskIds.append(taskId)
            return try! self.scheduleSampleTasks(scheduler: scheduler, times: times-1, scheduledTaskIds: newTaskIds)
        }
    }
    
    private func scheduleSampleTask(scheduler: IterableTaskScheduler) throws -> Pending<String, IterableTaskError> {
        let apiKey = "zee-api-key"
        let eventName = "CustomEvent1"
        let dataFields = ["var1": "val1", "var2": "val2"]
        
        let requestCreator = RequestCreator(auth: auth, deviceMetadata: deviceMetadata)
        guard case let Result.success(trackEventRequest) = requestCreator.createTrackEventRequest(eventName, dataFields: dataFields) else {
            throw IterableError.general(description: "Could not create trackEvent request")
        }
        
        let apiCallRequest = IterableAPICallRequest(apiKey: apiKey,
                                                    endpoint: Endpoint.api,
                                                    authToken: auth.authToken,
                                                    deviceMetadata: deviceMetadata,
                                                    iterableRequest: trackEventRequest)
        return scheduler.schedule(apiCallRequest: apiCallRequest)
    }

    private func verifyNoTaskIsExecuted(_ notificationCenter: MockNotificationCenter, forInterval interval: TimeInterval) {
        let expectation1 = expectation(description: "Wait for task complete notification.")
        expectation1.isInverted = true
        
        let reference1 = notificationCenter.addCallback(forNotification: .iterableTaskFinishedWithRetry) { _ in
            XCTFail()
        }
        let reference2 = notificationCenter.addCallback(forNotification: .iterableTaskFinishedWithNoRetry) { _ in
            XCTFail()
        }
        let reference3 = notificationCenter.addCallback(forNotification: .iterableTaskFinishedWithSuccess) { _ in
            XCTFail()
        }
        wait(for: [expectation1], timeout: interval)
        notificationCenter.removeCallbacks(withIds: reference1.callbackId, reference2.callbackId, reference3.callbackId)
    }

    private func verifyTaskIsExecuted(_ notificationCenter: MockNotificationCenter, withinInterval interval: TimeInterval) {
        let expectation1 = expectation(description: "Wait for task complete notification.")
        let reference = notificationCenter.addCallback(forNotification: .iterableTaskFinishedWithSuccess) { _ in
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: interval)
        notificationCenter.removeCallbacks(withIds: reference.callbackId)
    }

    private let deviceMetadata = DeviceMetadata(deviceId: IterableUtil.generateUUID(),
                                                platform: JsonValue.iOS,
                                                appPackageName: Bundle.main.appPackageName ?? "")
    
    private lazy var persistenceContextProvider: IterablePersistenceContextProvider = {
        let provider = CoreDataPersistenceContextProvider()!
        return provider
    }()
}

extension TaskRunnerTests: AuthProvider {
    var auth: Auth {
        Auth(userId: nil, email: "user@example.com", authToken: nil, userIdAnon: nil)
    }
}
