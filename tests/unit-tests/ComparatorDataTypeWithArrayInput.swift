//
//  ComparatorDataTypeWithArrayInput.swift
//  unit-tests
//
//  Created by Apple on 21/08/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import XCTest
@testable import IterableSDK

final class ComparatorDataTypeWithArrayInput: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func data(from jsonString: String) -> Data? {
        return jsonString.data(using: .utf8)
    }
    //MARK: Comparator Equal For MileStoneYear Array
    private let mockDataMileStoneYearEqual = """
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
                             "field": "milestoneYears",
                             "fieldType": "string",
                             "comparatorType": "Equals",
                             "dataType": "user",
                             "id": 2,
                             "value": "1997"
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

    func testMockDataMileStoneYearEqualSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "milestoneYears": [1996, 1997, 2002, 2020, 2024]
        ]]
        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataMileStoneYearEqual)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testMockDataMileStoneYearEqualFailure() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "milestoneYears": [1996, 1998, 2002, 2020, 2024]
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataMileStoneYearEqual)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator DoesNotEqual For MileStoneYear Array
    private let mockDataMileStoneYearDoesNotEqual = """
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
                             "field": "milestoneYears",
                             "fieldType": "string",
                             "comparatorType": "DoesNotEqual",
                             "dataType": "user",
                             "id": 2,
                             "value": "1997"
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

    func testMockDataMileStoneYearDoesNotEqualSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "milestoneYears": [1996, 1998, 2002, 2020, 2024]
        ]]
        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataMileStoneYearDoesNotEqual)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testMockDataMileStoneYearDoesNotEqualFailure() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "milestoneYears": [1996, 1997, 2002, 2020, 2024]
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataMileStoneYearDoesNotEqual)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }


    //MARK: Comparator GreaterThan For MileStoneYear Array
    private let mockDataMileStoneYearGreaterThan = """
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
                             "field": "milestoneYears",
                             "fieldType": "string",
                             "comparatorType": "GreaterThan",
                             "dataType": "user",
                             "id": 2,
                             "value": "1997"
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

    func testMockDataMileStoneYearGreaterThanSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "milestoneYears": [1996, 1998, 2002, 2020, 2024]
        ]]
        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataMileStoneYearGreaterThan)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testMockDataMileStoneYearGreaterThanFailure() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "milestoneYears": [1990, 1992, 1994, 1997]
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataMileStoneYearGreaterThan)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }


    //MARK: Comparator GreaterThanOrEqualTo For MileStoneYear Array
    private let mockDataMileStoneYearGreaterThanOrEqualTo = """
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
                             "field": "milestoneYears",
                             "fieldType": "string",
                             "comparatorType": "GreaterThanOrEqualTo",
                             "dataType": "user",
                             "id": 2,
                             "value": "1997"
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

    func testMockDataMileStoneYearGreaterThanOrEqualToSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "milestoneYears": [1997, 1998, 2002, 2020, 2024]
        ]]
        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataMileStoneYearGreaterThanOrEqualTo)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testMockDataMileStoneYearGreaterThanOrEqualToFailure() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "milestoneYears": [1990, 1992, 1994, 1996]
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataMileStoneYearGreaterThanOrEqualTo)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator LessThan For MileStoneYear Array
    private let mockDataMileStoneYearLessThan = """
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
                             "field": "milestoneYears",
                             "fieldType": "string",
                             "comparatorType": "LessThan",
                             "dataType": "user",
                             "id": 2,
                             "value": "1997"
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

    func testMockDataMileStoneYearLessThanSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "milestoneYears": [1990, 1992, 1994, 1996, 1998]
        ]]
        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataMileStoneYearLessThan)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testMockDataMileStoneYearLessThanFailure() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "milestoneYears": [1997, 1999, 2002, 2004]
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataMileStoneYearLessThan)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator LessThanOrEqualTo For MileStoneYear Array
    private let mockDataMileStoneYearLessThanOrEquaTo = """
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
                             "field": "milestoneYears",
                             "fieldType": "string",
                             "comparatorType": "LessThanOrEqualTo",
                             "dataType": "user",
                             "id": 2,
                             "value": "1997"
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

    func testMockDataMileStoneYearLessThanOrEqualToSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "milestoneYears": [1990, 1992, 1994, 1996, 1998]
        ]]
        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataMileStoneYearLessThanOrEquaTo)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testMockDataMileStoneYearLessThanOrEqualFailure() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "milestoneYears": [1998, 1999, 2002, 2004]
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataMileStoneYearLessThanOrEquaTo)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator Contain For String Array
    private let mockDataForArrayContains = """
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
                             "field": "addresses",
                             "fieldType": "string",
                             "comparatorType": "Contains",
                             "dataType": "user",
                             "id": 2,
                             "value": "US"
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

    func testMockDataMockDataForArrayContainsSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "addresses": ["US", "UK", "USA"]
        ]]
        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForArrayContains)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testMockDataMockDataForArrayContainsFailure() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "addresses": ["UK", "USA"]
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForArrayContains)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator Contain For String Array
    private let mockDataForArrayStartWith = """
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
                             "field": "addresses",
                             "fieldType": "string",
                             "comparatorType": "StartsWith",
                             "dataType": "user",
                             "id": 2,
                             "value": "US"
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

    func testMockDataMockDataForArrayStartWithSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "addresses": [ "US, New York",
                           "US, San Francisco",
                           "US, San Diego",
                           "US, Los Angeles",
                           "JP, Tokyo",
                           "DE, Berlin",
                           "GB, London"]
        ]]
        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForArrayStartWith)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testMockDataMockDataForArrayStartWithFailure() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "addresses": [ "JP",
                           "Tokyo",
                           "DE, Berlin",
                           "GB",
                           "London"]
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForArrayStartWith)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator Contain For String Array
    private let mockDataForArrayMatchRegex = """
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
                             "field": "addresses",
                             "fieldType": "string",
                             "comparatorType": "MatchesRegex",
                             "dataType": "user",
                             "id": 2,
                             "value": "^(JP|DE|GB)"
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

    func testMockDataMockDataForArrayMatchRegexSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "addresses": [ "JP",
                           "Tokyo",
                           "DE, Berlin",
                           "GB",
                           "London"]
            ]]
        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForArrayMatchRegex)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testMockDataMockDataForArrayMatchRegexFailure() {
        let eventItems: [[AnyHashable: Any]] = [[
            "dataType": "user",
            "createdAt": 1699246745093,
            "addresses": [ "US, New York",
                           "US, San Francisco",
                           "US, San Diego",
                           "US, Los Angeles",
                           ]
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForArrayMatchRegex)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator DoesNotEqual For MileStoneYear Array
    private let mockDataStringArrayMixCriteArea = """
       {
         "count": 1,
         "criteriaSets": [
           {
               "criteriaId": "382",
               "name": "comparison_for_Array_data_types_or",
               "createdAt": 1724315593795,
               "updatedAt": 1724315593795,
               "searchQuery": {
                   "combinator": "And",
                   "searchQueries": [
                       {
                           "combinator": "Or",
                           "searchQueries": [
                               {
                                   "dataType": "user",
                                   "searchCombo": {
                                       "combinator": "And",
                                       "searchQueries": [
                                           {
                                               "dataType": "user",
                                               "field": "milestoneYears",
                                               "comparatorType": "GreaterThan",
                                               "value": "1997",
                                               "fieldType": "long"
                                           }
                                       ]
                                   }
                               },
                               {
                                   "dataType": "customEvent",
                                   "searchCombo": {
                                       "combinator": "And",
                                       "searchQueries": [
                                           {
                                               "dataType": "customEvent",
                                               "field": "button-clicked.animal",
                                               "comparatorType": "DoesNotEqual",
                                               "value": "giraffe",
                                               "fieldType": "string"
                                           }
                                       ]
                                   }
                               },
                               {
                                   "dataType": "purchase",
                                   "searchCombo": {
                                       "combinator": "And",
                                       "searchQueries": [
                                           {
                                               "dataType": "purchase",
                                               "field": "total",
                                               "comparatorType": "LessThanOrEqualTo",
                                               "value": "200",
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

    func testMockDataStringArrayDoesNotEqualSuccess() {
        let eventItems: [[AnyHashable: Any]] = [
            [
                "dataType": "user",
                "createdAt": 1699246745093,
                "milestoneYears": [1998, 1999, 2002, 2004]
            ],
            [
                "dataType": "customEvent",
                "eventName": "button-clicked",
                "dataFields": ["animal": ["zirraf", "horse"]]
            ],
            [
                "dataType": "purchase",
                "total": [199.99, 210.0, 220.20, 250.10]
            ]
        ]
        let expectedCriteriaId = "382"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataStringArrayMixCriteArea)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testMockDataStringArrayDoesNotEqualFailure() {
        let eventItems: [[AnyHashable: Any]] = [
            [
                "dataType": "user",
                "createdAt": 1699246745093,
                "milestoneYears": [1990, 1992, 1996,1997]
            ],
            [
                "dataType": "customEvent",
                "eventName": "button-clicked",
                "dataFields": ["animal": ["zirraf", "horse", "giraffe"]]

            ],
            [
                "dataType": "purchase",
                "total": [210.0, 220.20, 250.10]
            ]
        ]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataStringArrayMixCriteArea)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
}
