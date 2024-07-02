# AnonymousUserMerge Class

## Class Introduction

The `AnonymousUserMerge` class is responsible for merging anonymous user with logged-in one.
It includes methods for merge user by userId and emailId.
We call methods of this class internally to merge user when setUserId or setEmail method call. After merge we sync events through Iterable API.

## Class Structure

The `AnonymousUserMerge` class includes the following key components:

- **Methods:**
    - `mergeUserUsingUserId(apiClient: IterableApiClient, destinationUserId: String)`: Merge user using userID if anonymous user exists and sync events
    - `mergeUserUsingEmail(apiClient: IterableApiClient, destinationEmail: String)`: Merge user using emailId if anonymous user exists and sync events
    - `callMergeApi(apiClient: IterableApiClient, sourceEmail: String, sourceUserId: String, destinationEmail: String, destinationUserId: String)`: Call API to merge user and sync remaining events.

## Methods Description

### `mergeUserUsingUserId(apiClient: IterableApiClient, destinationUserId: String)`

This method merge the anonymous user with the logged-in one. It does the following:

* Check for user exists using userId.
* If user exists then call the merge user API.

### `mergeUserUsingEmail(apiClient: IterableApiClient, destinationEmail: String)`

This method merge the anonymous user with the logged-in one. It does the following:

* Check for user exists using emailId.
* If user exists then call the merge user API.

### `callMergeApi(apiClient: IterableApiClient, sourceEmail: String, sourceUserId: String, destinationEmail: String, destinationUserId: String)`

This method call API to merge user. It does the following:

* Call the Iterable API and sync remaining events.
