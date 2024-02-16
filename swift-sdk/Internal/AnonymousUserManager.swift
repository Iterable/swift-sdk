//
//  AnonymousUserManager.swift
//  Iterable-iOS-SDK
//
//  Created by DEV CS on 08/08/23.
//

import Foundation

public class AnonymousUserManager: AnonymousUserManagerProtocol {
    
    init(localStorage: LocalStorageProtocol,
         dateProvider: DateProviderProtocol,
         notificationStateProvider: NotificationStateProviderProtocol) {
        ITBInfo()
        
        self.localStorage = localStorage
        self.dateProvider = dateProvider
        self.notificationStateProvider = notificationStateProvider
    }
    
    deinit {
        ITBInfo()
    }
    
    private var localStorage: LocalStorageProtocol
    private let dateProvider: DateProviderProtocol
    private let notificationStateProvider: NotificationStateProviderProtocol

    // Tracks an anonymous event and store it locally
    public func trackAnonEvent(name: String, dataFields: [AnyHashable: Any]?) {
        var body = [AnyHashable: Any]()
        body.setValue(for: JsonKey.eventName, value: name)
        body.setValue(for: JsonKey.Body.createdAt, value: Int(dateProvider.currentDate.timeIntervalSince1970) * 1000)
        body.setValue(for: JsonKey.createNewFields, value: true)
        if let dataFields = dataFields {
            body[JsonKey.dataFields] = dataFields
        }
        storeEventData(type: EventType.customEvent, data: body)
    }
    
    public func trackAnonUpdateUser(_ dataFields: [AnyHashable: Any]) {
        var body = [AnyHashable: Any]()
        body[JsonKey.dataFields] = dataFields
        storeEventData(type: EventType.updateUser, data: body, shouldOverWrite: true)
    }
    
    // Tracks an anonymous purchase event and store it locally
    public func trackAnonPurchaseEvent(total: NSNumber, items: [CommerceItem], dataFields: [AnyHashable: Any]?) {
        var body = [AnyHashable: Any]()
        body.setValue(for: JsonKey.Body.createdAt, value: Int(dateProvider.currentDate.timeIntervalSince1970) * 1000)
        body.setValue(for: JsonKey.Commerce.total, value: total.stringValue)
        body.setValue(for: JsonKey.Commerce.items, value: convertCommerceItemsToDictionary(items))
        if let dataFields = dataFields {
            body[JsonKey.dataFields] = dataFields
        }
        storeEventData(type: EventType.purchase, data: body)
    }
    
    // Tracks an anonymous cart event and store it locally
    public func trackAnonUpdateCart(items: [CommerceItem]) {
        var body = [AnyHashable: Any]()
        body.setValue(for: JsonKey.Body.createdAt, value: Int(dateProvider.currentDate.timeIntervalSince1970) * 1000)
        body.setValue(for: JsonKey.Commerce.items, value: convertCommerceItemsToDictionary(items))
        storeEventData(type: EventType.cartUpdate, data: body)
    }
    
    // Tracks an anonymous token registration event and store it locally
    public func trackAnonTokenRegistration(token: String) {
        var body = [AnyHashable: Any]()
        body.setValue(for: JsonKey.token, value: token)
        storeEventData(type: EventType.tokenRegistration, data: body)
    }
    
    // Stores an anonymous sessions locally. Updates the last session time each time when new session is created
    public func updateAnonSession() {
        if var sessions = localStorage.anonymousSessions {
            sessions.itbl_anon_sessions.totalAnonSessionCount += 1
            sessions.itbl_anon_sessions.lastAnonSession = (Int(self.dateProvider.currentDate.timeIntervalSince1970) * 1000)
            localStorage.anonymousSessions = sessions
        } else {
            // create session object for the first time
            let initialAnonSessions = IterableAnonSessions(totalAnonSessionCount: 1, lastAnonSession: (Int(self.dateProvider.currentDate.timeIntervalSince1970) * 1000), firstAnonSession: (Int(self.dateProvider.currentDate.timeIntervalSince1970) * 1000))
            let anonSessionWrapper = IterableAnonSessionsWrapper(itbl_anon_sessions: initialAnonSessions)
            localStorage.anonymousSessions = anonSessionWrapper
        }
    }
    
    // Creates a user after criterias met and login the user and then sync the data through track APIs
    private func createKnownUserIfCriteriaMatched(criteriaId: String?) {
        if (criteriaId != nil) {
            var anonSessions = convertToDictionary(data: localStorage.anonymousSessions?.itbl_anon_sessions)
            let userId = IterableUtil.generateUUID()
            IterableAPI.setUserId(userId)
            anonSessions["matchedCriteriaId"] = criteriaId
            var appName = ""
            notificationStateProvider.isNotificationsEnabled { isEnabled in
                if (isEnabled) {
                    appName = Bundle.main.appPackageName ?? ""
                }
                if (!appName.isEmpty) {
                    anonSessions["mobilePushOptIn"] = appName
                }
                IterableAPI.implementation?.apiClient.trackAnonSession(createdAt: (Int(self.dateProvider.currentDate.timeIntervalSince1970) * 1000), requestJson: anonSessions)
                self.syncEvents()
            }
        }
    }
    
