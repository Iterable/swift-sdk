//
//  Copyright © 2018 Iterable. All rights reserved.
//

import XCTest

@testable import IterableSDK

class IterableAPIResponseTests: XCTestCase {
    private let apiKey = "zee_api_key"
    private let email = "user@example.com"
    private let authToken = "asdf"
    
    private let dateProvider = MockDateProvider()
    
    func testHeadersInGetRequest() {
        let iterableRequest = IterableRequest.get(GetRequest(path: "", args: ["var1": "value1"]))
        let urlRequest = createApiClient().convertToURLRequest(iterableRequest: iterableRequest)!
        
        verifyIterableHeaders(urlRequest)
    }
    
    func testHeadersInPostRequest() {
        let iterableRequest = IterableRequest.post(PostRequest(path: "", args: ["var1": "value1"], body: [:]))
        let urlRequest = createApiClient().convertToURLRequest(iterableRequest: iterableRequest)!
        
        verifyIterableHeaders(urlRequest)
    }
    
    func testAuthInHeader() {
        let apiClient = createApiClientWithAuthToken()
        
        let iterableRequest = IterableRequest.post(PostRequest(path: "", args: ["var1": "value1"], body: [:]))
        let urlRequest = apiClient.convertToURLRequest(iterableRequest: iterableRequest)!
        
        verifyIterableHeaders(urlRequest)
        verifyAuthTokenInHeader(urlRequest, authToken)
    }
    
    func testResponseCode200() {
        let xpectation = expectation(description: "response code 200")
        let iterableRequest = IterableRequest.post(PostRequest(path: "", args: nil, body: [:]))
        
        createApiClient().send(iterableRequest: iterableRequest).onSuccess { _ in
            xpectation.fulfill()
        }
        
        wait(for: [xpectation], timeout: testExpectationTimeout)
    }
    
    func testResponseCode200WithNoData() {
        let xpectation = expectation(description: "no data")
        let iterableRequest = IterableRequest.post(PostRequest(path: "", args: nil, body: [:]))
        
        createApiClient(networkSession: MockNetworkSession(statusCode: 200, data: nil))
            .send(iterableRequest: iterableRequest).onError { sendError in
                xpectation.fulfill()
                XCTAssert(sendError.reason!.lowercased().contains("no data"))
            }
        
        wait(for: [xpectation], timeout: testExpectationTimeout)
    }
    
    func testResponseCode200WithInvalidJson() {
        let xpectation = expectation(description: "invalid json")
        let data = "{'''}}".data(using: .utf8)!
        let iterableRequest = IterableRequest.post(PostRequest(path: "", args: nil, body: [:]))
        
        createApiClient(networkSession: MockNetworkSession(statusCode: 200, data: data))
            .send(iterableRequest: iterableRequest).onError { sendError in
                xpectation.fulfill()
                XCTAssert(sendError.reason!.lowercased().contains("could not convert data"))
            }
        
        wait(for: [xpectation], timeout: testExpectationTimeout)
    }
    
    func testResponseCode400WithoutMessage() { // 400 = bad reqeust
        let xpectation = expectation(description: "400 without message")
        let iterableRequest = IterableRequest.post(PostRequest(path: "", args: nil, body: [:]))
        
        createApiClient(networkSession: MockNetworkSession(statusCode: 400))
            .send(iterableRequest: iterableRequest).onError { sendError in
                xpectation.fulfill()
                XCTAssert(sendError.reason!.lowercased().contains("invalid request"))
            }
        
        wait(for: [xpectation], timeout: testExpectationTimeout)
    }
    
    func testResponseCode400WithMessage() {
        let xpectation = expectation(description: "400 with message")
        let iterableRequest = IterableRequest.post(PostRequest(path: "", args: nil, body: [:]))
        
        createApiClient(networkSession: MockNetworkSession(statusCode: 400, json: ["msg": "Test error"]))
            .send(iterableRequest: iterableRequest).onError { sendError in
                xpectation.fulfill()
                XCTAssert(sendError.reason!.lowercased().contains("test error"))
            }
        
        wait(for: [xpectation], timeout: testExpectationTimeout)
    }
    
