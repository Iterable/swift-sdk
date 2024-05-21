//
//  Copyright © 2020 Iterable. All rights reserved.
//

import Foundation

class NetworkConnectivityManager: NSObject {
    init(networkMonitor: NetworkMonitorProtocol? = nil,
         connectivityChecker: NetworkConnectivityChecker = NetworkConnectivityChecker(),
         notificationCenter: NotificationCenterProtocol = NotificationCenter.default,
         offlineModePollingInterval: TimeInterval? = nil,
         onlineModePollingInterval: TimeInterval? = nil) {
        ITBInfo()
        self.networkMonitor = networkMonitor ?? Self.createNetworkMonitor()
        self.connectivityChecker = connectivityChecker
        self.notificationCenter = notificationCenter
        self.offlineModePollingInterval = offlineModePollingInterval ?? Self.defaultOfflineModePollingInterval
        self.onlineModePollingInterval = onlineModePollingInterval ?? Self.defaultOnlineModePollingInterval
        super.init()
        notificationCenter.addObserver(self,
                                       selector: #selector(onNetworkOnline(notification:)),
                                       name: .iterableNetworkOnline,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(onNetworkOffline(notification:)),
                                       name: .iterableNetworkOffline,
                                       object: nil)
    }
    
    deinit {
        ITBInfo()
        notificationCenter.removeObserver(self)
        stop()
    }
    
    var isOnline: Bool {
        online
    }
    
    var connectivityChangedCallback: ((Bool) -> Void)?
    
    func start() {
        ITBInfo()
        networkMonitor.statusUpdatedCallback = { [weak self] in self?.updateStatus() }
        networkMonitor.start()
        startTimer()
    }
    
    func stop() {
        ITBInfo()
        networkMonitor.stop()
        stopTimer()
    }
    
    private func startTimer() {
        ITBInfo()
        let interval = online ? onlineModePollingInterval : offlineModePollingInterval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self] _ in
            ITBInfo("timer called")
            self?.updateStatus()
        })
    }

    private func stopTimer() {
        ITBInfo()
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        ITBInfo()
        stopTimer()
        startTimer()
    }

    private func updateStatus() {
        ITBInfo()
        connectivityChecker.checkConnectivity().onSuccess { connected in
            self.online = connected
        }
    }
    
    @objc
    private func onNetworkOnline(notification _: Notification) {
        ITBInfo()
        online = true
    }

    @objc
    private func onNetworkOffline(notification _: Notification) {
        ITBInfo()
        online = false
    }

    private static func createNetworkMonitor() -> NetworkMonitorProtocol {
        return NetworkMonitor()
    }

    private let notificationCenter: NotificationCenterProtocol
    private var networkMonitor: NetworkMonitorProtocol
    private let connectivityChecker: NetworkConnectivityChecker
    private var timer: Timer?
    private let offlineModePollingInterval: TimeInterval
    private let onlineModePollingInterval: TimeInterval
    private static let defaultOfflineModePollingInterval: TimeInterval = 1 * 60.0
    private static let defaultOnlineModePollingInterval: TimeInterval = 10 * 60
    
    private var online = true {
        didSet {
            ITBInfo("online: \(online)")
            if online != oldValue {
                ITBInfo("connectivity changed")
                connectivityChangedCallback?(online)
                resetTimer()
            }
        }
    }
}

