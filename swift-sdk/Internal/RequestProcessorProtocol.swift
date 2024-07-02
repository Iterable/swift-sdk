//
//  Copyright © 2020 Iterable. All rights reserved.
//

import Foundation

struct RegisterTokenInfo {
    let hexToken: String
    let appName: String
    let pushServicePlatform: PushServicePlatform
    let apnsType: APNSType
    let deviceId: String
    let deviceAttributes: [String: String]
    let sdkVersion: String?
}

struct UpdateSubscriptionsInfo {
    let emailListIds: [NSNumber]?
    let unsubscribedChannelIds: [NSNumber]?
    let unsubscribedMessageTypeIds: [NSNumber]?
    let subscribedMessageTypeIds: [NSNumber]?
    let campaignId: NSNumber?
    let templateId: NSNumber?
}

/// `RequestHandler` will delegate network related calls to this protocol.
protocol RequestProcessorProtocol {
    @discardableResult
    func updateCart(items: [CommerceItem],
                    onSuccess: OnSuccessHandler?,
                    onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func updateCart(items: [CommerceItem],
                    createdAt: Int,
                    onSuccess: OnSuccessHandler?,
                    onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func trackPurchase(_ total: NSNumber,
                       items: [CommerceItem],
                       dataFields: [AnyHashable: Any]?,
                       campaignId: NSNumber?,
                       templateId: NSNumber?,
                       onSuccess: OnSuccessHandler?,
                       onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func trackPurchase(_ total: NSNumber,
                       items: [CommerceItem],
                       dataFields: [AnyHashable: Any]?,
                       createdAt: Int,
                       onSuccess: OnSuccessHandler?,
                       onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func trackPushOpen(_ campaignId: NSNumber,
                       templateId: NSNumber?,
                       messageId: String,
                       appAlreadyRunning: Bool,
                       dataFields: [AnyHashable: Any]?,
                       onSuccess: OnSuccessHandler?,
                       onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func track(event: String,
               dataFields: [AnyHashable: Any]?,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func track(event: String,
               withBody body: [AnyHashable: Any]?,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func trackInAppOpen(_ message: IterableInAppMessage,
                        location: InAppLocation,
                        inboxSessionId: String?,
                        onSuccess: OnSuccessHandler?,
                        onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func trackInAppClick(_ message: IterableInAppMessage,
                         location: InAppLocation,
                         inboxSessionId: String?,
                         clickedUrl: String,
                         onSuccess: OnSuccessHandler?,
                         onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func trackInAppClose(_ message: IterableInAppMessage,
                         location: InAppLocation,
                         inboxSessionId: String?,
                         source: InAppCloseSource?,
                         clickedUrl: String?,
                         onSuccess: OnSuccessHandler?,
                         onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    @discardableResult
    func track(inboxSession: IterableInboxSession,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func track(inAppDelivery message: IterableInAppMessage,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func inAppConsume(_ messageId: String,
                      onSuccess: OnSuccessHandler?,
                      onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func inAppConsume(message: IterableInAppMessage,
                      location: InAppLocation,
                      source: InAppDeleteSource?,
                      inboxSessionId: String?,
                      onSuccess: OnSuccessHandler?,
                      onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func track(embeddedMessageReceived message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func track(embeddedMessageClick message: IterableEmbeddedMessage, buttonIdentifier: String?, clickedUrl: String,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func track(embeddedMessageDismiss message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func track(embeddedMessageImpression message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
    
    @discardableResult
    func track(embeddedSession: IterableEmbeddedSession,
               onSuccess: OnSuccessHandler?,
               onFailure: OnFailureHandler?) -> Pending<SendRequestValue, SendRequestError>
}
