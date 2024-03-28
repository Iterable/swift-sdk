//
//  Copyright © 2020 Iterable. All rights reserved.
//

import Foundation

protocol ApiClientProtocol: AnyObject {
    func register(registerTokenInfo: RegisterTokenInfo, notificationsEnabled: Bool) -> Pending<SendRequestValue, SendRequestError>
    
    func updateUser(_ dataFields: [AnyHashable: Any], mergeNestedObjects: Bool) -> Pending<SendRequestValue, SendRequestError>
    
    func updateEmail(newEmail: String) -> Pending<SendRequestValue, SendRequestError>
    
    func updateCart(items: [CommerceItem]) -> Pending<SendRequestValue, SendRequestError>
    
    func updateCart(items: [CommerceItem], withUser user:[AnyHashable:Any], createdAt: Int) -> Pending<SendRequestValue, SendRequestError>
    
    func track(purchase total: NSNumber, items: [CommerceItem], dataFields: [AnyHashable: Any]?, campaignId: NSNumber?, templateId: NSNumber?) -> Pending<SendRequestValue, SendRequestError>
    
    func track(purchase total: NSNumber, items: [CommerceItem], dataFields: [AnyHashable: Any]?, withUser user: [AnyHashable: Any], createdAt: Int) -> Pending<SendRequestValue, SendRequestError>
    
    func track(pushOpen campaignId: NSNumber, templateId: NSNumber?, messageId: String, appAlreadyRunning: Bool, dataFields: [AnyHashable: Any]?) -> Pending<SendRequestValue, SendRequestError>
    
    func track(event eventName: String, dataFields: [AnyHashable: Any]?) -> Pending<SendRequestValue, SendRequestError>
    
    func track(event eventName: String, withBody body: [AnyHashable: Any]?) -> Pending<SendRequestValue, SendRequestError>
    
    func updateSubscriptions(_ emailListIds: [NSNumber]?,
                             unsubscribedChannelIds: [NSNumber]?,
                             unsubscribedMessageTypeIds: [NSNumber]?,
                             subscribedMessageTypeIds: [NSNumber]?,
                             campaignId: NSNumber?,
                             templateId: NSNumber?) -> Pending<SendRequestValue, SendRequestError>
    
    func getInAppMessages(_ count: NSNumber) -> Pending<SendRequestValue, SendRequestError>
    
    func track(inAppOpen inAppMessageContext: InAppMessageContext) -> Pending<SendRequestValue, SendRequestError>
    
    func track(inAppClick inAppMessageContext: InAppMessageContext, clickedUrl: String) -> Pending<SendRequestValue, SendRequestError>
    
    func track(inAppClose inAppMessageContext: InAppMessageContext, source: InAppCloseSource?, clickedUrl: String?) -> Pending<SendRequestValue, SendRequestError>
    
    func track(inAppDelivery inAppMessageContext: InAppMessageContext) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult func inAppConsume(messageId: String) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult func inAppConsume(inAppMessageContext: InAppMessageContext, source: InAppDeleteSource?) -> Pending<SendRequestValue, SendRequestError>
    
    func track(inboxSession: IterableInboxSession) -> Pending<SendRequestValue, SendRequestError>
    
    func disableDevice(forAllUsers allUsers: Bool, hexToken: String) -> Pending<SendRequestValue, SendRequestError>

    func getRemoteConfiguration() -> Pending<RemoteConfiguration, SendRequestError>
    
    func getUserByUserID(userId: String) -> Pending<SendRequestValue, SendRequestError>
    
    func getUserByEmail(email: String) -> Pending<SendRequestValue, SendRequestError>
    
    func mergeUser(sourceEmail: String, sourceUserId: String, destinationEmail: String, destinationUserId: String) -> Pending<SendRequestValue, SendRequestError>
    
    func getCriteria() -> Pending<SendRequestValue, SendRequestError>

    func trackAnonSession(createdAt: Int, withUserId userId: String, requestJson: [AnyHashable: Any])  -> Pending<SendRequestValue, SendRequestError>
}
