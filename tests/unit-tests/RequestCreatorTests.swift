//
//  Copyright © 2019 Iterable. All rights reserved.
//

import XCTest

@testable import IterableSDK

class RequestCreatorTests: XCTestCase {
    func testTrackInboxSession() {
        let inboxSessionId = IterableUtil.generateUUID()
        let startDate = Date()
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
        let urlRequest = convertToUrlRequest(createRequestCreator().createTrackInboxSessionRequest(inboxSession: inboxSession))
        TestUtils.validateHeader(urlRequest, apiKey)
        TestUtils.validate(request: urlRequest, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.trackInboxSession)
        
        let body = urlRequest.bodyDict
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.email), value: auth.email, inDictionary: body)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.inboxSessionId), value: inboxSession.id, inDictionary: body)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.inboxSessionStart), value: IterableUtil.int(fromDate: startDate), inDictionary: body)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.inboxSessionEnd), value: IterableUtil.int(fromDate: endDate), inDictionary: body)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.startTotalMessageCount), value: inboxSession.startTotalMessageCount, inDictionary: body)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.startUnreadMessageCount), value: inboxSession.startUnreadMessageCount, inDictionary: body)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.endTotalMessageCount), value: inboxSession.endTotalMessageCount, inDictionary: body)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.endUnreadMessageCount), value: inboxSession.endUnreadMessageCount, inDictionary: body)
        
        TestUtils.validateDeviceInfo(inBody: body, withDeviceId: deviceMetadata.deviceId)
        
        validateImpressions(impressions, inBody: body)
    }
    
    func testTrackInAppOpenRequest() {
        let messageId = "rsj5ktry6hm"
        let campaignId = 3562
        let inboxSessionId = "9fn38m945ug9r8th"
        let location = InAppLocation.inbox
        let locValue = location.jsonValue as! String
        
        let message = IterableInAppMessage(messageId: messageId, campaignId: campaignId as NSNumber, content: getEmptyInAppContent())
        
        let messageContext1 = InAppMessageContext.from(message: message, location: location, inboxSessionId: inboxSessionId)
        let request1 = convertToUrlRequest(createRequestCreator().createTrackInAppOpenRequest(inAppMessageContext: messageContext1))
        TestUtils.validateHeader(request1, apiKey)
        TestUtils.validate(request: request1, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.trackInAppOpen)
        
        let body1 = request1.bodyDict
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.email), value: email, inDictionary: body1)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.messageId), value: messageId, inDictionary: body1)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.inboxSessionId), value: inboxSessionId, inDictionary: body1)
        TestUtils.validateMatch(keyPath: KeyPath(string: locationKeyPath), value: locValue, inDictionary: body1)
        
        let messageContext2 = InAppMessageContext.from(message: message, location: location)
        let request2 = convertToUrlRequest(createRequestCreator().createTrackInAppOpenRequest(inAppMessageContext: messageContext2))
        TestUtils.validateHeader(request2, apiKey)
        TestUtils.validate(request: request2, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.trackInAppOpen)
        
        let body2 = request2.bodyDict
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.email), value: email, inDictionary: body2)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.messageId), value: messageId, inDictionary: body2)
        TestUtils.validateNil(keyPath: KeyPath(keys: JsonKey.inboxSessionId), inDictionary: body2)
        TestUtils.validateMatch(keyPath: KeyPath(string: locationKeyPath), value: locValue, inDictionary: body2)
    }
    
    func testTrackInAppClickRequest() {
        let messageId = "rsj5ktry6hm"
        let campaignId = 3562
        let inboxSessionId = "9fn38m945ug9r8th"
        let clickedUrl = "https://github.com/"
        let inboxLoc = InAppLocation.inbox
        let inboxLocValue = inboxLoc.jsonValue as! String
        
        let message = IterableInAppMessage(messageId: messageId, campaignId: campaignId as NSNumber, content: getEmptyInAppContent())
        
        let messageContext1 = InAppMessageContext.from(message: message, location: inboxLoc, inboxSessionId: inboxSessionId)
        let request1 = convertToUrlRequest(createRequestCreator().createTrackInAppClickRequest(inAppMessageContext: messageContext1, clickedUrl: clickedUrl))
        TestUtils.validateHeader(request1, apiKey)
        TestUtils.validate(request: request1, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.trackInAppClick)
        
        let body1 = request1.bodyDict
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.email), value: email, inDictionary: body1)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.messageId), value: messageId, inDictionary: body1)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.inboxSessionId), value: inboxSessionId, inDictionary: body1)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.clickedUrl), value: clickedUrl, inDictionary: body1)
        TestUtils.validateMatch(keyPath: KeyPath(string: locationKeyPath), value: inboxLocValue, inDictionary: body1)
        
        let messageContext2 = InAppMessageContext.from(message: message, location: inboxLoc)
        let request2 = convertToUrlRequest(createRequestCreator().createTrackInAppClickRequest(inAppMessageContext: messageContext2, clickedUrl: clickedUrl))
        TestUtils.validateHeader(request2, apiKey)
        TestUtils.validate(request: request2, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.trackInAppClick)
        
        let body2 = request2.bodyDict
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.email), value: email, inDictionary: body2)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.messageId), value: messageId, inDictionary: body2)
        TestUtils.validateNil(keyPath: KeyPath(keys: JsonKey.inboxSessionId), inDictionary: body2)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.clickedUrl), value: clickedUrl, inDictionary: body2)
        TestUtils.validateMatch(keyPath: KeyPath(string: locationKeyPath), value: inboxLocValue, inDictionary: body2)
    }
    
    func testTrackInAppCloseRequest() {
        let messageId = "rsj5ktry6hm"
        let campaignId = 3562
        let inboxSessionId = "9fn38m945ug9r8th"
        let clickedUrl = "https://github.com/"
        
        let inAppLoc = InAppLocation.inApp
        let inboxLoc = InAppLocation.inbox
        let inAppLocValue = inAppLoc.jsonValue as! String
        let inboxLocValue = inboxLoc.jsonValue as! String
        
        let message = IterableInAppMessage(messageId: messageId, campaignId: campaignId as NSNumber, content: getEmptyInAppContent())
        
        let messageContext1 = InAppMessageContext.from(message: message, location: inboxLoc, inboxSessionId: inboxSessionId)
        let request1 = convertToUrlRequest(createRequestCreator().createTrackInAppCloseRequest(inAppMessageContext: messageContext1, source: .back, clickedUrl: clickedUrl))
        TestUtils.validateHeader(request1, apiKey)
        TestUtils.validate(request: request1, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.trackInAppClose)
        
        let body1 = request1.bodyDict
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.email), value: email, inDictionary: body1)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.messageId), value: messageId, inDictionary: body1)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.inboxSessionId), value: inboxSessionId, inDictionary: body1)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.clickedUrl), value: clickedUrl, inDictionary: body1)
        TestUtils.validateMatch(keyPath: KeyPath(string: locationKeyPath), value: inboxLocValue, inDictionary: body1)
        
        let messageContext2 = InAppMessageContext.from(message: message, location: inAppLoc)
        let request2 = convertToUrlRequest(createRequestCreator().createTrackInAppCloseRequest(inAppMessageContext: messageContext2, source: .link, clickedUrl: nil))
        TestUtils.validateHeader(request2, apiKey)
        TestUtils.validate(request: request2, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.trackInAppClose)
        
        let body2 = request2.bodyDict
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.email), value: email, inDictionary: body2)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.messageId), value: messageId, inDictionary: body2)
        TestUtils.validateNil(keyPath: KeyPath(keys: JsonKey.inboxSessionId), inDictionary: body2)
        TestUtils.validateNil(keyPath: KeyPath(keys: JsonKey.clickedUrl), inDictionary: body2)
        TestUtils.validateMatch(keyPath: KeyPath(string: locationKeyPath), value: inAppLocValue, inDictionary: body2)
    }
    
    func testGetInAppMessagesRequestFailure() {
        let auth = Auth(userId: nil, email: nil, authToken: nil, userIdAnon: nil)
        let requestCreator = RequestCreator(auth: auth, deviceMetadata: deviceMetadata)
        
        let failingRequest = requestCreator.createGetInAppMessagesRequest(1)
        
        if let _ = try? failingRequest.get() {
            XCTFail("request succeeded despite userId and email being nil")
        }
    }
    
    func testGetInAppMessagesRequest() {
        let inAppMessageRequestCount: NSNumber = 42
        
        let request = createRequestCreator().createGetInAppMessagesRequest(inAppMessageRequestCount)
        let urlRequest = convertToUrlRequest(request)
        
        TestUtils.validateHeader(urlRequest, apiKey)
        TestUtils.validate(request: urlRequest, requestType: .get, apiEndPoint: Endpoint.api, path: Const.Path.getInAppMessages)
        
        guard case let .success(.get(getRequest)) = request, let args = getRequest.args else {
            XCTFail("could not unwrap to a get request and its arguments")
            return
        }
        
        XCTAssertEqual(args[JsonKey.email], auth.email)
        XCTAssertEqual(args[JsonKey.InApp.packageName], Bundle.main.appPackageName)
        XCTAssertEqual(args[JsonKey.InApp.count], inAppMessageRequestCount.stringValue)
        XCTAssertEqual(args[JsonKey.systemVersion], UIDevice.current.systemVersion)
    }
    
    func testTrackEventRequest() {
        let eventName = "dsfsdf"
        
        let request = convertToUrlRequest(createRequestCreator().createTrackEventRequest(eventName, dataFields: nil))
        
        TestUtils.validateHeader(request, apiKey)
        TestUtils.validate(request: request, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.trackEvent)
        
        let body = request.bodyDict
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.eventName), value: eventName, inDictionary: body)
        TestUtils.validateNil(keyPath: KeyPath(keys: JsonKey.dataFields), inDictionary: body)
    }
    
    func testTrackInAppDeliveryRequest() {
        let messageId = IterableUtil.generateUUID()
        let campaignId = TestHelper.generateIntGuid()
        
        let message = IterableInAppMessage(messageId: messageId, campaignId: campaignId as NSNumber, content: getEmptyInAppContent())
        let messageContext = InAppMessageContext.from(message: message, location: nil)
        let request = convertToUrlRequest(createRequestCreator().createTrackInAppDeliveryRequest(inAppMessageContext: messageContext))
        
        TestUtils.validateHeader(request, apiKey)
        TestUtils.validate(request: request, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.trackInAppDelivery)
        
        let body = request.bodyDict
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.email), value: email, inDictionary: body)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.messageId), value: messageId, inDictionary: body)
        TestUtils.validateDeviceInfo(inBody: body, withDeviceId: deviceMetadata.deviceId)
    }
    
    func testTrackInAppConsumeRequest() {
        let messageId = IterableUtil.generateUUID()
        
        let request = convertToUrlRequest(createRequestCreator().createInAppConsumeRequest(messageId))
        
        TestUtils.validateHeader(request, apiKey)
        TestUtils.validate(request: request, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.inAppConsume)
        
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.messageId), value: messageId, inDictionary: request.bodyDict)
    }
    
    func testUpdateSubscriptionsRequest() {
        let emailListIds = [NSNumber(value: 382), NSNumber(value: 517)]
        let unsubscriptedChannelIds = [NSNumber(value: 7845), NSNumber(value: 1048)]
        let unsubscribedMessageTypeIds = [NSNumber(value: 5671), NSNumber(value: 9087)]
        let subscribedMessageTypeIds = [NSNumber(value: 8923), NSNumber(value: 2940)]
        let campaignId = NSNumber(value: 23)
        let templateId = NSNumber(value: 10)
        
        let request = convertToUrlRequest(createRequestCreator().createUpdateSubscriptionsRequest(emailListIds,
                                                                                                  unsubscribedChannelIds: unsubscriptedChannelIds,
                                                                                                  unsubscribedMessageTypeIds: unsubscribedMessageTypeIds,
                                                                                                  subscribedMessageTypeIds: subscribedMessageTypeIds,
                                                                                                  campaignId: campaignId,
                                                                                                  templateId: templateId))
        
        TestUtils.validateHeader(request, apiKey)
        TestUtils.validate(request: request, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.updateSubscriptions)
        
        let body = request.bodyDict
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.emailListIds), value: emailListIds, inDictionary: body)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.unsubscribedChannelIds), value: unsubscriptedChannelIds, inDictionary: body)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.unsubscribedMessageTypeIds), value: unsubscribedMessageTypeIds, inDictionary: body)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.subscribedMessageTypeIds), value: subscribedMessageTypeIds, inDictionary: body)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.campaignId), value: campaignId, inDictionary: body)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.templateId), value: templateId, inDictionary: body)
    }
    
    func testUserlessUpdateUserRequest() {
        let userlessRequestCreator = RequestCreator(auth: userlessAuth,
                                                    deviceMetadata: deviceMetadata)
        
        let result = userlessRequestCreator.createUpdateUserRequest(dataFields: [:], mergeNestedObjects: false)
        
        switch result {
        case .success(_):
            XCTFail("request shouldn't have succeeded")
        case .failure(let error):
            XCTAssertEqual(error.errorDescription, "Both email and userId are nil")
        }
    }
    
    func testUserlessUpdateSubscriptionsRequest() {
        let userlessRequestCreator = RequestCreator(auth: userlessAuth,
                                                    deviceMetadata: deviceMetadata)
        
        let result = userlessRequestCreator.createUpdateSubscriptionsRequest()
        
        switch result {
        case .success(_):
            XCTFail("request shouldn't have succeeded")
        case .failure(let error):
            XCTAssertEqual(error.errorDescription, "Both email and userId are nil")
        }
    }
    
    func testUserlessTrackInboxSessionRequest() {
        let userlessRequestCreator = RequestCreator(auth: userlessAuth,
                                                    deviceMetadata: deviceMetadata)
        
        let result = userlessRequestCreator.createTrackInboxSessionRequest(inboxSession: IterableInboxSession())
        
        switch result {
        case .success(_):
            XCTFail("request shouldn't have succeeded")
        case .failure(let error):
            XCTAssertEqual(error.errorDescription, "Both email and userId are nil")
        }
    }
    
    func testFaultyTrackInboxSessionRequest() {
        let condition1 = expectation(description: "no inbox session ID")
        let condition2 = expectation(description: "no inbox session start date")
        let condition3 = expectation(description: "no inbox session end date")
        
        func createResultWithInboxSession(_ inboxSession: IterableInboxSession) -> Result<IterableRequest, IterableError> {
            return createRequestCreator().createTrackInboxSessionRequest(inboxSession: inboxSession)
        }
        
        let inboxSessions = [IterableInboxSession(id: nil, sessionStartTime: Date(), sessionEndTime: Date()),
                             IterableInboxSession(id: "", sessionStartTime: Date(), sessionEndTime: nil),
                             IterableInboxSession(id: "", sessionStartTime: nil, sessionEndTime: Date())]
        
        for inboxSession in inboxSessions {
            switch createResultWithInboxSession(inboxSession) {
            case .success(_):
                XCTFail("request shouldn't have succeeded")
            case .failure(let error):
                if error.errorDescription == "expecting session UUID" {
                    condition1.fulfill()
                } else if error.errorDescription == "expecting session start time" {
                    condition2.fulfill()
                } else if error.errorDescription == "expecting session end time" {
                    condition3.fulfill()
                }
            }
        }
        
        wait(for: [condition1, condition2, condition3], timeout: testExpectationTimeout)
    }
    
    func testRegisterTokenRequestPrefersUserId() {
        let userIdRequestCreator = RequestCreator(auth: userIdAuth,
                                                  deviceMetadata: deviceMetadata)
        
        let registerTokenInfo = RegisterTokenInfo(hexToken: "hex-token",
                                                  appName: "tester",
                                                  pushServicePlatform: .auto,
                                                  apnsType: .production,
                                                  deviceId: IterableUtil.generateUUID(),
                                                  deviceAttributes: [:],
                                                  sdkVersion: nil)
        
        let urlRequest = convertToUrlRequest(userIdRequestCreator.createRegisterTokenRequest(registerTokenInfo: registerTokenInfo,
                                                                                             notificationsEnabled: true))
        TestUtils.validateHeader(urlRequest, apiKey)
        TestUtils.validate(request: urlRequest, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.registerDeviceToken)
        
        let body = urlRequest.bodyDict
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.userId), value: userIdAuth.userId, inDictionary: body)
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.preferUserId), value: true, inDictionary: body)
    }
    
    func testProcessorTypeOfflineInHeader() throws {
        let eventName = "dsfsdf"
        
        let iterableRequest = try createRequestCreator().createTrackEventRequest(eventName, dataFields: nil).get()
        let apiCallRequest = IterableAPICallRequest(apiKey: apiKey,
                                                    endpoint: Endpoint.api,
                                                    authToken: nil,
                                                    deviceMetadata: deviceMetadata,
                                                    iterableRequest: iterableRequest)
        
        let request = apiCallRequest.convertToURLRequest(sentAt: dateProvider.currentDate, processorType: .offline)!
        
        TestUtils.validateHeader(request, apiKey, processorType: .offline)
        TestUtils.validate(request: request, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.trackEvent)
        
        let body = request.bodyDict
        TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.eventName), value: eventName, inDictionary: body)
        TestUtils.validateNil(keyPath: KeyPath(keys: JsonKey.dataFields), inDictionary: body)
    }

    private let apiKey = "zee-api-key"
    
    private let email = "user@example.com"
    
    private let locationKeyPath = "\(JsonKey.inAppMessageContext).\(JsonKey.inAppLocation)"
    
    private let userlessAuth = Auth(userId: nil, email: nil, authToken: nil, userIdAnon: nil)
    
    private let userIdAuth = Auth(userId: "ein", email: nil, authToken: nil, userIdAnon: nil)
    
    private let deviceMetadata = DeviceMetadata(deviceId: IterableUtil.generateUUID(),
                                                platform: JsonValue.iOS,
                                                appPackageName: Bundle.main.appPackageName ?? "")
    private let dateProvider = MockDateProvider()
    
    private func validateImpressions(_ impressions: [IterableInboxImpression], inBody body: [String: Any]) {
        guard let impressionsFromBody = body["impressions"] as? [[String: Any]] else {
            XCTFail("Could not find impressions element")
            return
        }
        
        XCTAssertEqual(impressionsFromBody.count, impressions.count)
        impressions.forEach {
            validateImpression($0, impressionsFromBody: impressionsFromBody)
        }
    }
    
    private func validateImpression(_ impression: IterableInboxImpression, impressionsFromBody: [[String: Any]]) {
        guard let matchedImpression = impressionsFromBody.first(where: { impression.messageId == $0["messageId"] as? String }) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(matchedImpression["silentInbox"] as? Bool, impression.silentInbox)
        XCTAssertEqual(matchedImpression["displayCount"] as? Int, impression.displayCount)
        XCTAssertEqual(matchedImpression["displayDuration"] as? TimeInterval, impression.displayDuration)
    }
    
    private func convertToUrlRequest(_ requestCreationResult: Result<IterableRequest, IterableError>) -> URLRequest {
        if case let Result.success(iterableRequest) = requestCreationResult {
            return createApiClient(networkSession: MockNetworkSession(statusCode: 200)).convertToURLRequest(iterableRequest: iterableRequest)!
        } else {
            fatalError()
        }
    }
    
    private func createRequestCreator() -> RequestCreator {
        RequestCreator(auth: auth, deviceMetadata: deviceMetadata)
    }
    
    private func createApiClient(networkSession: NetworkSessionProtocol) -> ApiClient {
        ApiClient(apiKey: apiKey,
                  authProvider: self,
                  endpoint: Endpoint.api,
                  networkSession: networkSession,
                  deviceMetadata: deviceMetadata,
                  dateProvider: dateProvider)
    }
    
    private func getEmptyInAppContent() -> IterableHtmlInAppContent {
        IterableHtmlInAppContent(edgeInsets: .zero, html: "")
    }
}

extension RequestCreatorTests: AuthProvider {
    var auth: Auth {
        Auth(userId: nil, email: email, authToken: nil, userIdAnon: nil)
    }
}
