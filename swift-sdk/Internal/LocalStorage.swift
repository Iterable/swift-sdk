//
//  Copyright © 2018 Iterable. All rights reserved.
//

import Foundation

struct LocalStorage: LocalStorageProtocol {

    init(userDefaults: UserDefaults = UserDefaults.standard,
         keychain: IterableKeychain = IterableKeychain()) {
        iterableUserDefaults = IterableUserDefaults(userDefaults: userDefaults)
        self.keychain = keychain
    }
    
    var userId: String? {
        get {
            keychain.userId
        } set {
            keychain.userId = newValue
        }
    }
    
    var userIdAnnon: String? {
        get {
            keychain.userIdAnnon
        } set {
            keychain.userIdAnnon = newValue
        }
    }
    
    var email: String? {
        get {
            keychain.email
        } set {
            keychain.email = newValue
        }
    }
    
    var authToken: String? {
        get {
            keychain.authToken
        } set {
            keychain.authToken = newValue
        }
    }
    
    var ddlChecked: Bool {
        get {
            iterableUserDefaults.ddlChecked
        } set {
            iterableUserDefaults.ddlChecked = newValue
        }
    }
    
    var deviceId: String? {
        get {
            iterableUserDefaults.deviceId
        } set {
            iterableUserDefaults.deviceId = newValue
        }
    }
    
    var sdkVersion: String? {
        get {
            iterableUserDefaults.sdkVersion
        } set {
            iterableUserDefaults.sdkVersion = newValue
        }
    }
    
    var offlineMode: Bool {
        get {
            iterableUserDefaults.offlineMode
        } set {
            iterableUserDefaults.offlineMode = newValue
        }
    }
    
    var anonymousUserEvents: [[AnyHashable: Any]]? {
        get {
            iterableUserDefaults.anonymousUserEvents
        } set {
            iterableUserDefaults.anonymousUserEvents = newValue
        }
    }

    var anonymousSessions: IterableAnonSessionsWrapper? {
        get {
            iterableUserDefaults.anonymousSessions
        } set {
            iterableUserDefaults.anonymousSessions = newValue
        }
    }

    var criteriaData: Data? {
        get {
            iterableUserDefaults.criteriaData
        } set {
            iterableUserDefaults.criteriaData = newValue
        }
    }

    var anonymousUsageTrack: Bool {
        get {
            iterableUserDefaults.anonymousUsageTrack
        } set {
            iterableUserDefaults.anonymousUsageTrack = newValue
        }
    }

    func getAttributionInfo(currentDate: Date) -> IterableAttributionInfo? {
        iterableUserDefaults.getAttributionInfo(currentDate: currentDate)
    }
    
    func save(attributionInfo: IterableAttributionInfo?, withExpiration expiration: Date?) {
        iterableUserDefaults.save(attributionInfo: attributionInfo, withExpiration: expiration)
    }
    
    func upgrade() {
        ITBInfo()
        
        /// moves `email`, `userId`, and `authToken` from `UserDefaults` to `IterableKeychain`
        moveAuthDataFromUserDefaultsToKeychain()
    }
    
    // MARK: Private
    
    private let iterableUserDefaults: IterableUserDefaults
    private let keychain: IterableKeychain
    
    private func moveAuthDataFromUserDefaultsToKeychain() {
        let (userDefaultEmail, userDefaultUserId, userDefaultAuthToken) = iterableUserDefaults.getAuthDataForMigration()
        
        if let userDefaultEmail = userDefaultEmail {
            if keychain.email == nil {
                keychain.email = userDefaultEmail
            }
            
            iterableUserDefaults.email = nil
            
            ITBInfo("UPDATED: migrated email from UserDefaults to IterableKeychain")
        }
        
        if let userDefaultUserId = userDefaultUserId {
            if keychain.userId == nil {
                keychain.userId = userDefaultUserId
            }
            
            iterableUserDefaults.userId = nil
            
            ITBInfo("UPDATED: migrated userId from UserDefaults to IterableKeychain")
        }
        
        if let userDefaultAuthToken = userDefaultAuthToken {
            if keychain.authToken == nil {
                keychain.authToken = userDefaultAuthToken
            }
            
            iterableUserDefaults.authToken = nil
            
            ITBInfo("UPDATED: migrated authToken from UserDefaults to IterableKeychain")
        }
    }
}
