//
//  Untitled.swift
//  swift-sdk
//
//  Created by Evan Greer on 9/19/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import Foundation
@objc public class IterableIdentityResolution: NSObject {

    /// userId or email of the signed-in user
    public var replayOnVisitorToKnown: Bool?

    /// the authToken which caused the failure
    public let mergeOnAnonymousToKnown: Bool?

    public init(replayOnVisitorToKnown: Bool?,
                mergeOnAnonymousToKnown: Bool?) {
        self.replayOnVisitorToKnown = replayOnVisitorToKnown
        self.mergeOnAnonymousToKnown = mergeOnAnonymousToKnown
    }
}
