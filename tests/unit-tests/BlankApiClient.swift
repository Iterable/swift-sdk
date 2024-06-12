//
//  Copyright © 2023 Iterable. All rights reserved.
//

import Foundation

@testable import IterableSDK

class BlankApiClient: ApiClientProtocol {
    func register(registerTokenInfo: RegisterTokenInfo, notificationsEnabled: Bool) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func updateUser(_ dataFields: [AnyHashable : Any], mergeNestedObjects: Bool) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func updateEmail(newEmail: String, merge: Bool?) -> Pending<SendRequestValue, SendRequestError> {
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
    
    func track(event eventName: String, dataFields: [AnyHashable : Any]?) -> Pending<SendRequestValue, SendRequestError> {
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
    
    func getEmbeddedMessages() -> Pending<PlacementsPayload, SendRequestError> {
        Pending()
    }
    
    func track(embeddedMessageReceived message: IterableEmbeddedMessage) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func track(embeddedMessageClick message: IterableEmbeddedMessage, buttonIdentifier: String?, clickedUrl: String) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func track(embeddedMessageDismiss message: IterableEmbeddedMessage) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func track(embeddedMessageImpression message: IterableEmbeddedMessage) -> Pending<SendRequestValue, SendRequestError> {
        Pending()
    }
    
    func track(embeddedSession: IterableEmbeddedSession) -> Pending<IterableSDK.SendRequestValue, SendRequestError> {
        Pending()
    }
}
