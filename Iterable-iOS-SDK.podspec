Pod::Spec.new do |s|
  s.name         = "Iterable-iOS-SDK"
  s.module_name  = "IterableSDK"
  s.version      = "6.5.4"
  s.summary      = "Iterable's official SDK for iOS"

  s.description  = <<-DESC
                   Iterable's iOS SDK integrating utility and the Iterable API
                   DESC

  s.homepage     = "https://github.com/Iterable/swift-sdk.git"
  s.license      = "MIT"
  s.author       = { "Jay Kim" => "jay.kim@iterable.com" }

  s.platform     = :ios, "12.0"
  s.source       = { :git => "https://github.com/Iterable/swift-sdk.git", :tag => s.version }
  s.source_files = "swift-sdk/**/*.{h,m,swift}"
  s.exclude_files = "swift-sdk/swiftui/**"

  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '5.3'
  }

  s.swift_version = '5.3'

  s.resource_bundles = {'Resources' => 'swift-sdk/Resources/**/*.{storyboard,xib,xcassets,xcdatamodeld}' }

  s.header_dir = 'IterableSDK'
end
