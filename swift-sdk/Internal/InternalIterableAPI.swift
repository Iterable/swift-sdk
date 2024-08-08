//
//  Copyright © 2018 Iterable. All rights reserved.
//

import Foundation
import UIKit

final class InternalIterableAPI: NSObject, PushTrackerProtocol, AuthProvider {
    var apiKey: String
    
    var lastPushPayload: [AnyHashable: Any]? {
        get {
            _payloadData
        } set {
            setPayloadData(newValue)
        }
    }

    var email: String? {
        get {
            _email
        } set {
            setEmail(newValue)
        }
    }
    
    var userId: String? {
        get {
            _userId
        } set {
            setUserId(newValue)
        }
    }
    
    var authToken: String? {
        get {
            authManager.getAuthToken()
        }
    }
    
    var deviceId: String {
        if let value = localStorage.deviceId {
            return value
        } else {
            let value = IterableUtil.generateUUID()
            localStorage.deviceId = value
            return value
        }
    }
    
    var deviceMetadata: DeviceMetadata {
        DeviceMetadata(deviceId: deviceId,
                       platform: JsonValue.iOS,
                       appPackageName: Bundle.main.appPackageName ?? "")
    }
    
    var attributionInfo: IterableAttributionInfo? {
        get {
            localStorage.getAttributionInfo(currentDate: dateProvider.currentDate)
        } set {
            let expiration = Calendar.current.date(byAdding: .hour,
                                                   value: Const.UserDefault.attributionInfoExpiration,
                                                   to: dateProvider.currentDate)
            localStorage.save(attributionInfo: newValue, withExpiration: expiration)
        }
    }
    
    var auth: Auth {
        Auth(userId: userId, email: email, authToken: authManager.getAuthToken())
    }

    var dependencyContainer: DependencyContainerProtocol
    
    lazy var inAppManager: IterableInternalInAppManagerProtocol = {
        self.dependencyContainer.createInAppManager(config: self.config,
                                                    apiClient: self.apiClient,
                                                    requestHandler: self.requestHandler,
                                                    deviceMetadata: deviceMetadata)
    }()
    
    lazy var authManager: IterableAuthManagerProtocol = {
        self.dependencyContainer.createAuthManager(config: self.config)
    }()
    
    lazy var embeddedManager: IterableInternalEmbeddedManagerProtocol = {
        self.dependencyContainer.createEmbeddedManager(config: self.config,
                                                                apiClient: self.apiClient)
    }()
    
    var apiEndPointForTest: String {
        get {
            apiEndPoint
        }
    }
    
    // MARK: - SDK Functions
    
    @discardableResult func handleUniversalLink(_ url: URL) -> Bool {
        let (result, pending) = deepLinkManager.handleUniversalLink(url,
                                                                   urlDelegate: config.urlDelegate,
                                                                   urlOpener: urlOpener,
                                                                   allowedProtocols: config.allowedProtocols)
        
        pending.onSuccess { attributionInfo in
            if let attributionInfo = attributionInfo {
                self.attributionInfo = attributionInfo
            }
        }
        return result
    }
    
    func setDeviceAttribute(name: String, value: String) {
        deviceAttributes[name] = value
    }
    
    func removeDeviceAttribute(name: String) {
        deviceAttributes.removeValue(forKey: name)
    }

    func setPayloadData(_ data: [AnyHashable: Any]?) {
        ITBInfo()
        _payloadData = data
    }
    
    func setEmail(_ email: String?, authToken: String? = nil, successHandler: OnSuccessHandler? = nil, failureHandler: OnFailureHandler? = nil) {
        ITBInfo()
        
        if _email == email && email != nil && authToken != nil {
            checkAndUpdateAuthToken(authToken)
            return
        }
        
        if _email == email {
            return
        }
        
        logoutPreviousUser()
        
        _email = email
        _userId = nil
        _successCallback = successHandler
        _failureCallback = failureHandler
        
        storeIdentifierData()
        
        onLogin(authToken)
    }
    
