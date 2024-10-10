//
//  IsOneOfInNonOfCriteareaTest.swift
//  unit-tests
//
//  Created by Apple on 02/09/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import XCTest
@testable import IterableSDK

final class IsOneOfInNotOneOfCriteareaTest: XCTestCase {

    //MARK: Comparator test For End
    private let mockDataIsOneOf = """
       {
         "count": 1,
         "criteriaSets": [
           {
               "criteriaId": "299",
               "name": "Criteria_IsNonOf_Is_One_of",
               "createdAt": 1722851586508,
               "updatedAt": 1725268680330,
               "searchQuery": {
                   "combinator": "And",
                   "searchQueries": [
                       {
                           "combinator": "And",
                           "searchQueries": [
                               {
                                   "dataType": "user",
                                   "searchCombo": {
                                       "combinator": "And",
                                       "searchQueries": [
                                           {
                                               "dataType": "user",
                                               "field": "country",
                                               "comparatorType": "Equals",
                                               "values": [
                                                   "China",
                                                   "Japan",
                                                   "Kenya"
                                               ]
                                           },
                                           {
                                               "dataType": "user",
                                               "field": "addresses",
                                               "comparatorType": "Equals",
                                               "values": [
                                                    "JP",
                                                    "DE",
                                                    "GB"
                                               ]
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

    func testCompareIsOneOfSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "dataFields": ["country": "China",
                            "addresses": ["US", "UK", "JP", "DE", "GB"]
                           ]
            ]
        ]


        let expectedCriteriaId = "299"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataIsOneOf)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareIsOneOfFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "dataFields": ["country": "Korea",
                            "addresses": ["US", "UK"]
                           ]
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataIsOneOf)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator test For End
    private let mockDataIsNotOneOf = """
       {
         "count": 1,
         "criteriaSets": [
           {
               "criteriaId": "299",
               "name": "Criteria_IsNonOf_Is_One_of",
               "createdAt": 1722851586508,
               "updatedAt": 1725268680330,
               "searchQuery": {
                   "combinator": "And",
                   "searchQueries": [
                       {
                           "combinator": "And",
                           "searchQueries": [
                               {
                                   "dataType": "user",
                                   "searchCombo": {
                                       "combinator": "And",
                                       "searchQueries": [
                                           {
                                               "dataType": "user",
                                               "field": "country",
                                               "comparatorType": "DoesNotEqual",
                                               "values": [
                                                   "China",
                                                   "Japan",
                                                   "Kenya"
                                               ]
                                           },
                                           {
                                               "dataType": "user",
                                               "field": "addresses",
                                               "comparatorType": "DoesNotEqual",
                                               "values": [
                                                    "JP",
                                                    "DE",
                                                    "GB"
                                               ]
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

    func testCompareIsNotOneOfSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "dataFields": ["country": "Korea",
                            "addresses": ["US", "UK"]
                           ]
            ]
        ]


        let expectedCriteriaId = "299"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataIsNotOneOf)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareIsNotOneOfFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "dataFields": ["country": "China",
                            "addresses": ["US", "UK", "JP", "DE", "GB"]
                           ]
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataIsNotOneOf)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }


    private let mockDataCrashTest = """
       {
         "count": 1,
         "criteriaSets": [
           {
               "criteriaId": "403",
               "name": "button-clicked.animal isNotOneOf [cat,giraffe,hippo,horse]",
               "createdAt": 1725471874865,
               "updatedAt": 1725631049514,
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
                                               "field": "button-clicked.animal",
                                               "comparatorType": "DoesNotEqual",
                                               "values": [
                                                   "cat",
                                                   "giraffe",
                                                   "hippo",
                                                   "horse"
                                               ]
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

    func testCompareMockDataCrashTest() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"customEvent",
             "dataFields": ["button-clicked": ["animal":"dog"]]
            ]
        ]


        let expectedCriteriaId = "403"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCrashTest)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

}
