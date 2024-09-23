//
//  RetryPolicy.swift
//  swift-sdk
//
//  Created by HARDIK MASHRU on 15/05/24.
//  Copyright © 2024 Iterable. All rights reserved.
//

import Foundation

public class RetryPolicy {

    /**
     * Number of consecutive JWT refresh retries the SDK should attempt before disabling JWT refresh attempts altogether.
     */
    var maxRetry: Int

    /**
     * Configurable duration (in seconds) between JWT refresh retries. Starting point for the retry backoff.
     */
    var retryInterval: Double

    /**
     * Linear or Exponential. Determines the backoff pattern to apply between retry attempts.
     */
    var retryBackoff: RetryPolicy.BackoffType

    public enum BackoffType {
        case linear
        case exponential
    }

    public init(maxRetry: Int, retryInterval: Double, retryBackoff: RetryPolicy.BackoffType) {
        self.maxRetry = maxRetry
        self.retryInterval = retryInterval
        self.retryBackoff = retryBackoff
    }
}
