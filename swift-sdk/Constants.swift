//
//  Copyright © 2018 Iterable. All rights reserved.
//

import Foundation

enum Endpoint {
    private static let apiHostName = "https://api.iterable.com"
    
    static let api = Endpoint.apiHostName + Const.apiPath
}

enum EventType {
    static let customEvent = "customEvent"
    static let purchase = "purchase"
    static let updateUser = "user"
    static let updateCart = "updateCart"
    static let anonSession = "anonSession"
    static let tokenRegistration = "tokenRegistration"
    static let trackEvent = "trackEvent"
}

enum Const {
    static let apiPath = "/api/"
    
    static let deepLinkRegex = "/a/[a-zA-Z0-9]+"
    static let href = "href"
    static let exponentialFactor = 2.0
    
    enum Http {
        static let GET = "GET"
        static let POST = "POST"
    }
    
    enum Path {
        static let updateCart = "commerce/updateCart"
        static let trackPurchase = "commerce/trackPurchase"
        static let disableDevice = "users/disableDevice"
        static let getInAppMessages = "inApp/getMessages"
        static let inAppConsume = "events/inAppConsume"
        static let registerDeviceToken = "users/registerDeviceToken"
        static let trackEvent = "events/track"
        static let trackInAppClick = "events/trackInAppClick"
        static let trackInAppOpen = "events/trackInAppOpen"
        static let trackInAppClose = "events/trackInAppClose"
        static let trackInAppDelivery = "events/trackInAppDelivery"
        static let trackPushOpen = "events/trackPushOpen"
        static let trackInboxSession = "events/trackInboxSession"
        static let updateUser = "users/update"
        static let updateEmail = "users/updateEmail"
        static let updateSubscriptions = "users/updateSubscriptions"
        static let getRemoteConfiguration = "mobile/getRemoteConfiguration"
        static let mergeUser = "users/merge";
        static let getCriteria = "anonymoususer/list";
        static let trackAnonSession = "anonymoususer/events/session";
        static let getEmbeddedMessages = "embedded-messaging/messages"
        static let embeddedMessageReceived = "embedded-messaging/events/received"
        static let embeddedMessageClick = "embedded-messaging/events/click"
        static let embeddedMessageDismiss = "embedded-messaging/events/dismiss"
        static let embeddedMessageImpression = "embedded-messaging/events/impression"
        static let trackEmbeddedSession = "embedded-messaging/events/session"
    }
    
    public enum UserDefault {
        static let attributionInfoKey = "itbl_attribution_info_key"
        static let emailKey = "itbl_email"
        static let userIdKey = "itbl_userid"
        static let authTokenKey = "itbl_auth_token"
        static let ddlChecked = "itbl_ddl_checked"
        static let deviceId = "itbl_device_id"
        static let sdkVersion = "itbl_sdk_version"
        static let offlineMode = "itbl_offline_mode"
        static let anonymousUserEvents = "itbl_anonymous_user_events"
        static let criteriaData = "itbl_criteria_data"
        static let anonymousSessions = "itbl_anon_sessions"
        static let matchedCriteria = "itbl_matched_criteria"
        static let eventList = "itbl_event_list"
        static let anonymousUsageTrack = "itbl_anonymous_usage_track"
        static let attributionInfoExpiration = 24
    }
    
    enum Keychain {
        static let serviceName = "itbl_keychain"
        
        enum Key {
            static let email = "itbl_email"
            static let userId = "itbl_userid"
            static let userIdAnnon = "itbl_userid_annon"
            static let authToken = "itbl_auth_token"
        }
    }
    
    enum PriorityLevel {
        static let critical = 100.0
        static let high = 200.0
        static let medium = 300.0
        static let low = 400.0
        
        static let unassigned = 300.5
    }
    
    enum ProcessorTypeName {
        static let online = "Online"
        static let offline = "Offline"
    }
    
    enum CookieName {
        static let campaignId = "iterableEmailCampaignId"
        static let templateId = "iterableTemplateId"
        static let messageId = "iterableMessageId"
    }
    
    enum HttpHeader {
        static let location = "Location"
        static let setCookie = "Set-Cookie"
    }
}

enum JsonKey {
    static let email = "email"
    static let userId = "userId"
    static let userKey = "userKey"
    static let currentEmail = "currentEmail"
    static let currentUserId = "currentUserId"
    static let newEmail = "newEmail"
    static let emailListIds = "emailListIds"
    static let unsubscribedChannelIds = "unsubscribedChannelIds"
    static let unsubscribedMessageTypeIds = "unsubscribedMessageTypeIds"
    static let subscribedMessageTypeIds = "subscribedMessageTypeIds"
    static let preferUserId = "preferUserId"
    
    static let sourceEmail = "sourceEmail"
    static let sourceUserId = "sourceUserId"
    static let destinationEmail = "destinationEmail"
    static let destinationUserId = "destinationUserId"
    
    static let mergeNestedObjects = "mergeNestedObjects"
    
    static let inboxMetadata = "inboxMetadata"
    static let inboxTitle = "title"
    static let inboxSubtitle = "subtitle"
    static let inboxIcon = "icon"
    
