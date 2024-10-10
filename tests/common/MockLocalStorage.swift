//
//  Copyright © 2022 Iterable. All rights reserved.
//

import Foundation

@testable import IterableSDK

class MockLocalStorage: LocalStorageProtocol {

    var userIdAnnon: String?
    
    var anonymousUserEvents: [[AnyHashable : Any]]?
    
    var criteriaData: Data?
    
    var anonymousSessions: IterableSDK.IterableAnonSessionsWrapper?
    
    var userId: String? = nil
    
    var email: String? = nil
    
    var authToken: String? = nil
    
    var ddlChecked: Bool = false
    
    var deviceId: String? = nil
    
    var sdkVersion: String? = nil
    
    var offlineMode: Bool = false

    var anonymousUsageTrack: Bool = true

    func getAttributionInfo(currentDate: Date) -> IterableAttributionInfo? {
        guard !MockLocalStorage.isExpired(expiration: attributionInfoExpiration, currentDate: currentDate) else {
            return nil
        }
        return attributionInfo
    }
    
    func save(attributionInfo: IterableAttributionInfo?, withExpiration expiration: Date?) {
        self.attributionInfo = attributionInfo
        attributionInfoExpiration = expiration
    }
    
    private var attributionInfo: IterableAttributionInfo? = nil
    private var attributionInfoExpiration: Date? = nil
    
    private static func isExpired(expiration: Date?, currentDate: Date) -> Bool {
        guard let expiration = expiration else {
            return false
        }
        
        return !(expiration.timeIntervalSinceReferenceDate > currentDate.timeIntervalSinceReferenceDate)
    }
}
