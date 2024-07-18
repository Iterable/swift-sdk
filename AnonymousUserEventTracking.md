# AnonymousUserManager Class

## Class Introduction

The `AnonymousUserManager` class is responsible for managing anonymous user sessions and tracking events.
The `AnonymousUserManager+Functions` class is contains util functions and `CriteriaCompletionChecker` struct which contains criteria checking logic.
It includes methods for updating sessions, tracking events (i.e custom event, update cart, update user and purchase) and create a user if criterias are met.
We call track methods of this class internally to make sure we have tracked the events even when user is NOT logged in and after certain criterias are met we create a user and logs them automatically and sync events through Iterable API.

## Class Structure

The `AnonymousUserManager` class includes the following key components:

- **Methods:**
    - `updateAnonSession()`: Updates the anonymous user session.
    - `trackAnonEvent(name: String, dataFields: [AnyHashable: Any]?)`: Tracks an anonymous event and store it locally.
    - `trackAnonPurchaseEvent(total: NSNumber, items: [CommerceItem], dataFields: [AnyHashable: Any]?)`: Tracks an anonymous purchase event and store it locally.
    - `trackAnonUpdateUser(_ dataFields: [AnyHashable: Any])`: Tracks an anonymous update user event and store it locally.
    - `trackAnonUpdateCart(items: [CommerceItem])`: Tracks an anonymous cart event and store it locally.
    - `trackAnonTokenRegistration(token: String)`: Tracks an anonymous token registration event and store it locally.
    - `getAnonCriteria()`: Gets the anonymous criteria.
    - `checkCriteriaCompletion()`: Checks if criterias are being met.
    - `createKnownUser()`: Creates a user after criterias met and login the user and then sync the data through track APIs.
    - `syncEvents()`: Syncs locally saved data through track APIs.
    - `updateAnonSession()`: Stores an anonymous sessions locally. Update the last session time when new session is created.
    - `storeEventData()`: Stores event data locally.
    - `logout()`: Reset the locally saved data when user logs out to make sure no old data is left.
    - `syncNonSyncedEvents()`: Syncs unsynced data which might have failed to sync when calling syncEvents for the first time after criterias met.
    - `convertCommerceItems(from dictionaries: [[AnyHashable: Any]]) -> [CommerceItem]`: Convert to commerce items from dictionaries.
    - `convertCommerceItemsToDictionary(_ items: [CommerceItem]) -> [[AnyHashable:Any]]`: Convert commerce items to dictionaries.
    - `getUTCDateTime()`: Converts UTC Datetime from current time.


## Methods Description

### `updateAnonSession()`

This method updates the anonymous user session. It does the following:

* Retrieves the previous session data from local storage.
* Increments the session number.
* Stores the updated session data back to local storage.

### `trackAnonEvent(name: String, dataFields: [AnyHashable: Any]?)`

This method tracks an anonymous event. It does the following:

* Creates a dictionary object with event details, including the event name, timestamp, data fields, and tracking type.
* Stores the event data in local storage.
* Checks criteria completion and creates a known user if criteria are met.

### `trackAnonPurchaseEvent(total: NSNumber, items: [CommerceItem], dataFields: [AnyHashable: Any]?)`

This method tracks an anonymous purchase event. It does the following:

* Converts the list of commerce items to JSON.
* Creates a dictionary object with purchase event details, including items, total, timestamp, data fields, and tracking type.
* Stores the purchase event data in local storage.
* Checks criteria completion and creates a known user if criteria are met.

### `trackAnonUpdateUser(dataFields: [AnyHashable: Any]?)`

This method tracks an anonymous update user event. It does the following:

* Creates a dictionary object with event details, including the event name, timestamp, data fields, and tracking type.
* Stores the event data in local storage, and if data of this event already exists it replaces the data.
* Checks criteria completion and creates a known user if criteria are met.

### `trackAnonUpdateCart(items: [CommerceItem])`

This method tracks an anonymous cart update. It does the following:

* Converts the list of commerce items to dictionary.
* Creates a dictionary object with cart update details, including items, timestamp, and tracking type.
* Stores the cart update data in local storage.
* Checks criteria completion and creates a known user if criteria are met.

### `trackAnonTokenRegistration(token: String)`

This method tracks an anonymous token registration event and stores it locally.
  
### `getAnonCriteria()`

This method is responsible for fetching criteria data. It simulates calling an API and saving data in local storage.

### `checkCriteriaCompletion()`

This private method checks if criteria for creating a known user are met. It compares stored event data with predefined criteria and returns `criteriaId` if any of the criteria is matched.

### `createKnownUser()`

This  method is responsible for creating a known user in the Iterable API. It does the following:

* Sets a random user ID using a UUID (Universally Unique Identifier).
* Retrieves user session data from local storage.
* If user session data exists, it updates the user information in the Iterable API.
* Calls the syncEvents() method to synchronize anonymous tracked events.
* Finally, it clears locally stored data after data is syncronized.

### `syncEvents()`

This method is used to synchronize anonymous tracked events stored in local storage with the Iterable API. It performs the following tasks:

* Retrieves the list of tracked events from local storage.
* Iterates through the list of events and processes each event based on its type.
* Supported event types include regular event tracking, purchase event tracking, and cart update tracking.
* For each event, it extracts relevant data, including event name, data fields, items (for purchase and cart update events), and timestamps.
* It then calls the Iterable API to sync these events.
* After processing all the events, it clears locally stored event data.

### `updateAnonSession()`

This method is responsible for storing/updating anonymous sessions locally. It updates the last session time each time when new session is created.
