//
//  Copyright © 2018 Iterable. All rights reserved.
//

import UserNotifications
import XCTest

@testable import IterableSDK

class IterableAPITests: XCTestCase {
    private static let apiKey = "zeeApiKey"
    private static let email = "user@example.com"
    private static let userId = "testUserId"
    private static let apiEndPointUS = "https://api.iterable.com/api/"
    private static let apiEndPointEU = "https://api.eu.iterable.com/api/"
    
    override func setUp() {
        super.setUp()
    }
    
    func testInitialize() {
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey)
        
        XCTAssertEqual(internalAPI.apiKey, IterableAPITests.apiKey)
    }
    
    func testInitializeWithConfig() {
        let prodIntegrationName = "the-best-app-ever"
        
        let config = IterableConfig()
        config.pushIntegrationName = prodIntegrationName
        config.inAppDisplayInterval = 1.0
        
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config)
        
        XCTAssertEqual(internalAPI.apiKey, IterableAPITests.apiKey)
    }
    
    func testInitializeWithDefaultDataRegion() {
        let prodIntegrationName = "the-best-app-ever"

        let config = IterableConfig()
        config.pushIntegrationName = prodIntegrationName
        config.inAppDisplayInterval = 1.0
        config.dataRegion = IterableDataRegion.US

        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config)

        XCTAssertEqual(internalAPI.apiEndPointForTest, IterableAPITests.apiEndPointUS)
    }
    
    func testInitializeWithEUDataRegion() {
        let prodIntegrationName = "the-best-app-ever"

        let config = IterableConfig()
        config.pushIntegrationName = prodIntegrationName
        config.inAppDisplayInterval = 1.0
        config.dataRegion = IterableDataRegion.EU

        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config)

        XCTAssertEqual(internalAPI.apiEndPointForTest, IterableAPITests.apiEndPointEU)
    }
    
    func testInitializeCheckEndpoint() {
        let expectation1 = XCTestExpectation(description: "api endpoint called")
        
        let mockNetworkSession = MockNetworkSession()
        mockNetworkSession.requestCallback = { urlRequest in
            if let url = urlRequest.url {
                if url.absoluteString.starts(with: Endpoint.api) {
                    expectation1.fulfill()
                }
            }
        }
        
        let config = IterableConfig()
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: mockNetworkSession)
        internalAPI.email = IterableAPITests.email
        internalAPI.track("Some Event")
        
        XCTAssertEqual(internalAPI.apiKey, IterableAPITests.apiKey)
        
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    func testInitializeWithNewEndpoint() {
        let expectation1 = XCTestExpectation(description: "new api endpoint called")
        
        let newApiEndpoint = "https://test.iterable.com/api/"
        
        let mockNetworkSession = MockNetworkSession()
        mockNetworkSession.requestCallback = { urlRequest in
            if let url = urlRequest.url {
                if url.absoluteString.starts(with: newApiEndpoint) {
                    expectation1.fulfill()
                }
            }
        }
        
        let config = IterableConfig()
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey,
                                                                   config: config,
                                                                   apiEndPointOverride: newApiEndpoint,
                                                                   networkSession: mockNetworkSession)
        internalAPI.email = IterableAPITests.email
        internalAPI.track("Some Event")
        
        XCTAssertEqual(internalAPI.apiKey, IterableAPITests.apiKey)
        
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    func testTrackEventWithNoEmailOrUser() {
        let eventName = "MyCustomEvent"
        let networkSession = MockNetworkSession(statusCode: 200)
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, networkSession: networkSession)
        internalAPI.email = nil
        internalAPI.userId = nil
        internalAPI.track(eventName)
        XCTAssertNil(networkSession.getRequest(withEndPoint: Const.Path.trackEvent))
    }
    
    func testTrackEventWithEmail() {
        let expectation = XCTestExpectation(description: "testTrackEventWithEmail")
        
        let eventName = "MyCustomEvent"
        let networkSession = MockNetworkSession(statusCode: 200)
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, networkSession: networkSession)
        internalAPI.email = IterableAPITests.email

        internalAPI.track(eventName, dataFields: nil, onSuccess: { _ in
            let request = networkSession.getRequest(withEndPoint: Const.Path.trackEvent)!
            TestUtils.validate(request: request, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.trackEvent, queryParams: [])
            let body = request.httpBody!.json() as! [String: Any]
            TestUtils.validateElementPresent(withName: JsonKey.eventName, andValue: eventName, inDictionary: body)
            TestUtils.validateElementPresent(withName: JsonKey.email, andValue: IterableAPITests.email, inDictionary: body)
            expectation.fulfill()
        }) { reason, _ in
            expectation.fulfill()
            if let reason = reason {
                XCTFail("encountered error: \(reason)")
            } else {
                XCTFail("encountered error")
            }
        }
        
        wait(for: [expectation], timeout: testExpectationTimeout)
    }
    
    // without callback
    func testTrackEventWithEmail2() {
        let expectation = XCTestExpectation(description: "testTrackEventWithEmail using no callback")
        let eventName = "MyCustomEvent"
        let networkSession = MockNetworkSession(statusCode: 200)
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, networkSession: networkSession)
        internalAPI.email = IterableAPITests.email
        internalAPI.track(eventName, dataFields: ["key1": "value1", "key2": "value2"])
        
        networkSession.callback = { _, response, _ in
            guard let (request, body) = TestUtils.matchingRequest(networkSession: networkSession,
                                                                  response: response,
                                                                  endPoint: Const.Path.trackEvent) else {
                return
            }
            TestUtils.validate(request: request, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.trackEvent, queryParams: [])
            TestUtils.validateElementPresent(withName: JsonKey.eventName, andValue: eventName, inDictionary: body)
            TestUtils.validateElementPresent(withName: JsonKey.email, andValue: IterableAPITests.email, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "dataFields"), value: ["key1": "value1", "key2": "value2"], inDictionary: body, message: "data fields did not match")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: testExpectationTimeout)
    }
    
    func testTrackEventBadNetwork() {
        let expectation = XCTestExpectation(description: "testTrackEventBadNetwork")
        
        let eventName = "MyCustomEvent"
        let networkSession = MockNetworkSession(statusCode: 502)
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, networkSession: networkSession)
        internalAPI.email = "user@example.com"
        internalAPI.track(
            eventName,
            dataFields: nil,
            onSuccess: { _ in
                // fail on success
                expectation.fulfill()
                XCTFail("did not expect success")
            },
            onFailure: { _, _ in expectation.fulfill() }
        )
        
        wait(for: [expectation], timeout: testExpectationTimeout)
    }

    func testSetEmailWithCallbackSuccess() {
        let expectation = XCTestExpectation(description: "Set email with callback success")

        let config = IterableConfig()
        let networkSession = MockNetworkSession(statusCode: 200)
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
                
        internalAPI.setEmail("test@example.com", successHandler: { success in
            XCTAssertNotNil(success)
            expectation.fulfill()
        }, failureHandler: { _, _ in
            XCTFail("Failed to set email")
            expectation.fulfill()
        })
        internalAPI.register(token: "zeeToken".data(using: .utf8)!)
        wait(for: [expectation], timeout: testExpectationTimeout)
    }

    func testSetEmailWithCallbackFailure() {
        let expectation = XCTestExpectation(description: "Set email with callback failure")
        
        let config = IterableConfig()
        let networkSession = MockNetworkSession(statusCode: 400)
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)

        internalAPI.setEmail("invalid_email", successHandler: { success in
            XCTFail("Email should not be set successfully")
            expectation.fulfill()
        }, failureHandler: { _, error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        })
        internalAPI.register(token: "zeeToken".data(using: .utf8)!)
        wait(for: [expectation], timeout: testExpectationTimeout)
    }

    func testSetUserIdWithCallbackSuccess() {
        let expectation = XCTestExpectation(description: "Set user ID with callback success")
        
        let config = IterableConfig()
        let networkSession = MockNetworkSession(statusCode: 200)
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        
        internalAPI.setUserId("user123", successHandler: { success in
            XCTAssertNotNil(success)
            expectation.fulfill()
        }, failureHandler: { _, _ in
            XCTFail("Failed to set user ID")
            expectation.fulfill()
        })
        internalAPI.register(token: "zeeToken".data(using: .utf8)!)
        wait(for: [expectation], timeout: testExpectationTimeout)
    }

    func testSetUserIdWithCallbackFailure() {
        let expectation = XCTestExpectation(description: "Set user ID with callback failure")
        
        let config = IterableConfig()
        let networkSession = MockNetworkSession(statusCode: 400)
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        
        internalAPI.setUserId("user123", successHandler: { success in
            XCTFail("User ID should not be set successfully")
            expectation.fulfill()
        }, failureHandler: { _, error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        })
        internalAPI.register(token: "zeeToken".data(using: .utf8)!)
        wait(for: [expectation], timeout: testExpectationTimeout)
    }
    
    func testEmailPersistence() {
        let internalAPI = InternalIterableAPI.initializeForTesting()
        
        internalAPI.email = IterableAPITests.email
        XCTAssertEqual(internalAPI.email, IterableAPITests.email)
        XCTAssertNil(internalAPI.userId)
    }
    
    func testUserIdPersistence() {
        let internalAPI = InternalIterableAPI.initializeForTesting()
        
        internalAPI.userId = IterableAPITests.userId
        XCTAssertEqual(internalAPI.userId, IterableAPITests.userId)
        XCTAssertNil(internalAPI.email)
    }
    
    func testUpdateUserWithEmail() {
        let expectation = XCTestExpectation(description: "testUpdateUserWithEmail")
        
        let networkSession = MockNetworkSession()
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, networkSession: networkSession)
        internalAPI.email = IterableAPITests.email
        let dataFields: [String: String] = ["var1": "val1", "var2": "val2"]
        internalAPI.updateUser(dataFields, mergeNestedObjects: true, onSuccess: { _ in
            guard let request = networkSession.getRequest(withEndPoint: Const.Path.updateUser) else {
                return
            }
            guard let body = TestUtils.getRequestBody(request: request) else {
                return
            }
            TestUtils.validate(request: request, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.updateUser, queryParams: [])
            TestUtils.validateElementPresent(withName: JsonKey.email, andValue: IterableAPITests.email, inDictionary: body)
            TestUtils.validateElementPresent(withName: JsonKey.mergeNestedObjects, andValue: true, inDictionary: body)
            TestUtils.validateElementPresent(withName: JsonKey.dataFields, andValue: dataFields, inDictionary: body)
            expectation.fulfill()
        }) { reason, _ in
            if let reason = reason {
                XCTFail("encountered error: \(reason)")
            } else {
                XCTFail("encountered error")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: testExpectationTimeout)
    }
    
    func testUpdateUserWithUserId() {
        let expectation = XCTestExpectation(description: "testUpdateUserWithUserId")
        
        let userId = UUID().uuidString
        let networkSession = MockNetworkSession()
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, networkSession: networkSession)
        internalAPI.userId = userId
        let dataFields: [String: String] = ["var1": "val1", "var2": "val2"]
        internalAPI.updateUser(dataFields, mergeNestedObjects: true, onSuccess: { _ in
            guard let request = networkSession.getRequest(withEndPoint: Const.Path.updateUser) else {
                return
            }
            guard let body = TestUtils.getRequestBody(request: request) else {
                return
            }
            TestUtils.validate(request: request, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.updateUser, queryParams: [])
            TestUtils.validateElementPresent(withName: JsonKey.userId, andValue: userId, inDictionary: body)
            TestUtils.validateElementPresent(withName: JsonKey.preferUserId, andValue: true, inDictionary: body)
            TestUtils.validateElementPresent(withName: JsonKey.mergeNestedObjects, andValue: true, inDictionary: body)
            TestUtils.validateElementPresent(withName: JsonKey.dataFields, andValue: dataFields, inDictionary: body)
            expectation.fulfill()
        }) { reason, _ in
            if let reason = reason {
                XCTFail("encountered error: \(reason)")
            } else {
                XCTFail("encountered error")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: testExpectationTimeout)
    }
    
    func testUpdateEmailWithEmail() {
        let expectation = XCTestExpectation(description: "testUpdateEmailWIthEmail")
        
        let newEmail = "new_user@example.com"
        let networkSession = MockNetworkSession(statusCode: 200)
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, networkSession: networkSession)
        internalAPI.email = IterableAPITests.email
        internalAPI.updateEmail(newEmail,
                                merge: true,
                                onSuccess: { _ in
                                    guard let request = networkSession.getRequest(withEndPoint: Const.Path.updateEmail) else {
                                        return
                                    }
                                    guard let body = TestUtils.getRequestBody(request: request) else {
                                        return
                                    }
                                    TestUtils.validate(request: request,
                                                       requestType: .post,
                                                       apiEndPoint: Endpoint.api,
                                                       path: Const.Path.updateEmail,
                                                       queryParams: [])
                                    TestUtils.validateElementPresent(withName: JsonKey.newEmail, andValue: newEmail, inDictionary: body)
                                    TestUtils.validateElementPresent(withName: JsonKey.currentEmail, andValue: IterableAPITests.email, inDictionary: body)
                                    XCTAssertEqual(internalAPI.email, newEmail)
                                    expectation.fulfill()
                                },
                                onFailure: { reason, _ in
                                    expectation.fulfill()
                                    if let reason = reason {
                                        XCTFail("encountered error: \(reason)")
                                    } else {
                                        XCTFail("encountered error")
                                    }
        })
        
        wait(for: [expectation], timeout: testExpectationTimeout)
    }
    
    func testUpdateEmailWithUserId() {
        let expectation = XCTestExpectation(description: "testUpdateEmailWithUserId")
        
        let currentUserId = IterableUtil.generateUUID()
        let newEmail = "new_user@example.com"
        let networkSession = MockNetworkSession(statusCode: 200)
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, networkSession: networkSession)
        internalAPI.userId = currentUserId
        internalAPI.updateEmail(newEmail,
                                merge: true,
                                onSuccess: { _ in
                                    guard let request = networkSession.getRequest(withEndPoint: Const.Path.updateEmail) else {
                                        return
                                    }
                                    guard let body = TestUtils.getRequestBody(request: request) else {
                                        return
                                    }
                                    TestUtils.validate(request: request,
                                                       requestType: .post,
                                                       apiEndPoint: Endpoint.api,
                                                       path: Const.Path.updateEmail,
                                                       queryParams: [])
                                    TestUtils.validateElementPresent(withName: JsonKey.newEmail, andValue: newEmail, inDictionary: body)
                                    TestUtils.validateElementPresent(withName: JsonKey.currentUserId, andValue: currentUserId, inDictionary: body)
                                    XCTAssertEqual(internalAPI.userId, currentUserId)
                                    XCTAssertNil(internalAPI.email)
                                    expectation.fulfill()
                                },
                                onFailure: { reason, _ in
                                    expectation.fulfill()
                                    if let reason = reason {
                                        XCTFail("encountered error: \(reason)")
                                    } else {
                                        XCTFail("encountered error")
                                    }
        })
        
        wait(for: [expectation], timeout: testExpectationTimeout)
    }

    func testUpdateEmailWithEmailWithoutMerge() {
        let expectation = XCTestExpectation(description: "testUpdateEmailWIthEmail")

        let newEmail = "new_user@example.com"
        let networkSession = MockNetworkSession(statusCode: 200)
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, networkSession: networkSession)
        internalAPI.email = IterableAPITests.email
        internalAPI.updateEmail(newEmail,
                                merge: nil,
                                onSuccess: { _ in
                                    guard let request = networkSession.getRequest(withEndPoint: Const.Path.updateEmail) else {
                                        return
                                    }
                                    guard let body = TestUtils.getRequestBody(request: request) else {
                                        return
                                    }
                                    TestUtils.validate(request: request,
                                                       requestType: .post,
                                                       apiEndPoint: Endpoint.api,
                                                       path: Const.Path.updateEmail,
                                                       queryParams: [])
                                    TestUtils.validateElementPresent(withName: JsonKey.newEmail, andValue: newEmail, inDictionary: body)
                                    TestUtils.validateElementPresent(withName: JsonKey.currentEmail, andValue: IterableAPITests.email, inDictionary: body)
                                    XCTAssertEqual(internalAPI.email, newEmail)
                                    expectation.fulfill()
                                },
                                onFailure: { reason, _ in
                                    expectation.fulfill()
                                    if let reason = reason {
                                        XCTFail("encountered error: \(reason)")
                                    } else {
                                        XCTFail("encountered error")
                                    }
        })

        wait(for: [expectation], timeout: testExpectationTimeout)
    }

    func testUpdateEmailWithUserIdWithoutMerge() {
        let expectation = XCTestExpectation(description: "testUpdateEmailWithUserId")

        let currentUserId = IterableUtil.generateUUID()
        let newEmail = "new_user@example.com"
        let networkSession = MockNetworkSession(statusCode: 200)
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, networkSession: networkSession)
        internalAPI.userId = currentUserId
        internalAPI.updateEmail(newEmail,
                                merge: nil,
                                onSuccess: { _ in
                                    guard let request = networkSession.getRequest(withEndPoint: Const.Path.updateEmail) else {
                                        return
                                    }
                                    guard let body = TestUtils.getRequestBody(request: request) else {
                                        return
                                    }
                                    TestUtils.validate(request: request,
                                                       requestType: .post,
                                                       apiEndPoint: Endpoint.api,
                                                       path: Const.Path.updateEmail,
                                                       queryParams: [])
                                    TestUtils.validateElementPresent(withName: JsonKey.newEmail, andValue: newEmail, inDictionary: body)
                                    TestUtils.validateElementPresent(withName: JsonKey.currentUserId, andValue: currentUserId, inDictionary: body)
                                    XCTAssertEqual(internalAPI.userId, currentUserId)
                                    XCTAssertNil(internalAPI.email)
                                    expectation.fulfill()
                                },
                                onFailure: { reason, _ in
                                    expectation.fulfill()
                                    if let reason = reason {
                                        XCTFail("encountered error: \(reason)")
                                    } else {
                                        XCTFail("encountered error")
                                    }
        })

        wait(for: [expectation], timeout: testExpectationTimeout)
    }

    func testRegisterTokenNilAppName() {
        let expectation = XCTestExpectation(description: "testRegisterToken")
        
        let config = IterableConfig()
        config.pushIntegrationName = nil
        config.sandboxPushIntegrationName = nil
        
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey,
                                                                   config: config,
                                                                   networkSession: MockNetworkSession(statusCode: 200))
        
        internalAPI.register(token: "zeeToken".data(using: .utf8)!, onSuccess: { _ in
            XCTFail("did not expect success here")
        }) { _, _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: testExpectationTimeoutForInverted)
    }
    
    func testRegisterTokenNilEmailAndUserId() {
        let expectation = XCTestExpectation(description: "testRegisterToken")
        
        let networkSession = MockNetworkSession(statusCode: 200)
        let config = IterableConfig()
        config.pushIntegrationName = "my-push-integration"
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        internalAPI.email = nil
        internalAPI.userId = nil
        
        internalAPI.register(token: "zeeToken".data(using: .utf8)!, onSuccess: { _ in
            XCTFail("did not expect success here")
        }) { _, _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: testExpectationTimeout)
    }
    
    func testRegisterToken() {
        let expectation = XCTestExpectation(description: "testRegisterToken")
        
        let networkSession = MockNetworkSession(statusCode: 200)
        let config = IterableConfig()
        config.pushIntegrationName = "my-push-integration"
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        internalAPI.email = "user@example.com"
        let token = "zeeToken".data(using: .utf8)!
        internalAPI.setDeviceAttribute(name: "reactNativeSDKVersion", value: "x.xx.xxx")
        let attributeToAddAndRemove = IterableUtil.generateUUID()
        internalAPI.setDeviceAttribute(name: attributeToAddAndRemove, value: "valueToAdd")
        internalAPI.removeDeviceAttribute(name: attributeToAddAndRemove)
        internalAPI.register(token: token, onSuccess: { _ in
            let request = networkSession.getRequest(withEndPoint: Const.Path.registerDeviceToken)!
            let body = request.httpBody!.json() as! [String: Any]
            
            TestUtils.validateElementPresent(withName: "email", andValue: "user@example.com", inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "device.applicationName"), value: "my-push-integration", inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "device.platform"), value: JsonValue.apnsSandbox, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "device.token"), value: token.hexString(), inDictionary: body)
            
            // more device fields
            let appPackageName = "iterable.host-app"
            let appVersion = "1.0.0"
            let appBuild = "2"
            TestUtils.validateExists(keyPath: KeyPath(string: "device.dataFields.deviceId"), type: String.self, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "device.dataFields.appPackageName"), value: appPackageName, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "device.dataFields.appVersion"), value: appVersion, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "device.dataFields.appBuild"), value: appBuild, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "device.dataFields.iterableSdkVersion"), value: IterableAPI.sdkVersion, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "device.dataFields.reactNativeSDKVersion"), value: "x.xx.xxx", inDictionary: body)
            TestUtils.validateNil(keyPath: KeyPath(string: "device.dataFields.\(attributeToAddAndRemove)"), inDictionary: body)
            
            expectation.fulfill()
        }) { reason, _ in
            // failure
            if let reason = reason {
                XCTFail("encountered error: \(reason)")
            } else {
                XCTFail("encountered error")
            }
        }
        
        wait(for: [expectation], timeout: testExpectationTimeout)
    }
    
    func testDisableDeviceNotRegistered() {
        let expectation = XCTestExpectation(description: "testDisableDevice")
        
        let networkSession = MockNetworkSession(statusCode: 200)
        let config = IterableConfig()
        config.pushIntegrationName = "my-push-integration"
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        internalAPI.email = "user@example.com"
        
        internalAPI.disableDeviceForCurrentUser(withOnSuccess: { _ in
            XCTFail("did not expect success here")
        }) { _, _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: testExpectationTimeoutForInverted)
    }
    
    func testDisableDeviceForCurrentUser() {
        let expectation = XCTestExpectation(description: "testDisableDeviceForCurrentUser")
        
        let networkSession = MockNetworkSession(statusCode: 200)
        let config = IterableConfig()
        config.pushIntegrationName = "my-push-integration"
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        internalAPI.email = "user@example.com"
        let token = "zeeToken".data(using: .utf8)!
        internalAPI.register(token: token)
        
        networkSession.callback = { _, response, _ in
            networkSession.callback = nil
            internalAPI.disableDeviceForCurrentUser(withOnSuccess: { _ in
                guard let request = networkSession.getRequest(withEndPoint: Const.Path.disableDevice) else {
                    return
                }
                
                guard let body = TestUtils.getRequestBody(request: request) else {
                    return
                }
                
                TestUtils.validate(request: request,
                                   requestType: .post,
                                   apiEndPoint: Endpoint.api,
                                   path: Const.Path.disableDevice,
                                   queryParams: [])
                
                TestUtils.validateElementPresent(withName: JsonKey.token, andValue: token.hexString(), inDictionary: body)
                TestUtils.validateElementPresent(withName: JsonKey.email, andValue: "user@example.com", inDictionary: body)
                
                expectation.fulfill()
            }) { _, _ in
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: testExpectationTimeout)
    }
    
    // Same test as above but without using success/failure callback
    func testDisableDeviceForCurrentUserWithoutCallback() {
        let expectation = XCTestExpectation(description: "testDisableDeviceForCurrentUserWithoutCallback")
        
        let networkSession = MockNetworkSession(statusCode: 200)
        let config = IterableConfig()
        config.pushIntegrationName = "my-push-integration"
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        internalAPI.email = "user@example.com"
        let token = "zeeToken".data(using: .utf8)!
        internalAPI.register(token: token)
        networkSession.callback = { _, _, _ in
            networkSession.callback = { _, _, _ in
                guard let request = networkSession.getRequest(withEndPoint: Const.Path.disableDevice) else {
                    return
                }
                guard let body = TestUtils.getRequestBody(request: request) else {
                    return
                }
                TestUtils.validate(request: request,
                                   requestType: .post,
                                   apiEndPoint: Endpoint.api,
                                   path: Const.Path.disableDevice,
                                   queryParams: [])
                
                TestUtils.validateElementPresent(withName: JsonKey.token, andValue: token.hexString(), inDictionary: body)
                TestUtils.validateElementPresent(withName: JsonKey.email, andValue: "user@example.com", inDictionary: body)
                expectation.fulfill()
            }
            internalAPI.disableDeviceForCurrentUser()
        }
        
        wait(for: [expectation], timeout: testExpectationTimeout)
    }
    
    func testDisableDeviceForAllUsers() {
        let expectation = XCTestExpectation(description: "testDisableDeviceForAllUsers")
        
        let networkSession = MockNetworkSession(statusCode: 200)
        let config = IterableConfig()
        config.pushIntegrationName = "my-push-integration"
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        internalAPI.email = "user@example.com"
        let token = "zeeToken".data(using: .utf8)!
        
        networkSession.callback = { _, _, _ in
            networkSession.callback = nil
            internalAPI.disableDeviceForAllUsers(withOnSuccess: { _ in
                guard let request = networkSession.getRequest(withEndPoint: Const.Path.disableDevice) else {
                    return
                }
                guard let body = TestUtils.getRequestBody(request: request) else {
                    return
                }
                TestUtils.validate(request: request,
                                   requestType: .post,
                                   apiEndPoint: Endpoint.api,
                                   path: Const.Path.disableDevice,
                                   queryParams: [])
                
                TestUtils.validateElementPresent(withName: JsonKey.token, andValue: token.hexString(), inDictionary: body)
                TestUtils.validateElementNotPresent(withName: JsonKey.email, inDictionary: body)
                TestUtils.validateElementNotPresent(withName: JsonKey.userId, inDictionary: body)
                expectation.fulfill()
            }) { _, _ in
                expectation.fulfill()
            }
        }
        
        internalAPI.register(token: token)
        
        wait(for: [expectation], timeout: testExpectationTimeout)
    }
    
    // Same test as above but without using success/failure callback
    func testDisableDeviceForAllUsersWithoutCallback() {
        let expectation = XCTestExpectation(description: "testDisableDeviceForAllUsersWithoutCallback")
        
        let networkSession = MockNetworkSession(statusCode: 200)
        let config = IterableConfig()
        config.pushIntegrationName = "my-push-integration"
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        internalAPI.email = "user@example.com"
        let token = "zeeToken".data(using: .utf8)!
        networkSession.callback = { _, _, _ in
            networkSession.callback = { _, _, _ in
                guard let request = networkSession.getRequest(withEndPoint: Const.Path.disableDevice) else {
                    return
                }
                guard let body = TestUtils.getRequestBody(request: request) else {
                    return
                }
                TestUtils.validate(request: request,
                                   requestType: .post,
                                   apiEndPoint: Endpoint.api,
                                   path: Const.Path.disableDevice,
                                   queryParams: [])
                
                TestUtils.validateElementPresent(withName: JsonKey.token, andValue: token.hexString(), inDictionary: body)
                TestUtils.validateElementNotPresent(withName: JsonKey.email, inDictionary: body)
                TestUtils.validateElementNotPresent(withName: JsonKey.userId, inDictionary: body)
                
                expectation.fulfill()
            }
            internalAPI.disableDeviceForAllUsers()
        }
        internalAPI.register(token: token)
        
        wait(for: [expectation], timeout: testExpectationTimeout)
    }
    
    func testUpdateCart() {
        let condition1 = XCTestExpectation(description: #function)
        
        let networkSession = MockNetworkSession(statusCode: 200)
        let internalAPI = InternalIterableAPI.initializeForTesting(networkSession: networkSession)
        internalAPI.email = IterableAPITests.email
        
        let items = [CommerceItem(id: "", name: "", price: 0.0, quantity: 1)]
        
        networkSession.callback = { _, response, _ in
            guard let (request, body) = TestUtils.matchingRequest(networkSession: networkSession,
                                                                  response: response,
                                                                  endPoint: Const.Path.updateCart) else {
                return
            }
            
            TestUtils.validate(request: request, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.updateCart, queryParams: [])
            TestUtils.validateMatch(keyPath: KeyPath(string: "\(JsonKey.Commerce.user).\(JsonKey.email)"), value: IterableAPITests.email, inDictionary: body)
            
            let itemsElement = body[JsonKey.Commerce.items] as! [[AnyHashable: Any]]
            XCTAssertEqual(itemsElement.count, items.count)
            
            // TODO: create a CommerceItem matcher for use right here, and in trackPurchase tests
            
            condition1.fulfill()
        }
        
        internalAPI.updateCart(items: items)
        
        wait(for: [condition1], timeout: testExpectationTimeout)
    }
    
    func testTrackPurchaseNoUserIdOrEmail() {
        let expectation = XCTestExpectation(description: "testTrackPurchaseNoUserIdOrEmail")
        
        let networkSession = MockNetworkSession(statusCode: 200)
        let config = IterableConfig()
        config.pushIntegrationName = "my-push-integration"
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        
        internalAPI.trackPurchase(10.0, items: [], dataFields: nil, onSuccess: { _ in
            // no userid or email should fail
            XCTFail("did not expect success here")
        }) { _, _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: testExpectationTimeoutForInverted)
    }
    
    func testTrackPurchaseWithUserId() {
        let expectation = XCTestExpectation(description: "testTrackPurchaseWithUserId")
        
        let networkSession = MockNetworkSession(statusCode: 200)
        let config = IterableConfig()
        config.pushIntegrationName = "my-push-integration"
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        internalAPI.userId = "zeeUserId"
        
        internalAPI.trackPurchase(10.55, items: [], dataFields: nil, onSuccess: { _ in
            guard let request = networkSession.getRequest(withEndPoint: Const.Path.trackPurchase) else {
                return
            }
            guard let body = TestUtils.getRequestBody(request: request) else {
                return
            }
            TestUtils.validate(request: request,
                               requestType: .post,
                               apiEndPoint: Endpoint.api,
                               path: Const.Path.trackPurchase,
                               queryParams: [])
            
            TestUtils.validateMatch(keyPath: KeyPath(string: "\(JsonKey.Commerce.user).\(JsonKey.userId)"), value: "zeeUserId", inDictionary: body)
            TestUtils.validateElementPresent(withName: JsonKey.Commerce.total, andValue: 10.55, inDictionary: body)
            
            expectation.fulfill()
        }) { reason, _ in
            if let reason = reason {
                XCTFail("encountered error: \(reason)")
            } else {
                XCTFail("encountered error")
            }
        }
        
        wait(for: [expectation], timeout: testExpectationTimeoutForInverted)
    }

    func testTrackPurchaseWithUserId2() {
        let expectation = XCTestExpectation(description: "testTrackPurchaseWithUserId")
        
        let campaignId: NSNumber = 22
        let templateId: NSNumber = 33
        let networkSession = MockNetworkSession(statusCode: 200)
        let config = IterableConfig()
        config.pushIntegrationName = "my-push-integration"
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        internalAPI.userId = "zeeUserId"
        
        internalAPI.trackPurchase(10.55, items: [], dataFields: nil, campaignId: campaignId, templateId: templateId, onSuccess: { _ in
            guard let request = networkSession.getRequest(withEndPoint: Const.Path.trackPurchase) else {
                return
            }
            guard let body = TestUtils.getRequestBody(request: request) else {
                return
            }
            TestUtils.validate(request: request,
                               requestType: .post,
                               apiEndPoint: Endpoint.api,
                               path: Const.Path.trackPurchase,
                               queryParams: [])
            
            TestUtils.validateMatch(keyPath: KeyPath(string: "\(JsonKey.Commerce.user).\(JsonKey.userId)"), value: "zeeUserId", inDictionary: body)
            TestUtils.validateElementPresent(withName: JsonKey.Commerce.total, andValue: 10.55, inDictionary: body)
            TestUtils.validateElementPresent(withName: JsonKey.campaignId, andValue: campaignId, inDictionary: body)
            TestUtils.validateElementPresent(withName: JsonKey.templateId, andValue: templateId, inDictionary: body)

            expectation.fulfill()
        }) { reason, _ in
            if let reason = reason {
                XCTFail("encountered error: \(reason)")
            } else {
                XCTFail("encountered error")
            }
        }
        
        wait(for: [expectation], timeout: testExpectationTimeoutForInverted)
    }

    func testTrackPurchaseWithEmail() {
        let expectation = XCTestExpectation(description: "testTrackPurchaseWithEmail")
        
        let networkSession = MockNetworkSession(statusCode: 200)
        let config = IterableConfig()
        config.pushIntegrationName = "my-push-integration"
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        internalAPI.email = "user@example.com"
        let total = NSNumber(value: 15.32)
        let items = [CommerceItem(id: "id1", name: "myCommerceItem", price: 5.0, quantity: 2)]
        
        internalAPI.trackPurchase(total, items: items, dataFields: nil, onSuccess: { _ in
            guard let request = networkSession.getRequest(withEndPoint: Const.Path.trackPurchase) else {
                return
            }
            guard let body = TestUtils.getRequestBody(request: request) else {
                return
            }
            TestUtils.validate(request: request,
                               requestType: .post,
                               apiEndPoint: Endpoint.api,
                               path: Const.Path.trackPurchase,
                               queryParams: [])
            
            TestUtils.validateMatch(keyPath: KeyPath(string: "\(JsonKey.Commerce.user).\(JsonKey.email)"), value: "user@example.com", inDictionary: body)
            TestUtils.validateElementPresent(withName: JsonKey.Commerce.total, andValue: total, inDictionary: body)
            let itemsElement = body[JsonKey.Commerce.items] as! [[AnyHashable: Any]]
            XCTAssertEqual(itemsElement.count, 1)
            let firstElement = itemsElement[0]
            TestUtils.validateElementPresent(withName: "id", andValue: "id1", inDictionary: firstElement)
            TestUtils.validateElementPresent(withName: "name", andValue: "myCommerceItem", inDictionary: firstElement)
            TestUtils.validateElementPresent(withName: "price", andValue: 5.0, inDictionary: firstElement)
            TestUtils.validateElementPresent(withName: "quantity", andValue: 2, inDictionary: firstElement)
            expectation.fulfill()
        }) { reason, _ in
            if let reason = reason {
                XCTFail("encountered error: \(reason)")
            } else {
                XCTFail("encountered error")
            }
        }
        
        wait(for: [expectation], timeout: testExpectationTimeout)
    }
    
    // Same test as above but without using success/failure handler
    func testPurchaseWithoutSuccessAndFailure() {
        let expectation = XCTestExpectation(description: "testTrackPurchaseWithoutSuccessAndFailure")
        
        let networkSession = MockNetworkSession(statusCode: 200)
        let config = IterableConfig()
        config.pushIntegrationName = "my-push-integration"
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        internalAPI.email = "user@example.com"
        let total = NSNumber(value: 15.32)
        let items = [CommerceItem(id: "id1", name: "myCommerceItem", price: 5.0, quantity: 2)]
        
        networkSession.callback = { _, response, _ in
            guard let (request, body) = TestUtils.matchingRequest(networkSession: networkSession,
                                                                  response: response,
                                                                  endPoint: Const.Path.trackPurchase) else {
                return
            }
            
            TestUtils.validate(request: request, requestType: .post, apiEndPoint: Endpoint.api, path: Const.Path.trackPurchase, queryParams: [])
            TestUtils.validateMatch(keyPath: KeyPath(string: "\(JsonKey.Commerce.user).\(JsonKey.email)"), value: "user@example.com", inDictionary: body)
            TestUtils.validateElementPresent(withName: JsonKey.Commerce.total, andValue: total, inDictionary: body)
            let itemsElement = body[JsonKey.Commerce.items] as! [[AnyHashable: Any]]
            XCTAssertEqual(itemsElement.count, 1)
            let firstElement = itemsElement[0]
            TestUtils.validateElementPresent(withName: "id", andValue: "id1", inDictionary: firstElement)
            TestUtils.validateElementPresent(withName: "name", andValue: "myCommerceItem", inDictionary: firstElement)
            TestUtils.validateElementPresent(withName: "price", andValue: 5.0, inDictionary: firstElement)
            TestUtils.validateElementPresent(withName: "quantity", andValue: 2, inDictionary: firstElement)
            expectation.fulfill()
        }
        
        internalAPI.trackPurchase(total, items: items)
        wait(for: [expectation], timeout: testExpectationTimeout)
    }
    
    func testGetInAppMessagesFunction() {
        let expectation1 = XCTestExpectation(description: "test functionality of getting in-app messages")
        
        let mockInAppFetcher = MockInAppFetcher()
        
        let config = IterableConfig()
        config.inAppDelegate = MockInAppDelegate(showInApp: .skip)
        
        let internalAPI = InternalIterableAPI.initializeForTesting(config: config, inAppFetcher: mockInAppFetcher)
        internalAPI.email = "user@example.com"
        
        let inAppMsg1 = IterableInAppMessage(messageId: "aswefwdf",
                                             campaignId: 123_344,
                                             content: IterableHtmlInAppContent(edgeInsets: .zero,
                                                                               html: ""))
        
        let inAppMsg2 = IterableInAppMessage(messageId: "oeirgjoeigj",
                                             campaignId: 948,
                                             content: IterableHtmlInAppContent(edgeInsets: .zero,
                                                                               html: ""))
        
        mockInAppFetcher.mockMessagesAvailableFromServer(internalApi: internalAPI, messages: [inAppMsg1, inAppMsg2]).onSuccess { _ in
            let messages = internalAPI.inAppManager.getMessages()
            
            XCTAssertEqual(messages.count, 2)
            
            XCTAssertEqual(messages[0], inAppMsg1)
            XCTAssertEqual(messages[1], inAppMsg2)
            
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    func testInAppConsume() {
        let expectation1 = expectation(description: "get in app messages")
        let messageId = UUID().uuidString
        
        let networkSession = MockNetworkSession(statusCode: 200)
        let config = IterableConfig()
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, config: config, networkSession: networkSession)
        internalAPI.email = "user@example.com"
        networkSession.callback = { _, response, _ in
            guard let (request, body) = TestUtils.matchingRequest(networkSession: networkSession,
                                                                  response: response,
                                                                  endPoint: Const.Path.inAppConsume) else {
                return
            }
            TestUtils.validate(request: request,
                               requestType: .post,
                               apiEndPoint: Endpoint.api,
                               path: Const.Path.inAppConsume,
                               queryParams: [])
            TestUtils.validateElementPresent(withName: "messageId", andValue: messageId, inDictionary: body)
            expectation1.fulfill()
        }
        
        let message = IterableInAppMessage(messageId: messageId,
                                           campaignId: 1,
                                           trigger: IterableInAppTrigger(dict: [JsonKey.InApp.type: "never"]),
                                           createdAt: nil,
                                           expiresAt: nil,
                                           content: IterableHtmlInAppContent(edgeInsets: .zero, html: ""),
                                           saveToInbox: true,
                                           inboxMetadata: nil,
                                           customPayload: nil)
        internalAPI.inAppConsume(message: message)
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    func testTrackInAppConsumeWithSource() {
        let messageId = "message1"
        let expectation1 = expectation(description: "testTrackInAppConsumeWithSource")
        
        let networkSession = MockNetworkSession(statusCode: 200)
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey, networkSession: networkSession)
        internalAPI.email = IterableAPITests.email
        
        networkSession.callback = { _, response, _ in
            guard let (request, body) = TestUtils.matchingRequest(networkSession: networkSession,
                                                                  response: response,
                                                                  endPoint: Const.Path.inAppConsume) else {
                return
            }
            
            TestUtils.validate(request: request,
                               requestType: .post,
                               apiEndPoint: Endpoint.api,
                               path: Const.Path.inAppConsume,
                               queryParams: [])
            TestUtils.validateMessageContext(messageId: messageId, email: IterableAPITests.email, saveToInbox: true, silentInbox: true, location: .inbox, inBody: body)
            TestUtils.validateDeviceInfo(inBody: body, withDeviceId: internalAPI.deviceId)
            TestUtils.validateMatch(keyPath: KeyPath(string: "\(JsonKey.deleteAction)"), value: InAppDeleteSource.deleteButton.jsonValue as! String, inDictionary: body)
            
            expectation1.fulfill()
        }
        
        let message = IterableInAppMessage(messageId: messageId,
                                           campaignId: 1,
                                           trigger: IterableInAppTrigger(dict: [JsonKey.InApp.type: "never"]),
                                           createdAt: nil,
                                           expiresAt: nil,
                                           content: IterableHtmlInAppContent(edgeInsets: .zero, html: ""),
                                           saveToInbox: true,
                                           inboxMetadata: nil,
                                           customPayload: nil)
        
        internalAPI.inAppConsume(message: message, location: .inbox, source: .deleteButton)
        
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    func testUpdateSubscriptions() {
        let expectation1 = expectation(description: "update subscriptions")
        let emailListIds = [NSNumber(value: 382)]
        let unsubscibedChannelIds = [NSNumber(value: 7845), NSNumber(value: 1048)]
        let unsubscribedMessageTypeIds = [NSNumber(value: 5671), NSNumber(value: 9087)]
        let campaignId = NSNumber(value: 23)
        let templateId = NSNumber(value: 10)
        
        let networkSession = MockNetworkSession(statusCode: 200)
        networkSession.callback = { _, response, _ in
            guard let (request, body) = TestUtils.matchingRequest(networkSession: networkSession,
                                                                  response: response,
                                                                  endPoint: Const.Path.updateSubscriptions) else {
                return
            }
            TestUtils.validate(request: request,
                               requestType: .post,
                               apiEndPoint: Endpoint.api,
                               path: Const.Path.updateSubscriptions,
                               queryParams: [])
            TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.emailListIds), value: emailListIds, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.unsubscribedChannelIds), value: unsubscibedChannelIds, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.unsubscribedMessageTypeIds), value: unsubscribedMessageTypeIds, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.campaignId), value: campaignId, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.templateId), value: templateId, inDictionary: body)
            expectation1.fulfill()
        }
        
        let config = IterableConfig()
        let localStorage = MockLocalStorage()
        localStorage.email = "user1@example.com"
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey,
                                                                   config: config,
                                                                   networkSession: networkSession,
                                                                   localStorage: localStorage)
        internalAPI.updateSubscriptions(emailListIds,
                                        unsubscribedChannelIds: unsubscibedChannelIds,
                                        unsubscribedMessageTypeIds: unsubscribedMessageTypeIds,
                                        subscribedMessageTypeIds: nil,
                                        campaignId: campaignId,
                                        templateId: templateId)
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    func testInitializeWithLaunchOptionsAndCustomAction() {
        let expectation1 = expectation(description: "initializeWithLaunchOptions")
        let userInfo: [AnyHashable: Any] = [
            "itbl": [
                "campaignId": 1234,
                "templateId": 4321,
                "isGhostPush": false,
                "messageId": "messageId",
                "defaultAction": [
                    "type": "customAction",
                ],
            ] as [String : Any],
        ]
        
        let launchOptions: [UIApplication.LaunchOptionsKey: Any] = [UIApplication.LaunchOptionsKey.remoteNotification: userInfo]
        let customActionDelegate = MockCustomActionDelegate(returnValue: false)
        customActionDelegate.callback = { name, _ in
            XCTAssertEqual(name, "customAction")
            expectation1.fulfill()
        }
        
        let config = IterableConfig()
        config.customActionDelegate = customActionDelegate
        InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey,
                                                 launchOptions: launchOptions,
                                                 config: config)
        
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    func testInitializeWithLaunchOptionsAndUrl() {
        let expectation1 = expectation(description: "initializeWithLaunchOptions")
        let userInfo: [AnyHashable: Any] = [
            "itbl": [
                "campaignId": 1234,
                "templateId": 4321,
                "isGhostPush": false,
                "messageId": "messageId",
                "defaultAction": [
                    "type": "openUrl",
                    "data": "http://somewhere.com",
                ],
            ] as [String : Any],
        ]
        let launchOptions: [UIApplication.LaunchOptionsKey: Any] = [UIApplication.LaunchOptionsKey.remoteNotification: userInfo]
        let urlDelegate = MockUrlDelegate(returnValue: true)
        urlDelegate.callback = { url, _ in
            XCTAssertEqual(url.absoluteString, "http://somewhere.com")
            expectation1.fulfill()
        }
        let config = IterableConfig()
        config.urlDelegate = urlDelegate
        InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey,
                                                 launchOptions: launchOptions,
                                                 config: config)
        
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    func testTrackPushOpen() {
        let expectation1 = expectation(description: "trackPushOpen")
        let messageId = UUID().uuidString
        let userInfo: [AnyHashable: Any] = [
            "itbl": [
                "campaignId": 1234,
                "templateId": 4321,
                "messageId": messageId,
                "isGhostPush": false,
                "defaultAction": [
                    "type": "openUrl",
                    "data": "http://somewhere.com",
                ],
            ] as [String : Any],
        ]
        
        let networkSession = MockNetworkSession(statusCode: 200)
        
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey,
                                                                   networkSession: networkSession)
        internalAPI.email = IterableAPITests.email
        
        networkSession.callback = { _, response, _ in
            guard let (request, body) = TestUtils.matchingRequest(networkSession: networkSession,
                                                                  response: response,
                                                                  endPoint: Const.Path.trackEvent) else {
                return
            }
            
            TestUtils.validate(request: request, apiEndPoint: Endpoint.api, path: Const.Path.trackEvent)
            TestUtils.validateMatch(keyPath: KeyPath(string: "campaignId"), value: 1234, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "templateId"), value: 4321, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "messageId"), value: messageId, inDictionary: body)
            
            expectation1.fulfill()
        }
        
        internalAPI.trackPushOpen(userInfo)
        
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    func testTrackPushOpenWithDataFields() {
        let expectation1 = expectation(description: "trackPushOpen with datafields")
        let messageId = UUID().uuidString
        let userInfo: [AnyHashable: Any] = [
            "itbl": [
                "campaignId": 1234,
                "templateId": 4321,
                "messageId": messageId,
                "isGhostPush": false,
            ] as [String : Any],
        ]
        
        let networkSession = MockNetworkSession(statusCode: 200)
        
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey,
                                                                   networkSession: networkSession)
        
        internalAPI.userId = IterableAPITests.userId
        
        networkSession.callback = { _, response, _ in
            guard let (request, body) = TestUtils.matchingRequest(networkSession: networkSession,
                                                                  response: response,
                                                                  endPoint: Const.Path.trackEvent) else {
                return
            }
            TestUtils.validate(request: request, apiEndPoint: Endpoint.api, path: Const.Path.trackEvent)
            TestUtils.validateMatch(keyPath: KeyPath(string: "campaignId"), value: 1234, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "templateId"), value: 4321, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "messageId"), value: messageId, inDictionary: body)
            let dataFields: [String: AnyHashable] = ["appAlreadyRunning": false, "key1": "value1"]
            TestUtils.validateMatch(keyPath: KeyPath(string: "dataFields"), value: dataFields, inDictionary: body)
            expectation1.fulfill()
        }
        internalAPI.trackPushOpen(userInfo, dataFields: ["key1": "value1"])
        
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    func testTrackPushOpenWithCallback() {
        let expectation1 = expectation(description: "trackPushOpen with callback")
        let messageId = UUID().uuidString
        let userInfo: [AnyHashable: Any] = [
            "itbl": [
                "campaignId": 1234,
                "templateId": 4321,
                "messageId": messageId,
                "isGhostPush": false,
            ] as [String : Any],
        ]
        
        let networkSession = MockNetworkSession(statusCode: 200)
        
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey,
                                                                   networkSession: networkSession)
        
        internalAPI.email = IterableAPITests.email
        
        internalAPI.trackPushOpen(userInfo, dataFields: ["key1": "value1"], onSuccess: { _ in
            guard let request = networkSession.getRequest(withEndPoint: Const.Path.trackEvent) else {
                return
            }
            
            guard let body = TestUtils.getRequestBody(request: request) else {
                return
            }
            
            TestUtils.validate(request: request, apiEndPoint: Endpoint.api, path: Const.Path.trackEvent)
            TestUtils.validateMatch(keyPath: KeyPath(string: "campaignId"), value: 1234, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "templateId"), value: 4321, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "messageId"), value: messageId, inDictionary: body)
            
            let dataFields: [String: AnyHashable] = ["appAlreadyRunning": false, "key1": "value1"]
            TestUtils.validateMatch(keyPath: KeyPath(string: "dataFields"), value: dataFields, inDictionary: body)
            
            expectation1.fulfill()
        }, onFailure: nil)
        
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    func testTrackPushOpenWithCampaignIdEtc() {
        let expectation1 = expectation(description: "trackPushOpen with campaignId etc")
        let messageId = UUID().uuidString
        
        let networkSession = MockNetworkSession(statusCode: 200)
        
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey,
                                                                   networkSession: networkSession)
        
        internalAPI.userId = IterableAPITests.userId
        
        networkSession.callback = { _, response, _ in
            guard let (request, body) = TestUtils.matchingRequest(networkSession: networkSession,
                                                                  response: response,
                                                                  endPoint: Const.Path.trackEvent) else {
                return
            }
            TestUtils.validate(request: request, apiEndPoint: Endpoint.api, path: Const.Path.trackEvent)
            TestUtils.validateMatch(keyPath: KeyPath(string: "campaignId"), value: 1234, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "templateId"), value: 4321, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(string: "messageId"), value: messageId, inDictionary: body)
            let dataFields: [String: AnyHashable] = ["appAlreadyRunning": true, "key1": "value1"]
            TestUtils.validateMatch(keyPath: KeyPath(string: "dataFields"), value: dataFields, inDictionary: body, message: "dataFields did not match")
            expectation1.fulfill()
        }
        internalAPI.trackPushOpen(1234, templateId: 4321, messageId: messageId, appAlreadyRunning: true, dataFields: ["key1": "value1"])
        
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    func testTrackPushOpenWithCampaignIdEtcWithCallback() {
        let expectation1 = expectation(description: "trackPushOpen with campaignId etc with callback")
        let messageId = UUID().uuidString
        
        let networkSession = MockNetworkSession(statusCode: 200)
        
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: IterableAPITests.apiKey,
                                                                   networkSession: networkSession)
        
        internalAPI.email = IterableAPITests.email
        
        internalAPI.trackPushOpen(1234,
                                  templateId: 4321,
                                  messageId: messageId,
                                  appAlreadyRunning: true,
                                  dataFields: ["key1": "value1"],
                                  onSuccess: { _ in
                                    guard let request = networkSession.getRequest(withEndPoint: Const.Path.trackEvent) else {
                                        return
                                    }
                                    
                                    guard let body = TestUtils.getRequestBody(request: request) else {
                                        return
                                    }
                                    
                                    TestUtils.validate(request: request, apiEndPoint: Endpoint.api, path: Const.Path.trackEvent)
                                    TestUtils.validateMatch(keyPath: KeyPath(string: "campaignId"), value: 1234, inDictionary: body)
                                    TestUtils.validateMatch(keyPath: KeyPath(string: "templateId"), value: 4321, inDictionary: body)
                                    TestUtils.validateMatch(keyPath: KeyPath(string: "messageId"), value: messageId, inDictionary: body)
                                    
                                    let dataFields: [String: AnyHashable] = ["appAlreadyRunning": true, "key1": "value1"]
                                    TestUtils.validateMatch(keyPath: KeyPath(string: "dataFields"), value: dataFields, inDictionary: body, message: "dataFields did not match")
                                    
                                    expectation1.fulfill()
                                  },
                                  onFailure: nil)
        
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }
    
    
    func testUpgradeJWTToken() throws {
        let authToken = "zee-auth-token"
        let previousKey = Const.UserDefault.authTokenKey
        let userDefaults = UserDefaults(suiteName: "upgrade.test")!
        userDefaults.set(authToken, forKey: previousKey)
        userDefaults.set("some-previous-version", forKey: Const.UserDefault.sdkVersion)
        let keychainWrapper = KeychainWrapper(serviceName: "upgrade.test")
        keychainWrapper.removeAll()
        let keychain = IterableKeychain(wrapper: keychainWrapper)
        let localStorage = LocalStorage(userDefaults: userDefaults, keychain: keychain)
        XCTAssertNil(localStorage.authToken)
        _ = InternalIterableAPI.initializeForTesting(localStorage: localStorage)
        XCTAssertEqual(localStorage.authToken, authToken)
        userDefaults.removePersistentDomain(forName: "upgrade.test")
    }
}
