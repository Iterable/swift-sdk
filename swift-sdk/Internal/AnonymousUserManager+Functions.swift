//
//  File.swift
//
//
//  Created by HARDIK MASHRU on 13/11/23.
//

import Foundation

// Convert commerce items to dictionaries
func convertCommerceItemsToDictionary(_ items: [CommerceItem]) -> [[AnyHashable:Any]] {
    let dictionaries = items.map { item in
        return item.toDictionary()
    }
    return dictionaries
}

// Convert to commerce items from dictionaries
func convertCommerceItems(from dictionaries: [[AnyHashable: Any]]) -> [CommerceItem] {
    return dictionaries.compactMap { dictionary in
        let item = CommerceItem(id: dictionary[JsonKey.CommerceItem.id] as? String ?? "", name: dictionary[JsonKey.CommerceItem.name] as? String ?? "", price: dictionary[JsonKey.CommerceItem.price] as? NSNumber ?? 0, quantity: dictionary[JsonKey.CommerceItem.quantity] as? UInt ?? 0)
        item.sku = dictionary[JsonKey.CommerceItem.sku] as? String
        item.itemDescription = dictionary[JsonKey.CommerceItem.description] as? String
        item.url = dictionary[JsonKey.CommerceItem.url] as? String
        item.imageUrl = dictionary[JsonKey.CommerceItem.imageUrl] as? String
        item.categories = dictionary[JsonKey.CommerceItem.categories] as? [String]
        item.dataFields = dictionary[JsonKey.CommerceItem.dataFields] as? [AnyHashable: Any]

        return item
    }
}

func convertToDictionary(data: Codable) -> [AnyHashable: Any] {
    do {
        let encoder = JSONEncoder()
        let data = try encoder.encode(data)
        if let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable: Any] {
            return dictionary
        }
    } catch {
        print("Error converting to dictionary: \(error)")
    }
    return [:]
}

// Converts UTC Datetime from current time
func getUTCDateTime() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    let utcDate = Date()
    return dateFormatter.string(from: utcDate)
}

struct CriteriaCompletionChecker {
    init(anonymousCriteria: Data, anonymousEvents: [[AnyHashable: Any]]) {
        self.anonymousEvents = anonymousEvents
        self.anonymousCriteria = anonymousCriteria
    }
    
    func getMatchedCriteria() -> String? {
        var criteriaId: String? = nil
        if let json = try? JSONSerialization.jsonObject(with: anonymousCriteria, options: []) as? [String: Any] {
            // Access the criteriaList
            if let criteriaList = json[JsonKey.criteriaSets] as? [[String: Any]] {
                // Iterate over the criteria
                for criteria in criteriaList {
                    // Perform operations on each criteria
                    if let searchQuery = criteria[JsonKey.CriteriaItem.searchQuery] as? [String: Any], let currentCriteriaId = criteria[JsonKey.CriteriaItem.criteriaId] as? String {
                        // we will split purhase/updatecart event items as seperate events because we need to compare it against the single item in criteria json
                        var eventsToProcess = getEventsWithCartItems()
                        eventsToProcess.append(contentsOf: getNonCartEvents())
                        let result = evaluateTree(node: searchQuery, localEventData: eventsToProcess)
                        if (result) {
                            criteriaId = currentCriteriaId
                            break
                        }
                    }
                }
            }
        }
        return criteriaId
    }
    
    func getMappedKeys(event: [AnyHashable: Any]) -> [String] {
        var itemKeys: [String] = []
        for (_ , value) in event {
            if let arrayValue = value as? [[AnyHashable: Any]], arrayValue.count > 0 { // this is a special case of items array in purchase event
                // If the value is an array, handle it
                itemKeys.append(contentsOf: extractKeys(dict: arrayValue[0]))
            } else {
                itemKeys.append(contentsOf: extractKeys(dict: event))
            }
        }
        return itemKeys
    }
    
