//
//  CombinationComplexCriteria.swift
//  unit-tests
//
//  Created by Apple on 05/09/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import XCTest
@testable import IterableSDK

final class CombinationComplexCriteria: XCTestCase {
    //MARK: Comparator test For End
    private let mockDataComplexCriteria1 = """
       {
         "count": 1,
         "criteriaSets": [
           {
             "criteriaId": "290",
             "name": "Complex Criteria Unit Test #1",
             "createdAt": 1722532861551,
             "updatedAt": 1722532861551,
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
                             "field": "firstName",
                             "comparatorType": "StartsWith",
                             "value": "A",
                             "fieldType": "string"
                           }
                         ]
                       }
                     },
                     {
                       "dataType": "user",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "dataType": "user",
                             "field": "firstName",
                             "comparatorType": "StartsWith",
                             "value": "B",
                             "fieldType": "string"
                           }
                         ]
                       }
                     },
                     {
                       "dataType": "user",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "dataType": "user",
                             "field": "firstName",
                             "comparatorType": "StartsWith",
                             "value": "C",
                             "fieldType": "string"
                           }
                         ]
                       }
                     }
                   ]
                 },
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
                             "comparatorType": "IsSet",
                             "value": "",
                             "fieldType": "string"
                           },
                           {
                             "dataType": "customEvent",
                             "field": "saved_cars.color",
                             "comparatorType": "IsSet",
                             "value": "",
                             "fieldType": "string"
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
                             "field": "eventName",
                             "comparatorType": "IsSet",
                             "value": "",
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
                 },
                 {
                   "combinator": "Not",
                   "searchQueries": [
                     {
                       "dataType": "purchase",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "dataType": "purchase",
                             "field": "total",
                             "comparatorType": "LessThanOrEqualTo",
                             "value": "100",
                             "fieldType": "double"
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
                             "field": "reason",
                             "comparatorType": "Equals",
                             "value": "testing",
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

    func testComplexCriteria1Success() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "dataFields": ["firstName": "Alex"]
            ],
            ["dataType": "customEvent",
             "eventName": "saved_cars",
             "dataFields": ["color":"black"]
            ],
            ["dataType": "customEvent",
             "eventName": "animal-found",
             "dataFields": ["vaccinated":true]
            ],
            ["dataType": "purchase",
             "dataFields": ["total": 30,
                            "reason":"testing"]
            ]
        ]


        let expectedCriteriaId = "290"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataComplexCriteria1)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }


    func testComplexCriteria1Failed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "dataFields": ["firstName": "Alex"]
            ],
            ["dataType": "customEvent",
             "eventName": "saved_cars",
             "dataFields": ["color":""]
            ],
            ["dataType": "customEvent",
             "eventName": "animal-found",
             "dataFields": ["vaccinated":true]
            ],
            ["dataType": "purchase",
             "dataFields": ["total": 30,
                            "reason":"testing"]
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataComplexCriteria1)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    private let mockDataComplexCriteria2 = """
       {
         "count": 1,
         "criteriaSets": [
           {
             "criteriaId": "291",
             "name": "Complex Criteria Unit Test #2",
             "createdAt": 1722533473263,
             "updatedAt": 1722533473263,
             "searchQuery": {
               "combinator": "Or",
               "searchQueries": [
                 {
                   "combinator": "Not",
                   "searchQueries": [
                     {
                       "dataType": "user",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "dataType": "user",
                             "field": "firstName",
                             "comparatorType": "StartsWith",
                             "value": "A",
                             "fieldType": "string"
                           }
                         ]
                       }
                     },
                     {
                       "dataType": "user",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "dataType": "user",
                             "field": "firstName",
                             "comparatorType": "StartsWith",
                             "value": "B",
                             "fieldType": "string"
                           }
                         ]
                       }
                     },
                     {
                       "dataType": "user",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "dataType": "user",
                             "field": "firstName",
                             "comparatorType": "StartsWith",
                             "value": "C",
                             "fieldType": "string"
                           }
                         ]
                       }
                     }
                   ]
                 },
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
                             "comparatorType": "IsSet",
                             "value": "",
                             "fieldType": "string"
                           },
                           {
                             "dataType": "customEvent",
                             "field": "saved_cars.color",
                             "comparatorType": "IsSet",
                             "value": "",
                             "fieldType": "string"
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
                             "field": "animal-found.vaccinated",
                             "comparatorType": "Equals",
                             "value": "true",
                             "fieldType": "boolean"
                           }
                         ]
                       }
                     }
                   ]
                 },
                 {
                   "combinator": "Or",
                   "searchQueries": [
                     {
                       "dataType": "purchase",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "dataType": "purchase",
                             "field": "total",
                             "comparatorType": "GreaterThanOrEqualTo",
                             "value": "100",
                             "fieldType": "double"
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
                             "field": "reason",
                             "comparatorType": "DoesNotEqual",
                             "value": "gift",
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

    func testComplexCriteria2Success() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "dataFields": ["firstName": "xcode"]
            ],
            ["dataType": "customEvent",
             "eventName": "saved_cars",
             "dataFields": ["color":"black"]
            ],
            ["dataType": "customEvent",
             "eventName": "animal-found",
             "dataFields": ["vaccinated":true]
            ],
            ["dataType": "purchase",
             "dataFields": ["total": 110,
                            "reason":"testing"]
            ]
        ]

        let expectedCriteriaId = "291"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataComplexCriteria2)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testComplexCriteria2Failed() {
        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "dataFields": ["firstName": "Alex"]
            ],
            ["dataType": "purchase",
             "dataFields": ["total": 10,
                            "reason":"gift"]
            ]
          ]


        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataComplexCriteria2)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    private let mockDataComplexCriteria3 = """
       {
         "count": 1,
         "criteriaSets": [
           {
             "criteriaId": "292",
             "name": "Complex Criteria Unit Test #3",
             "createdAt": 1722533789589,
             "updatedAt": 1722533838989,
             "searchQuery": {
               "combinator": "Not",
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
                             "field": "firstName",
                             "comparatorType": "StartsWith",
                             "value": "A",
                             "fieldType": "string"
                           }
                         ]
                       }
                     },
                     {
                       "dataType": "user",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "dataType": "user",
                             "field": "lastName",
                             "comparatorType": "StartsWith",
                             "value": "A",
                             "fieldType": "string"
                           }
                         ]
                       }
                     }
                   ]
                 },
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
                             "field": "firstName",
                             "comparatorType": "StartsWith",
                             "value": "C",
                             "fieldType": "string"
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
                             "field": "animal-found.vaccinated",
                             "comparatorType": "Equals",
                             "value": "false",
                             "fieldType": "boolean"
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
                             "field": "animal-found.count",
                             "comparatorType": "LessThan",
                             "value": "5",
                             "fieldType": "long"
                           }
                         ]
                       }
                     }
                   ]
                 },
                 {
                    "combinator": "Not",
                    "searchQueries": [
                       {
                          "dataType": "purchase",
                          "searchCombo": {
                             "combinator": "And",
                             "searchQueries": [
                                {
                                   "dataType": "purchase",
                                   "field": "total",
                                   "comparatorType": "LessThanOrEqualTo",
                                   "value": "10",
                                   "fieldType": "double"
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
                                   "field": "shoppingCartItems.quantity",
                                   "comparatorType": "LessThanOrEqualTo",
                                   "value": "34",
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

    func testComplexCriteria3Success() {
        let eventItems: [[AnyHashable: Any]] = [
            [
             "dataType":"purchase",
             "createdAt": 1699246745093,
             "items": [["id": "12", "name": "coffee", "price": 100, "quantity": 2]]
            ]
        ]

        let expectedCriteriaId = "292"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataComplexCriteria3)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }
    
    func testComplexCriteria3Success2() {
        let eventItems: [[AnyHashable: Any]] = [
            [
             "dataType":"purchase",
             "createdAt": 1699246745067,
             "items": [["id": "12", "name": "kittens", "price": 2, "quantity": 2]]
            ]
        ]

        let expectedCriteriaId = "292"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataComplexCriteria3)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testComplexCriteria3Fail() {
        let eventItems: [[AnyHashable: Any]] = [
            [
             "dataType":"purchase",
             "createdAt": 1699246745093,
             "items": [["id": "12", "name": "coffee", "price": 100, "quantity": 2]]
            ],
            ["dataType":"user",
             "dataFields": ["firstName": "Alex", "lastName":"Aris"]
            ]
        ]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataComplexCriteria3)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
}
