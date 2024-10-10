//
//  Copyright © 2023 Iterable. All rights reserved.
//

import Foundation

protocol DependencyContainerProtocol: RedirectNetworkSessionProvider {
    var dateProvider: DateProviderProtocol { get }
    var networkSession: NetworkSessionProtocol { get }
    var notificationStateProvider: NotificationStateProviderProtocol { get }
    var localStorage: LocalStorageProtocol { get }
    var inAppDisplayer: InAppDisplayerProtocol { get }
    var inAppPersister: InAppPersistenceProtocol { get }
    var urlOpener: UrlOpenerProtocol { get }
    var applicationStateProvider: ApplicationStateProviderProtocol { get }
    var notificationCenter: NotificationCenterProtocol { get }
    var apnsTypeChecker: APNSTypeCheckerProtocol { get }
    
    func createInAppFetcher(apiClient: ApiClientProtocol) -> InAppFetcherProtocol
    func createPersistenceContextProvider() -> IterablePersistenceContextProvider?
    func createRequestHandler(apiKey: String,
                              config: IterableConfig,
                              endpoint: String,
                              authProvider: AuthProvider?,
                              authManager: IterableAuthManagerProtocol,
                              deviceMetadata: DeviceMetadata,
                              offlineMode: Bool) -> RequestHandlerProtocol
    func createHealthMonitorDataProvider(persistenceContextProvider: IterablePersistenceContextProvider) -> HealthMonitorDataProviderProtocol
}

extension DependencyContainerProtocol {
    func createInAppManager(config: IterableConfig,
                            apiClient: ApiClientProtocol,
                            requestHandler: RequestHandlerProtocol,
                            deviceMetadata: DeviceMetadata) -> IterableInternalInAppManagerProtocol {
        InAppManager(requestHandler: requestHandler,
                     deviceMetadata: deviceMetadata,
                     fetcher: createInAppFetcher(apiClient: apiClient),
                     displayer: inAppDisplayer,
                     persister: inAppPersister,
                     inAppDelegate: config.inAppDelegate,
                     urlDelegate: config.urlDelegate,
                     customActionDelegate: config.customActionDelegate,
                     urlOpener: urlOpener,
                     allowedProtocols: config.allowedProtocols,
                     applicationStateProvider: applicationStateProvider,
                     notificationCenter: notificationCenter,
                     dateProvider: dateProvider,
                     moveToForegroundSyncInterval: config.inAppDisplayInterval)
    }
    
    func createAuthManager(config: IterableConfig) -> IterableAuthManagerProtocol {
        AuthManager(delegate: config.authDelegate,
                    authRetryPolicy: config.retryPolicy,
                    expirationRefreshPeriod: config.expiringAuthTokenRefreshPeriod,
                    localStorage: localStorage,
                    dateProvider: dateProvider)
    }

    func createEmbeddedManager(config: IterableConfig,
                                        apiClient: ApiClientProtocol) -> IterableInternalEmbeddedManagerProtocol {
        IterableEmbeddedManager(apiClient: apiClient,
                                urlDelegate: config.urlDelegate,
                                customActionDelegate: config.customActionDelegate,
                                urlOpener: urlOpener,
                                allowedProtocols: config.allowedProtocols,
                                enableEmbeddedMessaging: config.enableEmbeddedMessaging)
    }
    
