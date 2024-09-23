//
//  Copyright © 2018 Iterable. All rights reserved.
//

import Foundation
import os
import UIKit

@objc final class IterableUtil: NSObject {
    static var rootViewController: UIViewController? {
        if let rootViewController = AppExtensionHelper.application?.delegate?.window??.rootViewController {
            return rootViewController
        } else {
            return AppExtensionHelper.application?.windows.first?.rootViewController
        }
    }
    
    static func trim(string: String) -> String {
        string.trimmingCharacters(in: .whitespaces)
    }
    
    static func isNullOrEmpty(string: String?) -> Bool {
        guard let string = string else {
            return true
        }
        
        return trim(string: string).isEmpty
    }
    
    static func isNotNullOrEmpty(string: String?) -> Bool {
        !isNullOrEmpty(string: string)
    }
    
    static func generateUUID() -> String {
        UUID().uuidString
    }
    
    /// int is milliseconds since epoch.
    static func date(fromInt int: Int) -> Date {
        let seconds = Double(int) / 1000.0 // ms -> seconds
        
        return Date(timeIntervalSince1970: seconds)
    }
    
    /// milliseconds since epoch.
    static func int(fromDate date: Date) -> Int {
        Int(date.timeIntervalSince1970 * 1000)
    }

    /// seconds since epoch.
    static func secondsFromEpoch(for date: Date) -> Int {
        Int(date.timeIntervalSince1970)
    }
    
    static func getEmailOrUserId() -> String? {
        let email = IterableAPI.email
        let userId = IterableAPI.userId
        if email != nil {
            return email
        } else if userId != nil {
            return userId
        }
        return nil
    }

    // given "var1", "val1", "var2", "val2" as input
    // this will return "var1: val1, var2: val2"
    // this is useful for description of an object or struct
    static func describe(_ values: Any..., pairSeparator: String = ": ", separator: String = ", ") -> String {
        values.take(2).map { pair in
            if pair.count == 0 {
                return ""
            } else if pair.count == 1 {
                return "\(pair[0])\(pairSeparator)nil"
            } else {
                return "\(pair[0])\(pairSeparator)\(pair[1])"
            }
        }.joined(separator: separator)
    }
    
    // MARK: Helper Utility Functions
    
    // converts from IterableURLDelegate to UrlHandler
    static func urlHandler(fromUrlDelegate urlDelegate: IterableURLDelegate?, inContext context: IterableActionContext) -> UrlHandler {
        { url in
            urlDelegate?.handle(iterableURL: url, inContext: context) == true
        }
    }
    
    // converts from IterableCustomActionDelegate to CustomActionHandler
    static func customActionHandler(fromCustomActionDelegate customActionDelegate: IterableCustomActionDelegate?, inContext context: IterableActionContext) -> CustomActionHandler {
        { _ in
            guard let customActionDelegate = customActionDelegate else {
                return false
            }
            
            _ = customActionDelegate.handle(iterableCustomAction: context.action, inContext: context)
            
            return true
        }
    }
}