    func testRetryOnInvalidJwtPayload() throws {
        throw XCTSkip("skipping this test - retry logic updated, needs to be revisited")
           let xpectation = expectation(description: "retry on 401 with invalidJWTPayload")

           // Mock the dependencies and requestProvider for your test
           let authManager = MockAuthManager()

           let networkErrorSession = MockNetworkSession() { _ in
               MockNetworkSession.MockResponse(statusCode: 401,
                                               data: ["code":"InvalidJwtPayload"].toJsonData(),
                                               delay: 1)
           }

           let networkSuccessSession = MockNetworkSession() { _ in
               MockNetworkSession.MockResponse(statusCode: 200,
                                               data: ["msg": "success"].toJsonData(),
                                               delay: 1)
           }

           let urlErrorRequest = createApiClient(networkSession: networkErrorSession).convertToURLRequest(iterableRequest: IterableRequest.post(PostRequest(path: "", args: nil, body: [:])))!


           let urlSuccessRequest = createApiClient(networkSession: networkSuccessSession).convertToURLRequest(iterableRequest: IterableRequest.post(PostRequest(path: "", args: nil, body: [:])))!

           let requestProvider: () -> Pending<SendRequestValue, SendRequestError> = {
               if authManager.retryWasRequested {
                   return RequestSender.sendRequest(urlSuccessRequest, usingSession: networkSuccessSession)
               }
               return RequestSender.sendRequest(urlErrorRequest, usingSession: networkErrorSession)
           }

           let result = RequestProcessorUtil.sendRequest(
               requestProvider: requestProvider,
               authManager: authManager,
               requestIdentifier: "TestIdentifier"
           )

           result.onSuccess { value in
               xpectation.fulfill()
               XCTAssert(true)
           }.onError { error in
               if authManager.retryWasRequested {
                   xpectation.fulfill()
               }
           }

           waitForExpectations(timeout: testExpectationTimeout)
       }
    
    func testResponseCode401() { // 401 = unauthorized
        let xpectation = expectation(description: "401")
        let iterableRequest = IterableRequest.post(PostRequest(path: "", args: nil, body: [:]))
        
        createApiClient(networkSession: MockNetworkSession(statusCode: 401))
            .send(iterableRequest: iterableRequest).onError { sendError in
                xpectation.fulfill()
                XCTAssert(sendError.reason!.lowercased().contains("invalid request"))
            }
        
        wait(for: [xpectation], timeout: testExpectationTimeout)
    }
    
    func testResponseCode500() { // 500 = internal server error
        let xpectation = expectation(description: "500")
        let iterableRequest = IterableRequest.post(PostRequest(path: "", args: nil, body: [:]))
        
        createApiClient(networkSession: MockNetworkSession(statusCode: 500))
            .send(iterableRequest: iterableRequest).onError { sendError in
                xpectation.fulfill()
                XCTAssert(sendError.reason!.lowercased().contains("internal server error"))
            }
        
        wait(for: [xpectation], timeout: testExpectationTimeout)
    }
    
    func testNon200ResponseCode() { // 302 = redirection
        let xpectation = expectation(description: "non 200")
        let iterableRequest = IterableRequest.post(PostRequest(path: "", args: nil, body: [:]))
        
        createApiClient(networkSession: MockNetworkSession(statusCode: 302))
            .send(iterableRequest: iterableRequest).onError { sendError in
                xpectation.fulfill()
                XCTAssert(sendError.reason!.lowercased().contains("non-200 response"))
            }
        
        wait(for: [xpectation], timeout: testExpectationTimeout)
    }
    