    func setUserId(_ userId: String?, authToken: String? = nil, successHandler: OnSuccessHandler? = nil, failureHandler: OnFailureHandler? = nil) {
        ITBInfo()
        
        if _userId == userId && userId != nil && authToken != nil {
            checkAndUpdateAuthToken(authToken)
            return
        }
        
        if _userId == userId {
            return
        }
        
        logoutPreviousUser()
        
        _email = nil
        _userId = userId
        _successCallback = successHandler
        _failureCallback = failureHandler
        
        storeIdentifierData()
        
        onLogin(authToken)
    }
    
    func logoutUser(withOnSuccess onSuccess: OnSuccessHandler? = nil, onFailure: OnFailureHandler? = nil) {
        logoutPreviousUser(withOnSuccess: onSuccess, onFailure: onFailure)
    }
    
    // MARK: - API Request Calls
    
    func register(token: Data,
                  onSuccess: OnSuccessHandler? = nil,
                  onFailure: OnFailureHandler? = nil) {
        guard let appName = pushIntegrationName else {
            let errorMessage = "Not registering device token - appName must not be nil"
            ITBError(errorMessage)
            _failureCallback?(errorMessage, nil)
            onFailure?(errorMessage, nil)
            return
        }
        
        hexToken = token.hexString()
        let registerTokenInfo = RegisterTokenInfo(hexToken: token.hexString(),
                                                  appName: appName,
                                                  pushServicePlatform: config.pushPlatform,
                                                  apnsType: dependencyContainer.apnsTypeChecker.apnsType,
                                                  deviceId: deviceId,
                                                  deviceAttributes: deviceAttributes,
                                                  sdkVersion: localStorage.sdkVersion)
        requestHandler.register(registerTokenInfo: registerTokenInfo,
                                notificationStateProvider: notificationStateProvider,
                                onSuccess: { (_ data: [AnyHashable: Any]?) in
                                                self._successCallback?(data)
                                                onSuccess?(data)
                                },
                                onFailure: { (_ reason: String?, _ data: Data?) in
                                                self._failureCallback?(reason, data)
                                                onFailure?(reason, data)
                                }
        )
    }
    
    @discardableResult
    func disableDeviceForCurrentUser(withOnSuccess onSuccess: OnSuccessHandler? = nil,
                                     onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        guard let hexToken = hexToken else {
            let errorMessage = "no token present"
            onFailure?(errorMessage, nil)
            return SendRequestError.createErroredFuture(reason: errorMessage)
        }
        guard userId != nil || email != nil else {
            let errorMessage = "either userId or email must be present"
            onFailure?(errorMessage, nil)
            return SendRequestError.createErroredFuture(reason: errorMessage)
        }
        
        return requestHandler.disableDeviceForCurrentUser(hexToken: hexToken, withOnSuccess: onSuccess, onFailure: onFailure)
    }
    
    @discardableResult
    func disableDeviceForAllUsers(withOnSuccess onSuccess: OnSuccessHandler? = nil,
                                  onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        guard let hexToken = hexToken else {
            let errorMessage = "no token present"
            onFailure?(errorMessage, nil)
            return SendRequestError.createErroredFuture(reason: errorMessage)
        }
        return requestHandler.disableDeviceForAllUsers(hexToken: hexToken, withOnSuccess: onSuccess, onFailure: onFailure)
    }
    