    func getNonCartEvents() -> [[AnyHashable: Any]] {
        let nonPurchaseEvents = anonymousEvents.filter { dictionary in
            if let dataType = dictionary[JsonKey.eventType] as? String {
                return dataType != EventType.purchase && dataType != EventType.updateCart
            }
            return false
        }
        var processedEvents: [[AnyHashable: Any]] = []
        for eventItem in nonPurchaseEvents {
            var updatedItem = eventItem
            // handle dataFields if any
            if let dataFields = eventItem[JsonKey.CommerceItem.dataFields] as? [AnyHashable: Any] {
                for (key, value) in dataFields {
                    if key is String {
                        updatedItem[key] = value
                    }
                }
                updatedItem.removeValue(forKey: JsonKey.CommerceItem.dataFields)
            }
            processedEvents.append(updatedItem)
        }
        return processedEvents
    }
    
    private func processEvent(eventItem: [AnyHashable: Any], eventType: String, eventName: String, prefix: String) -> [AnyHashable: Any] {
        var updatedItem = [AnyHashable: Any]()
        if let items = eventItem[JsonKey.Commerce.items] as? [[AnyHashable: Any]] {
            let updatedCartOrPurchaseItems = items.map { item -> [AnyHashable: Any] in
                var updateCartOrPurchaseItem = [AnyHashable: Any]()
                for (key, value) in item {
                    if let stringKey = key as? String {
                        updateCartOrPurchaseItem[prefix + stringKey] = value
                    }
                }
                return updateCartOrPurchaseItem
            }
            if eventName.isEmpty {
                updatedItem[JsonKey.CriteriaItem.CartEventItemsPrefix.purchaseItemPrefix] = updatedCartOrPurchaseItems
            } else {
                updatedItem[JsonKey.CriteriaItem.CartEventItemsPrefix.updateCartItemPrefix] = updatedCartOrPurchaseItems
            }
        }

            
            // handle dataFields if any
            if let dataFields = eventItem[JsonKey.CommerceItem.dataFields] as? [AnyHashable: Any] {
                for (key, value) in dataFields {
                    if key is String {
                        updatedItem[key] = value
                    }
                }
            }

            for (key, value) in eventItem {
                if (key as! String != JsonKey.Commerce.items && key as! String != JsonKey.CommerceItem.dataFields) {
                    if (key as! String == JsonKey.eventType) {
                        updatedItem[key] = EventType.customEvent;
                    } else {
                        updatedItem[key] = value
                    }
                }
            }

            updatedItem[JsonKey.eventType] = eventType
            if !eventName.isEmpty {
                updatedItem[JsonKey.eventName] = eventName
            }
            updatedItem.removeValue(forKey: JsonKey.Commerce.items)
            return updatedItem;
    }
    
    func getEventsWithCartItems() -> [[AnyHashable: Any]] {
        let purchaseEvents = anonymousEvents.filter { dictionary in
            if let dataType = dictionary[JsonKey.eventType] as? String {
                return dataType == EventType.purchase || dataType == EventType.updateCart
            }
            return false
        }
        
        var processedEvents: [[AnyHashable: Any]] = []
        for var eventItem in purchaseEvents {
            if let eventType = eventItem[JsonKey.eventType] as? String, eventType == EventType.purchase {
                processedEvents.append(processEvent(eventItem: eventItem, eventType: EventType.purchase, eventName: "", prefix: JsonKey.CriteriaItem.CartEventPrefix.purchaseItemPrefix))
                
            } else if let eventType = eventItem[JsonKey.eventType] as? String, eventType == EventType.updateCart {
                processedEvents.append(processEvent(eventItem: eventItem, eventType: EventType.customEvent, eventName: EventType.updateCart, prefix: JsonKey.CriteriaItem.CartEventPrefix.updateCartItemPrefix))
            }
            eventItem.removeValue(forKey: JsonKey.CommerceItem.dataFields)
        }
        return processedEvents
    }
    
    func extractKeys(jsonObject: [String: Any]) -> [String] {
        return Array(jsonObject.keys)
    }
    
    func extractKeys(dict: [AnyHashable: Any]) -> [String] {
        var keys: [String] = []
        for key in dict.keys {
            if let stringKey = key as? String {
                // If needed, use stringKey which is now guaranteed to be a String
                keys.append(stringKey)
            }
        }
        return keys
    }

