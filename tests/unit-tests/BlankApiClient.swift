//
//  Copyright © 2023 Iterable. All rights reserved.
//

import Foundation

@testable import IterableSDK

class BlankApiClient: ApiClientProtocol {
    
    func trackAnonSession(createdAt: Int, withUserId userId: String, requestJson: [AnyHashable : Any]) -> IterableSDK.Pending<IterableSDK.SendRequestValue, IterableSDK.SendRequestError> {
        Pending()
    }
    
    func getCriteria() -> IterableSDK.Pending<IterableSDK.SendRequestValue, IterableSDK.SendRequestError> {
        Pending()
    }
    
    
    func track(event eventName: String, dataFields: [AnyHashable : Any]?) -> IterableSDK.Pending<IterableSDK.SendRequestValue, IterableSDK.SendRequestError> {
        Pending()
    }
    
    func track(event eventName: String, withBody body: [AnyHashable : Any]?) -> IterableSDK.Pending<IterableSDK.SendRequestValue, IterableSDK.SendRequestError> {
        Pending()
    }
    
    
    func updateCart(items: [IterableSDK.CommerceItem], withUser user: [AnyHashable : Any], createdAt: Int) -> IterableSDK.Pending<IterableSDK.SendRequestValue, IterableSDK.SendRequestError> {
        Pending()
    }
    
    func track(purchase total: NSNumber, items: [IterableSDK.CommerceItem], dataFields: [AnyHashable : Any]?, withUser user: [AnyHashable : Any], createdAt: Int) -> IterableSDK.Pending<IterableSDK.SendRequestValue, IterableSDK.SendRequestError> {
        Pending()
    }
    
    func register(registerTokenInfo: RegisterTokenInfo, notificationsEnabled: Bool) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func updateUser(_ dataFields: [AnyHashable : Any], mergeNestedObjects: Bool) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func updateEmail(newEmail: String) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func updateCart(items: [CommerceItem]) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func track(purchase total: NSNumber, items: [CommerceItem], dataFields: [AnyHashable : Any]?, campaignId: NSNumber?, templateId: NSNumber?) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func track(pushOpen campaignId: NSNumber, templateId: NSNumber?, messageId: String, appAlreadyRunning: Bool, dataFields: [AnyHashable : Any]?) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func updateSubscriptions(_ emailListIds: [NSNumber]?, unsubscribedChannelIds: [NSNumber]?, unsubscribedMessageTypeIds: [NSNumber]?, subscribedMessageTypeIds: [NSNumber]?, campaignId: NSNumber?, templateId: NSNumber?) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func getInAppMessages(_ count: NSNumber) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func track(inAppOpen inAppMessageContext: InAppMessageContext) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func track(inAppClick inAppMessageContext: InAppMessageContext, clickedUrl: String) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func track(inAppClose inAppMessageContext: InAppMessageContext, source: InAppCloseSource?, clickedUrl: String?) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func track(inAppDelivery inAppMessageContext: InAppMessageContext) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func inAppConsume(messageId: String) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func inAppConsume(inAppMessageContext: InAppMessageContext, source: InAppDeleteSource?) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func track(inboxSession: IterableInboxSession) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func disableDevice(forAllUsers allUsers: Bool, hexToken: String) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func getRemoteConfiguration() -> Pending<RemoteConfiguration, SendRequestError> {
        Pending()
    }
    
    func getUserByUserID(userId: String) -> IterableSDK.Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func getUserByEmail(email: String) -> IterableSDK.Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func mergeUser(sourceEmail: String, sourceUserId: String, destinationEmail: String, destinationUserId: String) -> IterableSDK.Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
}
