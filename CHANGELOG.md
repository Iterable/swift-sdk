# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [6.5.4]
### Fixed
- SDK is now compatible with Xcode 16 beta 2

## [6.5.3]
### Changed
- Deprecated support for iOS 10 and iOS 11.

## [6.5.2]
### Fixed
- The Privacy Manifest has been relocated to the resources folder within the SDK. This adjustment facilitates the inclusion of the SDK's privacy manifest in the generation process.
- Resolved a bug where a scheduled authentication token refresh would occur even if the user had logged out in the interim.

### Changed
- Improved the Out Of The Box (OOTB) Embedded CardView image content view by setting it to aspect fill. This change ensures a consistent appearance across web, iOS, and Android platforms.

## [6.5.1]

### Added

- iOS SDK now includes a new privacy policy file indicating SDK's usage of user data

### Fixed

- Fixed an issue where AuthManager's onTokenRequested would get called without user logged in
- Updates logic for notificationsEnabled flag to be more inclusive in case of failures for fetching the current settings 

## [6.5.0]

### Added

- Introduces support for embedded messaging: an eligibility–based, personalized messages sent from Iterable to your mobile and web apps, which can display them inline, using native interface components
- To display embedded messages, you can use customizable, out-of-the-box components provided by the SDK (cards, notifications, banners), or you can build fully custom components of your own design.
- To learn more, read [Embedded Messages with Iterable's iOS SDK](https://support.iterable.com/hc/articles/23061840746900).

### Changed

- `IterableConfig` is updated with an `enableEmbeddedMessaging` flag that needs to be set to true to allow use of embedded messaging functionality

## [6.4.17]

### Fixed

- Resolved push open tracking issue when the app is running in the background.

## [6.4.16]

### Added

- `sendRequestWithRetries` function added as part of the `NetworkHelperclass`
- For an API request that results in a 500-level error response, the SDK now executes up to five retries. Before each of the final three attempts, there is a two-second delay.

### Changed

- updates `sendRequest` in `RequestProcessorUtil` to retry the API request that resulted in a 401 response upon receipt of a new JWT
- updates `NetworkHelper` class logic to use `sendRequestWithRetries`method which wraps the original `networkSession.makeRequest`
- When an API request fails with a 401 because of an invalid JWT token, the SDK now immediately requests a new JWT token for the signed-in user.

## [6.4.15]

### Added

- This release allows you to use projects hosted on Iterable's EU data center. If your project is hosted on Iterable's [European data center (EUDC)](https://support.iterable.com/hc/articles/17572750887444), configure the SDK to use Iterable's EU-based API endpoints:

_Swift_

```swift
let config = IterableConfig()
config.dataRegion = IterableDataRegion.EU
IterableAPI.initialize(apiKey: "<YOUR_API_KEY>", launchOptions: launchOptions, config: config)
```

_Objective-C_

```objectivec
IterableConfig *config = [[IterableConfig alloc] init];
config.dataRegion = IterableDataRegion.EU;
[IterableAPI initializeWithApiKey:@"<YOUR_API_KEY>" launchOptions:launchOptions config:config];
```

### Fixed

- Offline Mode is now off by default. Offline mode components will only load when the `offlineMode` configuration for RequestHandler is set to true.

### Changed

- Offline mode configuration now persists throughout the current app session. Changes will take effect from the next app session.

## [6.4.14]

### Added

- Success and Failure handlers can now be passed to following functions:
  `InAppManager.remove`, `InAppManager.setRead`, `IterableAPI.setEmail` and `IterableAPI.setUserId`

## [6.4.13]

### Added

- `ITBNotificationServiceExtension` has a new optional delegate in the scenario of wanting to receive and pass along push information (e.g. Firebase)

### Changed

- The behavior of `lastPushPayload` now matches that of the Android SDK in being purely in memory and will now not count the payload of a silent push

### Fixed

- The `itbl_inapp.json` file generated from in-app messaging has been relocated to the correct spot

## [6.4.12]

### Added

- Added a new function to `IterableAPI` to get the currently set authentication token
- Added a new function (`onTokenRegistrationFailed`) to the `IterableAuthDelegate` upon authentication token retrieval failure

### Changed

- Changed `setEmail` and `setUserId` to run through the login process if also sent in an authentication token (and a non-`nil` ID)

### Fixed

- Fixed instances where setting a new authentication token for a user failed

## [6.4.11]

### Fixed

- Fixed so that `AuthManager` clears the previous refresh timer before setting a new one (thanks, @cranberyxl!)

## [6.4.10]

### Fixed

- Fixed instances where `config.inAppDisplayInterval` would not set custom interval set via react native layer.

### [6.4.9]

### Added

[Version version 6.4.9](https://github.com/Iterable/swift-sdk/releases/tag/6.4.9) of Iterable's iOS SDK makes it possible to store in-app messages in memory, rather than in an unencrypted local file. However, an unencrypted local file is still the default option.

To store in-app messages in memory, set `useInMemoryStorageForInApps` to true:

_Swift_

```swift
let config = IterableConfig()
config.useInMemoryStorageForInApps = true
IterableAPI.initialize(apiKey: "<YOUR_API_KEY>", launchOptions: launchOptions, config: config)
```

_Objective-C_

```objectivec
IterableConfig *config = [[IterableConfig alloc] init];
config.useInMemoryStorageForInApps = YES;
[IterableAPI initializeWithApiKey:@"<YOUR_API_KEY>" launchOptions:launchOptions config:config];
```

When users upgrade to a version of your iOS app that uses this version of the SDK (or higher), and you've enabled this option, the local file used for in-app message storage (if it already exists) is deleted. However, no data is lost.

### [6.4.8]

### Changed

Starting with this release, as a privacy enhancement, Iterable’s iOS SDK
encrypts the following data when storing it at rest:

- `email` — The user's email address.
- `userId` — The user's ID.
- `authToken` — The JWT used to authenticate the user with Iterable's API.
- `lastPushPayload` — The JSON payload that came along with the last push
  notification received by the app.

(Note that Iterable's iOS SDK does not store in-app messages at rest—before or
after this update.)

When a user upgrades to a version of your app that uses this version of the SDK
(or higher), the fields shown above are encrypted. No data that's already stored
is lost.

For more information about the encryption described above, examine the SDK
source code:

- [`IterableKeychain`](https://github.com/Iterable/swift-sdk/blob/master/swift-sdk/Internal/IterableKeychain.swift)
- [`KeychainWrapper`](https://github.com/Iterable/swift-sdk/blob/master/swift-sdk/Internal/KeychainWrapper.swift)

## [6.4.7]

### Added

- Added `setEmail` and `setUserId` as publicly accessible functions, which will set the identity of the SDK to attribute to events. The optional second parameter will take in a JWT if you already have one at the time of this call (as opposed to through `IterableAuthDelegate`).

## [6.4.6]

### Fixed

- Added Objective-C access to `IterableInboxViewController` and `IterableInboxNavigationViewController`

## [6.4.5]

### Added

- This release makes offline events processing available to all Iterable customers who'd like to use it — just ask your customer success manager to enable it for your account. Offline events processing saves a local copy of events triggered in your app while the device is offline (up to 1000 events). When a connection is re-established and your app is in the foreground, the events will be sent to Iterable. For more information, read [Offline events processing](https://support.iterable.com/hc/articles/360035395671#offline-events-processing).

## [6.4.4]

### Fixed

- Core data issues.

## [6.4.3]

### Added

- Retry request on JWT token obtained.

### Fixed

- Core data multithreading issue.
- Update email with JWT token.

## [6.4.2]

### Added

- Added support for apps built using Mac Catalyst.
  ​

### Fixed

- Fixed a couple of problems related to Swift Package Manager and the creation of release builds and simulator artifacts.
- Fixed a problem with the SDK’s Carthage integration.
- Fixed a problem that prevented the SDK from properly tracking inbox sessions when a mobile inbox is displayed in `popup` mode.
- In-app delete events are now correctly associated with inbox session IDs.
- Fixed some problems in a script that generates XCFramework binaries.

## [6.4.1]

### Fixed

- Fix archiving issue. There was an issue when archiving for projects with deployment target set to iOS 10. This release fixes the issue.

## [6.4.0]

### Fixed

- Prevents in-app messages from executing JavaScript code included in their HTML templates.

### Changed

- Removed support for iOS 9.

### Added

- Added the `allowedProtocols` field on the `IterableConfig` class.
  - Use this array to declare the specific URL protocols that the SDK can expect to see on incoming links (and that it should therefore handle). This will help prevent the app from opening unexpected links that use arbitrary URLprotocols.
  - Iterable&#39;s iOS SDK will always handle `https` links (in push notifications, in-app messages, etc.), regardless of the contents of this array. However, you must explicitly specify any non-`https` URL protocols you&#39;d _also_ like the SDK to handle.
  - If you don&#39;t set up this array, your app will only handle `https` links. If it receives other kinds of links (for example, using `http` or custom URL protocols), it won&#39;t open them (as deep links or in the browser).
  - For example, to allow the SDK to handle `http://`, `tel://`, and `custom://` links, set the `allowedProtocols` field, on the `IterableConfig` object you pass to the SDK&#39;s `initialize` method, to `["http", "tel", "config"]`.

## [6.3.4]

#### Fixed

- When syncing in-app queues, new messages that already have `read` set to `true` will not spawn an `InAppDelivery` event
- Fixed the alignment of the no messages title on the inbox empty state

#### Changed

- Wrapped various app extension unsafe classes for Xcode 13 compatibility

#### Added

- Added ability to not show the unread count badge

## [6.3.3]

#### Changed

- CocoaPods targets adding this SDK do not require `use_frameworks!` anymore

#### Fixed

- Inline comments will not show anymore warnings in Objective-C projects

## [6.3.2]

#### Added

- `updateCart` has been added to the SDK
- `dataFields` have been added as a field to `CommerceItem`

#### Removed

- The following calls that were previously marked as deprecated have been removed:
  - `IterableAPI.track(inAppOpen messageId: String)`
  - `IterableAPI.track(inAppClick messageId: String, buttonURL: String)`
  - `IterableAPI.inAppConsume(messageId: String)`
  - `IterableAPI.getAndTrack(deeplink webpageURL: URL, callbackBlock: @escaping ITEActionBlock)`
  - `IterableAPI.showSystemNotification(withTitle title: String, body: String, button: String?, callbackBlock: ITEActionBlock?)`
  - `IterableAPI.showSystemNotification(withTitle title: String, body: String, buttonLeft: String?, buttonRight: String?, callbackBlock: ITEActionBlock?)`

## [6.3.1]

#### Added

- The following properties have been added to the `CommerceItem` class:

  - `sku` - The item's SKU
  - `itemDescription` - A description of the item
  - `url` - A URL associated with the item
  - `imageUrl` - A URL that points to an image of the item
  - `categories` - Categories associated with the item

  Set these values on `CommerceItem` objects passed to the `IterableAPI.trackPurchase` method.

#### Fixed

- The notification service extension has been re-architected for better reliability

## [6.3.0]

#### Added

- **Offline events processing** - This feature saves a local copy of events triggered in your app while the device is offline (up to 1000 events). When a connection is re-established and your app is in the foreground, the events will be sent to Iterable.
  This feature is off by default, and we're rolling it out on a customer-by-customer basis. After you start using this version of the SDK, we'll send you a message before we enable the feature on your account (unfortunately, we can't give you an exact timeline for when this will happen). If you have any questions, talk to your Iterable customer success manager.

## [6.3.0-beta4]

#### Changed

- This beta is rebuilt from version 6.2.22

#### Added

- A health monitor now checks to make sure offline events don't get written when there are already a maximum amount of events in the database, or if an error is returned from the database

## [6.2.22]

#### Added

- In-app message prioritization - Ordering the display of in-app messages based on a priority you select in Iterable when creating in-app campaigns

#### Fixed

- The authentication flow, with JWT, now does the proper order of operations to avoid a false negative when setting the user (with `setEmail` or `setUser`)
- The empty inbox message will now properly wraparound
- An inbox message that has its read state changed will now only animate the unread dot

#### Removed

- Removed deferred deep linking related code as a cautionary measure for iOS 14.5 policy updates - note: we still keep the system generated UUID
- Removed deferred deep linking feature

## [6.3.0-beta3]

#### Changed

- This beta is rebuilt from version 6.2.21

## [6.2.21]

#### Added

- Support for syncing in-app message read state across multiple devices:
  - When the SDK fetches in-app messages from Iterable, it examines each
    message's `read` field to determine if it has already been read.
  - The SDK's default implementation no longer automatically displays in-app
    messages that have already been seen on another device (even if those
    messages were _not_ configured to go directly to the inbox).
  - When you view a message, the SDK calls [`POST /api/events/trackInAppOpen`](https://api.iterable.com/api/docs#events_trackInAppOpen)
    to create an `inAppOpen` event on the user's Iterable profile. Previous
    versions of the SDK made this same API call, but the call now also causes
    Iterable to set the message's `read` field to `true`.
  - Previous versions of the SDK will correctly sync a message's read / unread
    indicator for the default implementation of a mobile inbox. However, these
    older SDK versions will not automatically suppress messages that have
    already been seen on another device (as this version of the SDK will).
- Support for the display of a custom message (title and body) in an empty
  mobile inbox. For more details, see [Customizing Mobile Inbox on iOS](https://support.iterable.com/hc/articles/360039091471#empty-state)

## [6.3.0-beta2]

#### Added

- Added callback for initialize method that is used by our React Native SDK.

#### Fixed

- Fixed how we look up `Resources` folder for Cocoapods.

## [6.2.20]

#### Added

- Added callback to initialize method needed for React Native. This change should have no effect for iOS SDK.

## [6.3.0-beta1]

#### Added

- This beta SDK release includes support for two new Iterable features (both of which are in beta):
  - Offline events processing - Capturing engagement events when a device is offline and sending them to Iterable when a network connection is reestablished
  - In-app message prioritization - Ordering the display of in-app messages based on a priority you select in Iterable when creating in-app campaigns

If you'd like to try out these beta features, talk with your Iterable customer success manager.

## [6.2.19]

#### Added

- When using the inbox feature in popup mode, the method of modal transition can now be specified through `popupModalPresentationStyle`

## [6.2.18]

#### Fixed

- Users who were already set to the SDK will now always request a JWT (if enabled) whenever a user is set to the SDK

## [6.2.17]

#### Fixed

- Added a call to get in-app messages after a JWT retrieval when setting the user to the Iterable SDK instance
- Fixed passing along deep links from the React Native SDK initialization

## [6.2.16]

#### Fixed

- SDK initialization fix for React Native. Push notifications and deep links were not working for React Native when app is not in memory.

## [6.2.15]

#### Fixed

- Removed specific plist files from the SPM targets to stop unnecessary warnings

## [6.2.14]

#### Added

- Added in-app animations

#### Fixed

- Fixed non-inbox in-apps showing up in the inbox if multiple were about to be shown

## [6.2.13]

#### Fixed

- Made `IterablePushNotificationMetadata` struct public.
- Optimized auth token refresh.
- Use `systemBackground` color for iOS 14.

## [6.2.12]

#### Added

- Added authentication support

## [6.2.12-beta1]

#### Added

- Added authentication support

## [6.2.11]

#### Added

- Xcode 12 and iOS 14 support.

#### Fixed

- Fixed minor warnings.

## [6.2.10]

#### Added

- An option to pause automatic in-app displaying has been added. To pause, set `IterableAPI.inAppManager.isAutoDisplayPaused` to `true` (default: `false`).

## [6.2.9]

#### Fixed

- In rare instances `regiserDeviceToken` API can cause crash. This should fix it.

## [6.2.8]

#### Added

- In-app messages now get "pre-loaded" with a timer (or until the in-app loads) to mitigate seeing the loading of the message

#### Fixed

- The JSON payload is now checked to be a valid JSON object before serialization
- Some classes that were intended for internal framework usage only have been assigned proper permission levels (thanks, made2k!)
- The root view controller is now correctly found on projects that are newly created in iOS 13
- `nil` is properly returned when deep linking encounters an error

## [6.2.7]

#### Added

- Added internal `deviceAttributes` field for compatibility

## [6.2.6]

#### Notes

- This SDK release is based off of 6.2.4, as 6.2.5 had some framework specific code that we don't believe has any user impact, but out of caution, is omitted from this release, and has the noted fixes below.

#### Fixed

- Action buttons now show properly when a mediaURL isn't specified
- The `trackEvent` event is now named accordingly
- Fixed the `campaignId` data type within our SDK (thanks, nkotula!)

## [6.2.5]

#### Fixed

- Fixed the `campaignId` data type within our SDK (thanks, nkotula!)

## [6.2.4]

#### Fixed

- Properly attribute the source of in app closes

## [6.2.3]

#### Added

- `IterableInAppManagerProtocol` has been given `getMessage(withId id: String)` (Objective-C: `@objc(getMessageWithId:)`)

#### Fixed

- For Objective-C apps, `IterableLogDelegate.log` has had a typo fixed; the new signature is `@objc(log:message:)`
- For Objective-C apps, `IterableAPI.updateSubscriptions` has had a typo fixed; the new signature is `@objc(updateSubscriptions:unsubscribedChannelIds:unsubscribedMessageTypeIds:subscribedMessageTypeIds:campaignId:templateId:)`

## [6.2.2]

#### Fixed

- Moved podspec `resources` to `resource_bundles` to avoid name collisions for static libraries (thanks, iletch!)
- Give `LogLevel` an Objective-C specific name (`IterableLogLevel`) (thanks, osawhoop!)

## [6.2.1]

#### Fixed

- Made class extensions internal rather than public to avoid collisions (thanks, RolandasRazma!)

## [6.2.0]

#### Added

- Moved Mobile Inbox support to GA (no longer in beta), and:
  - Added support for various ways to customize the default interface for a mobile inbox
  - Added a sample project that demonstrates how to customize the default interface for a mobile inbox
  - Added tracking for inbox sessions (when the inbox is visible in the app) and inbox message impressions (when a individual message's item is visible in the mobile inbox message list)
- Added support for Swift Package Manager

#### Deprecated

Please see each method's source code documentation for details.

- `IterableAPI.track(inAppOpen messageId: String)`
- `IterableAPI.track(inAppClick messageId: String, buttonURL: String)`

## [6.1.5]

#### Fixed

- Fixed in-apps where display types that were not `fullScreen` were not displaying properly or becoming unresponsive.

## [6.1.4]

#### Fixed

- Fixed the function signature of the `updateSubscriptions` call (thanks, Conor!)
- Fixed `NoneLogDelegate` not being usable for `IterableConfig.logDelegate` (thanks, katebertelsen!)

## [6.1.3]

#### Changed

- Converted a log message variable to be interpreted as an UTF8 String (thanks, chunkyguy!)
- Enabled `BUILD_LIBRARY_FOR_DISTRIBUTION` for better compatibility across development environments

## [6.2.0-beta1]

#### Added

- [Mobile Inbox](https://github.com/Iterable/swift-sdk/#mobile-inbox)
- [Mobile Inbox related events](https://github.com/Iterable/swift-sdk/#mobile-inbox-events-and-the-events-lifecycle)

#### Removed

- `IterableAPI.spawnInAppNotification(_:)`
  - In-app messages are automatically shown by SDK now. Please check our [migration guide](https://github.com/iterable/swift-sdk/#migrating-in-app-messages-from-the-previous-version-of-the-sdk).
- `IterableAPI.get(inAppMessages:)`
  - Use `IterableAPI.inAppManager.getMessages()` instead

#### Changed

- There is no need to set `IterableConfig.pushIntegrationName` for new projects.

#### Deprecated

Please see method documentation for details about how to replace them.

- `IterableAPI.inAppConsume(messageId:)`
- `IterableAPI.showSystemNotification(..)`
- `IterableAPI.getAndTrack(deeplink:callbackBlock:)`

## [6.1.2]

#### Fixed

- Fixed a bug in token to hex conversion code.

## [6.1.1]

#### Changed

- Use `WKWebView` instead of deprecated class `UIWebView`.
- Migrated all Objective-C code to Swift.

## [6.2.0-dev1]

#### Added

- Inbox
  - Brand new inbox functionality. Please see documentation for more details.

## [6.1.0]

#### Changed

- In this version we have changed the way we use in-app notifications. In-app messages are now being sent asynchronously and your code can control the order and time in which an in-app notification will be shown. There is no need to poll for new in-app messages. Please refer to the **in-app messages** section of README file for how to use in-app messages. If you are already using in-app messages, please refer to [migration guide](https://github.com/iterable/swift-sdk#migrating-from-a-version-prior-to-610) section of README file.

## [6.1.0-beta4]

#### Changed

- Url scheme `iterable://` is reserved for Iterable internal actions. In an earlier beta version, the reserved url scheme was `itbl://` but we are not using that now. `itbl://` scheme is only there for backward compatibility and should not be used.
- Url scheme `action://` is for user custom actions.

## [6.1.0-beta3]

#### Changed

- Increase number of in-app messages fetched from the server to 100.

## [6.1.0-beta2]

#### Added

- Support for `action://your-custom-action-name` URL scheme for calling custom actions
  - For example, to have `IterableCustomActionDelegate` call a custom `buyCoffee` action when a user taps on an in-app message's **Buy** button.
- Support for reserved `itbl://sdk-custom-action` scheme for SDK internal actions.
  - URL scheme `itbl://sdk-custom-action` is reserved for internal SDK actions. Do not use it for custom actions.
  - For example, future versions of the SDK may allow buttons to call href `itbl://delete` to delete an in-app message.

#### Fixed

- Carthage support with Xcode 10.2
- Xcode 10.2 Warnings
- URL Query parameters encoding bug

## [6.1.0-beta1]

#### Added

- We have improved the in-app messaging implementation significantly.
  - The SDK now maintains a local queue and keep it in sync with the server-side queue automatically.
  - Iterable servers now notify apps via silent push messages whenever the in-app message queue is updated.
  - In-app messages are shown by default whenever they arrive.
- It should be straightforward to migrate to the new implementation. There are, however, some breaking changes. Please see [migration guide](https://github.com/iterable/swift-sdk#Migrating-in-app-messages-from-the-previous-version-of-the-SDK) for more details.

#### Removed

- `spawnInAppNotification` call is removed. Please refer to migration guide mentioned above.

#### Changed

- You can now use `updateEmail` if the user is identified with either `email` or `userId`. Earlier you could only call `updateEmail` if the user was identified by `email`.
- The SDK now sets `notificationsEnabled` flag on the device to indicate whether notifications are enabled for your app.

#### Fixed

- nothing yet

## [6.0.8](https://github.com/Iterable/swift-sdk/releases/tag/6.0.8)

#### Fixed

- Carthage support with Xcode 10.2

## [6.0.4](https://github.com/Iterable/swift-sdk/releases/tag/6.0.4)

#### Added

- More refactoring and tests.

#### Changed

- Now we do not call createUserForUserId when registering device. This is handled on the server side.

#### Fixed

- `destinationUrl` was not being returned correctly from the SDK when using custom schemes for inApp messages.

## [6.0.3](https://github.com/Iterable/swift-sdk/releases/tag/6.0.3)

#### Added

- Call createUserForUserId when registering a device with userId
- Refactoring and tests.

## [6.0.2](https://github.com/Iterable/swift-sdk/releases/tag/6.0.2)

#### Added

- You can now set `logHandler` in IterableConfig.
- Now you don't have to call `IterableAPI.registerToken` on login/logout.

#### Fixed

- Don't show in-app message if one is already showing.

## [6.0.1](https://github.com/Iterable/swift-sdk/releases/tag/6.0.1)

#### Fixed

- Fixed issue that affects clients who are upgrading from Objective C Iterable SDK to Swift SDK. If you have attribution info stored in the previous Objective C SDK, it was not being deserialized in Swift SDK.