    func evaluateTree(node: [String: Any], localEventData: [[AnyHashable: Any]]) -> Bool {
        if let searchQueries = node[JsonKey.CriteriaItem.searchQueries] as? [[String: Any]], let combinator = node[JsonKey.CriteriaItem.combinator] as? String {
            if combinator == JsonKey.CriteriaItem.Combinator.and {
                for query in searchQueries {
                    if !evaluateTree(node: query, localEventData: localEventData) {
                        return false  // If any subquery fails, return false
                    }
                }
                return true  // If all subqueries pass, return true
            } else if combinator == JsonKey.CriteriaItem.Combinator.or {
                for query in searchQueries {
                    if evaluateTree(node: query, localEventData: localEventData) {
                        return true  // If any subquery passes, return true
                    }
                }
                return false  // If all subqueries fail, return false
            } else if combinator == JsonKey.CriteriaItem.Combinator.not {
                for var query in searchQueries {
                    query["isNot"] = true
                    if evaluateTree(node: query, localEventData: localEventData) {
                        return false  // If all subquery passes, return false
                    }
                }
                return true  // If any subqueries fail, return true
            }
        } else if node[JsonKey.CriteriaItem.searchCombo] is [String: Any] {
            return evaluateSearchQueries(node: node, localEventData: localEventData)
        }
        
        return false
    }
    
    func evaluateSearchQueries(node: [String: Any], localEventData: [[AnyHashable: Any]]) -> Bool {
        // Make a mutable copy of the node
            var mutableNode = node
        for (index, eventData) in localEventData.enumerated() {
                guard let trackingType = eventData[JsonKey.eventType] as? String else { continue }
                let dataType = mutableNode[JsonKey.eventType] as? String
                if eventData[JsonKey.CriteriaItem.criteriaId] == nil && dataType == trackingType {
                    if let searchCombo = mutableNode[JsonKey.CriteriaItem.searchCombo] as? [String: Any] {
                        let searchQueries = searchCombo[JsonKey.CriteriaItem.searchQueries] as? [[AnyHashable: Any]] ?? []
                        let combinator = searchCombo[JsonKey.CriteriaItem.combinator] as? String ?? ""
                        let isNot = node["isNot"] as? Bool ?? false
                        if evaluateEvent(eventData: eventData, searchQueries: searchQueries, combinator: combinator) {
                                   if var minMatch = mutableNode[JsonKey.CriteriaItem.minMatch] as? Int {
                                       minMatch -= 1
                                       if minMatch > 0 {
                                           mutableNode[JsonKey.CriteriaItem.minMatch] = minMatch
                                           continue
                                }
                        }
                        if isNot && index + 1 != localEventData.count {
                            continue
                        }
                        return true
                    } else if (isNot){
                        return false;
                    }
                }
            }
        }
        return false
    }
    
    
    // Evaluate the event based on search queries and combinator
       private func evaluateEvent(eventData: [AnyHashable: Any], searchQueries: [[AnyHashable: Any]], combinator: String) -> Bool {
            return evaluateFieldLogic(searchQueries: searchQueries, eventData: eventData)
       }
    

    
    // Check if item criteria exists in search queries
       private func doesItemCriteriaExist(searchQueries: [[AnyHashable: Any]]) -> Bool {
           return searchQueries.contains { query in
               if let field = query[JsonKey.CriteriaItem.field] as? String {
                   return field.hasPrefix(JsonKey.CriteriaItem.CartEventItemsPrefix.updateCartItemPrefix) ||
                          field.hasPrefix(JsonKey.CriteriaItem.CartEventItemsPrefix.purchaseItemPrefix)
               }
               return false
           }
       }
    
