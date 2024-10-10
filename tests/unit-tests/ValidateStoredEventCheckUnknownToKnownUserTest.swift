//
//  ValidateStoredEventCheckUnknownToKnownUserTest.swift
//  unit-tests
//
//  Created by Apple on 20/09/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import XCTest
@testable import IterableSDK

final class ValidateStoredEventCheckUnknownToKnownUserTest: XCTestCase, AuthProvider  {
    private static let apiKey = "zeeApiKey"
    private let authToken = "asdf"
    private let dateProvider = MockDateProvider()
    let mockSession = MockNetworkSession(statusCode: 200)
    let localStorage = MockLocalStorage()

    var auth: Auth {
        Auth(userId: nil, email: nil, authToken: authToken, userIdAnon: nil)
    }

    override func setUp() {
        super.setUp()
    }

    func data(from jsonString: String) -> Data? {
        return jsonString.data(using: .utf8)
    }

    override func tearDown() {
           // Clean up after each test
           super.tearDown()
       }

    // Helper function to wait for a specified duration
    private func waitForDuration(seconds: TimeInterval) {
        let waitExpectation = expectation(description: "Waiting for \(seconds) seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            waitExpectation.fulfill()
        }
        wait(for: [waitExpectation], timeout: seconds + 1)
    }

    func testCriteriaCustomEventCheck() {  // criteria not met with merge false with setUserId
        let config = IterableConfig()
        config.enableAnonTracking = true
        IterableAPI.initializeForTesting(apiKey: ValidateStoredEventCheckUnknownToKnownUserTest.apiKey,
                                                                   config: config,
                                                                   networkSession: mockSession,
                                                                   localStorage: localStorage)

        IterableAPI.track(event: "animal-found", dataFields: ["type": "cat", "count": 16, "vaccinated": true])
        IterableAPI.track(purchase: 10.0, items: [CommerceItem(id: "mocha", name: "Mocha", price: 10.0, quantity: 17, dataFields: nil)])
        IterableAPI.updateCart(items: [CommerceItem(id: "fdsafds", name: "sneakers", price: 4, quantity: 3, dataFields: ["timestemp_createdAt": Int(Date().timeIntervalSince1970)])])
        IterableAPI.track(event: "button-clicked", dataFields: ["lastPageViewed":"signup page", "timestemp_createdAt": Int(Date().timeIntervalSince1970)])
        waitForDuration(seconds: 3)

        IterableAPI.setUserId("testuser123")

        if let events = self.localStorage.anonymousUserEvents {
            XCTAssertFalse(events.isEmpty, "Expected events to be logged")
        } else {
           XCTFail("Expected events to be logged but found nil")
        }

        self.waitForDuration(seconds: 3)

        //Sync Completed
        if self.localStorage.anonymousUserEvents != nil {
            XCTFail("Expected local stored Event nil but found")
        } else {
            XCTAssertNil(self.localStorage.anonymousUserEvents, "Event found nil as event Sync Completed")
        }
    }


}
