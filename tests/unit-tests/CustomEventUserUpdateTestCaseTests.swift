//
//  CustomEventUserUpdateTestCaseTests.swift
//  unit-tests
//
//  Created by Apple on 16/09/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import XCTest
@testable import IterableSDK

final class CustomEventUserUpdateTestCaseTests: XCTestCase {

    private let mockData = """
    {
      "count": 48,
      "criteriaSets": [
        {
          "criteriaId": "48",
          "name": "Custom event",
          "createdAt": 1716561634904,
          "updatedAt": 1716561634904,
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
                          "value": "button-clicked",
                          "fieldType": "string"
                        },
                        {
                          "dataType": "customEvent",
                          "field": "button-clicked.lastPageViewed",
                          "comparatorType": "Equals",
                          "value": "signup page",
                          "fieldType": "string"
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

    override func setUp() {
        super.setUp()
    }

    func data(from jsonString: String) -> Data? {
        return jsonString.data(using: .utf8)
    }

    func testCompareDataWithCustomEventCriteriaFailed1() {
        let eventItems: [[AnyHashable: Any]] = [
            ["dataType": "customEvent", "createdAt": 1699246745093, "eventName": "button-clicked", "dataFields": ["button-clicked.lastPageViewed": "signup page"]
            ]]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    func testCompareDataWithCustomEventCriteriaFailed2() {
        let eventItems: [[AnyHashable: Any]] = [
            ["dataType": "customEvent", "createdAt": 1699246745093, "eventName": "button-clicked", "dataFields": ["button-clicked.button-clicked.lastPageViewed": "signup page"]
            ]]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    func testCompareDataWithCustomEventCriteriaFailed3() {
        let eventItems: [[AnyHashable: Any]] = [
            ["dataType": "customEvent", "createdAt": 1699246745093, "eventName": "button-clicked", "dataFields": ["button-clicked": ["button-clicked.lastPageViewed": "signup page"]]
            ]]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    func testCompareDataWithCustomEventCriteriaFailed4() {
        let eventItems: [[AnyHashable: Any]] = [
            ["dataType": "customEvent", "createdAt": 1699246745093, "eventName": "button-clicked", "dataFields": ["button-clicked": ["lastPageViewed": "signup page"]]
            ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    func testCompareDataWithCustomEventCriteriaSuccessCase() {
        let eventItems: [[AnyHashable: Any]] = [
            ["dataType": "customEvent", "createdAt": 1699246745093, "eventName": "button-clicked", "dataFields": ["lastPageViewed": "signup page"]
            ]]
        let expectedCriteriaId = "48"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }


    private let mockDataForMultiLevelNested = """
    {
        "count": 3,
        "criteriaSets": [
            {
                "criteriaId": "425",
                "name": "Multi level Nested field criteria",
                "createdAt": 1726811375306,
                "updatedAt": 1726811375306,
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
                                                "field": "button-clicked.updateCart.updatedShoppingCartItems.quantity",
                                                "comparatorType": "Equals",
                                                "value": "10",
                                                "fieldType": "long"
                                            },
                                            {
                                                "dataType": "customEvent",
                                                "field": "button-clicked.browserVisit.website.domain",
                                                "comparatorType": "Equals",
                                                "value": "https://mybrand.com/socks",
                                                "fieldType": "string"
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

    func testMultiLevelNestedFailed1() {
        let eventItems: [[AnyHashable: Any]] = [
            [
              "dataType": "customEvent",
              "createdAt": 1699246745093,
              "eventName": "button-clicked",
              "dataFields": [
                "updateCart": [
                  "updatedShoppingCartItems": [
                    "quantity": 10
                  ]
                ],
                "browserVisit": [
                  "website.domain": "https://mybrand.com/socks"
                ]
              ]
            ]
          ]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForMultiLevelNested)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    func testMultiLevelNestedFailed2() {
        let eventItems: [[AnyHashable: Any]] = [
            [
              "dataType": "customEvent",
              "createdAt": 1699246745093,
              "eventName": "button-clicked",
              "dataFields": [
                "updateCart": [
                  "updatedShoppingCartItems.quantity": 10
                ],
                "browserVisit": [
                  "website.domain": "https://mybrand.com/socks"
                ]
              ]
            ]
          ]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForMultiLevelNested)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    func testMultiLevelNestedFailed3() {
        let eventItems: [[AnyHashable: Any]] = [
            [
              "dataType": "customEvent",
              "createdAt": 1699246745093,
              "eventName": "button-clicked",
              "dataFields": [
                "button-clicked": [
                  "updateCart": [
                    "updatedShoppingCartItems": [
                      "quantity": 10
                    ]
                  ],
                  "browserVisit": [
                    "website": [
                      "domain": "https://mybrand.com/socks"
                    ]
                  ]
                ]
              ]
            ]
          ]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForMultiLevelNested)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    func testMultiLevelNestedFailed4() {
        let eventItems: [[AnyHashable: Any]] = [
            [
              "dataType": "customEvent",
              "createdAt": 1699246745093,
              "eventName": "button-clicked",
              "dataFields": [
                "quantity": 10,
                "domain": "https://mybrand.com/socks"
              ]
            ]
          ]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForMultiLevelNested)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    func testMultiLevelNestedSuccessCase() {
        let eventItems: [[AnyHashable: Any]] = [
            [
              "dataType": "customEvent",
              "createdAt": 1699246745093,
              "eventName": "button-clicked",
              "dataFields": [
                "updateCart": [
                  "updatedShoppingCartItems": [
                    "quantity": 10
                  ]
                ],
                "browserVisit": [
                  "website": [
                    "domain": "https://mybrand.com/socks"
                  ]
                ]
              ]
            ]
          ]
        let expectedCriteriaId = "425"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForMultiLevelNested)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }
}