    // Check if an item matches the search queries
        private func doesItemMatchQueries(item: [String: Any], searchQueries: [[AnyHashable: Any]]) -> Bool {
            // Filter searchQueries based on whether the item's keys contain the query field
            var filteredSearchQueries: [[AnyHashable: Any]] = []
            for searchQuery in searchQueries {
                if let field = searchQuery[JsonKey.CriteriaItem.field] as? String {
                    if field.hasPrefix(JsonKey.CriteriaItem.CartEventPrefix.updateCartItemPrefix) ||
                        field.hasPrefix(JsonKey.CriteriaItem.CartEventPrefix.purchaseItemPrefix) {
                        if !item.keys.contains(where: { $0 == field }) {
                            return false
                        }
                        filteredSearchQueries.append(searchQuery)
                    }
                }
            }
            // Return false if no queries are left after filtering
            if filteredSearchQueries.isEmpty {
                return false
            }
        
            let result = filteredSearchQueries.allSatisfy { query in
                let field = query[JsonKey.CriteriaItem.field]
                if let value = item[field as! String], let comparatorType =  query[JsonKey.CriteriaItem.comparatorType] as? String{
                    return evaluateComparison(comparatorType: comparatorType, matchObj: value, valueToCompare: query[JsonKey.CriteriaItem.value] ?? query[JsonKey.CriteriaItem.values])
                }
                return false
            }
            
            if !result {
                return result
            }
            
            if !filteredSearchQueries.isEmpty {
                return true
            }
            
            return false
        }
    
    // Evaluate the field logic against the event data
      private func evaluateFieldLogic(searchQueries: [[AnyHashable: Any]], eventData: [AnyHashable: Any]) -> Bool {
          let localDataKeys = Array(eventData.keys)
          var itemMatchedResult = false
          var itemsKey: String? = nil
          
          if localDataKeys.contains(JsonKey.CriteriaItem.CartEventItemsPrefix.updateCartItemPrefix) {
              itemsKey = JsonKey.CriteriaItem.CartEventItemsPrefix.updateCartItemPrefix
          } else if localDataKeys.contains(JsonKey.CriteriaItem.CartEventItemsPrefix.purchaseItemPrefix) {
              itemsKey = JsonKey.CriteriaItem.CartEventItemsPrefix.purchaseItemPrefix
          }
          if let itemsKey = itemsKey {
              if let items = eventData[itemsKey] as? [[String: Any]] {
                  let result = items.contains { doesItemMatchQueries(item: $0, searchQueries: searchQueries) }
                  if !result && doesItemCriteriaExist(searchQueries: searchQueries) {
                      return result
                  }
                  itemMatchedResult = result
               }
          }
          
          // Assuming localDataKeys is [String]
          let filteredLocalDataKeys = localDataKeys.filter { $0 as! String != JsonKey.CriteriaItem.CartEventItemsPrefix.updateCartItemPrefix }
          if filteredLocalDataKeys.isEmpty {
              return itemMatchedResult
          }
          
          // Assuming searchQueries is [[String: Any]]
          let filteredSearchQueries = searchQueries.filter { query in
              if let field = query[JsonKey.CriteriaItem.field] as? String {
                  return !field.hasPrefix(JsonKey.CriteriaItem.CartEventPrefix.updateCartItemPrefix) &&
                         !field.hasPrefix(JsonKey.CriteriaItem.CartEventPrefix.purchaseItemPrefix)
              }
              return false
          }

          if filteredSearchQueries.isEmpty {
              return itemMatchedResult
          }
          
          let matchResult = filteredSearchQueries.allSatisfy { query in
              let field = query[JsonKey.CriteriaItem.field] as! String
              var doesKeyExist = false
              if let eventType = query[JsonKey.eventType] as? String, eventType == EventType.customEvent, let fieldType = query[JsonKey.CriteriaItem.fieldType] as? String, fieldType == "object", let comparatorType = query[JsonKey.CriteriaItem.comparatorType] as? String, comparatorType == JsonKey.CriteriaItem.Comparator.IsSet, let eventName = eventData[JsonKey.eventName] as? String {
                  if (eventName == EventType.updateCart && field == eventName) ||
                     (field == eventName) {
                      return true
                  }
              } else {
                  doesKeyExist = filteredLocalDataKeys.filter {$0 as! String == field }.count > 0
              }

              if field.contains(".") {
                  var fields = field.split(separator: ".").map { String($0) }
                  if let type = eventData[JsonKey.eventType] as? String, let name = eventData[JsonKey.eventName] as? String, type == EventType.customEvent, name == fields.first {
                      fields = Array(fields.dropFirst())
                  }

                  var fieldValue: Any = eventData
                  var isSubFieldArray = false
                  var isSubMatch = false

                  for subField in fields {
                      if let subFieldValue = (fieldValue as? [String: Any])?[subField] {
                          if let arrayValue = subFieldValue as? [[String: Any]] {
                              isSubFieldArray = true
                              isSubMatch = arrayValue.contains { item in
                                  let data = fields.reversed().reduce([String: Any]()) { acc, key in
                                      if key == subField {
                                          return [key: item]
                                      }
                                      return [key: acc]
                                  }
                                  return evaluateFieldLogic(searchQueries: searchQueries, eventData: eventData.merging(data) { $1 })
                              }
                          } else {
                              fieldValue = subFieldValue
                          }
                      }
                  }

                  if isSubFieldArray {
                      return isSubMatch
                  }

                  if let valueFromObj =  getFieldValue(data: eventData, field: field), let comparatorType = query[JsonKey.CriteriaItem.comparatorType] as? String {
                      return evaluateComparison(comparatorType: comparatorType, matchObj: valueFromObj, valueToCompare: query[JsonKey.CriteriaItem.value]  ?? query[JsonKey.CriteriaItem.values])
                  }
              } else if doesKeyExist {
                  if let comparatorType = query[JsonKey.CriteriaItem.comparatorType] as? String, (evaluateComparison(comparatorType: comparatorType, matchObj: eventData[field] ?? "", valueToCompare: query[JsonKey.CriteriaItem.value] ?? query[JsonKey.CriteriaItem.values])) {
                      return true
                  }
              }

              return false
          }
          return matchResult
      }


