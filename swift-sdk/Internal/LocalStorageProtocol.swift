//
//  Copyright © 2018 Iterable. All rights reserved.
//

import Foundation

protocol LocalStorageProtocol {
    var userId: String? { get set }
    
    var userIdAnnon: String? { get set }
    
    var email: String? { get set }
    
    var authToken: String? { get set }
    
    var ddlChecked: Bool { get set }
    
    var deviceId: String? { get set }
    
    var sdkVersion: String? { get set }
    
    var offlineMode: Bool { get set }

    var anonymousUsageTrack: Bool { get set }

    var anonymousUserEvents: [[AnyHashable: Any]]? { get set }

    var criteriaData: Data? { get set }

    var anonymousSessions: IterableAnonSessionsWrapper? { get set }
    
    func getAttributionInfo(currentDate: Date) -> IterableAttributionInfo?
    
    func save(attributionInfo: IterableAttributionInfo?, withExpiration expiration: Date?)
    
    func upgrade()
}

extension LocalStorageProtocol {
    func upgrade() {
    }
}