    @discardableResult
    func updateUser(_ dataFields: [AnyHashable: Any],
                    mergeNestedObjects: Bool,
                    onSuccess: OnSuccessHandler? = nil,
                    onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.updateUser(dataFields, mergeNestedObjects: mergeNestedObjects, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    @discardableResult
    func updateEmail(_ newEmail: String,
                     withToken token: String? = nil,
                     onSuccess: OnSuccessHandler? = nil,
                     onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.updateEmail(newEmail,
                                   onSuccess: nil,
                                   onFailure: nil).onSuccess { json in
            if self.email != nil {
                self.setEmail(newEmail, authToken: token)
            }
            
            onSuccess?(json)
        }.onError { error in
            onFailure?(error.reason, error.data)
        }
    }
    
    @discardableResult
    func updateCart(items: [CommerceItem],
                    onSuccess: OnSuccessHandler? = nil,
                    onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.updateCart(items: items, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    @discardableResult
    func trackPurchase(_ total: NSNumber,
                       items: [CommerceItem],
                       dataFields: [AnyHashable: Any]? = nil,
                       campaignId: NSNumber? = nil,
                       templateId: NSNumber? = nil,
                       onSuccess: OnSuccessHandler? = nil,
                       onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.trackPurchase(total,
                                     items: items,
                                     dataFields: dataFields,
                                     campaignId: campaignId,
                                     templateId: templateId,
                                     onSuccess: onSuccess,
                                     onFailure: onFailure)
    }

    
    @discardableResult
    func trackPushOpen(_ userInfo: [AnyHashable: Any],
                       dataFields: [AnyHashable: Any]? = nil,
                       onSuccess: OnSuccessHandler? = nil,
                       onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        save(pushPayload: userInfo)
        
        if let metadata = IterablePushNotificationMetadata.metadata(fromLaunchOptions: userInfo), metadata.isRealCampaignNotification() {
            return trackPushOpen(metadata.campaignId,
                                 templateId: metadata.templateId,
                                 messageId: metadata.messageId,
                                 appAlreadyRunning: false,
                                 dataFields: dataFields,
                                 onSuccess: onSuccess,
                                 onFailure: onFailure)
        } else {
            return SendRequestError.createErroredFuture(reason: "Not tracking push open - payload is not an Iterable notification, or is a test/proof/ghost push")
        }
    }
    
    @discardableResult
    func trackPushOpen(_ campaignId: NSNumber,
                       templateId: NSNumber?,
                       messageId: String,
                       appAlreadyRunning: Bool,
                       dataFields: [AnyHashable: Any]? = nil,
                       onSuccess: OnSuccessHandler? = nil,
                       onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.trackPushOpen(campaignId,
                                       templateId: templateId,
                                       messageId: messageId,
                                       appAlreadyRunning: appAlreadyRunning,
                                       dataFields: dataFields,
                                       onSuccess: onSuccess,
                                       onFailure: onFailure)
    }
    
    @discardableResult
    func track(_ eventName: String,
               dataFields: [AnyHashable: Any]? = nil,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.track(event: eventName, dataFields: dataFields, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    @discardableResult
    func updateSubscriptions(_ emailListIds: [NSNumber]?,
                             unsubscribedChannelIds: [NSNumber]?,
                             unsubscribedMessageTypeIds: [NSNumber]?,
                             subscribedMessageTypeIds: [NSNumber]?,
                             campaignId: NSNumber?,
                             templateId: NSNumber?,
                             onSuccess: OnSuccessHandler? = nil,
                             onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        let updateSubscriptionsInfo = UpdateSubscriptionsInfo(emailListIds: emailListIds,
                                                              unsubscribedChannelIds: unsubscribedChannelIds,
                                                              unsubscribedMessageTypeIds: unsubscribedMessageTypeIds,
                                                              subscribedMessageTypeIds: subscribedMessageTypeIds,
                                                              campaignId: campaignId,
                                                              templateId: templateId)
        return requestHandler.updateSubscriptions(info: updateSubscriptionsInfo, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    @discardableResult
    func trackInAppOpen(_ message: IterableInAppMessage,
                        location: InAppLocation,
                        inboxSessionId: String? = nil,
                        onSuccess: OnSuccessHandler? = nil,
                        onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.trackInAppOpen(message,
                                        location: location,
                                        inboxSessionId: inboxSessionId,
                                        onSuccess: onSuccess,
                                        onFailure: onFailure)
    }
    
    @discardableResult
    func trackInAppClick(_ message: IterableInAppMessage,
                         location: InAppLocation = .inApp,
                         inboxSessionId: String? = nil,
                         clickedUrl: String,
                         onSuccess: OnSuccessHandler? = nil,
                         onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.trackInAppClick(message, location: location,
                                         inboxSessionId: inboxSessionId,
                                         clickedUrl: clickedUrl,
                                         onSuccess: onSuccess,
                                         onFailure: onFailure)
    }
    
    @discardableResult
    func trackInAppClose(_ message: IterableInAppMessage,
                         location: InAppLocation = .inApp,
                         inboxSessionId: String? = nil,
                         source: InAppCloseSource? = nil,
                         clickedUrl: String? = nil,
                         onSuccess: OnSuccessHandler? = nil,
                         onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.trackInAppClose(message,
                                         location: location,
                                         inboxSessionId: inboxSessionId,
                                         source: source,
                                         clickedUrl: clickedUrl,
                                         onSuccess: onSuccess,
                                         onFailure: onFailure)
    }
    
    @discardableResult
    func track(inboxSession: IterableInboxSession,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.track(inboxSession: inboxSession, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    @discardableResult
    func track(inAppDelivery message: IterableInAppMessage,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.track(inAppDelivery: message, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    @discardableResult
    func inAppConsume(_ messageId: String,
                      onSuccess: OnSuccessHandler? = nil,
                      onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.inAppConsume(messageId, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    @discardableResult
    func inAppConsume(message: IterableInAppMessage,
                      location: InAppLocation = .inApp,
                      source: InAppDeleteSource? = nil,
                      inboxSessionId: String? = nil,
                      onSuccess: OnSuccessHandler? = nil,
                      onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.inAppConsume(message: message,
                                    location: location,
                                    source: source,
                                    inboxSessionId: inboxSessionId,
                                    onSuccess: onSuccess,
                                    onFailure: onFailure)
    }
    
    @discardableResult
    func track(embeddedMessageReceived message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.track(embeddedMessageReceived: message,
                             onSuccess: onSuccess,
                             onFailure: onFailure)
    }
    
    @discardableResult
    func track(embeddedMessageClick message: IterableEmbeddedMessage,
               buttonIdentifier: String?,
               clickedUrl: String,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.track(embeddedMessageClick: message,
                             buttonIdentifier: buttonIdentifier,
                             clickedUrl: clickedUrl,
                             onSuccess: onSuccess,
                             onFailure: onFailure)
    }
    
    @discardableResult
    func track(embeddedMessageDismiss message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.track(embeddedMessageDismiss: message,
                             onSuccess: onSuccess,
                             onFailure: onFailure)
    }
    
    @discardableResult
    func track(embeddedMessageImpression message: IterableEmbeddedMessage,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.track(embeddedMessageImpression: message,
                             onSuccess: onSuccess,
                             onFailure: onFailure)
    }
    
    @discardableResult
    func track(embeddedSession: IterableEmbeddedSession,
               onSuccess: OnSuccessHandler? = nil,
               onFailure: OnFailureHandler? = nil) -> Pending<SendRequestValue, SendRequestError> {
        requestHandler.track(embeddedSession: embeddedSession, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    // MARK: - Private/Internal
    
    private var config: IterableConfig
    private var apiEndPoint: String
    
    /// Following are needed for handling pending notification and deep link.
    static var pendingNotificationResponse: NotificationResponseProtocol?
    static var pendingUniversalLink: URL?
    
    private let dateProvider: DateProviderProtocol
    private let inAppDisplayer: InAppDisplayerProtocol
    private var notificationStateProvider: NotificationStateProviderProtocol
    private var localStorage: LocalStorageProtocol
    private var networkSession: NetworkSessionProtocol
    private var urlOpener: UrlOpenerProtocol
    
    private var deepLinkManager: DeepLinkManager
    
    private var _email: String?
    private var _payloadData: [AnyHashable: Any]?
    private var _userId: String?
    private var _successCallback: OnSuccessHandler? = nil
    private var _failureCallback: OnFailureHandler? = nil

    
    /// the hex representation of this device token
    private var hexToken: String?
    
    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    lazy var apiClient: ApiClientProtocol = {
        ApiClient(apiKey: apiKey,
                  authProvider: self,
                  endpoint: apiEndPoint,
                  networkSession: networkSession,
                  deviceMetadata: deviceMetadata,
                  dateProvider: dateProvider)
    }()
    
    lazy var requestHandler: RequestHandlerProtocol = {
        let offlineMode = self.localStorage.offlineMode
        return dependencyContainer.createRequestHandler(apiKey: apiKey,
                                                        config: config,
                                                        endpoint: apiEndPoint,
                                                        authProvider: self,
                                                        authManager: authManager,
                                                        deviceMetadata: deviceMetadata,
                                                        offlineMode: offlineMode)
    }()
    
    private var deviceAttributes = [String: String]()
    
    private var pushIntegrationName: String? {
        if let pushIntegrationName = config.pushIntegrationName, let sandboxPushIntegrationName = config.sandboxPushIntegrationName {
            switch config.pushPlatform {
            case .production:
                return pushIntegrationName
            case .sandbox:
                return sandboxPushIntegrationName
            case .auto:
                return dependencyContainer.apnsTypeChecker.apnsType == .sandbox ? sandboxPushIntegrationName : pushIntegrationName
            }
        } else if let pushIntegrationName = config.pushIntegrationName {
            return pushIntegrationName
        } else {
            return Bundle.main.appPackageName
        }
    }
    
    private func isEitherUserIdOrEmailSet() -> Bool {
        IterableUtil.isNotNullOrEmpty(string: _email) || IterableUtil.isNotNullOrEmpty(string: _userId)
    }
    
    private func logoutPreviousUser(withOnSuccess onSuccess: OnSuccessHandler? = nil, onFailure: OnFailureHandler? = nil) {
        ITBInfo()
        
        guard isEitherUserIdOrEmailSet() else {
            return
        }
        
        if config.autoPushRegistration {
            disableDeviceForCurrentUser(withOnSuccess: onSuccess, onFailure: onFailure)
        }
        
        _email = nil
        _userId = nil
        
        storeIdentifierData()
        
        authManager.logoutUser()
                
        _ = inAppManager.reset()
        _ = embeddedManager.reset()
        
        try? requestHandler.handleLogout()
    }
    
    private func storeIdentifierData() {
        localStorage.email = _email
        localStorage.userId = _userId
    }
    
    private func onLogin(_ authToken: String? = nil) {
        ITBInfo()
        
        self.authManager.pauseAuthRetries(false)
        if let authToken = authToken {
            self.authManager.setNewToken(authToken)
            completeUserLogin()
        } else if isEitherUserIdOrEmailSet() && config.authDelegate != nil {
            requestNewAuthToken()
        } else {
            completeUserLogin()
        }
    }
    
    private func requestNewAuthToken() {
        ITBInfo()
        
        authManager.requestNewAuthToken(hasFailedPriorAuth: false, onSuccess: { [weak self] token in
            if token != nil {
                self?.completeUserLogin()
            }
        }, shouldIgnoreRetryPolicy: true)
    }
    
    private func completeUserLogin() {
        ITBInfo()
        
        guard isEitherUserIdOrEmailSet() else {
            return
        }
        
        if config.autoPushRegistration {
            notificationStateProvider.registerForRemoteNotifications()
        } else {
            _successCallback?([:])
        }
        
        _ = inAppManager.scheduleSync()
    }
    
    private func retrieveIdentifierData() {
        _email = localStorage.email
        _userId = localStorage.userId
    }
    
    private func save(pushPayload payload: [AnyHashable: Any]) {
        
        if let metadata = IterablePushNotificationMetadata.metadata(fromLaunchOptions: payload) {
            if let templateId = metadata.templateId {
                attributionInfo = IterableAttributionInfo(campaignId: metadata.campaignId, templateId: templateId, messageId: metadata.messageId)
            }

            if !metadata.isGhostPush {
                lastPushPayload = payload
            }
        }
    }
    
    private func checkAndUpdateAuthToken(_ authToken: String? = nil) {
        if config.authDelegate != nil && authToken != authManager.getAuthToken() {
            onLogin(authToken)
        }
    }
    
    private static func setApiEndpoint(apiEndPointOverride: String?, config: IterableConfig) -> String {
        let apiEndPoint = config.dataRegion
        return apiEndPointOverride ?? apiEndPoint
    }
    
    init(apiKey: String,
         launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil,
         config: IterableConfig = IterableConfig(),
         apiEndPointOverride: String? = nil,
         dependencyContainer: DependencyContainerProtocol = DependencyContainer()) {
        IterableLogUtil.sharedInstance = IterableLogUtil(dateProvider: dependencyContainer.dateProvider, logDelegate: config.logDelegate)
        ITBInfo()
        self.apiKey = apiKey
        self.launchOptions = launchOptions
        self.config = config
        apiEndPoint = InternalIterableAPI.setApiEndpoint(apiEndPointOverride: apiEndPointOverride, config: config)
        self.dependencyContainer = dependencyContainer
        dateProvider = dependencyContainer.dateProvider
        networkSession = dependencyContainer.networkSession
        notificationStateProvider = dependencyContainer.notificationStateProvider
        localStorage = dependencyContainer.localStorage
        inAppDisplayer = dependencyContainer.inAppDisplayer
        urlOpener = dependencyContainer.urlOpener
        deepLinkManager = DeepLinkManager(redirectNetworkSessionProvider: dependencyContainer)
    }
    
    func start() -> Pending<Bool, Error> {
        ITBInfo()
        
        updateSDKVersion()
        
        // get email and userId from UserDefaults if present
        retrieveIdentifierData()
        
        if config.autoPushRegistration, isEitherUserIdOrEmailSet() {
            notificationStateProvider.registerForRemoteNotifications()
        }
        
        IterableAppIntegration.implementation = InternalIterableAppIntegration(tracker: self,
                                                                               urlDelegate: config.urlDelegate,
                                                                               customActionDelegate: config.customActionDelegate,
                                                                               urlOpener: urlOpener,
                                                                               allowedProtocols: config.allowedProtocols,
                                                                               inAppNotifiable: inAppManager,
                                                                               embeddedNotifiable: embeddedManager)
        
        handle(launchOptions: launchOptions)
        
        handlePendingNotification()
        
        handlePendingUniversalLink()
        
        requestHandler.start()
        
        checkRemoteConfiguration()
                
        return inAppManager.start()
    }
    
    private func handle(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let launchOptions = launchOptions else {
            return
        }
        if let remoteNotificationPayload = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            if let _ = IterableUtil.rootViewController {
                // we are ready
                IterableAppIntegration.implementation?.performDefaultNotificationAction(remoteNotificationPayload)
            } else {
                // keywindow not set yet
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    IterableAppIntegration.implementation?.performDefaultNotificationAction(remoteNotificationPayload)
                }
            }
        }
    }
    
    private func handlePendingNotification() {
        if let pendingNotificationResponse = Self.pendingNotificationResponse {
            IterableAppIntegration.implementation?.userNotificationCenter(nil, didReceive: pendingNotificationResponse, withCompletionHandler: nil)
            Self.pendingNotificationResponse = nil
        }
    }
    
    private func handlePendingUniversalLink() {
        if let pendingUniversalLink = Self.pendingUniversalLink {
            handleUniversalLink(pendingUniversalLink)
            Self.pendingUniversalLink = nil
        }
    }
    
    private func updateSDKVersion() {
        if let lastVersion = localStorage.sdkVersion, lastVersion != IterableAPI.sdkVersion {
            performUpgrade(lastVersion: lastVersion, newVersion: IterableAPI.sdkVersion)
        } else {
            localStorage.sdkVersion = IterableAPI.sdkVersion
        }
    }
    
    private func performUpgrade(lastVersion _: String, newVersion: String) {
        // do upgrade things here
        localStorage.upgrade()
        
        // then set new version
        localStorage.sdkVersion = newVersion
    }
    
    private func checkRemoteConfiguration() {
        ITBInfo()
        requestHandler.getRemoteConfiguration().onSuccess { remoteConfiguration in
            self.localStorage.offlineMode = remoteConfiguration.offlineMode
            self.requestHandler.offlineMode = remoteConfiguration.offlineMode
            ITBInfo("setting offlineMode: \(self.requestHandler.offlineMode)")
        }.onError { error in
            let offlineMode = self.requestHandler.offlineMode
            ITBError("Could not get remote configuration: \(error.localizedDescription), using saved value: \(offlineMode)")
        }
    }
    
    deinit {
        ITBInfo()
        requestHandler.stop()
    }
}
