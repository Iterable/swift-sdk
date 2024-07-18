//
//  AnonymousUserMerge.swift
//  Iterable-iOS-SDK
//
//  Created by Hani Vora on 19/12/23.
//

import Foundation

protocol AnonymousUserMergeProtocol {
    func tryMergeUser(sourceUserId: String?, sourceEmail: String?, destinationUserIdOrEmail: String?, isEmail: Bool, merge: Bool, onMergeResult: @escaping MergeActionHandler)
}

class AnonymousUserMerge: AnonymousUserMergeProtocol {
    
    var anonymousUserManager: AnonymousUserManagerProtocol
    var apiClient: ApiClient
    
    init(apiClient: ApiClient, anonymousUserManager: AnonymousUserManagerProtocol) {
        self.apiClient = apiClient
        self.anonymousUserManager = anonymousUserManager
    }
    
    public func tryMergeUser(sourceUserId: String?, sourceEmail: String?, destinationUserIdOrEmail: String?, isEmail: Bool, merge: Bool, onMergeResult: @escaping MergeActionHandler) {
        if (sourceUserId != nil && destinationUserIdOrEmail != nil && merge) {
            let destinationEmail = isEmail ? destinationUserIdOrEmail : nil
            let destinationUserId = isEmail ? nil : destinationUserIdOrEmail
            
            apiClient.mergeUser(sourceEmail: sourceEmail, sourceUserId: sourceUserId,  destinationEmail : destinationEmail, destinationUserId: destinationUserId).onSuccess {_ in
                onMergeResult(MergeResult.mergesuccessful, nil)
            }.onError {error in
                print("Merge failed error: \(error)")
                onMergeResult(MergeResult.mergefailed, error.reason)
            }
        } else {
            // this will return mergeResult true in case of anon userId doesn't exist or destinationUserIdOrEmail is nil because merge is not required
            onMergeResult(MergeResult.mergenotrequired, nil)
        }
    }
}
