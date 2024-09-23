//
//  Copyright © 2021 Iterable. All rights reserved.
//

import Foundation

@objc public protocol IterableAuthManagerProtocol {
    func getAuthToken() -> String?
    func resetFailedAuthCount()
    func requestNewAuthToken(hasFailedPriorAuth: Bool, onSuccess: ((String?) -> Void)?, shouldIgnoreRetryPolicy: Bool)
    func scheduleAuthTokenRefreshTimer(interval: TimeInterval, isScheduledRefresh: Bool, successCallback: AuthTokenRetrievalHandler?)
    func setNewToken(_ newToken: String)
    func logoutUser()
    func handleAuthFailure(failedAuthToken: String?, reason: AuthFailureReason)
    func pauseAuthRetries(_ pauseAuthRetry: Bool)
    func setIsLastAuthTokenValid(_ isValid: Bool)
    func getNextRetryInterval() -> Double
}
