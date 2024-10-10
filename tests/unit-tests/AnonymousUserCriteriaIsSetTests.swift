//
//  File.swift
//  
//
//  Created by vishwa on 27/06/24.
//

import XCTest

@testable import IterableSDK

class AnonymousUserCriteriaIsSetTests: XCTestCase {
    
    private let mockDataUserProperty = """
    {
      "count": 1,
      "criteriaSets": [
      
        {
          "criteriaId": "1",
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
                    "dataType": "user",
                    "searchCombo": {
                      "combinator": "And",
                      "searchQueries": [
                        {
                          "field": "country",
                          "fieldType": "string",
                          "comparatorType": "IsSet",
                          "dataType": "user",
                          "id": 25,
                          "value": ""
                        },
                        {
                          "field": "eventTimeStamp",
                          "fieldType": "long",
                          "comparatorType": "IsSet",
                          "dataType": "user",
                          "id": 26,
                          "valueLong": null,
                          "value": ""
                        },
                        {
                          "field": "phoneNumberDetails",
                          "fieldType": "object",
                          "comparatorType": "IsSet",
                          "dataType": "user",
                          "id": 28,
                          "value": ""
                        },
                        {
                          "field": "shoppingCartItems.price",
                          "fieldType": "double",
                          "comparatorType": "IsSet",
                          "dataType": "user",
                          "id": 30,
                          "value": ""
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

    private let mockDataCustomEvent = """
    {
      "count": 1,
      "criteriaSets": [
        {
          "criteriaId": "1",
          "name": "updateCart",
          "createdAt": 1716561779683,
          "updatedAt": 1717423966940,
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
                          "field": "button-clicked",
                          "fieldType": "object",
                          "comparatorType": "IsSet",
                          "dataType": "customEvent",
                          "id": 2,
                          "value": ""
                        },
                        {
                          "field": "button-clicked.animal",
                          "fieldType": "string",
                          "comparatorType": "IsSet",
                          "dataType": "customEvent",
                          "id": 4,
                          "value": ""
                        },
                        {
                          "field": "button-clicked.clickCount",
                          "fieldType": "long",
                          "comparatorType": "IsSet",
                          "dataType": "customEvent",
                          "id": 5,
                          "valueLong": null,
                          "value": ""
                        },
                        {
                          "field": "total",
                          "fieldType": "double",
                          "comparatorType": "IsSet",
                          "dataType": "customEvent",
                          "id": 9,
                          "value": ""
                        }
                      ]
                    }
                  }
                ]
              }
            ]
          }
        },
       
      ]
    }
    """
    
    private let mockDataPurchase = """
    {
      "count": 1,
      "criteriaSets": [

        {
          "criteriaId": "1",
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
                    "dataType": "purchase",
                    "searchCombo": {
                      "combinator": "And",
                      "searchQueries": [
                        {
                          "field": "shoppingCartItems",
                          "fieldType": "object",
                          "comparatorType": "IsSet",
                          "dataType": "purchase",
                          "id": 1,
                          "value": ""
                        },
                        {
                          "field": "shoppingCartItems.price",
                          "fieldType": "double",
                          "comparatorType": "IsSet",
                          "dataType": "purchase",
                          "id": 3,
                          "value": ""
                        },
                        {
                          "field": "shoppingCartItems.name",
                          "fieldType": "string",
                          "comparatorType": "IsSet",
                          "dataType": "purchase",
                          "id": 5,
                          "value": ""
                        },
                        {
                          "field": "total",
                          "fieldType": "double",
                          "comparatorType": "IsSet",
                          "dataType": "purchase",
                          "id": 7,
                          "value": ""
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
    
    private let mockDataUpdateCart = """
    {
      "count": 1,
      "criteriaSets": [
        {
          "criteriaId": "1",
          "name": "Contact Property",
          "createdAt": 1716561944428,
          "updatedAt": 1716561944428,
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
                          "field": "updateCart",
                          "fieldType": "object",
                          "comparatorType": "IsSet",
                          "dataType": "customEvent",
                          "id": 9,
                          "value": ""
                        },
                        {
                          "field": "updateCart.updatedShoppingCartItems.name",
                          "fieldType": "string",
                          "comparatorType": "IsSet",
                          "dataType": "customEvent",
                          "id": 13,
                          "value": ""
                        },
                        {
                          "field": "updateCart.updatedShoppingCartItems.price",
                          "fieldType": "double",
                          "comparatorType": "IsSet",
                          "dataType": "customEvent",
                          "id": 15,
                          "value": ""
                        },
                        {
                          "field": "updateCart.updatedShoppingCartItems.quantity",
                          "fieldType": "long",
                          "comparatorType": "IsSet",
                          "dataType": "customEvent",
                          "id": 16,
                          "valueLong": null,
                          "value": ""
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
    
    func testCompareDataIsSetUserPropertySuccess() {
        let eventItems: [[AnyHashable: Any]] = [["dataType": "user", "createdAt": 1699246745093, "phoneNumberDetails": "999999", "country": "UK", "eventTimeStamp": "1234567890", "shoppingCartItems.price": "33"]]
        let expectedCriteriaId = "1"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataUserProperty)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }
    
    func testCompareDataIsSetUserPropertyFailure() {
        let eventItems: [[AnyHashable: Any]] = [["dataType": "user", "createdAt": 1699246745093, "phoneNumberDetails": "999999", "country": "", "eventTimeStamp": "", "shoppingCartItems.price": "33"]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataUserProperty)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
    
    
    func testCompareDataIsSetCustomEventSuccess() {
        let eventItems: [[AnyHashable: Any]] = [["dataType": "customEvent", "eventName":"button-clicked", "dataFields": ["button-clicked":"cc", "animal": "aa", "clickCount": "1", "total": "10"]]]
        let expectedCriteriaId = "1"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCustomEvent)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }
    
    func testCompareDataIsSetCustomEventFailure() {
        let eventItems: [[AnyHashable: Any]] = [["dataType": "customEvent", "eventName":"vvv", "dataFields": ["button-clicked":"", "animal": "", "clickCount": "1", "total": "10"]]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataCustomEvent)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
    
    func testCompareDataIsSetPurchaseSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "coffee", "price": 4.67, "quantity": 3]],
            "total": 11.0,
            "createdAt": 1699246745093,
            "dataType": "purchase"
        ]]
        let expectedCriteriaId = "1"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataPurchase)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }
    
    func testCompareDataIsSetPurchaseFailure() {
        let eventItems: [[AnyHashable: Any]] = [ [
            "items": [["id": "12", "name": "coffee", "price": 4.67, "quantity": 3]],
            "createdAt": 1699246745093,
            "dataType": "purchase"
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataPurchase)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
    
    func testCompareDataIsSetUpdateCartSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "keyboard", "price": 90, "quantity": 60]],
            "createdAt": 1699246745093,
            "dataType": "updateCart"
        ]]
        let expectedCriteriaId = "1"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataUpdateCart)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }
    
    func testCompareDataIsSetUpdateCartFailure() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "keyboard", "price": 90]],
            "createdAt": 1699246745093,
            "dataType": "updateCart"
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataUpdateCart)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
}