    // Syncs unsynced data which might have failed to sync when calling syncEvents for the first time after criterias met
    public func syncNonSyncedEvents() {
        syncEvents()
    }
    
    // Reset the locally saved data when user logs out to make sure no old data is left
    public func logout() {
        localStorage.anonymousSessions = nil
        localStorage.anonymousUserEvents = nil
    }
    
    // Syncs locally saved data through track APIs
    private func syncEvents() {
        let events = localStorage.anonymousUserEvents
        var successfulSyncedData: [Int] = []
        
        if let _events = events {
            for var eventData in _events {
                if let eventType = eventData[JsonKey.eventType] as? String {
                    eventData.removeValue(forKey: JsonKey.eventType)
                    switch eventType {
                    case EventType.customEvent:
                        IterableAPI.implementation?.track(eventData[JsonKey.eventName] as? String ?? "", withBody: eventData, onSuccess: {result in
                            successfulSyncedData.append(eventData[JsonKey.eventTimeStamp] as? Int ?? 0)
                        })
                        break
                    case EventType.purchase:
                        var userDict = [AnyHashable: Any]()
                        userDict[JsonKey.userId] = localStorage.userId
                        userDict[JsonKey.preferUserId] = true
                        userDict[JsonKey.createNewFields] = true
                        var total = NSNumber(value: 0)
                        if let _total = NumberFormatter().number(from: eventData[JsonKey.Commerce.total] as! String) {
                            total = _total
                        } else {
                            print("Conversion failed")
                        }
                        
                        IterableAPI.implementation?.trackPurchase(total, items: convertCommerceItems(from: eventData[JsonKey.Commerce.items] as! [[AnyHashable: Any]]), dataFields: eventData[JsonKey.dataFields] as? [AnyHashable : Any], withUser: userDict, createdAt: eventData[JsonKey.Body.createdAt] as? Int ?? 0, onSuccess: {result in
                            successfulSyncedData.append(eventData[JsonKey.eventTimeStamp] as? Int ?? 0)
                        })
                        break
                    case EventType.cartUpdate:
                        var userDict = [AnyHashable: Any]()
                        userDict[JsonKey.userId] = localStorage.userId
                        userDict[JsonKey.createNewFields] = true
                        IterableAPI.implementation?.updateCart(items: convertCommerceItems(from: eventData[JsonKey.Commerce.items] as! [[AnyHashable: Any]]), withUser: userDict, createdAt: eventData[JsonKey.Body.createdAt] as? Int ?? 0, onSuccess: {result in
                            successfulSyncedData.append(eventData[JsonKey.eventTimeStamp] as? Int ?? 0)
                        })
                        break
                    case EventType.updateUser:
                        IterableAPI.implementation?.updateUser(eventData[JsonKey.dataFields] as? [AnyHashable : Any] ?? [:], mergeNestedObjects: false)
                        break
                    default:
                        break
                    }
                }
            }
            
            // commenting this code for now as we need to execute this code in some other place so after all events are suceesfully synced as this code will execute too promptly right after the above loop so we simply clear all the data where or not the APIs were successful or not
            /* let notSynchedData = filterEvents(excludingTimestamps: successfulSyncedData)
            if let _ = notSynchedData {
                localStorage.anonymousUserEvents = notSynchedData
            } else {
                localStorage.anonymousUserEvents = nil
            } */
            
            localStorage.anonymousUserEvents = nil
            localStorage.anonymousSessions = nil
        }
    }
    
    // Checks if criterias are being met and returns criteriaId if it matches the criteria.
    private func evaluateCriteriaAndReturnID() -> String? {
        guard let events = localStorage.anonymousUserEvents, let criteriaData = localStorage.criteriaData  else {
            return nil
        }
        let matchedCriteriaId = CriteriaCompletionChecker(anonymousCriteria: criteriaData, anonymousEvents: events).getMatchedCriteria()
        return matchedCriteriaId
    }
    // Gets the anonymous criteria
    public func getAnonCriteria() {
        IterableAPI.implementation?.getCriteriaData { returnedData in
            self.localStorage.criteriaData = returnedData
        };
    }
    
    // Stores event data locally
    private func storeEventData(type: String, data: [AnyHashable: Any], shouldOverWrite: Bool? = false) {
        let storedData = localStorage.anonymousUserEvents
        var eventsDataObjects: [[AnyHashable: Any]] = [[:]]
        
        if let _storedData = storedData {
            eventsDataObjects = _storedData
        }
        var appendData = data
        appendData.setValue(for: JsonKey.eventType, value: type)
        appendData.setValue(for: JsonKey.eventTimeStamp, value: Int(dateProvider.currentDate.timeIntervalSince1970)) // this we use as unique idenfier too

        if shouldOverWrite == true {
            eventsDataObjects = eventsDataObjects.map { var subDictionary = $0; subDictionary[type] = data; return subDictionary }
        } else {
            eventsDataObjects.append(appendData)
        }
        localStorage.anonymousUserEvents = eventsDataObjects
        createKnownUserIfCriteriaMatched(criteriaId: evaluateCriteriaAndReturnID())
    }
}
