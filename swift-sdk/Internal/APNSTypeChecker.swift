//
//  Copyright © 2018 Iterable. All rights reserved.
//

import Foundation

enum APNSType {
    case sandbox
    case production
}

protocol APNSTypeCheckerProtocol {
    var apnsType: APNSType { get }
}

struct APNSTypeChecker: APNSTypeCheckerProtocol {
    var apnsType: APNSType {
        APNSTypeChecker.isSandboxAPNS() ? .sandbox : .production
    }
    
    private static func isSandboxAPNS() -> Bool {
        #if targetEnvironment(simulator)
            return isSandboxAPNS(mobileProvision: mobileProvision, isSimulator: true)
        #else
            return isSandboxAPNS(mobileProvision: mobileProvision, isSimulator: false)
        #endif
    }
    
    private static var mobileProvision: [AnyHashable: Any] = {
        readMobileProvision()
    }()
    
    private static func readMobileProvision() -> [AnyHashable: Any] {
        guard let provisioningPath = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") else {
            ITBError("resource not found")
            return [:]
        }
        
        return readMobileProvision(fromPath: provisioningPath)
    }
    
    static func isSandboxAPNS(mobileProvision: [AnyHashable: Any], isSimulator: Bool) -> Bool {
        if mobileProvision.count == 0 {
            // mobileprovision file not found; default to production on devices and sandbox on simulator
            if isSimulator {
                return true
            } else {
                return false
            }
        } else {
            if
                let entitlements = mobileProvision["Entitlements"] as? [AnyHashable: Any],
                let apsEnv = entitlements["aps-environment"] as? String {
                return apsEnv == "development"
            }
        }
        
        return false
    }
    
    static func readMobileProvision(fromPath path: String) -> [AnyHashable: Any] {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            ITBError("Could not read file: \(path)")
            return [:]
        }

        let encodings: [String.Encoding] = [
            .ascii,
            .isoLatin1,
            .utf8,
            .utf16,
            .utf16BigEndian,
            .utf16LittleEndian,
            .utf32,
            .utf32BigEndian,
            .utf32LittleEndian,
            .macOSRoman
        ]
        
        var plistString: String?
        
        for encoding in encodings {
            if let string = String(data: data, encoding: encoding),
            let propertyListString = scan(string: string, begin: "<plist", end: "</plist>") {
                plistString = propertyListString
                break
            }
        }
        
        guard let propertyListData = plistString?.data(using: .utf8) else {
            ITBDebug("Failed to detect APNS type from provisioning file. Defaulting to type - Production. Please use IterableConfig.pushPlatform to manually set APNS platform type")
            return [:]
        }
        
        guard let deserialized = try? PropertyListSerialization.propertyList(from: propertyListData, options: [], format: nil) else {
            return [:]
        }
        
        if let propertyList = deserialized as? [AnyHashable: Any] {
            return propertyList
        } else {
            return [:]
        }
    }
    
    private static func scan(string: String, begin: String, end: String) -> String? {
        let scanner = Scanner(string: string)
        
        var buffer: NSString?
        
        guard
            scanner.scanUpTo(begin, into: nil),
            scanner.scanUpTo(end, into: &buffer),
            let plistString = buffer
        
        else {
            return nil
        }
        
        return plistString.appending(end)
    }
}
