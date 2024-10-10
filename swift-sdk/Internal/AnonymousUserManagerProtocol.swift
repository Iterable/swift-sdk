//
//  AnonymousUserManagerProtocol.swift
//
//
//  Created by HARDIK MASHRU on 09/11/23.
//
import Foundation
@objc public protocol AnonymousUserManagerProtocol {
    func trackAnonEvent(name: String, dataFields: [AnyHashable: Any]?)
    func trackAnonPurchaseEvent(total: NSNumber, items: [CommerceItem], dataFields: [AnyHashable: Any]?)
    func trackAnonUpdateCart(items: [CommerceItem])
    func trackAnonTokenRegistration(token: String)
    func trackAnonUpdateUser(_ dataFields: [AnyHashable: Any])
    func updateAnonSession()
    func getAnonCriteria()
    func syncNonSyncedEvents()
}