    func createRequestHandler(apiKey: String,
                              config: IterableConfig,
                              endpoint: String,
                              authProvider: AuthProvider?,
                              authManager: IterableAuthManagerProtocol,
                              deviceMetadata: DeviceMetadata,
                              offlineMode: Bool) -> RequestHandlerProtocol {
        let onlineProcessor = OnlineRequestProcessor(apiKey: apiKey,
                                                     authProvider: authProvider,
                                                     authManager: authManager,
                                                     endpoint: endpoint,
                                                     networkSession: networkSession,
                                                     deviceMetadata: deviceMetadata,
                                                     dateProvider: dateProvider)
        lazy var offlineProcessor: OfflineRequestProcessor? = nil
        lazy var healthMonitor: HealthMonitor? = nil
        guard let persistenceContextProvider = createPersistenceContextProvider() else {
            return RequestHandler(onlineProcessor: onlineProcessor,
                                  offlineProcessor: nil,
                                  healthMonitor: nil,
                                  offlineMode: offlineMode)
        }
        if offlineMode {
            
            let healthMonitorDataProvider = createHealthMonitorDataProvider(persistenceContextProvider: persistenceContextProvider)
            
            healthMonitor = HealthMonitor(dataProvider: healthMonitorDataProvider,
                                          dateProvider: dateProvider,
                                          networkSession: networkSession)
            offlineProcessor = OfflineRequestProcessor(apiKey: apiKey,
                                                       authProvider: authProvider,
                                                       authManager: authManager,
                                                       endpoint: endpoint,
                                                       deviceMetadata: deviceMetadata,
                                                       taskScheduler: createTaskScheduler(persistenceContextProvider: persistenceContextProvider,
                                                                                          healthMonitor: healthMonitor!),
                                                       taskRunner: createTaskRunner(persistenceContextProvider: persistenceContextProvider,
                                                                                    healthMonitor: healthMonitor!),
                                                       notificationCenter: notificationCenter)
            
            
            return RequestHandler(onlineProcessor: onlineProcessor,
                                  offlineProcessor: offlineProcessor,
                                  healthMonitor: healthMonitor,
                                  offlineMode: offlineMode)
        } else {
            return RequestHandler(onlineProcessor: onlineProcessor,
                                  offlineProcessor: nil,
                                  healthMonitor: nil,
                                  offlineMode: offlineMode)
        }
    }
    
    func createHealthMonitorDataProvider(persistenceContextProvider: IterablePersistenceContextProvider) -> HealthMonitorDataProviderProtocol {
        HealthMonitorDataProvider(maxTasks: 1000, persistenceContextProvider: persistenceContextProvider)
    }
    
    func createPersistenceContextProvider() -> IterablePersistenceContextProvider? {
        CoreDataPersistenceContextProvider(dateProvider: dateProvider)
    }
    
    func createRedirectNetworkSession(delegate: RedirectNetworkSessionDelegate) -> NetworkSessionProtocol {
        RedirectNetworkSession(delegate: delegate)
    }

    func createAnonymousUserManager(config: IterableConfig) -> AnonymousUserManagerProtocol {
        AnonymousUserManager(config:config,
                             localStorage: localStorage,
                             dateProvider: dateProvider,
                             notificationStateProvider: notificationStateProvider)
    }
    
    private func createTaskScheduler(persistenceContextProvider: IterablePersistenceContextProvider,
                                     healthMonitor: HealthMonitor) -> IterableTaskScheduler {
        IterableTaskScheduler(persistenceContextProvider: persistenceContextProvider,
                              notificationCenter: notificationCenter,
                              healthMonitor: healthMonitor,
                              dateProvider: dateProvider)
    }
    
    private func createTaskRunner(persistenceContextProvider: IterablePersistenceContextProvider,
                                  healthMonitor: HealthMonitor) -> IterableTaskRunner {
        IterableTaskRunner(networkSession: networkSession,
                           persistenceContextProvider: persistenceContextProvider,
                           healthMonitor: healthMonitor,
                           notificationCenter: notificationCenter,
                           connectivityManager: NetworkConnectivityManager())
    }
    
    func createAnonymousUserMerge(apiClient: ApiClient, anonymousUserManager: AnonymousUserManagerProtocol, localStorage: LocalStorageProtocol) -> AnonymousUserMergeProtocol {
        AnonymousUserMerge(apiClient: apiClient, anonymousUserManager: anonymousUserManager, localStorage: localStorage)
    }
}
