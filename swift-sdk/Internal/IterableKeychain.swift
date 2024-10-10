//
//  Copyright © 2021 Iterable. All rights reserved.
//

import Foundation

class IterableKeychain {
    init(wrapper: KeychainWrapper = KeychainWrapper()) {
        self.wrapper = wrapper
    }
    
    var email: String? {
        get {
            let data = wrapper.data(forKey: Const.Keychain.Key.email)
            
            return data.flatMap { String(data: $0, encoding: .utf8) }
        }
        
        set {
            guard let token = newValue,
                  let data = token.data(using: .utf8) else {
                wrapper.removeValue(forKey: Const.Keychain.Key.email)
                return
            }
            
            wrapper.set(data, forKey: Const.Keychain.Key.email)
        }
    }
    
    var userId: String? {
        get {
            let data = wrapper.data(forKey: Const.Keychain.Key.userId)
            
            return data.flatMap { String(data: $0, encoding: .utf8) }
        }
        
        set {
            guard let token = newValue,
                  let data = token.data(using: .utf8) else {
                wrapper.removeValue(forKey: Const.Keychain.Key.userId)
                return
            }
            
            wrapper.set(data, forKey: Const.Keychain.Key.userId)
        }
    }
    
    var userIdAnnon: String? {
        get {
            let data = wrapper.data(forKey: Const.Keychain.Key.userIdAnnon)
            
            return data.flatMap { String(data: $0, encoding: .utf8) }
        }
        
        set {
            guard let token = newValue,
                  let data = token.data(using: .utf8) else {
                wrapper.removeValue(forKey: Const.Keychain.Key.userIdAnnon)
                return
            }
            
            wrapper.set(data, forKey: Const.Keychain.Key.userIdAnnon)
        }
    }
    
    var authToken: String? {
        get {
            let data = wrapper.data(forKey: Const.Keychain.Key.authToken)
            
            return data.flatMap { String(data: $0, encoding: .utf8) }
        }
        
        set {
            guard let token = newValue,
                  let data = token.data(using: .utf8) else {
                wrapper.removeValue(forKey: Const.Keychain.Key.authToken)
                return
            }
            
            wrapper.set(data, forKey: Const.Keychain.Key.authToken)
        }
    }
    
    // MARK: - PRIVATE/INTERNAL
    
    private let wrapper: KeychainWrapper
    
    private func encodeJsonPayload(_ json: [AnyHashable: Any]?) -> Data? {
        guard let json = json, JSONSerialization.isValidJSONObject(json) else {
            return nil
        }
        
        return try? JSONSerialization.data(withJSONObject: json)
    }
    
    private func decodeJsonPayload(_ data: Data?) -> [AnyHashable: Any]? {
        guard let data = data else {
            return nil
        }
        
        return try? JSONSerialization.jsonObject(with: data) as? [AnyHashable: Any]
    }
    
}
