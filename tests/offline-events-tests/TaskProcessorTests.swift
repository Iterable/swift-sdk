//
//  Copyright © 2020 Iterable. All rights reserved.
//

import XCTest

@testable import IterableSDK

class TaskProcessorTests: XCTestCase {
    func testAPICallForTrackEventWithPersistence() throws {
        let apiKey = "test-api-key"
        let email = "user@example.com"
        let eventName = "CustomEvent1"
        let dataFields = ["var1": "val1", "var2": "val2"]
        
        let expectation1 = expectation(description: #function)
        let auth = Auth(userId: nil, email: email, authToken: nil, userIdAnon: nil)
        let config = IterableConfig()
        let networkSession = MockNetworkSession()
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: apiKey, config: config, networkSession: networkSession)
        
        let requestCreator = RequestCreator(auth: auth,
                                            deviceMetadata: internalAPI.deviceMetadata)
        guard case let Result.success(trackEventRequest) = requestCreator.createTrackEventRequest(eventName, dataFields: dataFields) else {
            XCTFail("Could not create trackEvent request")
            return
        }
        
        let apiCallRequest = IterableAPICallRequest(apiKey: apiKey,
                                                    endpoint: Endpoint.api,
                                                    authToken: auth.authToken,
                                                    deviceMetadata: internalAPI.deviceMetadata,
                                                    iterableRequest: trackEventRequest)
        let data = try JSONEncoder().encode(apiCallRequest)
        
        // persist data
        let taskId = IterableUtil.generateUUID()
        try persistenceProvider.mainQueueContext().create(task: IterableTask(id: taskId,
                                                                             type: .apiCall,
                                                                             scheduledAt: Date(),
                                                                             data: data,
                                                                             requestedAt: Date()))
        try persistenceProvider.mainQueueContext().save()
        
        // load data
        let found = try persistenceProvider.mainQueueContext().findTask(withId: taskId)!
        
        // process data
        let processor = IterableAPICallTaskProcessor(networkSession: networkSession)
        try processor.process(task: found).onSuccess { _ in
            let request = networkSession.getRequest(withEndPoint: Const.Path.trackEvent)!
            let body = request.httpBody!.json() as! [String: Any]
            TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.email), value: email, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.dataFields), value: dataFields, inDictionary: body)
            expectation1.fulfill()
        }
        
        try persistenceProvider.mainQueueContext().delete(task: found)
        try persistenceProvider.mainQueueContext().save()
        
        wait(for: [expectation1], timeout: 15.0)
    }

    func testNetworkAvailable() throws {
        let expectation1 = expectation(description: #function)
        let task = try createSampleTask()!
        
        let networkSession = MockNetworkSession(statusCode: 200)
        // process data
        let processor = IterableAPICallTaskProcessor(networkSession: networkSession)
        try processor.process(task: task)
            .onSuccess { taskResult in
                switch taskResult {
                case .success(detail: _):
                    expectation1.fulfill()
                case .failureWithNoRetry(detail: _):
                    XCTFail("not expecting failure with no retry")
                case .failureWithRetry(retryAfter: _, detail: _):
                    XCTFail("not expecting failure with retry")
                }
            }
            .onError { _ in
                XCTFail()
            }

        try persistenceProvider.mainQueueContext().delete(task: task)
        try persistenceProvider.mainQueueContext().save()
        wait(for: [expectation1], timeout: 15.0)
    }

    func testNetworkUnavailable() throws {
        let expectation1 = expectation(description: #function)
        let task = try createSampleTask()!
        
        let networkError = IterableError.general(description: "The Internet connection appears to be offline.")
        let networkSession = MockNetworkSession(statusCode: 0, data: nil, error: networkError)
        // process data
        let processor = IterableAPICallTaskProcessor(networkSession: networkSession)
        try processor.process(task: task)
            .onSuccess { taskResult in
                switch taskResult {
                case .success(detail: _):
                    XCTFail("not expecting success")
                case .failureWithNoRetry(detail: _):
                    XCTFail("not expecting failure with no retry")
                case .failureWithRetry(retryAfter: _, detail: _):
                    expectation1.fulfill()
                }
            }
            .onError { _ in
                XCTFail()
            }

        try persistenceProvider.mainQueueContext().delete(task: task)
        try persistenceProvider.mainQueueContext().save()
        wait(for: [expectation1], timeout: 15.0)
    }

    func testUnrecoverableError() throws {
        let expectation1 = expectation(description: #function)
        let task = try createSampleTask()!
        
        let networkSession = MockNetworkSession(statusCode: 401, data: nil, error: nil)
        // process data
        let processor = IterableAPICallTaskProcessor(networkSession: networkSession)
        try processor.process(task: task)
            .onSuccess { taskResult in
                switch taskResult {
                case .success(detail: _):
                    XCTFail("not expecting success")
                case .failureWithNoRetry(detail: _):
                    expectation1.fulfill()
                case .failureWithRetry(retryAfter: _, detail: _):
                    XCTFail("not expecting failure with retry")
                }
            }
            .onError { _ in
                XCTFail()
            }

        try persistenceProvider.mainQueueContext().delete(task: task)
        try persistenceProvider.mainQueueContext().save()
        wait(for: [expectation1], timeout: 15.0)
    }
    
    func testSentAtInHeader() throws {
        let expectation1 = expectation(description: #function)
        let task = try createSampleTask()!
        let date = Date()
        let sentAtTime = "\(Int(date.timeIntervalSince1970))"
        let dateProvider = MockDateProvider()
        dateProvider.currentDate = date
        
        let networkSession = MockNetworkSession()
        networkSession.requestCallback = { request in
            if request.allHTTPHeaderFields!.contains(where: { $0.key == "Sent-At" && $0.value == sentAtTime }) {
                expectation1.fulfill()
            }
        }
        
        // process data
        let processor = IterableAPICallTaskProcessor(networkSession: networkSession, dateProvider: dateProvider)
        try processor.process(task: task)
            .onSuccess { taskResult in
                switch taskResult {
                case .success(detail: _):
                    break
                case .failureWithNoRetry(detail: _):
                    XCTFail("not expecting failure with no retry")
                case .failureWithRetry(retryAfter: _, detail: _):
                    XCTFail("not expecting failure with retry")
                }
            }
            .onError { _ in
                XCTFail()
            }

        try persistenceProvider.mainQueueContext().delete(task: task)
        try persistenceProvider.mainQueueContext().save()
        wait(for: [expectation1], timeout: 5.0)
    }

    func testCreatedAtInBody() throws {
        let expectation1 = expectation(description: #function)
        let date = Date()
        let createdAtTime = Int(date.timeIntervalSince1970)
        let task = try createSampleTask(scheduledAt: date)!
        
        let networkSession = MockNetworkSession()
        networkSession.requestCallback = { request in
            if request.bodyDict.contains(where: { $0.key == "createdAt" && ($0.value as! Int) == createdAtTime }) {
                expectation1.fulfill()
            }
        }
        
        // process data
        let processor = IterableAPICallTaskProcessor(networkSession: networkSession)
        try processor.process(task: task)
            .onSuccess { taskResult in
                switch taskResult {
                case .success(detail: _):
                    break
                case .failureWithNoRetry(detail: _):
                    XCTFail("not expecting failure with no retry")
                case .failureWithRetry(retryAfter: _, detail: _):
                    XCTFail("not expecting failure with retry")
                }
            }
            .onError { _ in
                XCTFail()
            }

        try persistenceProvider.mainQueueContext().delete(task: task)
        try persistenceProvider.mainQueueContext().save()
        wait(for: [expectation1], timeout: 5.0)
    }

    private func createSampleTask(scheduledAt: Date = Date(), requestedAt: Date = Date()) throws -> IterableTask? {
        let apiKey = "test-api-key"
        let email = "user@example.com"
        let eventName = "CustomEvent1"
        let dataFields = ["var1": "val1", "var2": "val2"]
        
        let auth = Auth(userId: nil, email: email, authToken: nil, userIdAnon: nil)
        let requestCreator = RequestCreator(auth: auth,
                                            deviceMetadata: deviceMetadata)
        guard case let Result.success(trackEventRequest) = requestCreator.createTrackEventRequest(eventName, dataFields: dataFields) else {
            XCTFail("Could not create trackEvent request")
            return nil
        }
        
        let apiCallRequest = IterableAPICallRequest(apiKey: apiKey,
                                                    endpoint: Endpoint.api,
                                                    authToken: auth.authToken,
                                                    deviceMetadata: deviceMetadata,
                                                    iterableRequest: trackEventRequest)
        let data = try JSONEncoder().encode(apiCallRequest)
        
        // persist data
        let taskId = IterableUtil.generateUUID()
        try persistenceProvider.mainQueueContext().create(task: IterableTask(id: taskId,
                                                                             type: .apiCall,
                                                                             scheduledAt: scheduledAt,
                                                                             data: data,
                                                                             requestedAt: requestedAt))
        try persistenceProvider.mainQueueContext().save()

        return try persistenceProvider.mainQueueContext().findTask(withId: taskId)
    }

    private let deviceMetadata = DeviceMetadata(deviceId: IterableUtil.generateUUID(),
                                                platform: JsonValue.iOS,
                                                appPackageName: Bundle.main.appPackageName ?? "")

    private lazy var persistenceProvider: IterablePersistenceContextProvider = {
        let provider = CoreDataPersistenceContextProvider()!
        try! provider.mainQueueContext().deleteAllTasks()
        try! provider.mainQueueContext().save()
        return provider
    }()
}
