//
//  SavingComplexCriteriaMatch.swift
//  unit-tests
//
//  Created by Apple on 01/08/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import XCTest
@testable import IterableSDK

final class DataTypeComparatorSearchQueryCriteria: XCTestCase {

    //MARK: Comparator test For Equal
    private let mockDataEqual = """
       {
         "count": 1,
         "criteriaSets": [
           {
             "criteriaId": "285",
             "name": "Criteria_EventTimeStamp_3_Long",
             "createdAt": 1722497422151,
             "updatedAt": 1722500235276,
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
                             "comparatorType": "Equals",
                             "value": "3",
                             "fieldType": "long"
                           },
                            {
                              "dataType": "user",
                              "field": "savings",
                              "comparatorType": "Equals",
                              "value": "19.99",
                              "fieldType": "double"
                            },
                            {
                              "dataType": "user",
                              "field": "likes_boba",
                              "comparatorType": "Equals",
                              "value": "true",
                              "fieldType": "boolean"
                            },
                            {
                              "dataType": "user",
                              "field": "country",
                              "comparatorType": "Equals",
                              "value": "Chaina",
                              "fieldType": "String"
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

    func testCompareDataEqualSuccess() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["savings": 19.99,                       "eventTimeStamp": 3,
                                                          "likes_boba": true,
                                                          "country":"Chaina"]]]

        let expectedCriteriaId = "285"

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataEqual)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataEqualFailed() {

        //let eventItems: [[AnyHashable: Any]] = [["dataType":"user","savings": 10.1]]

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["savings": 10.99,                       "eventTimeStamp": 30,
                                                          "likes_boba": false,
                                                            "country":"Taiwan"]]]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataEqual)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator test For DoesNotEqual
    private let mockDataDoesNotEquals = """
       {
         "count": 1,
         "criteriaSets": [
           {
             "criteriaId": "285",
             "name": "Criteria_EventTimeStamp_3_Long",
             "createdAt": 1722497422151,
             "updatedAt": 1722500235276,
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
                             "value": "3",
                             "fieldType": "long"
                           },
                            {
                              "dataType": "user",
                              "field": "savings",
                              "comparatorType": "DoesNotEqual",
                              "value": "19.99",
                              "fieldType": "double"
                            },
                            {
                              "dataType": "user",
                              "field": "likes_boba",
                              "comparatorType": "DoesNotEqual",
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


    func testCompareDataDoesNotEqualSuccess() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["savings": 11.2,                       "eventTimeStamp": 30,
                                                     "likes_boba": false]
                                                 ]]
        let expectedCriteriaId = "285"

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataDoesNotEquals)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataDoesNotEqualFailed() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["savings": 19.99,                       "eventTimeStamp": 30,
                                                               "likes_boba": true]]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataDoesNotEquals)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator test For LessThan and LessThanOrEqual
    private let mockDataLessThanOrEqual = """
            {
                "count": 1,
                "criteriaSets": [
                    {
                       "criteriaId": "289",
                       "name": "Criteria_EventTimeStamp_3_Long",
                       "createdAt": 1722497422151,
                       "updatedAt": 1722500235276,
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
                                                       "comparatorType": "LessThan",
                                                       "value": "15",
                                                       "fieldType": "long"
                                                   },
                                                   {
                                                       "dataType": "user",
                                                       "field": "savings",
                                                       "comparatorType": "LessThan",
                                                       "value": "15",
                                                       "fieldType": "double"
                                                   }
                                               ]
                                           }
                                       }
                                   ]
                               }
                           ]
                       }
                   },
                   {
                       "criteriaId": "290",
                       "name": "Criteria_EventTimeStamp_3_Long",
                       "createdAt": 1722497422151,
                       "updatedAt": 1722500235276,
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
                                                       "comparatorType": "LessThanOrEqualTo",
                                                       "value": "17",
                                                       "fieldType": "long"
                                                   },
                                                   {
                                                       "dataType": "user",
                                                       "field": "savings",
                                                       "comparatorType": "LessThanOrEqualTo",
                                                       "value": "17",
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


    func testCompareDataLessThanSuccess() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                "dataFields":["savings": 10,                       "eventTimeStamp": 14]
                                                ]]
        let expectedCriteriaId = "289"

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataLessThanOrEqual)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataLessThanFailed() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["savings": 18,                       "eventTimeStamp": 18]]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataLessThanOrEqual)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    func testCompareDataLessThanOrEqualSuccess() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["savings": 17,                               "eventTimeStamp": 14]]]
        let expectedCriteriaId = "290"

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataLessThanOrEqual)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataLessThanOrEqualFailed() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["savings": 18,                               "eventTimeStamp": 12]]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataLessThanOrEqual)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator test For GreaterThan and GreaterThanOrEqual
    private let mockDataGreaterThanOrEqual = """
            {
                "count": 1,
                "criteriaSets": [
                    {
                       "criteriaId": "290",
                       "name": "Criteria_EventTimeStamp_3_Long",
                       "createdAt": 1722497422151,
                       "updatedAt": 1722500235276,
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
                                                       "comparatorType": "GreaterThan",
                                                       "value": "50",
                                                       "fieldType": "long"
                                                   },
                                                   {
                                                       "dataType": "user",
                                                       "field": "savings",
                                                       "comparatorType": "GreaterThan",
                                                       "value": "55",
                                                       "fieldType": "double"
                                                   }
                                               ]
                                           }
                                       }
                                   ]
                               }
                           ]
                       }
                   },
                   {
                       "criteriaId": "291",
                       "name": "Criteria_EventTimeStamp_3_Long",
                       "createdAt": 1722497422151,
                       "updatedAt": 1722500235276,
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
                                                       "comparatorType": "GreaterThanOrEqualTo",
                                                       "value": "20",
                                                       "fieldType": "long"
                                                   },
                                                   {
                                                       "dataType": "user",
                                                       "field": "savings",
                                                       "comparatorType": "GreaterThanOrEqualTo",
                                                       "value": "20",
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


    func testCompareDataGreaterThanSuccess() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["savings": 56,                               "eventTimeStamp": 51]]]
        let expectedCriteriaId = "290"

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataGreaterThanOrEqual)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataGreaterThanFailed() {

        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["savings": 5,                               "eventTimeStamp": 3]]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataGreaterThanOrEqual)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    func testCompareDataGreaterThanOrEqualSuccess() {

        let eventItems: [[AnyHashable: Any]] = [["dataType": "user", 
                                                 "dataFields":["savings": 20,                               "eventTimeStamp": 30]]]
        let expectedCriteriaId = "291"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataGreaterThanOrEqual)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataGreaterThanOrEqualFailed() {
        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["savings": 18,                               "eventTimeStamp":16]]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataGreaterThanOrEqual)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }


    //MARK: Comparator test For IsSet
    private let mockDataIsSet = """
       {
         "count": 1,
         "criteriaSets": [
           {
             "criteriaId": "285",
             "name": "Criteria_EventTimeStamp_3_Long",
             "createdAt": 1722497422151,
             "updatedAt": 1722500235276,
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
                             "comparatorType": "IsSet",
                             "value": "",
                             "fieldType": "long"
                           },
                           {
                               "dataType": "user",
                               "field": "savings",
                               "comparatorType": "IsSet",
                               "value": "",
                               "fieldType": "double"
                           },
                            {
                               "dataType": "user",
                               "field": "saved_cars",
                               "comparatorType": "IsSet",
                               "value": "",
                               "fieldType": "double"
                           },
                            {
                               "dataType": "user",
                               "field": "country",
                               "comparatorType": "IsSet",
                               "value": "",
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

    func testCompareDataIsSetySuccess() {
        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["savings": 10,                               "eventTimeStamp":20,
                                                               "saved_cars":"10",
                                                               "country": "Taiwan"]]]
        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataIsSet)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataIsSetFailure() {
        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "dataFields":["savings": "",                               "eventTimeStamp":"",
                                                               "saved_cars":"",
                                                               "country": ""]]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataIsSet)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }


    //MARK: Comparator test For IsSet
    private let mockDataContainRegexStartWith = """
        {
            "count": 1,
            "criteriaSets": [
                {
                    "criteriaId": "288",
                    "name": "Criteria_Country_User",
                    "createdAt": 1722511481998,
                    "updatedAt": 1722511481998,
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
                                                    "comparatorType": "MatchesRegex",
                                                    "value": "^T.*iwa.*n$",
                                                    "fieldType": "string"
                                                },
                                                {
                                                    "dataType": "user",
                                                    "field": "country",
                                                    "comparatorType": "StartsWith",
                                                    "value": "T",
                                                    "fieldType": "string"
                                                },
                                                 {
                                                     "dataType": "user",
                                                     "field": "country",
                                                     "comparatorType": "Contains",
                                                     "value": "wan",
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

    func testCompareDataMatchesRegexSuccess() {
        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "country":"Taiwan"]]
        let expectedCriteriaId = "288"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataContainRegexStartWith)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataMatchesRegexFailure() {
        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "country":"Chaina",
                                                 "phoneNumber": "1212567"]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataContainRegexStartWith)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    func testCompareDataStartWithFailure() {
        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "country":"Chaina"]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataContainRegexStartWith)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    func testCompareDataContainFailure() {
        let eventItems: [[AnyHashable: Any]] = [["dataType":"user",
                                                 "country":"ina"]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataContainRegexStartWith)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

}