    static let inboxExpiresAt = "expiresAt"
    static let inboxCreatedAt = "createdAt"
    
    static let inAppMessageContext = "messageContext"
    
    static let campaignId = "campaignId"
    static let templateId = "templateId"
    static let messageId = "messageId"
    static let inboxSessionId = "inboxSessionId"
    
    static let saveToInbox = "saveToInbox"
    static let silentInbox = "silentInbox"
    static let inAppLocation = "location"
    static let clickedUrl = "clickedUrl"
    static let read = "read"
    static let priorityLevel = "priorityLevel"
    
    static let inboxSessionStart = "inboxSessionStart"
    static let inboxSessionEnd = "inboxSessionEnd"
    static let startTotalMessageCount = "startTotalMessageCount"
    static let startUnreadMessageCount = "startUnreadMessageCount"
    static let endTotalMessageCount = "endTotalMessageCount"
    static let endUnreadMessageCount = "endUnreadMessageCount"
    static let impressions = "impressions"
    static let closeAction = "closeAction"
    static let deleteAction = "deleteAction"
    
    static let url = "url"
    
    static let device = "device"
    static let token = "token"
    static let dataFields = "dataFields"
    static let deviceInfo = "deviceInfo"
    static let identifierForVendor = "identifierForVendor"
    static let deviceId = "deviceId"
    static let localizedModel = "localizedModel"
    static let model = "model"
    static let userInterfaceIdiom = "userInterfaceIdiom"
    static let systemName = "systemName"
    static let systemVersion = "systemVersion"
    static let platform = "platform"
    static let appPackageName = "appPackageName"
    static let appVersion = "appVersion"
    static let appBuild = "appBuild"
    static let applicationName = "applicationName"
    static let eventName = "eventName"
    static let actionIdentifier = "actionIdentifier"
    static let userText = "userText"
    static let appAlreadyRunning = "appAlreadyRunning"
    static let anonSessionContext = "anonSessionContext"
    
    static let html = "html"
    
    static let iterableSdkVersion = "iterableSdkVersion"
    
    static let notificationsEnabled = "notificationsEnabled"
    
    static let contentType = "Content-Type"
    
    // AUT
    static let createNewFields = "createNewFields"
    static let eventType = "dataType"
    static let eventTimeStamp = "eventTimeStamp"
    static let criteriaSets = "criteriaSets"
    static let matchedCriteriaId = "matchedCriteriaId"
    static let mobilePushOptIn = "mobilePushOptIn"
    
    enum CriteriaItem {
        static let searchQuery = "searchQuery"
        static let criteriaId = "criteriaId"
        static let searchQueries = "searchQueries"
        static let combinator = "combinator"
        static let searchCombo = "searchCombo"
        static let field = "field"
        static let comparatorType = "comparatorType"
        static let fieldType = "fieldType"
        static let value = "value"
        static let values = "values"
        static let minMatch = "minMatch"

        enum Combinator {
            static let and = "And"
            static let or = "Or"
            static let not = "Not"
        }
        
        enum CartEventItemsPrefix {
            static let updateCartItemPrefix = "updateCart.updatedShoppingCartItems"
            static let purchaseItemPrefix = "shoppingCartItems"
        }
        
        enum CartEventPrefix {
            static let updateCartItemPrefix = CartEventItemsPrefix.updateCartItemPrefix + "."
            static let purchaseItemPrefix = CartEventItemsPrefix.purchaseItemPrefix + "."
        }
        
        enum Comparator {
            static let Equals = "Equals"
            static let DoesNotEquals = "DoesNotEqual"
            static let IsSet = "IsSet"
            static let GreaterThan = "GreaterThan"
            static let LessThan = "LessThan"
            static let GreaterThanOrEqualTo = "GreaterThanOrEqualTo"
            static let LessThanOrEqualTo = "LessThanOrEqualTo"
            static let Contains = "Contains"
            static let StartsWith = "StartsWith"
            static let MatchesRegex = "MatchesRegex"
        }
    }

    
//    embedded
    static let embeddedSessionId = "session"
    static let placementId = "placementId"
    static let embeddedSessionStart = "embeddedSessionStart"
    static let embeddedSessionEnd = "embeddedSessionEnd"
    static let embeddedButtonId = "buttonIdentifier"
    static let embeddedTargetUrl = "targetUrl"
    
    
    enum ActionButton {
        static let identifier = "identifier"
        static let action = "action"
    }
    
    enum Commerce {
        static let items = "items"
        static let total = "total"
        static let user = "user"
    }
    
    enum CommerceItem {
        static let id = "id"
        static let name = "name"
        static let price = "price"
        static let quantity = "quantity"
        static let sku = "sku"
        static let description = "description"
        static let imageUrl = "imageUrl"
        static let url = "url"
        static let categories = "categories"
        static let dataFields = "dataFields"
    }
    
    enum Device {
        static let localizedModel = "localizedModel"
        static let vendorId = "identifierForVendor"
        static let model = "model"
        static let systemName = "systemName"
        static let systemVersion = "systemVersion"
        static let userInterfaceIdiom = "userInterfaceIdiom"
    }
    