    func testNoNetworkResponse() {
        let xpectation = expectation(description: "no network response")
        let iterableRequest = IterableRequest.post(PostRequest(path: "", args: nil, body: [:]))
        
        createApiClient(networkSession: NoNetworkNetworkSession())
            .send(iterableRequest: iterableRequest).onError { sendError in
                xpectation.fulfill()
                XCTAssert(sendError.reason!.lowercased().contains("nsurlerrordomain"))
            }
        
        wait(for: [xpectation], timeout: testExpectationTimeout)
    }
    
    func testSendRequestWithRetry() {
        let xpectation = expectation(description: "retry on status code >= 500")
        
        let networkSession = MockNetworkSession { _ in
            MockNetworkSession.MockResponse(statusCode: 503,
                                            data: Data(),
                                            delay: 0)
        }
        
        let iterableRequest = IterableRequest.post(PostRequest(path: "", args: nil, body: [:]))
        
        let apiClient = createApiClient(networkSession: networkSession)
        var urlRequest = apiClient.convertToURLRequest(iterableRequest: iterableRequest)!
        urlRequest.timeoutInterval = 1
                
        RequestSender.sendRequest(urlRequest, usingSession: networkSession).onError { sendError in
            xpectation.fulfill()
            XCTAssert(sendError.reason!.lowercased().contains("internal server error"))
        }
        
        wait(for: [xpectation], timeout: testExpectationTimeout)
    }

    
    func testNetworkTimeoutResponse() {
        let xpectation = expectation(description: "timeout network response")
        
        let responseTime = 2.0
        let timeout = 0.1
        
        let networkSession = MockNetworkSession() { _ in
            MockNetworkSession.MockResponse(statusCode: 200,
                                            data: Dictionary<AnyHashable, Any>().toJsonData(),
                                            delay: responseTime)
        }
        networkSession.timeout = timeout
        
        let iterableRequest = IterableRequest.post(PostRequest(path: "", args: nil, body: [:]))
        
        let apiClient = createApiClient(networkSession: networkSession)
        var urlRequest = apiClient.convertToURLRequest(iterableRequest: iterableRequest)!
        urlRequest.timeoutInterval = timeout
        
        RequestSender.sendRequest(urlRequest, usingSession: networkSession).onError { sendError in
            xpectation.fulfill()
            XCTAssert(sendError.reason!.lowercased().contains("timed out"))
        }
        
        wait(for: [xpectation], timeout: testExpectationTimeout)
    }

    
    private func verifyIterableHeaders(_ urlRequest: URLRequest) {
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: JsonKey.Header.sdkPlatform), JsonValue.iOS)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: JsonKey.Header.sdkVersion), IterableAPI.sdkVersion)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: JsonKey.Header.apiKey), apiKey)
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: JsonKey.contentType), JsonValue.applicationJson)
    }
    
    private func verifyAuthTokenInHeader(_ urlRequest: URLRequest, _ authToken: String) {
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: JsonKey.Header.authorization), "\(JsonValue.bearer) \(authToken)")
    }
    
    private func createApiClient(networkSession: NetworkSessionProtocol = MockNetworkSession()) -> ApiClient {
        ApiClient(apiKey: apiKey,
                  authProvider: self,
                  endpoint: Endpoint.api,
                  networkSession: networkSession,
                  deviceMetadata: InternalIterableAPI.initializeForTesting().deviceMetadata,
                  dateProvider: dateProvider)
    }
    
    private func createApiClientWithAuthToken() -> ApiClient {
        ApiClient(apiKey: apiKey,
                  authProvider: self,
                  endpoint: Endpoint.api,
                  networkSession: MockNetworkSession(),
                  deviceMetadata: InternalIterableAPI.initializeForTesting().deviceMetadata,
                  dateProvider: dateProvider)
    }
}

extension IterableAPIResponseTests: AuthProvider {
    var auth: Auth {
        Auth(userId: nil, email: email, authToken: authToken, userIdAnon: nil)
    }
}

class AuthProviderNoToken: AuthProvider {
    var auth: Auth {
        Auth(userId: nil, email: "user@example.com", authToken: nil, userIdAnon: nil)
    }
}
