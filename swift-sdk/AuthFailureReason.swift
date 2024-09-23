//
//  AuthFailureReason.swift
//  swift-sdk
//
//  Created by HARDIK MASHRU on 21/05/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import Foundation
@objc public enum AuthFailureReason: Int {
    case authTokenExpired
    case authTokenGenericError
    case authTokenExpirationInvalid
    case authTokenSignatureInvalid
    case authTokenFormatInvalid
    case authTokenInvalidated
    case authTokenPayloadInvalid
    case authTokenUserKeyInvalid
    case authTokenNull
    case authTokenGenerationError
    case authTokenMissing
}