    func getFieldValue(data: Any, field: String) -> Any? {
        var fields = field.split(separator: ".").map(String.init)
        if let dictionary = data as? [String: Any] ,let dataType = dictionary[JsonKey.eventType] as? String, dataType == EventType.customEvent, let firstField = fields.first, let eventName = dictionary[JsonKey.eventName] as? String, firstField == eventName {
            fields.removeFirst()
        }
        var currentValue: Any? = data
        for (index, currentField) in fields.enumerated() {
            if index == fields.count - 1 {
                if let currentDict = currentValue as? [String: Any] {
                    return currentDict[currentField]
                }
            } else {
                if let currentDict = currentValue as? [String: Any], let nextValue = currentDict[currentField] {
                    currentValue = nextValue
                } else {
                    return nil
                }
            }
        }
        return nil
    }


    func evaluateComparison(comparatorType: String, matchObj: Any, valueToCompare: Any?) -> Bool {
        if var stringValue = valueToCompare as? String {
            if let doubleValue = Double(stringValue) {
                stringValue = formattedDoubleValue(doubleValue)
            }

            switch comparatorType {
                case JsonKey.CriteriaItem.Comparator.Equals:
                    return compareValueEquality(matchObj, stringValue)
                case JsonKey.CriteriaItem.Comparator.DoesNotEquals:
                    return !compareValueEquality(matchObj, stringValue)
                case JsonKey.CriteriaItem.Comparator.IsSet:
                    return compareValueIsSet(matchObj)
                case JsonKey.CriteriaItem.Comparator.GreaterThan:
                    return compareNumericValues(matchObj, stringValue, compareOperator: >)
                case JsonKey.CriteriaItem.Comparator.LessThan:
                    return compareNumericValues(matchObj, stringValue, compareOperator: <)
                case JsonKey.CriteriaItem.Comparator.GreaterThanOrEqualTo:
                    return compareNumericValues(matchObj, stringValue, compareOperator: >=)
                case JsonKey.CriteriaItem.Comparator.LessThanOrEqualTo:
                    return compareNumericValues(matchObj, stringValue, compareOperator: <=)
                case JsonKey.CriteriaItem.Comparator.Contains:
                    return compareStringContains(matchObj, stringValue)
                case JsonKey.CriteriaItem.Comparator.StartsWith:
                    return compareStringStartsWith(matchObj, stringValue)
                case JsonKey.CriteriaItem.Comparator.MatchesRegex:
                    return compareWithRegex(matchObj, pattern: stringValue)
                default:
                    return false
            }
        } else if var arrayOfString = valueToCompare as? [String] {
            arrayOfString = arrayOfString.compactMap({ stringValue in
                if let doubleValue = Double(stringValue) {
                    return formattedDoubleValue(doubleValue)
                }
                return stringValue
            })
            switch comparatorType {
                case JsonKey.CriteriaItem.Comparator.Equals:
                    return compareValuesEquality(matchObj, arrayOfString)
                case JsonKey.CriteriaItem.Comparator.DoesNotEquals:
                    return !compareValuesEquality(matchObj, arrayOfString)
                default:
                    return false
            }
        }
        return false
    }

