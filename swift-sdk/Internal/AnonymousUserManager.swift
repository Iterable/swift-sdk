//
//  AnonymousUserManager.swift
//  Iterable-iOS-SDK
//
//  Created by DEV CS on 08/08/23.
//

import Foundation

public class AnonymousUserManager: AnonymousUserManagerProtocol {
    
    init(config: IterableConfig,
         localStorage: LocalStorageProtocol,
         dateProvider: DateProviderProtocol,
         notificationStateProvider: NotificationStateProviderProtocol) {
        ITBInfo()
        self.config = config
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
    private var config: IterableConfig

    // Tracks an anonymous event and store it locally
    public func trackAnonEvent(name: String, dataFields: [AnyHashable: Any]?) {
        var body = [AnyHashable: Any]()
        body.setValue(for: JsonKey.eventName, value: name)
        body.setValue(for: JsonKey.Body.createdAt, value: IterableUtil.secondsFromEpoch(for: dateProvider.currentDate))
        body.setValue(for: JsonKey.createNewFields, value: true)
        if let dataFields = dataFields {
            body[JsonKey.dataFields] = dataFields
        }
        storeEventData(type: EventType.customEvent, data: body)
    }
    
    public func trackAnonUpdateUser(_ dataFields: [AnyHashable: Any]) {
        storeEventData(type: EventType.updateUser, data: dataFields, shouldOverWrite: true)
    }
    
    // Tracks an anonymous purchase event and store it locally
    public func trackAnonPurchaseEvent(total: NSNumber, items: [CommerceItem], dataFields: [AnyHashable: Any]?) {
        var body = [AnyHashable: Any]()
        body.setValue(for: JsonKey.Body.createdAt, value:IterableUtil.secondsFromEpoch(for: dateProvider.currentDate))
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
        body.setValue(for: JsonKey.Body.createdAt, value: IterableUtil.secondsFromEpoch(for: dateProvider.currentDate))
        body.setValue(for: JsonKey.Commerce.items, value: convertCommerceItemsToDictionary(items))
        storeEventData(type: EventType.updateCart, data: body)
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
            sessions.itbl_anon_sessions.lastAnonSession = IterableUtil.secondsFromEpoch(for: dateProvider.currentDate)
            localStorage.anonymousSessions = sessions
        } else {
            // create session object for the first time
            let initialAnonSessions = IterableAnonSessions(totalAnonSessionCount: 1, lastAnonSession: IterableUtil.secondsFromEpoch(for: dateProvider.currentDate), firstAnonSession: IterableUtil.secondsFromEpoch(for: dateProvider.currentDate))
            let anonSessionWrapper = IterableAnonSessionsWrapper(itbl_anon_sessions: initialAnonSessions)
            localStorage.anonymousSessions = anonSessionWrapper
        }
    }
    
    // Creates a user after criterias met and login the user and then sync the data through track APIs
    private func createKnownUserIfCriteriaMatched(_ criteriaId: String) {
        var anonSessions = convertToDictionary(data: localStorage.anonymousSessions?.itbl_anon_sessions)
        let userId = IterableUtil.generateUUID()
        anonSessions[JsonKey.matchedCriteriaId] = Int(criteriaId)
        let appName = Bundle.main.appPackageName ?? ""
        notificationStateProvider.isNotificationsEnabled { isEnabled in
            if (!appName.isEmpty && isEnabled) {
                anonSessions[JsonKey.mobilePushOptIn] = appName
            }
            
            // store last update user event
            var updateUserEventIndex : Int?
            var dataFields: [AnyHashable:Any]?
            if let events = self.localStorage.anonymousUserEvents {
                // if there is an update user event, find the index of the last one
                if let eventIndex = events.lastIndex(where: { dict in
                    if let eventType = dict[JsonKey.eventType] as? String, eventType == EventType.updateUser {
                        return true
                    }
                    return false
                }) {
                    updateUserEventIndex = eventIndex
                    var updateUserEvent = events[eventIndex]
                    updateUserEvent.removeValue(forKey: JsonKey.eventType)
                    //save update user event to data fields removing the event type
                    dataFields = updateUserEvent
                }
            }
           
            //track anon session for new user
            IterableAPI.implementation?.apiClient.trackAnonSession(createdAt: IterableUtil.secondsFromEpoch(for: self.dateProvider.currentDate), withUserId: userId, dataFields: dataFields,requestJson: anonSessions).onError { error in
                if (error.httpStatusCode == 409) {
                    self.getAnonCriteria() // refetch the criteria
                }
            }.onSuccess { success in
                //remove the update user event from local storage
                if var events = self.localStorage.anonymousUserEvents, let index = updateUserEventIndex {
                    events.remove(at: index)
                    self.localStorage.anonymousUserEvents = events
                }

                self.localStorage.userIdAnnon = userId
                self.config.anonUserDelegate?.onAnonUserCreated(userId: userId)
                IterableAPI.implementation?.setUserId(userId, authToken: nil, successHandler: nil, failureHandler: nil, isAnon: true, identityResolution: nil)
                self.syncNonSyncedEvents()
            }
        }
    }
    
