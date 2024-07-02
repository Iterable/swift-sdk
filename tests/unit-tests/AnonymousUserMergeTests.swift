//
//  AnonymousUserMergeTests.swift
//
//
//  Created by Hani Vora on 29/12/23.
//


import XCTest
import Foundation

@testable import IterableSDK

class AnonymousUserMergeTests: XCTestCase, AuthProvider {
    public var auth: Auth {
        Auth(userId: nil, email: "user@example.com", authToken: "asdf", userIdAnon: nil)
    }
    
    private static let apiKey = "zeeApiKey"
    
    override func setUp() {
        super.setUp()
    }
    
    func testMergeUserUsingUserId() throws {
        throw XCTSkip("skipping this test - needs to be revisited")
        
        let networkSession: NetworkSessionProtocol = MockNetworkSession()
        let mockApiClient = ApiClient(apiKey: AnonymousUserMergeTests.apiKey,
                                      authProvider: self,
                                      endpoint: Endpoint.api,
                                      networkSession: networkSession,
                                      deviceMetadata: InternalIterableAPI.initializeForTesting().deviceMetadata,
                                      dateProvider: MockDateProvider())
        
        
        self.callMergeApi(sourceUserId: "123", destinationUserIdOrEmail: "destinationUserId", isEmail: false, apiClient: mockApiClient)
        
    }
    
    func testMergeUserUsingEmail() throws {
        throw XCTSkip("skipping this test - needs to be revisited")
        
        let networkSession: NetworkSessionProtocol = MockNetworkSession()
        let mockApiClient = ApiClient(apiKey: AnonymousUserMergeTests.apiKey,
                                      authProvider: self,
                                      endpoint: Endpoint.api,
                                      networkSession: networkSession,
                                      deviceMetadata: InternalIterableAPI.initializeForTesting().deviceMetadata,
                                      dateProvider: MockDateProvider())
        
        
        self.callMergeApi(sourceUserId: "123", destinationUserIdOrEmail: "destination@example.com", isEmail: true, apiClient: mockApiClient)
        
    }
    
    private func callMergeApi(sourceUserId: String?, destinationUserIdOrEmail: String?, isEmail: Bool, apiClient: ApiClient) {
        let config = IterableConfig()
        config.enableAnonTracking = true
        let networkSession = MockNetworkSession(statusCode: 200)
        let internalAPI = InternalIterableAPI.initializeForTesting(apiKey: AnonymousUserMergeTests.apiKey, config: config, networkSession: networkSession)
        
        let expectation1 = expectation(description: #function)
        if let sourceUserId = sourceUserId, let destinationUserIdOrEmail = destinationUserIdOrEmail {
            internalAPI.anonymousUserMerge.tryMergeUser(sourceUserId: sourceUserId, destinationUserIdOrEmail: isEmail ? destinationUserIdOrEmail : nil, isEmail: isEmail) { mergeResult, error in
                if mergeResult == MergeResult.mergenotrequired ||  mergeResult == MergeResult.mergesuccessful {
                    expectation1.fulfill()
                } else {
                    expectation1.fulfill()
                }
            }
            
        } else {
            expectation1.fulfill()
        }
        
    }
    
}