    func formattedDoubleValue(_ d: Double) -> String {
        if d == Double(Int64(d)) {
            return String(format: "%lld", Int64(d))
        } else {
            return String(format: "%f", d).trimmingCharacters(in: CharacterSet(charactersIn: "0"))
        }
    }
    
    func compareValueEquality(_ sourceTo: Any, _ stringValue: String) -> Bool {
        switch (sourceTo, stringValue) {
        case (let doubleNumber as Double, let value): return doubleNumber == Double(value)
        case (let intNumber as Int, let value): return intNumber == Int(value)
        case (let longNumber as Int64, let value): return longNumber == Int64(value)
        case (let booleanValue as Bool, let value): return booleanValue == Bool(value)
        case (let stringTypeValue as String, let value): return stringTypeValue == value
        case (let doubleNumbers as [Double], let value):
            guard let doubleValue = Double(value) else { return false }
            return doubleNumbers.contains(doubleValue)
        case (let intNumbers as [Int], let value):
            guard let intValue = Int(value) else { return false }
            return intNumbers.contains(intValue)
        case (let longNumbers as [Int64], let value):
            guard let intValue = Int64(value) else { return false }
            return longNumbers.contains(intValue)
        case (let stringTypeValues as [String], let value):
            return stringTypeValues.contains(value)
        default: return false
        }
    }

    func compareValuesEquality(_ sourceTo: Any, _ stringsValue: [String]) -> Bool {
        switch (sourceTo, stringsValue) {
        case (let doubleNumber as Double, let values): return values.compactMap({Double($0)}).contains(doubleNumber)
        case (let intNumber as Int, let values): return values.compactMap({Int($0)}).contains(intNumber)
        case (let longNumber as Int64, let values): return values.compactMap({Int64($0)}).contains(longNumber)
        case (let booleanValue as Bool, let values): return values.compactMap({Bool($0)}).contains(booleanValue)
        case (let stringTypeValue as String, let values): return values.contains(stringTypeValue)
        case (let doubleNumbers as [Double], let values):
            let set1 = Set(doubleNumbers)
            let set2 = Set(values.compactMap({Double($0)}))
            return !set1.intersection(set2).isEmpty
        case (let intNumbers as [Int], let values):
            let set1 = Set(intNumbers)
            let set2 = Set(values.compactMap({Int($0)}))
            return !set1.intersection(set2).isEmpty
        case (let longNumbers as [Int64], let values):
            let set1 = Set(longNumbers)
            let set2 = Set(values.compactMap({Int64($0)}))
            return !set1.intersection(set2).isEmpty
        case (let stringTypeValues as [String], let values):
            let set1 = Set(stringTypeValues)
            let set2 = Set(values)
            return !set1.intersection(set2).isEmpty
        default: return false
        }
    }

