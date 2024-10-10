//
//  NestedFieldSupportForArrayData.swift
//  unit-tests
//
//  Created by Apple on 27/08/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import XCTest
@testable import IterableSDK

final class NestedFieldSupportForArrayData: XCTestCase {
    //MARK: Comparator test For End
    private let mockData = """
       {
         "count": 1,
         "criteriaSets": [
           {
               "criteriaId": "168",
               "name": "nested testing",
               "createdAt": 1721251169153,
               "updatedAt": 1723488175352,
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
                                               "field": "furniture",
                                               "comparatorType": "IsSet",
                                               "value": "",
                                               "fieldType": "nested"
                                           },
                                           {
                                               "dataType": "user",
                                               "field": "furniture.furnitureColor",
                                               "comparatorType": "Equals",
                                               "value": "White",
                                               "fieldType": "string"
                                           },
                                           {
                                               "dataType": "user",
                                               "field": "furniture.furnitureType",
                                               "comparatorType": "Equals",
                                               "value": "Sofa",
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

    func testNestedFieldSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            [
                "dataType":"user",
                 "email":"user@example.com",
                 "dataFields":[
                    "furniture": [
                        [
                            "furnitureType": "Sofa",
                            "furnitureColor": "White",
                            "lengthInches": 40,
                            "widthInches": 60
                        ],
                        [
                            "furnitureType": "Table",
                            "furnitureColor": "Gray",
                            "lengthInches": 20,
                            "widthInches": 30
                        ],
                    ]
                ]
            ]
        ]


        let expectedCriteriaId = "168"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testNestedFieldFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            [
                "dataType":"user",
                 "email":"user@example.com",
                 "dataFields":[
                    "furniture": [
                        [
                            "furnitureType": "Sofa",
                            "furnitureColor": "Gray",
                            "lengthInches": 40,
                            "widthInches": 60
                        ],
                        [
                            "furnitureType": "Table",
                            "furnitureColor": "White",
                            "lengthInches": 20,
                            "widthInches": 30
                        ],
                    ]
                ]
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    private let mokeDataForUserArray = """
           {
             "count": 1,
             "criteriaSets": [
                     {
                         "criteriaId": "436",
                         "name": "Criteria 2.1 - 09252024 Bug Bash",
                         "createdAt": 1727286807360,
                         "updatedAt": 1727950464167,
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
                                                         "field": "furniture.material.type",
                                                         "comparatorType": "Contains",
                                                         "value": "table",
                                                         "fieldType": "string"
                                                     },
                                                     {
                                                         "dataType": "user",
                                                         "field": "furniture.material.color",
                                                         "comparatorType": "Equals",
                                                         "values": [
                                                             "black"
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
    func testNestedFieldArrayValueUserSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            [
              "dataType": "user",
              "dataFields": [
                "furniture": [
                  "material": [
                    [
                      "type": "table",
                      "color": "black",
                      "lengthInches": 40,
                      "widthInches": 60
                    ],
                    [
                      "type": "Sofa",
                      "color": "Gray",
                      "lengthInches": 20,
                      "widthInches": 30
                    ]
                  ]
                ]
              ]
            ]
          ]


        let expectedCriteriaId = "436"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mokeDataForUserArray)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testNestedFieldArrayUserValueFail() {

        let eventItems: [[AnyHashable: Any]] = [
            [
              "dataType": "user",
              "dataFields": [
                "furniture": [
                  "material": [
                    [
                      "type": "Chair",
                      "color": "black",
                      "lengthInches": 40,
                      "widthInches": 60
                    ],
                    [
                      "type": "Sofa",
                      "color": "black",
                      "lengthInches": 20,
                      "widthInches": 30
                    ]
                  ]
                ]
              ]
            ]
          ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mokeDataForUserArray)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    private let mokeDataForEventArray = """
           {
             "count": 1,
             "criteriaSets": [
                    {
                         "criteriaId": "459",
                         "name": "event a.h.b=d && a.h.c=g",
                         "createdAt": 1727717997842,
                         "updatedAt": 1728024187962,
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
                                                         "field": "TopLevelArrayObject.a.h.b",
                                                         "comparatorType": "Equals",
                                                         "value": "d",
                                                         "fieldType": "string"
                                                     },
                                                     {
                                                         "dataType": "customEvent",
                                                         "field": "TopLevelArrayObject.a.h.c",
                                                         "comparatorType": "Equals",
                                                         "value": "g",
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
    func testNestedFieldArrayValueEventSuccess() {
        let eventItems: [[AnyHashable: Any]] = [
            [
              "dataType": "customEvent",
              "eventName": "TopLevelArrayObject",
              "dataFields": [
                "a": ["h": [["b": "e",
                             "c": "h"],
                            ["b": "d",
                             "c": "g"]]]
              ]
            ]
          ]


        let expectedCriteriaId = "459"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mokeDataForEventArray)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testNestedFieldArrayEventValueFail() {

        let eventItems: [[AnyHashable: Any]] = [
            [
              "dataType": "customEvent",
              "eventName": "TopLevelArrayObject",
              "dataFields": [
                "a": ["h": [["b": "d",
                             "c": "h"],
                            ["b": "e",
                             "c": "g"]]]
              ]
            ]
          ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mokeDataForEventArray)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
}
