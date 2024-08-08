//
//  Copyright © 2018 Iterable. All rights reserved.
//

import Foundation

class DeepLinkManager: NSObject {
    init(redirectNetworkSessionProvider: RedirectNetworkSessionProvider) {
        self.redirectNetworkSessionProvider = redirectNetworkSessionProvider
    }
    
    /// Handles a Universal Link
    /// For Iterable links, it will track the click and retrieve the original URL,
    /// pass it to `IterableURLDelegate` for handling
    /// If it's not an Iterable link, it just passes the same URL to `IterableURLDelegate`
    func handleUniversalLink(_ url: URL,
                             urlDelegate: IterableURLDelegate?,
                             urlOpener: UrlOpenerProtocol,
                             allowedProtocols: [String] = []) -> (Bool, Pending<IterableAttributionInfo?, Error>) {
        if isIterableDeepLink(url.absoluteString) {
            let pending = resolve(appLinkURL: url).map { (resolvedUrl, attributionInfo) -> IterableAttributionInfo? in
                var resolvedUrlString: String
                if let resolvedUrl = resolvedUrl {
                    resolvedUrlString = resolvedUrl.absoluteString
                } else {
                    resolvedUrlString = url.absoluteString
                }
                
                if let action = IterableAction.actionOpenUrl(fromUrlString: resolvedUrlString) {
                    let context = IterableActionContext(action: action, source: .universalLink)
                    
                    ActionRunner.execute(action: action,
                                                 context: context,
                                                 urlHandler: IterableUtil.urlHandler(fromUrlDelegate: urlDelegate,
                                                                                     inContext: context),
                                                 urlOpener: urlOpener,
                                                 allowedProtocols: allowedProtocols)
                }
                
                return attributionInfo
            }
            
            // Always return true for deep link
            return (true, pending)
        } else {
            var result: Bool = false
            if let action = IterableAction.actionOpenUrl(fromUrlString: url.absoluteString) {
                let context = IterableActionContext(action: action, source: .universalLink)
                
                result = ActionRunner.execute(action: action,
                                             context: context,
                                             urlHandler: IterableUtil.urlHandler(fromUrlDelegate: urlDelegate,
                                                                                 inContext: context),
                                             urlOpener: urlOpener,
                                             allowedProtocols: allowedProtocols)
            }
            return (result, Fulfill<IterableAttributionInfo?, Error>(value: nil))
        }
    }
    
    /// And we will resolve with redirected URL from our server and we will also try to get attribution info.
    /// Otherwise, we will just resolve with the original URL.
    private func resolve(appLinkURL: URL) -> Pending<(URL?, IterableAttributionInfo?), Error> {
        let fulfill = Fulfill<(URL?, IterableAttributionInfo?), Error>()
        
        deepLinkCampaignId = nil
        deepLinkTemplateId = nil
        deepLinkMessageId = nil
        
        if isIterableDeepLink(appLinkURL.absoluteString) {
            redirectUrlSession.makeDataRequest(with: appLinkURL) { [unowned self] _, _, error in
                if let error = error {
                    ITBError("error: \(error.localizedDescription)")
                    fulfill.resolve(with: (nil, nil))
                } else {
                    if let deepLinkCampaignId = self.deepLinkCampaignId,
                        let deepLinkTemplateId = self.deepLinkTemplateId,
                        let deepLinkMessageId = self.deepLinkMessageId {
                        fulfill.resolve(with: (self.deepLinkLocation, IterableAttributionInfo(campaignId: deepLinkCampaignId, templateId: deepLinkTemplateId, messageId: deepLinkMessageId)))
                    } else {
                        fulfill.resolve(with: (self.deepLinkLocation, nil))
                    }
                }
            }
        } else {
            fulfill.resolve(with: (appLinkURL, nil))
        }
        
        return fulfill
    }
    
    private func isIterableDeepLink(_ urlString: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: Const.deepLinkRegex, options: []) else {
            return false
        }
        
        return regex.firstMatch(in: urlString, options: [], range: NSMakeRange(0, urlString.count)) != nil
    }
    
    private lazy var redirectUrlSession: NetworkSessionProtocol = {
        redirectNetworkSessionProvider.createRedirectNetworkSession(delegate: self)
    }()

    
    private var redirectNetworkSessionProvider: RedirectNetworkSessionProvider
    private var deepLinkLocation: URL?
    private var deepLinkCampaignId: NSNumber?
    private var deepLinkTemplateId: NSNumber?
    private var deepLinkMessageId: String?
}

extension DeepLinkManager: RedirectNetworkSessionDelegate {
    func onRedirect(deepLinkLocation: URL?, campaignId: NSNumber?, templateId: NSNumber?, messageId: String?) {
        self.deepLinkLocation = deepLinkLocation
        self.deepLinkCampaignId = campaignId
        self.deepLinkTemplateId = templateId
        self.deepLinkMessageId = messageId
    }
}
