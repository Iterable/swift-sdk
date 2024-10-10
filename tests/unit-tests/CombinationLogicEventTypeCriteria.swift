//
//  CombinationLogicEventTypeCriteria.swift
//  unit-tests
//
//  Created by Apple on 06/08/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import XCTest
@testable import IterableSDK

final class CombinationLogicEventTypeCriteria: XCTestCase {

    //MARK: Comparator test For End
    private let mockDataCombinatUserAnd = """
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
                             "field": "firstName",
                             "fieldType": "string",
                             "comparatorType": "Equals",
                             "dataType": "user",
                             "id": 2,
                             "value": "David"
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
                                "field": "total",
                                "fieldType": "double",
                                "comparatorType": "Equals",
                                "dataType": "customEvent",
                                "id": 6,
                                "value": "10"
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

    func testCompareDataUserAndSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "firstName": "David"
            ],
            ["total": "10",
             "dataType": "customEvent"
            ]
        ]


        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatUserAnd)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataUserAndFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "firstName": "David1"
            ],
            ["total": "10",
             "dataType": "customEvent"
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatUserAnd)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    private let mockDataCombinatUserOr = """
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
                   "combinator": "Or",
                   "searchQueries": [
                     {
                       "dataType": "user",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "field": "firstName",
                             "fieldType": "string",
                             "comparatorType": "Equals",
                             "dataType": "user",
                             "id": 2,
                             "value": "David"
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
                                "field": "total",
                                "fieldType": "double",
                                "comparatorType": "Equals",
                                "dataType": "customEvent",
                                "id": 6,
                                "value": "10"
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

    func testCompareDataUserOrSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "firstName": "David"
            ],
            ["total": "12",
             "dataType": "customEvent"
            ]
        ]


        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatUserOr)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataUserOrFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "firstName": "David1"
            ],
            ["total": "12",
             "dataType": "customEvent"
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatUserOr)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    private let mockDataCombinatUserNot = """
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
                   "combinator": "Not",
                   "searchQueries": [
                     {
                       "dataType": "user",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "field": "firstName",
                             "fieldType": "string",
                             "comparatorType": "Equals",
                             "dataType": "user",
                             "id": 2,
                             "value": "David"
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
                                "field": "total",
                                "fieldType": "double",
                                "comparatorType": "Equals",
                                "dataType": "customEvent",
                                "id": 6,
                                "value": "10"
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

    //First -> Wrong
    //Secon -> Correct


    func testCompareDataUserNotSuccess() {
        
        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "firstName": "Devidson"
            ],
            ["total": "13",
             "dataType": "customEvent"
            ]
        ]


        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatUserNot)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataUserNotFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "firstName": "David"
            ],
            ["total": "10",
             "dataType": "customEvent"
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatUserNot)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator test For UpdateCart And
    private let mockDataCombinatUpdateCartAnd = """
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
                       "dataType": "customEvent",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "field": "updateCart.updatedShoppingCartItems.name",
                             "fieldType": "string",
                             "comparatorType": "Equals",
                             "dataType": "customEvent",
                             "id": 8,
                             "value": "fried"
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
                                "field": "firstName",
                                "fieldType": "string",
                                "comparatorType": "Equals",
                                "dataType": "user",
                                "id": 10,
                                "value": "David"
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

    func testCompareDataUpdateCartAndSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "firstName": "David"
            ],
            ["items": [["id": "12",
                        "name": "fried",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"updateCart"
            ]
        ]

        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatUpdateCartAnd)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataUpdateCartAndFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "firstName": "David"
            ],
            ["items": [["id": "12",
                        "name": "frieded",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"updateCart"
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatUpdateCartAnd)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }


    //MARK: Comparator test For UpdateCart And
    private let mockDataCombinatUpdateCartOr = """
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
                   "combinator": "Or",
                   "searchQueries": [
                     {
                       "dataType": "customEvent",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "field": "updateCart.updatedShoppingCartItems.name",
                             "fieldType": "string",
                             "comparatorType": "Equals",
                             "dataType": "customEvent",
                             "id": 8,
                             "value": "fried"
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
                                "field": "firstName",
                                "fieldType": "string",
                                "comparatorType": "Equals",
                                "dataType": "user",
                                "id": 10,
                                "value": "David"
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

    func testCompareDataUpdateCartOrSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "firstName": "Davidson"
            ],
            ["items": [["id": "12",
                        "name": "fried",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"updateCart"
            ]
        ]

        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatUpdateCartOr)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataUpdateCartOrFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "firstName": "Davidjson"
            ],
            ["items": [["id": "12",
                        "name": "frieded",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"updateCart"
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatUpdateCartOr)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator test For UpdateCart And
    private let mockDataCombinatUpdateCartNot = """
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
                   "combinator": "Not",
                   "searchQueries": [
                     {
                       "dataType": "customEvent",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "field": "updateCart.updatedShoppingCartItems.name",
                             "fieldType": "string",
                             "comparatorType": "Equals",
                             "dataType": "customEvent",
                             "id": 8,
                             "value": "fried"
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
                                "field": "firstName",
                                "fieldType": "string",
                                "comparatorType": "Equals",
                                "dataType": "user",
                                "id": 10,
                                "value": "David"
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

    func testCompareDataUpdateCartNotSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "firstName": "Davidson"
            ],
            ["items": [["id": "12",
                        "name": "friedddd",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"updateCart"
            ]
        ]

        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatUpdateCartNot)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataUpdateCartNotFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["dataType":"user",
             "firstName": "David"
            ],
            ["items": [["id": "12",
                        "name": "fried",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"updateCart"
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatUpdateCartNot)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }



    //MARK: Comparator test For Purchase And
    private let mockDataCombinatPurchaseAnd = """
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
                       "dataType": "purchase",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "field": "shoppingCartItems.name",
                             "fieldType": "string",
                             "comparatorType": "Equals",
                             "dataType": "purchase",
                             "id": 13,
                             "value": "chicken"
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
                                "field": "updateCart.updatedShoppingCartItems.name",
                                "fieldType": "string",
                                "comparatorType": "Equals",
                                "dataType": "customEvent",
                                "id": 14,
                                "value": "fried"
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

    func testCompareDataPurchaseAndSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            ["items": [["id": "12",
                        "name": "chicken",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"purchase"
            ],
            ["items": [["id": "12",
                        "name": "fried",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"updateCart"
            ]
        ]

        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatPurchaseAnd)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataPurchaseAndFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["items": [["id": "12",
                        "name": "chicken1",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"purchase"
            ],
            ["items": [["id": "12",
                        "name": "fried1",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"updateCart"
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatPurchaseAnd)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }


    //MARK: Comparator test For Purchase Or
    private let mockDataCombinatPurchaseOr = """
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
                   "combinator": "Or",
                   "searchQueries": [
                     {
                       "dataType": "purchase",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "field": "shoppingCartItems.name",
                             "fieldType": "string",
                             "comparatorType": "Equals",
                             "dataType": "purchase",
                             "id": 13,
                             "value": "chicken"
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
                                "field": "updateCart.updatedShoppingCartItems.name",
                                "fieldType": "string",
                                "comparatorType": "Equals",
                                "dataType": "customEvent",
                                "id": 14,
                                "value": "fried"
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

    func testCompareDataPurchaseOrSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            ["items": [["id": "12",
                        "name": "chicken",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"purchase"
            ],
            ["items": [["id": "12",
                        "name": "fried1",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"updateCart"
            ]
        ]

        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatPurchaseOr)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataPurchaseOrFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["items": [["id": "12",
                        "name": "chicken1",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"purchase"
            ],
            ["items": [["id": "12",
                        "name": "fried1",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"updateCart"
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatPurchaseOr)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }


    //MARK: Comparator test For Purchase Not
    private let mockDataCombinatPurchaseNot = """
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
                   "combinator": "Not",
                   "searchQueries": [
                     {
                       "dataType": "purchase",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "field": "shoppingCartItems.name",
                             "fieldType": "string",
                             "comparatorType": "Equals",
                             "dataType": "purchase",
                             "id": 13,
                             "value": "chicken"
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
                                "field": "updateCart.updatedShoppingCartItems.name",
                                "fieldType": "string",
                                "comparatorType": "Equals",
                                "dataType": "customEvent",
                                "id": 14,
                                "value": "fried"
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

    func testCompareDataPurchaseNotSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            ["items": [["id": "12",
                        "name": "chicken1",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"purchase"
            ],
            ["items": [["id": "12",
                        "name": "fried1",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"updateCart"
            ]
        ]

        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatPurchaseNot)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataPurchaseNotFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["items": [["id": "12",
                        "name": "chicken",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"purchase"
            ],
            ["items": [["id": "12",
                        "name": "fried",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"updateCart"
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatPurchaseNot)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator test For Purchase Not
    private let mockDataCombinatPurchaseCustomEventAnd = """
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
                       "dataType": "purchase",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "field": "shoppingCartItems.name",
                             "fieldType": "string",
                             "comparatorType": "Equals",
                             "dataType": "purchase",
                             "id": 13,
                             "value": "chicken"
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
                                "field": "eventName",
                                "fieldType": "string",
                                "comparatorType": "Equals",
                                "dataType": "customEvent",
                                "id": 16,
                                "value": "birthday"
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

    func testCompareDataPurchaseCustomEventAndSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            ["items": [["id": "12",
                        "name": "chicken",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"purchase"
            ],
            ["dataType":"customEvent",
             "eventName": "birthday"
            ]
        ]

        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatPurchaseCustomEventAnd)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataPurchaseCustomEventAndFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["items": [["id": "12",
                        "name": "chicken1",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"purchase"
            ],
            ["dataType":"customEvent",
             "eventName": "birthday1"
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatPurchaseCustomEventAnd)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator test For Purchase Not
    private let mockDataCombinatPurchaseCustomEventOr = """
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
                   "combinator": "Or",
                   "searchQueries": [
                     {
                       "dataType": "purchase",
                       "searchCombo": {
                         "combinator": "And",
                         "searchQueries": [
                           {
                             "field": "shoppingCartItems.name",
                             "fieldType": "string",
                             "comparatorType": "Equals",
                             "dataType": "purchase",
                             "id": 13,
                             "value": "chicken"
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
                                "field": "eventName",
                                "fieldType": "string",
                                "comparatorType": "Equals",
                                "dataType": "customEvent",
                                "id": 16,
                                "value": "birthday"
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

    func testCompareDataPurchaseCustomEventOrSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            ["items": [["id": "12",
                        "name": "chicken",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"purchase"
            ],
            ["dataType":"customEvent",
             "eventName": "birthday1"
            ]
        ]

        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatPurchaseCustomEventOr)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataPurchaseCustomEventOrFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["items": [["id": "12",
                        "name": "chicken1",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"purchase"
            ],
            ["dataType":"customEvent",
             "eventName": "birthday1"
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatPurchaseCustomEventOr)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }

    //MARK: Comparator test For Purchase Not
    private let mockDataCombinatPurchaseCustomEventNot = """
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
                       "combinator": "Not",
                       "searchQueries": [
                         {
                           "dataType": "purchase",
                           "searchCombo": {
                             "combinator": "And",
                             "searchQueries": [
                               {
                                 "field": "shoppingCartItems.name",
                                 "fieldType": "string",
                                 "comparatorType": "Equals",
                                 "dataType": "purchase",
                                 "id": 13,
                                 "value": "chicken"
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
                                    "field": "eventName",
                                    "fieldType": "string",
                                    "comparatorType": "Equals",
                                    "dataType": "customEvent",
                                    "id": 16,
                                    "value": "birthday"
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

    func testCompareDataPurchaseCustomEventNotSuccess() {

        let eventItems: [[AnyHashable: Any]] = [
            ["items": [["id": "12",
                        "name": "beef",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"purchase"
            ],
            ["dataType":"customEvent",
             "eventName": "anniversary"
            ]
        ]

        let expectedCriteriaId = "285"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatPurchaseCustomEventNot)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataPurchaseCustomEventNotFailed() {

        let eventItems: [[AnyHashable: Any]] = [
            ["items": [["id": "12",
                        "name": "chicken",
                        "price": 130,
                        "quantity": 110]],
             "dataType":"purchase"
            ],
            ["dataType":"customEvent",
             "eventName": "birthday"
            ]
        ]

        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCombinatPurchaseCustomEventNot)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
}

