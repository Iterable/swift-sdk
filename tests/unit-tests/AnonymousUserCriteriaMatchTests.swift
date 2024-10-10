//
//  File.swift
//
//
//  Created by HARDIK MASHRU on 14/11/23.
//

import XCTest

@testable import IterableSDK

class AnonymousUserCriteriaMatchTests: XCTestCase {
    
    private let mockData = """
    {
      "count": 4,
      "criteriaSets": [
        {
          "criteriaId": "49",
          "name": "updateCart",
          "createdAt": 1716561779683,
          "updatedAt": 1717423966940,
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
                          "dataType": "customEvent",
                          "field": "eventName",
                          "comparatorType": "Equals",
                          "value": "updateCart",
                          "fieldType": "string"
                        },
                        {
                          "dataType": "customEvent",
                          "field": "updateCart.updatedShoppingCartItems.price",
                          "comparatorType": "Equals",
                          "value": "10.0",
                          "fieldType": "double"
                        }
                      ]
                    },
                    "minMatch": 2,
                    "maxMatch": 3
                  },
                  {
                    "dataType": "customEvent",
                    "searchCombo": {
                      "combinator": "And",
                      "searchQueries": [
                        {
                          "dataType": "customEvent",
                          "field": "eventName",
                          "comparatorType": "Equals",
                          "value": "updateCart",
                          "fieldType": "string"
                        },
                        {
                          "dataType": "customEvent",
                          "field": "updateCart.updatedShoppingCartItems.quantity",
                          "comparatorType": "GreaterThanOrEqualTo",
                          "value": "50",
                          "fieldType": "long"
                        },
                        {
                          "dataType": "customEvent",
                          "field": "updateCart.updatedShoppingCartItems.price",
                          "comparatorType": "GreaterThanOrEqualTo",
                          "value": "50",
                          "fieldType": "long"
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
                    "dataType": "user",
                    "searchCombo": {
                      "combinator": "And",
                      "searchQueries": [
                        {
                          "dataType": "user",
                          "field": "country",
                          "comparatorType": "Equals",
                          "value": "UK",
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
                          "field": "preferred_car_models",
                          "comparatorType": "Contains",
                          "value": "Mazda",
                          "fieldType": "string"
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
          "criteriaId": "50",
          "name": "purchase",
          "createdAt": 1716561874633,
          "updatedAt": 1716561874633,
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
                          "dataType": "purchase",
                          "field": "shoppingCartItems.name",
                          "comparatorType": "Equals",
                          "value": "keyboard",
                          "fieldType": "string"
                        },
                        {
                          "field":"shoppingCartItems.price",
                          "fieldType":"double",
                          "comparatorType":"Equals",
                          "dataType":"purchase",
                          "id":2,
                          "value":"4.67"
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
                          "comparatorType": "GreaterThanOrEqualTo",
                          "value": "3",
                          "fieldType": "long"
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
    
    func testCompareDataWithUserCriteriaSuccess() {
        let eventItems: [[AnyHashable: Any]] = [["dataType": "user", "createdAt": 1699246745093, "phone_number": "999999", "country": "UK"]]
        let expectedCriteriaId = "51"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }
    
    func testCompareDataWithUserCriteriaFailure() {
        let eventItems: [[AnyHashable: Any]] = [["dataType": "user", "createdAt": 1699246745093, "phone_number": "999999", "country": "US"]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
    
    func testCompareDataWithCustomEventCriteriaSuccess() {
        let eventItems: [[AnyHashable: Any]] = [
            ["dataType": "customEvent", "createdAt": 1699246745093, "eventName": "button-clicked", "dataFields": ["lastPageViewed": "signup page"]
            ]]
        let expectedCriteriaId = "48"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }
    
    func testCompareDataWithCustomEventCriteriaFailure() {
        let eventItems: [[AnyHashable: Any]] = [
            ["dataType": "customEvent", "createdAt": 1699246745093, "eventName": "button", "dataFields": ["lastPageViewed": "signup page"]
            ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
    
    func testCompareDataWithUpdateCartCriteriaSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "keyboard", "price": 50, "quantity": 60]],
            "createdAt": 1699246745093,
            "dataType": "updateCart",
        ]]
        let expectedCriteriaId = "49"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
        
    }
    
    func testCompareDataWithUpdateCartCriteriaFailure() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "keyboard", "price": 40, "quantity": 3]],
            "createdAt": 1699246745093,
            "dataType": "customEvent",
            "dataFields": ["campaignId": "1234"]
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
    
    func testCompareDataWithMinMatchCriteriaSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "keyboard", "price": 10.0, "quantity": 3]],
            "createdAt": 1699246745093,
            "dataType": "updateCart",
        ],[
            "items": [["id": "13", "name": "keyboard2", "price": 10.0, "quantity": 4]],
            "createdAt": 1699246745093,
            "dataType": "updateCart"]]
        let expectedCriteriaId = "49"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }
    
    func testCompareDataWithMinMatchCriteriaFailure() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "keyboard", "price": 10, "quantity": 3]],
            "createdAt": 1699246745093,
            "dataType": "customEvent",
            "dataFields": ["campaignId": "1234"]
        ],["dataType": "customEvent", "eventName": "processing_cancelled"]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
    
    func testCompareDataWithANDCombinatorSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "keyboard", "price": 4.67, "quantity": 3]],
            "total": 11.0,
            "createdAt": 1699246745093,
            "dataType": "purchase",
            "dataFields": ["campaignId": "1234"]
        ]]
        let expectedCriteriaId = "50"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
        
    }
    
    func testCompareDataWithANDCombinatorFail() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "Mocha", "price": 4.67, "quantity": 2]],
            "total": 9.0,
            "createdAt": 1699246745093,
            "dataType": "purchase"
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
    
    
    func testCompareDataWithORCombinatorSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "Mocha", "price": 5.9, "quantity": 4]],
            "total": 9.0,
            "createdAt": 1699246745093,
            "dataType": "purchase"
        ]]
        let expectedCriteriaId = "50"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }
    
    func testCompareDataWithORCombinatorFail() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "Mocha", "price": 2.9, "quantity": 1]],
            "total": 9.0,
            "createdAt": 1699246745093,
            "dataType": "purchase"
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockData)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
}