    // Syncs unsynced data which might have failed to sync when calling syncEvents for the first time after criterias met
    public func syncNonSyncedEvents() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // little delay necessary in case it takes time to store userIdAnon in localstorage
            self.syncEvents()
        }
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
                        var total = NSNumber(value: 0)
                        if let _total = NumberFormatter().number(from: eventData[JsonKey.Commerce.total] as! String) {
                            total = _total
                        }
                        
                        IterableAPI.implementation?.trackPurchase(total, items: convertCommerceItems(from: eventData[JsonKey.Commerce.items] as! [[AnyHashable: Any]]), dataFields: eventData[JsonKey.dataFields] as? [AnyHashable : Any], createdAt: eventData[JsonKey.Body.createdAt] as? Int ?? 0, onSuccess: {result in
                            successfulSyncedData.append(eventData[JsonKey.eventTimeStamp] as? Int ?? 0)
                        })
                        break
                    case EventType.updateCart:
                        IterableAPI.implementation?.updateCart(items: convertCommerceItems(from: eventData[JsonKey.Commerce.items] as! [[AnyHashable: Any]]), createdAt: eventData[JsonKey.Body.createdAt] as? Int ?? 0,
                                               onSuccess: {result in
                                                  successfulSyncedData.append(eventData[JsonKey.eventTimeStamp] as? Int ?? 0)
                        })
                        break
                    case EventType.updateUser:
                        IterableAPI.implementation?.updateUser(eventData, mergeNestedObjects: false)
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
        if !self.localStorage.anonymousUsageTrack {
            return
        }

        let storedData = localStorage.anonymousUserEvents
        var eventsDataObjects: [[AnyHashable: Any]] = []

        if let _storedData = storedData {
            eventsDataObjects = _storedData
        }
        var appendData = data
        appendData.setValue(for: JsonKey.eventType, value: type)
        appendData.setValue(for: JsonKey.eventTimeStamp, value:IterableUtil.secondsFromEpoch(for: dateProvider.currentDate)) // this we use as unique idenfier too

        if shouldOverWrite == true {
            let trackingType = type
                    if let indexToUpdate = eventsDataObjects.firstIndex(where: { $0[JsonKey.eventType] as? String == trackingType }) {
                        let dataToUpdate = eventsDataObjects[indexToUpdate]
                        eventsDataObjects[indexToUpdate] = dataToUpdate.merging(data) { (_, new) in new }
                    } else {
                        eventsDataObjects.append(appendData)
                    }
        } else {
            eventsDataObjects.append(appendData)
        }

        let eventDataCount = eventsDataObjects.count
        if  eventDataCount > config.eventThresholdLimit {
            eventsDataObjects = eventsDataObjects.suffix(config.eventThresholdLimit)
        }
        localStorage.anonymousUserEvents = eventsDataObjects
        if let criteriaId = evaluateCriteriaAndReturnID() {
            createKnownUserIfCriteriaMatched(criteriaId)
        }
    }
}
