//
//  DoesNotEqualCriteriaMatch.swift
//  unit-tests
//
//  Created by Apple on 01/08/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import XCTest
@testable import IterableSDK

final class ComparatorTypeDoesNotEqualMatchTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func data(from jsonString: String) -> Data? {
        return jsonString.data(using: .utf8)
    }

    private let mokeDataBool = """
       {
         "count": 1,
         "criteriaSets": [
        {
                    "criteriaId": "194",
                    "name": "Contact: Phone Number != 57688559",
                    "createdAt": 1721337331194,
                    "updatedAt": 1722338525737,
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
                                                    "field": "subscribed",
                                                    "fieldType": "boolean",
                                                    "comparatorType": "DoesNotEqual",
                                                    "dataType": "user",
                                                    "id": 25,
                                                    "value": "true"
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

    func testCompareDataSuccessForBool() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["subscribed": false
                                                              ]]]
        let expectedCriteriaId = "194"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mokeDataBool)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataFailedForBool() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["subscribed": true,
                                                               ]]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mokeDataBool)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    private let mokeDataString = """
       {
         "count": 1,
         "criteriaSets": [
        {
                    "criteriaId": "195",
                    "name": "Contact: Phone Number != 57688559",
                    "createdAt": 1721337331194,
                    "updatedAt": 1722338525737,
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
                                                     "field": "phoneNumber",
                                                     "comparatorType": "DoesNotEqual",
                                                     "value": "57688559",
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

    func testCompareDataSuccessForString() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["phoneNumber": "123456"
                                                               ]]]
        let expectedCriteriaId = "195"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mokeDataString)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataFailedForString() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["phoneNumber": "57688559"
                                                               ]]]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mokeDataString)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }


    private let mokeDataDouble = """
       {
         "count": 1,
         "criteriaSets": [
        {
                    "criteriaId": "196",
                    "name": "Contact: Phone Number != 57688559",
                    "createdAt": 1721337331194,
                    "updatedAt": 1722338525737,
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
                                                      "field": "savings",
                                                      "comparatorType": "DoesNotEqual",
                                                      "value": "19.99",
                                                      "fieldType": "double"
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
    func testCompareDataSuccessForDouble() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["savings": 9.99
                                                               ]]]
        let expectedCriteriaId = "196"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mokeDataDouble)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataFailedForDouble() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["savings": 19.99
                                                               ]]]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mokeDataDouble)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    private let mokeDataLong = """
       {
         "count": 1,
         "criteriaSets": [
        {
                    "criteriaId": "197",
                    "name": "Contact: Phone Number != 57688559",
                    "createdAt": 1721337331194,
                    "updatedAt": 1722338525737,
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
                                                    "field": "eventTimeStamp",
                                                    "comparatorType": "DoesNotEqual",
                                                    "value": "15",
                                                    "fieldType": "long"
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

    func testCompareDataSuccessForLong() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["eventTimeStamp": 20
                                                               ]]]
        let expectedCriteriaId = "197"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mokeDataLong)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataFailedForLong() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["eventTimeStamp": 15
                                                               ]]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mokeDataLong)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

}

