//
//  AnonymousUserComplexCriteriaMatchTests.swift
//  unit-tests
//
//  Created by vishwa on 26/06/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import XCTest

@testable import IterableSDK

class AnonymousUserComplexCriteriaMatchTests: XCTestCase {
    
    private let mockDataForCriteria1 = """
    {
      "count": 1,
      "criteriaSets": [
        {
          "criteriaId": "49",
          "name": "updateCart",
          "createdAt": 1716561779683,
          "updatedAt": 1717423966940,
          "searchQuery": {
            "combinator": "Or",
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
                          "field": "eventName",
                          "fieldType": "string",
                          "comparatorType": "Equals",
                          "dataType": "customEvent",
                          "id": 23,
                          "value": "button-clicked"
                        },
                        {
                          "field": "button-clicked.animal",
                          "fieldType": "string",
                          "comparatorType": "Equals",
                          "dataType": "customEvent",
                          "id": 25,
                          "value": "giraffe"
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
                          "field": "updateCart.updatedShoppingCartItems.price",
                          "fieldType": "double",
                          "comparatorType": "GreaterThanOrEqualTo",
                          "dataType": "customEvent",
                          "id": 28,
                          "value": "120"
                        },
                        {
                          "field": "updateCart.updatedShoppingCartItems.quantity",
                          "fieldType": "long",
                          "comparatorType": "GreaterThanOrEqualTo",
                          "dataType": "customEvent",
                          "id": 29,
                          "valueLong": 100,
                          "value": "100"
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
                    "dataType": "purchase",
                    "searchCombo": {
                      "combinator": "And",
                      "searchQueries": [
                        {
                          "field": "shoppingCartItems.name",
                          "fieldType": "string",
                          "comparatorType": "Equals",
                          "dataType": "purchase",
                          "id": 31,
                          "value": "monitor"
                        },
                        {
                          "field": "shoppingCartItems.quantity",
                          "fieldType": "long",
                          "comparatorType": "GreaterThanOrEqualTo",
                          "dataType": "purchase",
                          "id": 32,
                          "valueLong": 5,
                          "value": "5"
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
                          "field": "country",
                          "fieldType": "string",
                          "comparatorType": "Equals",
                          "dataType": "user",
                          "id": 34,
                          "value": "Japan"
                        },
                        {
                          "field": "preferred_car_models",
                          "fieldType": "string",
                          "comparatorType": "Contains",
                          "dataType": "user",
                          "id": 36,
                          "value": "Honda"
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
    
    private let mockDataForCriteria2 = """
    {
      "count": 1,
      "criteriaSets": [
        {
          "criteriaId": "51",
          "name": "Contact Property",
          "createdAt": 1716561944428,
          "updatedAt": 1716561944428,
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
                          "field": "eventName",
                          "fieldType": "string",
                          "comparatorType": "Equals",
                          "dataType": "customEvent",
                          "id": 2,
                          "value": "button-clicked"
                        },
                        {
                          "field": "button-clicked.lastPageViewed",
                          "fieldType": "string",
                          "comparatorType": "Equals",
                          "dataType": "customEvent",
                          "id": 4,
                          "value": "welcome page"
                        }
                      ]
                    }
                  },
                  {
                    "dataType": "customEvent",
                    "minMatch": 2,
                    "maxMatch": 3,
                    "searchCombo": {
                      "combinator": "And",
                      "searchQueries": [
                        {
                          "field": "updateCart.updatedShoppingCartItems.price",
                          "fieldType": "double",
                          "comparatorType": "GreaterThanOrEqualTo",
                          "dataType": "customEvent",
                          "id": 6,
                          "value": "85"
                        },
                        {
                          "field": "updateCart.updatedShoppingCartItems.quantity",
                          "fieldType": "long",
                          "comparatorType": "GreaterThanOrEqualTo",
                          "dataType": "customEvent",
                          "id": 7,
                          "valueLong": 50,
                          "value": "50"
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
                          "field": "shoppingCartItems.name",
                          "fieldType": "string",
                          "comparatorType": "Equals",
                          "dataType": "purchase",
                          "id": 16,
                          "isFiltering": false,
                          "value": "coffee"
                        },
                        {
                          "field": "shoppingCartItems.quantity",
                          "fieldType": "long",
                          "comparatorType": "GreaterThanOrEqualTo",
                          "dataType": "purchase",
                          "id": 17,
                          "valueLong": 2,
                          "value": "2"
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
                          "field": "country",
                          "fieldType": "string",
                          "comparatorType": "Equals",
                          "dataType": "user",
                          "id": 19,
                          "value": "USA"
                        },
                        {
                          "field": "preferred_car_models",
                          "fieldType": "string",
                          "comparatorType": "Contains",
                          "dataType": "user",
                          "id": 21,
                          "value": "Subaru"
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
    
    private let mockDataForCriteria3 = """
    {
      "count": 1,
      "criteriaSets": [
        {
          "criteriaId": "50",
          "name": "purchase",
          "createdAt": 1716561874633,
          "updatedAt": 1716561874633,
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
                          "field": "eventName",
                          "fieldType": "string",
                          "comparatorType": "Equals",
                          "dataType": "customEvent",
                          "id": 2,
                          "value": "button-clicked"
                        },
                        {
                          "field": "button-clicked.lastPageViewed",
                          "fieldType": "string",
                          "comparatorType": "Equals",
                          "dataType": "customEvent",
                          "id": 4,
                          "value": "welcome page"
                        }
                      ]
                    }
                  },
                  {
                    "dataType": "customEvent",
                    "minMatch": 2,
                    "maxMatch": 3,
                    "searchCombo": {
                      "combinator": "And",
                      "searchQueries": [
                        {
                          "field": "updateCart.updatedShoppingCartItems.price",
                          "fieldType": "double",
                          "comparatorType": "GreaterThanOrEqualTo",
                          "dataType": "customEvent",
                          "id": 6,
                          "value": "85"
                        },
                        {
                          "field": "updateCart.updatedShoppingCartItems.quantity",
                          "fieldType": "long",
                          "comparatorType": "GreaterThanOrEqualTo",
                          "dataType": "customEvent",
                          "id": 7,
                          "valueLong": 50,
                          "value": "50"
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
                          "field": "shoppingCartItems.name",
                          "fieldType": "string",
                          "comparatorType": "Equals",
                          "dataType": "purchase",
                          "id": 9,
                          "value": "coffee"
                        },
                        {
                          "field": "shoppingCartItems.quantity",
                          "fieldType": "long",
                          "comparatorType": "GreaterThanOrEqualTo",
                          "dataType": "purchase",
                          "id": 10,
                          "valueLong": 2,
                          "value": "2"
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
                          "field": "country",
                          "fieldType": "string",
                          "comparatorType": "Equals",
                          "dataType": "user",
                          "id": 12,
                          "value": "USA"
                        },
                        {
                          "field": "preferred_car_models",
                          "fieldType": "string",
                          "comparatorType": "Contains",
                          "dataType": "user",
                          "id": 14,
                          "value": "Subaru"
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

    private let mockDataForCriteria4 = """
    {
      "count": 1,
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
                          "id": 1,
                          "value": "sneakers"
                        },
                        {
                          "field": "shoppingCartItems.quantity",
                          "fieldType": "long",
                          "comparatorType": "LessThanOrEqualTo",
                          "dataType": "purchase",
                          "id": 2,
                          "valueLong": 3,
                          "value": "3"
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
                    "dataType": "purchase",
                    "searchCombo": {
                      "combinator": "And",
                      "searchQueries": [
                        {
                          "field": "shoppingCartItems.name",
                          "fieldType": "string",
                          "comparatorType": "Equals",
                          "dataType": "purchase",
                          "id": 4,
                          "value": "slippers"
                        },
                        {
                          "field": "shoppingCartItems.quantity",
                          "fieldType": "long",
                          "comparatorType": "GreaterThanOrEqualTo",
                          "dataType": "purchase",
                          "id": 5,
                          "valueLong": 3,
                          "value": "3"
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
    
    func testCompareDataWithCriteria1Success() {
        let eventItems: [[AnyHashable: Any]] = [
            ["dataType": "customEvent", "createdAt": 1699246745093, "eventName": "button-clicked", "dataFields": ["animal": "giraffe"]
            ], [
                "items": [["id": "12", "name": "keyboard", "price": 130, "quantity": 110]],
                "createdAt": 1699246745093,
                "dataType": "updateCart",
            ]]
        let expectedCriteriaId = "49"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForCriteria1)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }

    func testCompareDataWithCriteria1Failure() {
        let eventItems: [[AnyHashable: Any]] = [
            ["dataType": "customEvent", "createdAt": 1699246745093, "eventName": "button-clicked", "dataFields": ["animal": "giraffe22"]
            ], [
                "items": [["id": "12", "name": "keyboard", "price": 130, "quantity": 110]],
                "createdAt": 1699246745093,
                "dataType": "updateCart",
            ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForCriteria1)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
    
    func testCompareDataWithCriteria2Success() {
        let eventItems: [[AnyHashable: Any]] = [
            ["dataType": "customEvent", "createdAt": 1699246745093, "eventName": "button-clicked", "dataFields": ["lastPageViewed": "welcome page"]
            ], ["dataType": "user", "createdAt": 1699246745093, "phone_number": "999999", "country": "USA",    "dataFields": ["preferred_car_models": "Subaru"]
               ]]
        let expectedCriteriaId = "51"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForCriteria2)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }
    
    func testCompareDataWithCriteria2Failure() {
        let eventItems: [[AnyHashable: Any]] = [
            ["dataType": "customEvent", "createdAt": 1699246745093, "eventName": "button-clicked", "dataFields": ["lastPageViewed": "welcome page"]
            ], ["dataType": "user", "createdAt": 1699246745093, "phone_number": "999999", "country": "USA",    "dataFields": ["preferred_car_models": "Mazda"]
               ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForCriteria2)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
    
    func testCompareDataWithCriteria3Success() {
        let eventItems: [[AnyHashable: Any]] = [
            [
                "items": [["id": "12", "name": "keyboard", "price": 90, "quantity": 60]],
                "createdAt": 1699246745093,
                "dataType": "updateCart"
            ], [
                "items": [["id": "121", "name": "keyboard2", "price": 100, "quantity": 80]],
                "createdAt": 1699246745093,
                "dataType": "updateCart"
            ], [
                "items": [["id": "12", "name": "coffee", "price": 4.67, "quantity": 3]],
                "total": 11.0,
                "createdAt": 1699246745093,
                "dataType": "purchase"
            ], [
                "dataType": "user", "createdAt": 1699246745093, "dataFields": [ "phone_number": "999999", "country": "USA", "preferred_car_models": "Subaru"]
            ], [
                "dataType": "customEvent", "createdAt": 1699246745093, "eventName": "button-clicked", "dataFields": ["lastPageViewed": "welcome page"]
            ], ]
      
        let expectedCriteriaId = "50"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForCriteria3)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
        
    }
    
    func testCompareDataWithCriteria3Failure() {
        let eventItems: [[AnyHashable: Any]] = [
            [
                "dataType": "customEvent", "createdAt": 1699246745093, "eventName": "button-clicked2", "dataFields": ["lastPageViewed": "welcome page"]
            ], [
                "items": [["id": "12", "name": "keyboard", "price": 90, "quantity": 60]],
                "createdAt": 1699246745093,
                "dataType": "updateCart"
            ], [
                "items": [["id": "121", "name": "keyboard2", "price": 100, "quantity": 80]],
                "createdAt": 1699246745093,
                "dataType": "updateCart"
            ], [
                "items": [["id": "12", "name": "coffee", "price": 4.67, "quantity": 3]],
                "total": 11.0,
                "createdAt": 1699246745093,
                "dataType": "purchase"
            ], [
                "dataType": "user", "createdAt": 1699246745093, "phone_number": "999999", "country": "US",    "dataFields": ["preferred_car_models": "Subaru"]
            ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForCriteria3)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
    
    func testCompareDataWithCriteria4Success() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "slippers", "price": 4.67, "quantity": 5]],
            "total": 11.0,
            "createdAt": 1699246745093,
            "dataType": "purchase"
        ]]
        let expectedCriteriaId = "48"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForCriteria4)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }
    
    func testCompareDataWithCriteria4Failure() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "sneakers", "price": 4.67, "quantity": 2]],
            "total": 11.0,
            "createdAt": 1699246745093,
            "dataType": "purchase"
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataForCriteria4)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
    
}

