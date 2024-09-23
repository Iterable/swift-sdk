//
//  AuthFailure.swift
//  swift-sdk
//
//  Created by HARDIK MASHRU on 21/05/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import Foundation
@objc public class AuthFailure: NSObject {

    /// userId or email of the signed-in user
    public let userKey: String?

    /// the authToken which caused the failure
    public let failedAuthToken: String?

    /// the timestamp of the failed request
    public let failedRequestTime: Int

    /// indicates a reason for failure
    public let failureReason: AuthFailureReason

    public init(userKey: String?,
                failedAuthToken: String?,
                failedRequestTime: Int,
                failureReason: AuthFailureReason) {
        self.userKey = userKey
        self.failedAuthToken = failedAuthToken
        self.failedRequestTime = failedRequestTime
        self.failureReason = failureReason
    }
}
