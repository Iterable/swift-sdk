//
//  ValidateCustomEventUserUpdateAPITest.swift
//  unit-tests
//
//  Created by Apple on 17/09/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import XCTest
@testable import IterableSDK

final class ValidateCustomEventUserUpdateAPITest: XCTestCase, AuthProvider  {
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


    let mockData = """
    {
      "count": 1,
      "criteriaSets": [
        {
          "criteriaId": "6",
          "name": "EventCriteria",
          "createdAt": 1719328487701,
          "updatedAt": 1719328487701,
          "searchQuery": {
            "combinator": "And",
            "searchQueries": [
              {
                "combinator": "And",
                "searchQueries": [
                  {
                    "dataType": "customEvent",
                    "searchCombo": {
                      "combinator": "And",
                      "searchQueries": [
                        {
                          "dataType": "customEvent",
                          "field": "eventName",
                          "comparatorType": "Equals",
                          "value": "animal-found",
                          "fieldType": "string"
                        },
                        {
                          "dataType": "customEvent",
                          "field": "animal-found.type",
                          "comparatorType": "Equals",
                          "value": "cat",
                          "fieldType": "string"
                        },
                        {
                          "dataType": "customEvent",
                          "field": "animal-found.count",
                          "comparatorType": "Equals",
                          "value": "6",
                          "fieldType": "string"
                        },
                        {
                          "dataType": "customEvent",
                          "field": "animal-found.vaccinated",
                          "comparatorType": "Equals",
                          "value": "true",
                          "fieldType": "boolean"
                        }
                      ]
                    }
                  }
                ]
              }
            ]
          }
        }
      ]
    }
    """

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
        IterableAPI.initializeForTesting(apiKey: ValidateCustomEventUserUpdateAPITest.apiKey,
                                                                   config: config,
                                                                   networkSession: mockSession,
                                                                   localStorage: localStorage)

        IterableAPI.track(event: "button-clicked", dataFields: ["lastPageViewed":"signup page", "timestemp_createdAt": Int(Date().timeIntervalSince1970)])

        IterableAPI.track(event: "animal-found", dataFields: ["type": "cat",
                                                              "count": 6,
                                                              "vaccinated": true])

        guard let jsonData = mockData.data(using: .utf8) else { return }
        localStorage.criteriaData = jsonData

        if let events = localStorage.anonymousUserEvents {
            XCTAssertFalse(events.isEmpty, "Expected events to be logged")
       } else {
           XCTFail("Expected events to be logged but found nil")
       }

        IterableAPI.track(event: "animal-found", dataFields: ["type": "cat",
                                                              "count": 6,
                                                              "vaccinated": true])

        let checker = CriteriaCompletionChecker(anonymousCriteria: jsonData, anonymousEvents:localStorage.anonymousUserEvents ?? [])
        let matchedCriteriaId = checker.getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, "6")

        IterableAPI.track(event: "animal-found", dataFields: ["type": "cat",
                                                              "count": 6,
                                                              "vaccinated": true])
        waitForDuration(seconds: 3)
        if let anonUser = localStorage.userIdAnnon {
            XCTAssertFalse(anonUser.isEmpty, "Expected anon user")
       } else {
           XCTFail("Expected anon user but found nil")
       }

        IterableAPI.logoutUser()

        waitForDuration(seconds: 3)


        IterableAPI.setUserId("testuser123")


        waitForDuration(seconds: 3)

        if localStorage.anonymousUserEvents != nil {
        XCTFail("Expected local stored Event nil but found")
       } else {
           XCTAssertNil(localStorage.anonymousUserEvents, "Event found nil as user logout")
       }


        let dataFields = ["type": "cat",
                          "count": 6,
                          "vaccinated": true] as [String : Any]
        IterableAPI.track(event: "animal-found", dataFields: dataFields)

        waitForDuration(seconds: 3)
        if let request = self.mockSession.getRequest(withEndPoint: Const.Path.trackEvent) {
            print(request)
            TestUtils.validate(request: request, apiEndPoint: Endpoint.api, path: Const.Path.trackEvent)
            TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.eventName), value: "animal-found", inDictionary: request.bodyDict)


            //Check direct key exist failure
            TestUtils.validateNil(keyPath: KeyPath(keys: "count"), inDictionary: request.bodyDict)
            TestUtils.validateNil(keyPath: KeyPath(keys: "type"), inDictionary: request.bodyDict)
            TestUtils.validateNil(keyPath: KeyPath(keys: "vaccinated"), inDictionary: request.bodyDict)


            //Check inside dataFields with nested key exist success
            TestUtils.validateExists(keyPath: KeyPath(keys: JsonKey.dataFields, "count"), type: Int.self, inDictionary: request.bodyDict)
            TestUtils.validateExists(keyPath: KeyPath(keys: JsonKey.dataFields, "type"), type: String.self, inDictionary: request.bodyDict)
            TestUtils.validateExists(keyPath: KeyPath(keys: JsonKey.dataFields, "vaccinated"), type: Bool.self, inDictionary: request.bodyDict)


            //Check inside dataFields with nested key success
            TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.dataFields, "type"), value: "cat", inDictionary: request.bodyDict)
            TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.dataFields, "count"), value: 6, inDictionary: request.bodyDict)
            TestUtils.validateMatch(keyPath: KeyPath(keys: JsonKey.dataFields, "vaccinated"), value: true, inDictionary: request.bodyDict)

            //Check inside dataFields with nested key failure
            TestUtils.validateNil(keyPath: KeyPath(keys: JsonKey.dataFields, "animal-found.count"), inDictionary: request.bodyDict)
            TestUtils.validateNil(keyPath: KeyPath(keys: JsonKey.dataFields, "animal-found.type"), inDictionary: request.bodyDict)
            TestUtils.validateNil(keyPath: KeyPath(keys: JsonKey.dataFields, "animal-found.vaccinated"), inDictionary: request.bodyDict)

        } else {
            XCTFail("Expected track event API call was not made")

        }
    
    }


}