    enum Embedded {
        static let packageName = "packageName"
        static let sdkVersion = "SDKVersion"
    }
    
    enum Header {
        static let apiKey = "Api-Key"
        static let sdkVersion = "SDK-Version"
        static let sdkPlatform = "SDK-Platform"
        static let authorization = "Authorization"
        static let sentAt = "Sent-At"
        static let requestProcessor = "SDK-Request-Processor"
    }
    
    enum Body {
        static let createdAt = "createdAt"
    }
    
    enum InApp {
        static let trigger = "trigger"
        static let type = "type"
        static let contentType = "contentType"
        static let inAppDisplaySettings = "inAppDisplaySettings"
        static let backgroundAlpha = "backgroundAlpha"
        static let customPayload = "customPayload"
        static let inAppMessages = "inAppMessages"
        static let count = "count"
        static let packageName = "packageName"
        static let sdkVersion = "SDKVersion"
        static let content = "content"
    }
    
    enum Payload {
        static let metadata = "itbl"
        static let actionButtons = "actionButtons"
        static let defaultAction = "defaultAction"
    }
    
    enum Response {
        static let iterableCode = "code"
    }
    
    enum JWT {
        static let exp = "exp"
    }
}

enum JsonValue {
    static let applicationJson = "application/json"
    static let apnsSandbox = "APNS_SANDBOX"
    static let apnsProduction = "APNS"
    static let iOS = "iOS"
    static let bearer = "Bearer"

    enum ActionIdentifier {
        static let pushOpenDefault = "default"
    }
    
    enum DeviceIdiom {
        static let pad = "Pad"
        static let phone = "Phone"
        static let carPlay = "CarPlay"
        static let tv = "TV"
        static let unspecified = "Unspecified"
    }
    
    enum Code {
        static let badApiKey = "BadApiKey"
        static let invalidJwtPayload = "InvalidJwtPayload"
        static let badAuthorizationHeader = "BadAuthorizationHeader"
        static let jwtUserIdentifiersMismatched = "JwtUserIdentifiersMismatched"
    }
}

public enum IterableDataRegion {
    public static let US = "https://api.iterable.com/api/"
    public static let EU = "https://api.eu.iterable.com/api/"
}

public protocol JsonValueRepresentable {
    var jsonValue: Any { get }
}

@objc public enum InAppLocation: Int, JsonValueRepresentable {
    case inApp
    case inbox
    
    public var jsonValue: Any {
        switch self {
        case .inApp:
            return "in-app"
        case .inbox:
            return "inbox"
        }
    }
}

@objc public enum InAppCloseSource: Int, JsonValueRepresentable {
    case back
    case link
    
    public var jsonValue: Any {
        switch self {
        case .back:
            return "back"
        case .link:
            return "link"
        }
    }
}

@objc public enum InAppDeleteSource: Int, JsonValueRepresentable {
    case inboxSwipe
    case deleteButton
    
    public var jsonValue: Any {
        switch self {
        case .inboxSwipe:
            return "inbox-swipe"
        case .deleteButton:
            return "delete-button"
        }
    }
}

extension Int: JsonValueRepresentable {
    public var jsonValue: Any {
        self
    }
}

extension String: JsonValueRepresentable {
    public var jsonValue: Any {
        self
    }
}

extension Bool: JsonValueRepresentable {
    public var jsonValue: Any {
        self
    }
}

extension Dictionary: JsonValueRepresentable {
    public var jsonValue: Any {
        self
    }
}

extension Array: JsonValueRepresentable where Element: JsonValueRepresentable {
    public var jsonValue: Any {
        self
    }
}

enum MobileDeviceType: String, Codable {
    case iOS
    case Android
}

@objc public enum IterableActionSource: Int {
    case push
    case universalLink
    case inApp
    case embedded
}

// Lowest level that will be logged. By default the LogLevel is set to LogLevel.info.
@objc(IterableLogLevel) public enum LogLevel: Int {
    case debug = 1
    case info
    case error
}

/**
 Enum representing push platform; apple push notification service, production vs sandbox
 */
@objc public enum PushServicePlatform: Int {
    /** The sandbox push service */
    case sandbox
    /** The production push service */
    case production
    /** Detect automatically */
    case auto
}

// These are custom action for "iterable://delete" etc.
public enum IterableCustomActionName: String, CaseIterable {
    case dismiss
    case delete
}

public enum MergeResult: String {
    case mergenotrequired
    case mergesuccessful
    case mergefailed
}

public typealias ITEActionBlock = (String?) -> Void
public typealias ITBURLCallback = (URL?) -> Void
public typealias OnSuccessHandler = (_ data: [AnyHashable: Any]?) -> Void
public typealias OnFailureHandler = (_ reason: String?, _ data: Data?) -> Void
public typealias UrlHandler = (URL) -> Bool
public typealias CustomActionHandler = (String) -> Bool
public typealias AuthTokenRetrievalHandler = (String?) -> Void
public typealias MergeActionHandler = (MergeResult, String?) -> Void
