//
//  File.swift
//
//
//  Created by HARDIK MASHRU on 14/11/23.
//

import XCTest

@testable import IterableSDK

class AnonymousUserCriteriaMatchTests: XCTestCase {
    
    private let mockDataWithOr = """
    {
       "count":1,
       "criteriaList":[
          {
             "criteriaId":12345,
             "searchQuery":{
                "combinator":"Or",
                "searchQueries":[
                 {
                    "dataType":"purchase",
                    "searchCombo":{
                       "combinator":"Or",
                       "searchQueries":[
                          {
                             "field":"shoppingCartItems.price",
                             "fieldType":"double",
                             "comparatorType":"Equals",
                             "dataType":"purchase",
                             "id":2,
                             "value":"5.9"
                          },
                          {
                             "field":"shoppingCartItems.quantity",
                             "fieldType":"long",
                             "comparatorType":"GreaterThan",
                             "dataType":"purchase",
                             "id":3,
                             "valueLong":2,
                             "value":"2"
                          },
                          {
                             "field":"total",
                             "fieldType":"long",
                             "comparatorType":"GreaterThanOrEqualTo",
                             "dataType":"purchase",
                             "id":4,
                             "valueLong":10,
                             "value":"10"
                          }
                       ]
                    }
                 }
              ]
             }
          }
       ]
    }
    """

    private let mockDataWithAnd = """
    {
       "count":1,
       "criteriaList":[
          {
             "criteriaId":12345,
             "searchQuery":{
                "combinator":"And",
                "searchQueries":[
                   {
                      "combinator":"And",
                      "searchQueries":[
                         {
                            "dataType":"purchase",
                            "searchCombo":{
                               "combinator":"And",
                               "searchQueries":[
                                  {
                                     "field":"shoppingCartItems.price",
                                     "fieldType":"double",
                                     "comparatorType":"Equals",
                                     "dataType":"purchase",
                                     "id":2,
                                     "value":"4.67"
                                  },
                                  {
                                     "field":"shoppingCartItems.quantity",
                                     "fieldType":"long",
                                     "comparatorType":"GreaterThan",
                                     "dataType":"purchase",
                                     "id":3,
                                     "valueLong":2,
                                     "value":"2"
                                  },
                                  {
                                     "field":"total",
                                     "fieldType":"long",
                                     "comparatorType":"GreaterThanOrEqualTo",
                                     "dataType":"purchase",
                                     "id":4,
                                     "valueLong":10,
                                     "value":"10"
                                  },
                                  {
                                     "field":"campaignId",
                                     "fieldType":"long",
                                     "comparatorType":"Equals",
                                     "dataType":"purchase",
                                     "id":11,
                                     "value":"1234"
                                  }
                               ]
                            }
                         },
                       {
                       "combinator":"And",
                       "searchQueries":[
                          {
                             "dataType":"customEvent",
                             "searchCombo":{
                                "combinator":"Or",
                                "searchQueries":[
                                   {
                                       "field":"eventName",
                                       "fieldType":"string",
                                       "comparatorType":"Equals",
                                       "dataType":"customEvent",
                                       "id":9,
                                       "value":"processing_cancelled"
                                   },
                                   {
                                       "field":"messageId",
                                       "fieldType":"string",
                                       "comparatorType":"Equals",
                                       "dataType":"customEvent",
                                       "id":10,
                                       "value":"1234"
                                   }
                                ]
                             }
                          }
                        ]
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
    
    func testCompareDataWithANDCombinatorSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "Mocha", "price": 4.67, "quantity": 3]],
            "total": 11.0,
            "createdAt": 1699246745093,
            "dataType": "purchase",
            "dataFields": ["campaignId": 1234]
        ], ["dataType": "customEvent", "eventName": "processing_cancelled"]]
        let expectedCriteriaId = "12345"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataWithAnd)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }
    
    func testCompareDataWithANDCombinatorFail() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "Mocha", "price": 4.67, "quantity": 3]],
            "total": 9.0,
            "createdAt": 1699246745093,
            "dataType": "purchase"
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataWithAnd)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
    
    
    func testCompareDataWithORCombinatorSuccess() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "Mocha", "price": 5.9, "quantity": 1]],
            "total": 9.0,
            "createdAt": 1699246745093,
            "dataType": "purchase"
        ]]
        let expectedCriteriaId = "12345"
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataWithOr)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, expectedCriteriaId)
    }
    
    func testCompareDataWithORCombinatorFail() {
        let eventItems: [[AnyHashable: Any]] = [[
            "items": [["id": "12", "name": "Mocha", "price": 2.9, "quantity": 1]],
            "total": 9.0,
            "createdAt": 1699246745093,
            "dataType": "purchase"
        ]]
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: data(from: mockDataWithOr)!, anonymousEvents: eventItems).getMatchedCriteria()
        XCTAssertEqual(matchedCriteriaId, nil)
    }
}