    func compareValueIsSet(_ sourceTo: Any?) -> Bool {
        switch sourceTo {
        case let doubleValue as Double:
            return !doubleValue.isNaN // Checks if the Double is not NaN (not a number)
            
        case _ as Int:
            return true // Ints are always set (0 is a valid value)
            
        case _ as Int64:
            return true // Int64s are always set (0 is a valid value)
            
        case _ as Bool:
            return true // Bools are always set (false is a valid value)
            
        case let stringValue as String:
            return !stringValue.isEmpty // Checks if the string is not empty
            
        case let arrayValue as [Any]:
            return !arrayValue.isEmpty // Checks if the array is not empty
            
        case let dictValue as [AnyHashable: Any]:
            return !dictValue.isEmpty // Checks if the dictionary is not empty
            
        default:
            return sourceTo != nil // Return false for nil or other unspecified types
        }
    }

    func compareNumericValues(_ sourceTo: Any, _ stringValue: String, compareOperator: (Double, Double) -> Bool) -> Bool {
        if let sourceNumber = Double(stringValue) {
            switch sourceTo {
            case let doubleNumber as Double:
                return compareOperator(doubleNumber, sourceNumber)
            case let intNumber as Int:
                return compareOperator(Double(intNumber), sourceNumber)
            case let longNumber as Int64:
                return compareOperator(Double(longNumber), sourceNumber)
            case let stringNumber as String:
                if let doubleFromString = Double(stringNumber) {
                    return compareOperator(doubleFromString, sourceNumber)
                } else {
                    return false // Handle the case where string cannot be converted to a Double
                }
            case (let doubleNumbers as [Double]):
                for value in doubleNumbers {
                    if compareOperator(Double(value), sourceNumber) {
                        return true
                    }
                }
                return false
            case (let intNumbers as [Int]):
                for value in intNumbers {
                    if compareOperator(Double(value), sourceNumber) {
                        return true
                    }
                }
                return false
            case (let longNumbers as [Int64]):
                for value in longNumbers {
                    if compareOperator(Double(value), sourceNumber) {
                        return true
                    }
                }
                return false
            case (let stringTypeValues as [String]):
                for value in stringTypeValues {
                    if let doubleFromString = Double(value), compareOperator(doubleFromString, sourceNumber) {
                        return true
                    }
                }
                return false
            default:
                return false
            }
        } else {
            return false // Handle the case where stringValue cannot be converted to a Double
        }
    }
    
    func compareStringContains(_ sourceTo: Any, _ stringValue: String) -> Bool {
        if let stringTypeValue = sourceTo as? String {
            // sourceTo is a String
            return stringTypeValue.contains(stringValue)
        } else if let arrayTypeValue = sourceTo as? [String] {
            // sourceTo is an Array of String
            return arrayTypeValue.contains(stringValue)
        }
        return false
    }

    func compareStringStartsWith(_ sourceTo: Any, _ stringValue: String) -> Bool {
        if let stringTypeValue = sourceTo as? String {
            // sourceTo is a String
            return stringTypeValue.hasPrefix(stringValue)
        } else if let arrayTypeValue = sourceTo as? [String] {
            // sourceTo is an Array of String
            for value in arrayTypeValue {
                if value.hasPrefix(stringValue) {
                    return true
                }
            }
        }
        return false
    }
    
    func compareWithRegex(_ sourceTo: Any, pattern: String) -> Bool {
        if let stringTypeValue = sourceTo as? String {
            do {
                let regex = try NSRegularExpression(pattern: pattern)
                let range = NSRange(stringTypeValue.startIndex..<stringTypeValue.endIndex, in: stringTypeValue)
                return regex.firstMatch(in: stringTypeValue, options: [], range: range) != nil
            } catch {
                return false
            }
        } else if let stringTypeValues = sourceTo as? [String] {
            for stringTypeValue in stringTypeValues {
                do {
                    let regex = try NSRegularExpression(pattern: pattern)
                    let range = NSRange(stringTypeValue.startIndex..<stringTypeValue.endIndex, in: stringTypeValue)
                    if regex.firstMatch(in: stringTypeValue, options: [], range: range) != nil {
                        return true
                    }
                } catch {}
            }
            return false
        } else {
            return false
        }
    }
    
    private let anonymousCriteria: Data
    private let anonymousEvents: [[AnyHashable: Any]]
}
