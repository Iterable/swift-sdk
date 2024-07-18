//
//  Copyright © 2020 Iterable. All rights reserved.
//

import XCTest

@testable import IterableSDK

let testExpectationTimeout = 15.0 // How long to wait when we expect to succeed
let testExpectationTimeoutForInverted = 1.0 // How long to wait when we expect to fail

class RequestHandlerTests: XCTestCase {
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
    
    func testRegister() throws {
        let registerTokenInfo = RegisterTokenInfo(hexToken: "zee-token",
                                                  appName: "zee-app-name",
                                                  pushServicePlatform: .auto,
                                                  apnsType: .sandbox,
                                                  deviceId: "deviceId",
                                                  deviceAttributes: [:],
                                                  sdkVersion: "6.x.x")
        
        let device = UIDevice.current
        let dataFields: [String: Any] = [
            "deviceId": registerTokenInfo.deviceId,
            "iterableSdkVersion": registerTokenInfo.sdkVersion!,
            "notificationsEnabled": true,
            "appPackageName": Bundle.main.appPackageName!,
            "appVersion": Bundle.main.appVersion!,
            "appBuild": Bundle.main.appBuild!,
            "localizedModel": device.localizedModel,
            "userInterfaceIdiom": "Phone",
            "systemName": device.systemName,
            "systemVersion": device.systemVersion,
            "model": device.model,
            "identifierForVendor": device.identifierForVendor!.uuidString
        ]
        let deviceDict: [String: Any] = [
            "token": registerTokenInfo.hexToken,
            "applicationName": registerTokenInfo.appName,
            "platform": "APNS_SANDBOX",
            "dataFields": dataFields
        ]
        let bodyDict: [String: Any] = [
            "device": deviceDict,
            "email": "user@example.com"
        ]

        let expectation1 = expectation(description: #function)
        let networkSession = MockNetworkSession()
        let requestHandler = createRequestHandler(networkSession: networkSession,
                                                  notificationCenter: MockNotificationCenter(),
                                                  selectOffline: false)
        requestHandler.register(registerTokenInfo: registerTokenInfo,
                                notificationStateProvider: MockNotificationStateProvider(enabled: true),
                                onSuccess: nil,
                                onFailure: nil)

        networkSession.requestCallback = { request in
            TestUtils.validate(request: request, apiEndPoint: Endpoint.api, path: Const.Path.registerDeviceToken)
            var requestBody = request.bodyDict
            requestBody.removeValue(forKey: "createdAt")
            XCTAssertTrue(TestUtils.areEqual(dict1: bodyDict, dict2: requestBody))
            expectation1.fulfill()
        }

        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    func testDisableUserforCurrentUser() throws {
        let hexToken = "zee-token"
        let bodyDict: [String: Any] = [
            "token": hexToken,
            "email": "user@example.com"
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.disableDeviceForCurrentUser(hexToken: hexToken,
                                                       withOnSuccess: expectations.onSuccess,
                                                       onFailure: expectations.onFailure)
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.disableDevice,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testDisableUserforAllUsers() throws {
        let hexToken = "zee-token"
        let bodyDict: [String: Any] = [
            "token": hexToken,
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.disableDeviceForAllUsers(hexToken: hexToken,
                                                    withOnSuccess: expectations.onSuccess,
                                                    onFailure: expectations.onFailure)
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.disableDevice,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testUpdateUser() throws {
        let dataFields = ["var1": "val1", "var2": "val2"]
        let bodyDict: [String: Any] = [
            "dataFields": dataFields,
            "email": "user@example.com",
            "mergeNestedObjects": true
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.updateUser(dataFields,
                                      mergeNestedObjects: true,
                                      onSuccess: expectations.onSuccess,
                                      onFailure: expectations.onFailure)
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.updateUser,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testUpdateEmail() throws {
        let bodyDict: [String: Any] = [
            "currentEmail": "user@example.com",
            "newEmail": "new_user@example.com"
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.updateEmail("new_user@example.com",
                                       onSuccess: expectations.onSuccess,
                                       onFailure: expectations.onFailure)
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.updateEmail,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testTrackPurchase() throws {
        let total = NSNumber(value: 15.32)
        let items = [CommerceItem(id: "id1", name: "myCommerceItem", price: 5.1, quantity: 2)]
        let dataFields = ["var1": "val1", "var2": "val2"]
        
        let bodyDict: [String: Any] = [
            "items": [[
                "id": items[0].id,
                "name": items[0].name,
                "price": items[0].price,
                "quantity": items[0].quantity,
            ] as [String : Any]],
            "total": total,
            "dataFields": dataFields,
            "user": [
                "email": "user@example.com",
            ],
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.trackPurchase(total,
                                         items: items,
                                         dataFields: dataFields,
                                         campaignId: nil,
                                         templateId: nil,
                                         onSuccess: expectations.onSuccess,
                                         onFailure: expectations.onFailure)
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.trackPurchase,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }

    func testTrackPurchase2() throws {
        let total = NSNumber(value: 15.32)
        let items = [CommerceItem(id: "id1", name: "myCommerceItem", price: 5.1, quantity: 2)]
        let dataFields = ["var1": "val1", "var2": "val2"]
        let campaignId: NSNumber = 33
        let templateId: NSNumber = 55
        
        let bodyDict: [String: Any] = [
            "items": [[
                "id": items[0].id,
                "name": items[0].name,
                "price": items[0].price,
                "quantity": items[0].quantity,
            ] as [String : Any]],
            "total": total,
            "dataFields": dataFields,
            "campaignId": campaignId,
            "templateId": templateId,
            "user": [
                "email": "user@example.com",
            ],
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.trackPurchase(total,
                                         items: items,
                                         dataFields: dataFields,
                                         campaignId: campaignId,
                                         templateId: templateId,
                                         onSuccess: expectations.onSuccess,
                                         onFailure: expectations.onFailure)
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.trackPurchase,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }

    func testTrackPushOpen() throws {
        let campaignId = 1
        let templateId = 2
        let messageId = "message_id"
        let appAlreadyRunning = true
        let dataFields: [String: Any] = [
            "var1": "val1",
            "var2": "val2",
        ]
        var bodyDataFields = dataFields
        bodyDataFields["appAlreadyRunning"] = appAlreadyRunning
        let bodyDict: [String: Any] = [
            "dataFields": bodyDataFields,
            "campaignId": campaignId,
            "templateId": templateId,
            "messageId": messageId,
            "email": "user@example.com"
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.trackPushOpen(NSNumber(value: campaignId),
                                         templateId: NSNumber(value: templateId),
                                         messageId: messageId,
                                         appAlreadyRunning: appAlreadyRunning,
                                         dataFields: dataFields,
                                         onSuccess: expectations.onSuccess,
                                         onFailure: expectations.onFailure)
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.trackPushOpen,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testTrackEvent() throws {
        let eventName = "CustomEvent1"
        let dataFields = ["var1": "val1", "var2": "val2"]
        let bodyDict: [String: Any] = [
            "eventName": eventName,
            "dataFields": dataFields,
            "email": "user@example.com"
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.track(event: eventName,
                                 dataFields: dataFields,
                                 onSuccess: expectations.onSuccess,
                                 onFailure: expectations.onFailure)
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.trackEvent,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testUpdateSubscriptions() throws {
        let info = UpdateSubscriptionsInfo(emailListIds: [123],
                                           unsubscribedChannelIds: [456],
                                           unsubscribedMessageTypeIds: [789],
                                           subscribedMessageTypeIds: [111],
                                           campaignId: 1,
                                           templateId: 2)
        let bodyDict: [String: Any] = [
            "emailListIds": info.emailListIds!,
            "unsubscribedChannelIds": info.unsubscribedChannelIds!,
            "unsubscribedMessageTypeIds": info.unsubscribedMessageTypeIds!,
            "subscribedMessageTypeIds": info.subscribedMessageTypeIds!,
            "campaignId": info.campaignId!,
            "templateId": info.templateId!,
            "email": "user@example.com"
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.updateSubscriptions(info: info,
                                               onSuccess: expectations.onSuccess,
                                               onFailure: expectations.onFailure)
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.updateSubscriptions,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testTrackInAppOpen() throws {
        let messageId = "message_id"
        let message = InAppTestHelper.emptyInAppMessage(messageId: messageId)
        let inboxSessionId = "ibx1"
        let bodyDict: [String: Any] = [
            "email": "user@example.com",
            "messageId": messageId,
            "inboxSessionId": inboxSessionId,
            "deviceInfo": Self.deviceMetadata.asDictionary()!,
            "messageContext": [
                "location": "in-app",
                "saveToInbox": false,
                "silentInbox": false,
            ] as [String : Any],
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.trackInAppOpen(message,
                                          location: .inApp,
                                          inboxSessionId: inboxSessionId,
                                          onSuccess: expectations.onSuccess,
                                          onFailure: expectations.onFailure)
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.trackInAppOpen,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testTrackInAppClick() throws {
        let messageId = "message_id"
        let message = InAppTestHelper.emptyInAppMessage(messageId: messageId)
        let inboxSessionId = "ibx1"
        let clickedUrl = "https://somewhere.com"
        let bodyDict: [String: Any] = [
            "email": "user@example.com",
            "messageId": messageId,
            "inboxSessionId": inboxSessionId,
            "deviceInfo": Self.deviceMetadata.asDictionary()!,
            "clickedUrl": clickedUrl,
            "messageContext": [
                "location": "inbox",
                "saveToInbox": false,
                "silentInbox": false,
            ] as [String : Any],
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.trackInAppClick(message,
                                           location: .inbox,
                                           inboxSessionId: inboxSessionId,
                                           clickedUrl: clickedUrl,
                                           onSuccess: expectations.onSuccess,
                                           onFailure: expectations.onFailure)
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.trackInAppClick,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testTrackInAppClose() throws {
        let messageId = "message_id"
        let message = InAppTestHelper.emptyInAppMessage(messageId: messageId)
        let inboxSessionId = "ibx1"
        let clickedUrl = "https://closeme.com"
        let closeSource = InAppCloseSource.link
        let bodyDict: [String: Any] = [
            "email": "user@example.com",
            "messageId": messageId,
            "inboxSessionId": inboxSessionId,
            "deviceInfo": Self.deviceMetadata.asDictionary()!,
            "clickedUrl": clickedUrl,
            "messageContext": [
                "location": "inbox",
                "saveToInbox": false,
                "silentInbox": false,
            ] as [String : Any],
            "closeAction": "link",
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.trackInAppClose(message, location: .inbox,
                                           inboxSessionId: inboxSessionId,
                                           source: closeSource,
                                           clickedUrl: clickedUrl,
                                           onSuccess: expectations.onSuccess,
                                           onFailure: expectations.onFailure)
            
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.trackInAppClose,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testTrackInboxSession() throws {
        let inboxSessionId = IterableUtil.generateUUID()
        let startDate = dateProvider.currentDate
        let endDate = startDate.addingTimeInterval(60 * 5)
        let impressions = [
            IterableInboxImpression(messageId: "message1", silentInbox: true, displayCount: 2, displayDuration: 1.23),
            IterableInboxImpression(messageId: "message2", silentInbox: false, displayCount: 3, displayDuration: 2.34),
        ]
        let inboxSession = IterableInboxSession(id: inboxSessionId,
                                                sessionStartTime: startDate,
                                                sessionEndTime: endDate,
                                                startTotalMessageCount: 15,
                                                startUnreadMessageCount: 5,
                                                endTotalMessageCount: 10,
                                                endUnreadMessageCount: 3,
                                                impressions: impressions)
        
        let bodyDict: [String: Any] = [
            "email": "user@example.com",
            "inboxSessionId": inboxSessionId,
            "inboxSessionStart": IterableUtil.int(fromDate: startDate),
            "inboxSessionEnd": IterableUtil.int(fromDate: endDate),
            "startTotalMessageCount": inboxSession.startTotalMessageCount,
            "startUnreadMessageCount": inboxSession.startUnreadMessageCount,
            "endTotalMessageCount": inboxSession.endTotalMessageCount,
            "endUnreadMessageCount": inboxSession.endUnreadMessageCount,
            "impressions": impressions.compactMap { $0.asDictionary() },
            "deviceInfo": Self.deviceMetadata.asDictionary()!,
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.track(inboxSession: inboxSession,
                                 onSuccess: expectations.onSuccess,
                                 onFailure: expectations.onFailure)
            
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.trackInboxSession,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testTrackInAppDelivery() throws {
        let messageId = "message_id"
        let message = InAppTestHelper.emptyInAppMessage(messageId: messageId)
        
        let bodyDict: [String: Any] = [
            "email": "user@example.com",
            "messageId": messageId,
            "messageContext": [
                "saveToInbox": false,
                "silentInbox": false,
            ],
            "deviceInfo": Self.deviceMetadata.asDictionary()!,
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.track(inAppDelivery: message,
                                 onSuccess: expectations.onSuccess,
                                 onFailure: expectations.onFailure)
            
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.trackInAppDelivery,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testTrackInAppConsume() throws {
        let messageId = "message_id"
        
        let bodyDict: [String: Any] = [
            "email": "user@example.com",
            "messageId": messageId,
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.inAppConsume(messageId,
                                        onSuccess: expectations.onSuccess,
                                        onFailure: expectations.onFailure)
            
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.inAppConsume,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testTrackInAppConsume2() throws {
        let messageId = "message_id"
        let inboxSessionId = UUID().uuidString
        let message = InAppTestHelper.emptyInAppMessage(messageId: messageId)
        let location = InAppLocation.inbox
        let source = InAppDeleteSource.deleteButton
        let bodyDict: [String: Any] = [
            "email": "user@example.com",
            "messageId": messageId,
            "messageContext": [
                "location": "inbox",
                "saveToInbox": false,
                "silentInbox": false,
            ] as [String : Any],
            "inboxSessionId": inboxSessionId,
            "deleteAction": "delete-button",
            "deviceInfo": Self.deviceMetadata.asDictionary()!,
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) in
            requestHandler.inAppConsume(message: message,
                                        location: location,
                                        source: source,
                                        inboxSessionId: inboxSessionId,
                                        onSuccess: expectations.onSuccess,
                                        onFailure: expectations.onFailure)
            
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.inAppConsume,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testTrackInAppOpen2() throws {
        let messageId = "message_id"
        let inboxSessionId = UUID().uuidString
        let bodyDict: [String: Any] = [
            "email": "user@example.com",
            "messageId": messageId,
            "deviceInfo": Self.deviceMetadata.asDictionary()!,
            "messageContext": [
                "location": "in-app",
                "saveToInbox": false,
                "silentInbox": false,
            ] as [String : Any],
            "inboxSessionId": inboxSessionId,
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) -> Pending<SendRequestValue, SendRequestError> in
            let message = IterableInAppMessage(messageId: messageId,
                                               campaignId: nil,
                                               content: IterableHtmlInAppContent(edgeInsets: .zero, html: ""))
            
            return requestHandler.trackInAppOpen(message,
                                          location: .inApp,
                                          inboxSessionId: inboxSessionId,
                                          onSuccess: expectations.onSuccess,
                                          onFailure: expectations.onFailure)
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.trackInAppOpen,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testTrackInAppClick2() throws {
        let messageId = "message_id"
        let clickedUrl = "https://somewhere.com"
        let bodyDict: [String: Any] = [
            "email": "user@example.com",
            "messageId": messageId,
            "deviceInfo": Self.deviceMetadata.asDictionary()!,
            "clickedUrl": clickedUrl,
            "messageContext": [
                "location": "in-app",
                "saveToInbox": false,
                "silentInbox": false,
            ] as [String : Any],
        ]
        
        let expectations = createExpectations(description: #function)
        
        let requestGenerator = { (requestHandler: RequestHandlerProtocol) -> Pending<SendRequestValue, SendRequestError> in
            let message = IterableInAppMessage(messageId: messageId,
                                               campaignId: nil,
                                               content: IterableHtmlInAppContent(edgeInsets: .zero, html: ""))
            
            return requestHandler.trackInAppClick(message,
                                           location: .inApp,
                                           inboxSessionId: nil,
                                           clickedUrl: clickedUrl,
                                           onSuccess: expectations.onSuccess,
                                           onFailure: expectations.onFailure)
        }
        
        try handleRequestWithSuccessAndFailure(requestGenerator: requestGenerator,
                                                path: Const.Path.trackInAppClick,
                                                bodyDict: bodyDict)
        
        wait(for: [expectations.successExpectation, expectations.failureExpectation], timeout: testExpectationTimeout)
    }
    
    func testDeleteAllTasksOnLogout() throws {
        let localStorage = MockLocalStorage()
        localStorage.offlineMode = true
        let internalApi = InternalIterableAPI.initializeForTesting(networkSession: MockNetworkSession(),
                                                                   localStorage: localStorage)
        internalApi.email = "user@example.com"
        
        let taskId = IterableUtil.generateUUID()
        try persistenceContextProvider.mainQueueContext().create(task: IterableTask(id: taskId,
                                                                                    type: .apiCall,
                                                                                    scheduledAt: Date(),
                                                                                    data: nil,
                                                                                    requestedAt: Date()))
        try persistenceContextProvider.mainQueueContext().save()

        internalApi.logoutUser()
        
        let result = TestUtils.tryUntil(attempts: 10) {
            let count = try! persistenceContextProvider.mainQueueContext().findAllTasks().count
            return count == 0
        }
        
        XCTAssertTrue(result)
    }
    
    func testGetRemoteConfiguration() throws {
        let expectation1 = expectation(description: #function)
        let expectedRemoteConfiguration = RemoteConfiguration(offlineMode: true)
        let data = try JSONEncoder().encode(expectedRemoteConfiguration)
        let notificationCenter = MockNotificationCenter()
        let networkSession = MockNetworkSession(statusCode: 200, data: data)

        networkSession.requestCallback = { request in
            TestUtils.validate(request: request,
                               requestType: .get,
                               apiEndPoint: Endpoint.api,
                               path: Const.Path.getRemoteConfiguration,
                               queryParams: [("platform", "iOS"),
                                             ("systemVersion", UIDevice.current.systemVersion),
                                             ("SDKVersion", IterableAPI.sdkVersion),
                                             ("packageName", Bundle.main.appPackageName!)])
        }
        let requestHandler = createRequestHandler(networkSession: networkSession,
                                                  notificationCenter: notificationCenter,
                                                  selectOffline: false)
        requestHandler.getRemoteConfiguration().onSuccess { remoteConfiguration in
            XCTAssertEqual(remoteConfiguration, expectedRemoteConfiguration)
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    func testCreatedAtSentAtForOffline() throws {
        let expectation1 = expectation(description: #function)
        let date = Date().addingTimeInterval(-5000)
        dateProvider.currentDate = date

        let campaignId = 1
        let templateId = 2
        let messageId = "message_id"
        let appAlreadyRunning = true
        let dataFields: [String: Any] = [
            "var1": "val1",
            "var2": "val2",
        ]

        let networkSession = MockNetworkSession(statusCode: 200)
        networkSession.requestCallback = { request in
            if request.url?.absoluteString.contains(Const.Path.trackPushOpen) == true {
                let sentAt = request.value(forHTTPHeaderField: "Sent-At")
                let createdAt = TestUtils.getRequestBody(request: request)?["createdAt"] as? Int
                XCTAssertEqual(createdAt, Int(date.timeIntervalSince1970))
                XCTAssertEqual(sentAt, "\(Int(date.timeIntervalSince1970))")
                expectation1.fulfill()
            }
        }
        let requestHandler = createRequestHandler(networkSession: networkSession,
                                                  notificationCenter: MockNotificationCenter(),
                                                  selectOffline: true)
        requestHandler.trackPushOpen(NSNumber(value: campaignId),
                                     templateId: NSNumber(value: templateId),
                                     messageId: messageId,
                                     appAlreadyRunning: appAlreadyRunning,
                                     dataFields: dataFields,
                                     onSuccess: nil,
                                     onFailure: nil)
        waitForTaskRunner(requestHandler: requestHandler, expectation: expectation1)
    }

    func testCreatedAtSentAtForOnline() throws {
        let expectation1 = expectation(description: #function)
        let date = Date().addingTimeInterval(-5000)
        dateProvider.currentDate = date

        let campaignId = 1
        let templateId = 2
        let messageId = "message_id"
        let appAlreadyRunning = true
        let dataFields: [String: Any] = [
            "var1": "val1",
            "var2": "val2",
        ]

        let networkSession = MockNetworkSession(statusCode: 200)
        networkSession.requestCallback = { request in
            let sentAt = request.value(forHTTPHeaderField: "Sent-At")
            XCTAssertEqual(sentAt, "\(Int(date.timeIntervalSince1970))")
            let createdAt = TestUtils.getRequestBody(request: request)?["createdAt"] as? Int
            XCTAssertEqual(createdAt, Int(date.timeIntervalSince1970))
            expectation1.fulfill()
        }
        let requestHandler = createRequestHandler(networkSession: networkSession,
                                                  notificationCenter: MockNotificationCenter(),
                                                  selectOffline: false)
        requestHandler.trackPushOpen(NSNumber(value: campaignId),
                                     templateId: NSNumber(value: templateId),
                                     messageId: messageId,
                                     appAlreadyRunning: appAlreadyRunning,
                                     dataFields: dataFields,
                                     onSuccess: nil,
                                     onFailure: nil)
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }

    func testNoRemoteConfigurationUsesOnline() throws {
        let expectation1 = expectation(description: "getRemoteConfiguration is called")
        var mapper = [String: Data?]()
        mapper["getRemoteConfiguration"] = nil
        let networkSession = MockNetworkSession(statusCode: 200, urlPatternDataMapping: mapper)
        networkSession.requestCallback = { request in
            if request.url!.absoluteString.contains(Const.Path.getRemoteConfiguration) {
                expectation1.fulfill()
            }
        }
        let localStorage = MockLocalStorage()
        localStorage.email = "user@example.com"
        let internalAPI = InternalIterableAPI.initializeForTesting(networkSession: networkSession, localStorage: localStorage)
        wait(for: [expectation1], timeout: testExpectationTimeout)

        let expectation2 = expectation(description: #function)
        networkSession.requestCallback = { request in
            if request.url!.absoluteString.contains("track") {
                let processor = request.allHTTPHeaderFields?[JsonKey.Header.requestProcessor]!
                XCTAssertEqual(processor, Const.ProcessorTypeName.online)
                expectation2.fulfill()
            }
        }
        internalAPI.track("myEvent")
        wait(for: [expectation2], timeout: testExpectationTimeout)
    }

    func testDefaultRemoteConfigurationUsesOnlineMode() throws {
        let expectation1 = expectation(description: "getRemoteConfiguration is called")
        let remoteConfigurationData = """
        {
            "offlineMode": false,
            "offlineModeBeta": false
        }
        """.data(using: .utf8)!
        var mapper = [String: Data?]()
        mapper["getRemoteConfiguration"] = remoteConfigurationData
        let networkSession = MockNetworkSession(statusCode: 200, urlPatternDataMapping: mapper)
        networkSession.requestCallback = { request in
            if request.url!.absoluteString.contains(Const.Path.getRemoteConfiguration) {
                expectation1.fulfill()
            }
        }
        let localStorage = MockLocalStorage()
        localStorage.email = "user@example.com"
        let internalAPI = InternalIterableAPI.initializeForTesting(networkSession: networkSession, localStorage: localStorage)
        wait(for: [expectation1], timeout: testExpectationTimeout)

        let expectation2 = expectation(description: #function)
        networkSession.requestCallback = { request in
            if request.url!.absoluteString.contains("track") {
                let processor = request.allHTTPHeaderFields?[JsonKey.Header.requestProcessor]!
                XCTAssertEqual(processor, Const.ProcessorTypeName.online)
                expectation2.fulfill()
            }
        }
        internalAPI.track("myEvent")
        wait(for: [expectation2], timeout: testExpectationTimeout)
    }

    func testFeatureFlagTurnOnOfflineMode() throws {
        let expectation1 = expectation(description: "getRemoteConfiguration is called")
        let remoteConfigurationData = """
        {
            "offlineMode": true,
            "offlineModeBeta": true
        }
        """.data(using: .utf8)!
        var mapper = [String: Data?]()
        mapper["getRemoteConfiguration"] = remoteConfigurationData
        let networkSession = MockNetworkSession(statusCode: 200, urlPatternDataMapping: mapper)
        networkSession.requestCallback = { request in
            if request.url!.absoluteString.contains(Const.Path.getRemoteConfiguration) {
                expectation1.fulfill()
            }
        }
        let localStorage = MockLocalStorage()
        localStorage.email = "user@example.com"
        let internalAPI = InternalIterableAPI.initializeForTesting(networkSession: networkSession, localStorage: localStorage)
        wait(for: [expectation1], timeout: testExpectationTimeout)

        let expectation2 = expectation(description: #function)
        networkSession.requestCallback = { request in
            if request.url!.absoluteString.contains("track") {
                let processor = request.allHTTPHeaderFields?[JsonKey.Header.requestProcessor]!
                XCTAssertEqual(processor, Const.ProcessorTypeName.offline)
                expectation2.fulfill()
            }
        }
        internalAPI.track("myEvent")
        wait(for: [expectation2], timeout: testExpectationTimeout)
    }

    func testLoadOfflineModeEnabledFromLocalStorage() throws {
        let expectation1 = expectation(description: "getRemoteConfiguration is called")
        var mapper = [String: Data?]()
        mapper["getRemoteConfiguration"] = nil
        let networkSession = MockNetworkSession(statusCode: 200, urlPatternDataMapping: mapper)
        networkSession.requestCallback = { request in
            if request.url!.absoluteString.contains(Const.Path.getRemoteConfiguration) {
                expectation1.fulfill()
            }
        }
        let localStorage = MockLocalStorage()
        localStorage.email = "user@example.com"
        localStorage.offlineMode = true
        let internalAPI = InternalIterableAPI.initializeForTesting(networkSession: networkSession, localStorage: localStorage)
        wait(for: [expectation1], timeout: testExpectationTimeout)

        let expectation2 = expectation(description: #function)
        networkSession.requestCallback = { request in
            if request.url!.absoluteString.contains("track") {
                let processor = request.allHTTPHeaderFields?[JsonKey.Header.requestProcessor]!
                XCTAssertEqual(processor, Const.ProcessorTypeName.offline)
                expectation2.fulfill()
            }
        }
        internalAPI.track("myEvent")
        wait(for: [expectation2], timeout: testExpectationTimeout)
    }

    func testLoadOfflineModeDisabledFromLocalStorage() throws {
        let expectation1 = expectation(description: "getRemoteConfiguration is called")
        var mapper = [String: Data?]()
        mapper["getRemoteConfiguration"] = nil
        let networkSession = MockNetworkSession(statusCode: 200, urlPatternDataMapping: mapper)
        networkSession.requestCallback = { request in
            if request.url!.absoluteString.contains(Const.Path.getRemoteConfiguration) {
                expectation1.fulfill()
            }
        }
        let localStorage = MockLocalStorage()
        localStorage.email = "user@example.com"
        localStorage.offlineMode = false
        let internalAPI = InternalIterableAPI.initializeForTesting(networkSession: networkSession, localStorage: localStorage)
        wait(for: [expectation1], timeout: testExpectationTimeout)

        let expectation2 = expectation(description: #function)
        networkSession.requestCallback = { request in
            if request.url!.absoluteString.contains("track") {
                let processor = request.allHTTPHeaderFields?[JsonKey.Header.requestProcessor]!
                XCTAssertEqual(processor, Const.ProcessorTypeName.online)
                expectation2.fulfill()
            }
        }
        internalAPI.track("myEvent")
        wait(for: [expectation2], timeout: testExpectationTimeout)
    }

    
    private func handleRequestWithSuccessAndFailure(requestGenerator: (RequestHandlerProtocol) -> Pending<SendRequestValue, SendRequestError>,
                                                     path: String,
                                                     bodyDict: [AnyHashable: Any]) throws {
        
        handleOnlineRequestWithSuccess(requestGenerator: requestGenerator,
                                        path: path,
                                        bodyDict: bodyDict)
        handleOnlineRequestWithFailure(requestGenerator: requestGenerator,
                                        path: path,
                                        bodyDict: bodyDict)
        handleOfflineRequestWithSuccess(requestGenerator: requestGenerator,
                                         path: path,
                                         bodyDict: bodyDict)
        handleOfflineRequestWithFailure(requestGenerator: requestGenerator,
                                         path: path,
                                         bodyDict: bodyDict)
    }
    
    private func handleOnlineRequestWithSuccess(requestGenerator: (RequestHandlerProtocol) -> Pending<SendRequestValue, SendRequestError>,
                                                 path: String,
                                                 bodyDict: [AnyHashable: Any]) {
        let notificationCenter = MockNotificationCenter()
        let networkSession = MockNetworkSession()
        networkSession.requestCallback = { request in
            TestUtils.validate(request: request, apiEndPoint: Endpoint.api, path: path)
            XCTAssertTrue(TestUtils.areEqual(dict1: bodyDict, dict2: request.bodyDict))
        }
        let requestHandler = createRequestHandler(networkSession: networkSession,
                                                  notificationCenter: notificationCenter,
                                                  selectOffline: false)
        let request = { requestGenerator(requestHandler) }
        let expectation1 = expectation(description: #function)
        handleRequestWithSuccess(request: request,
                                  networkSession: networkSession,
                                  path: path,
                                  bodyDict: bodyDict,
                                  expectation: expectation1)
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    private func handleOnlineRequestWithFailure(requestGenerator: (RequestHandlerProtocol) -> Pending<SendRequestValue, SendRequestError>,
                                                 path: String,
                                                 bodyDict: [AnyHashable: Any]) {
        let notificationCenter = MockNotificationCenter()
        let networkSession = MockNetworkSession(statusCode: 400)
        networkSession.requestCallback = { request in
            TestUtils.validate(request: request, apiEndPoint: Endpoint.api, path: path)
            XCTAssertTrue(TestUtils.areEqual(dict1: bodyDict, dict2: request.bodyDict))
        }
        let requestHandler = createRequestHandler(networkSession: networkSession,
                                                  notificationCenter: notificationCenter,
                                                  selectOffline: false)
        let request = { requestGenerator(requestHandler) }
        let expectation1 = expectation(description: #function)
        handleRequestWithFailure(request: request,
                                  networkSession: networkSession,
                                  path: path,
                                  bodyDict: bodyDict,
                                  expectation: expectation1)
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    private func handleOfflineRequestWithSuccess(requestGenerator: (RequestHandlerProtocol) -> Pending<SendRequestValue, SendRequestError>,
                                                  path: String,
                                                  bodyDict: [AnyHashable: Any]) {
        let notificationCenter = MockNotificationCenter()
        let networkSession = MockNetworkSession()
        networkSession.requestCallback = { request in
            TestUtils.validate(request: request, apiEndPoint: Endpoint.api, path: path)
            XCTAssertTrue(TestUtils.areEqual(dict1: bodyDict, dict2: request.bodyDict))
        }
        let requestHandler = createRequestHandler(networkSession: networkSession,
                                                  notificationCenter: notificationCenter,
                                                  selectOffline: true)
        let request = { requestGenerator(requestHandler) }
        let expectation1 = expectation(description: #function)
        handleRequestWithSuccess(request: request,
                                 networkSession: networkSession,
                                 path: path,
                                 bodyDict: bodyDict,
                                 expectation: expectation1)
        waitForTaskRunner(requestHandler: requestHandler,
                          expectation: expectation1)
    }
    
    private func handleOfflineRequestWithFailure(requestGenerator: (RequestHandlerProtocol) -> Pending<SendRequestValue, SendRequestError>,
                                                  path: String,
                                                  bodyDict: [AnyHashable: Any]) {
        let notificationCenter = MockNotificationCenter()
        let networkSession = MockNetworkSession(statusCode: 400)
        networkSession.requestCallback = { request in
            TestUtils.validate(request: request, apiEndPoint: Endpoint.api, path: path)
            var requestBody = request.bodyDict
            requestBody.removeValue(forKey: "createdAt")
            XCTAssertTrue(TestUtils.areEqual(dict1: bodyDict, dict2: requestBody))
        }
        let requestHandler = createRequestHandler(networkSession: networkSession,
                                                  notificationCenter: notificationCenter,
                                                  selectOffline: true)
        let request = { requestGenerator(requestHandler) }
        let expectation1 = expectation(description: #function)
        handleRequestWithFailure(request: request,
                                  networkSession: networkSession,
                                  path: path,
                                  bodyDict: bodyDict,
                                  expectation: expectation1)
        waitForTaskRunner(requestHandler: requestHandler,
                          expectation: expectation1)
    }
    
    private func createRequestHandler(networkSession: NetworkSessionProtocol,
                                      notificationCenter: NotificationCenterProtocol,
                                      selectOffline: Bool) -> RequestHandlerProtocol {
        let healthMonitor = HealthMonitor(dataProvider: HealthMonitorDataProvider(maxTasks: 1000,
                                                                                  persistenceContextProvider: persistenceContextProvider),
                                          dateProvider: dateProvider,
                                          networkSession: networkSession)
        let taskScheduler = IterableTaskScheduler(persistenceContextProvider: persistenceContextProvider,
                                                  notificationCenter: notificationCenter,
                                                  healthMonitor: healthMonitor,
                                                  dateProvider: dateProvider)
        let taskRunner = IterableTaskRunner(networkSession: networkSession,
                                            persistenceContextProvider: persistenceContextProvider,
                                            healthMonitor: healthMonitor,
                                            notificationCenter: notificationCenter,
                                            timeInterval: 0.5,
                                            dateProvider: dateProvider)
        
        let onlineProcessor = OnlineRequestProcessor(apiKey: "zee-api-key",
                                                     authProvider: self,
                                                     authManager: nil,
                                                     endpoint: Endpoint.api,
                                                     networkSession: networkSession,
                                                     deviceMetadata: Self.deviceMetadata,
                                                     dateProvider: self.dateProvider)
        let offlineProcessor = OfflineRequestProcessor(apiKey: "zee-api-key",
                                                       authProvider: self,
                                                       authManager: nil,
                                                       endpoint: Endpoint.api,
                                                       deviceMetadata: Self.deviceMetadata,
                                                       taskScheduler: taskScheduler,
                                                       taskRunner: taskRunner,
                                                       notificationCenter: notificationCenter)
        
        return RequestHandler(onlineProcessor: onlineProcessor,
                              offlineProcessor: offlineProcessor,
                              healthMonitor: healthMonitor,
                              offlineMode: selectOffline)
    }
    
    private func handleRequestWithSuccess(request: () -> Pending<SendRequestValue, SendRequestError>,
                                           networkSession: MockNetworkSession,
                                           path: String,
                                           bodyDict: [AnyHashable: Any],
                                           expectation: XCTestExpectation) {
        networkSession.requestCallback = { request in
            TestUtils.validate(request: request, apiEndPoint: Endpoint.api, path: path)
            var requestBody = request.bodyDict
            requestBody.removeValue(forKey: "createdAt")
            XCTAssertTrue(TestUtils.areEqual(dict1: bodyDict, dict2: requestBody))
        }
        
        request().onSuccess { json in
            expectation.fulfill()
        }.onError { error in
            XCTFail()
        }
    }
    
    private func handleRequestWithFailure(request: () -> Pending<SendRequestValue, SendRequestError>,
                                           networkSession: MockNetworkSession,
                                           path: String,
                                           bodyDict: [AnyHashable: Any],
                                           expectation: XCTestExpectation) {
        networkSession.requestCallback = { request in
            TestUtils.validate(request: request, apiEndPoint: Endpoint.api, path: path)
            var requestBody = request.bodyDict
            requestBody.removeValue(forKey: "createdAt")
            XCTAssertTrue(TestUtils.areEqual(dict1: bodyDict, dict2: requestBody))
        }
        request().onSuccess { json in
            XCTFail()
        }.onError { error in
            expectation.fulfill()
        }
    }
    
    private func waitForTaskRunner(requestHandler: RequestHandlerProtocol,
                                   expectation: XCTestExpectation) {
        requestHandler.start()
        wait(for: [expectation], timeout: testExpectationTimeout)
        requestHandler.stop()
    }
    
    struct Exp {
        let successExpectation: XCTestExpectation
        let onSuccess: OnSuccessHandler
        let failureExpectation: XCTestExpectation
        let onFailure: OnFailureHandler
    }
    
    private func createExpectations(description: String) -> Exp {
        let (successExpectation, onSuccess) = createSuccessExpectation(description: "success: \(description)")
        let (failureExpectation, onFailure) = createFailureExpectation(description: "failure: \(description)")
        return Exp(successExpectation: successExpectation,
                   onSuccess: onSuccess,
                   failureExpectation: failureExpectation,
                   onFailure: onFailure)
    }
    
    private func createSuccessExpectation(description: String) -> (XCTestExpectation, OnSuccessHandler) {
        let expectation1 = expectation(description: description)
        expectation1.expectedFulfillmentCount = 2
        let onSuccess: OnSuccessHandler = { _ in
            expectation1.fulfill()
        }
        return (expectation: expectation1, onSuccess: onSuccess)
    }
    
    private func createFailureExpectation(description: String) -> (XCTestExpectation, OnFailureHandler) {
        let expectation1 = expectation(description: description)
        expectation1.expectedFulfillmentCount = 2
        let onFailure: OnFailureHandler = { _, _ in
            expectation1.fulfill()
        }
        return (expectation: expectation1, onFailure: onFailure)
    }
    
    private static let deviceMetadata = DeviceMetadata(deviceId: IterableUtil.generateUUID(),
                                                       platform: JsonValue.iOS,
                                                       appPackageName: Bundle.main.appPackageName ?? "")
    
    private let dateProvider = MockDateProvider()
    
    private lazy var persistenceContextProvider: IterablePersistenceContextProvider = {
        let provider = CoreDataPersistenceContextProvider(dateProvider: dateProvider)!
        return provider
    }()
}

extension RequestHandlerTests: AuthProvider {
    var auth: Auth {
        Auth(userId: nil, email: "user@example.com", authToken: nil, userIdAnon: nil)
    }
}

fileprivate extension MockNetworkSession {
    convenience init(statusCode: Int, urlPatternDataMapping: [String: Data?]?) {
        let mapping = urlPatternDataMapping?.mapValues { data in
            MockNetworkSession.MockResponse(statusCode: statusCode,
                                            data: data,
                                            delay: 0.0,
                                            error: nil)
        }
        self.init(mapping: mapping)
    }
}
