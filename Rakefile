# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler/setup'
Bundler.require :default

require 'sugarcube-attributedstring'
require 'bubble-wrap/reactor'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'HBFav'
  app.version = "2.8.2"
  app.short_version = "2.8.2"
  app.sdk_version = '8.1'
  app.deployment_target = '7.0'
  app.device_family = [:iphone, :ipad]
  app.identifier = "HBFav"
  app.prerendered_icon = true
  app.status_bar_style = :light_content
  app.my_env.file = './config/environment.yaml'

  ## Very experimental
  app.archs['iPhoneOS'] << 'arm64'
  app.archs['iPhoneSimulator'] << 'x86_64'

  app.development do
    app.provisioning_profile = '/Users/naoya/Dropbox/HBFav/HBFav_with_Push_Notification.mobileprovision'
    app.codesign_certificate='iPhone Developer: Naoya Ito (DCUZR42N2P)'
    app.entitlements['aps-environment'] = 'development'
  end

  app.release do
    app.provisioning_profile = '/Users/naoya/Dropbox/HBFav/HBFav_with_Push_Notification_for_Production.mobileprovision'
    app.codesign_certificate='iPhone Distribution: Naoya Ito (KC9234ZWM8)'
    app.entitlements['aps-environment'] = 'production'
  end

  app.interface_orientations = [:portrait]

  app.info_plist['NSAppTransportSecurity'] = {
    'NSAllowsArbitraryLoads' => true
  }
  app.info_plist["UILaunchImages"] = [
    # for iPhone 6 Plus
    {
      "UILaunchImageMinimumOSVersion" => "8.0",
      "UILaunchImageName" => "Default-736h@3x",
      "UILaunchImageOrientation" => "Portrait",
      "UILaunchImageSize" => "{414, 736}"
    },
    # for iPhone 6
    {
      "UILaunchImageMinimumOSVersion" => "8.0",
      "UILaunchImageName" => "Default-667h@2x",
      "UILaunchImageOrientation" => "Portrait",
      "UILaunchImageSize" => "{375, 667}"
    },
    # for iPhone 5, iPhone 5s 
    {
      "UILaunchImageMinimumOSVersion" => "6.1",
      "UILaunchImageName" => "Default-568h@2x",
      "UILaunchImageOrientation" => "Portrait",
      "UILaunchImageSize" => "{320, 568}"
    }
  ]
  app.info_plist['CFBundleURLTypes'] = [
    {
      'CFBundleURLName' => 'net.bloghackers.app',
      'CFBundleURLSchemes' => ['hbfav']
    },
    {
      'CFBundleURLName' => 'com.getpocket.sdk',
      'CFBundleURLSchemes' => ['pocketapp16058']
    }
  ]
  app.info_plist['MinimumOSVersion'] = '7.0'
  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = false
  app.info_plist['UIStatusBarStyle'] = "UIStatusBarStyleLightContent"
  app.info_plist['UIBackgroundModes'] = ['fetch', 'remote-notification']

  app.pods do
    pod 'SFHFKeychainUtils'
    pod 'PocketAPI', :git => 'git@github.com:naoya/Pocket-ObjC-SDK.git', :branch => 'cocoapods-dependency'
    pod 'NSDate+TimeAgo'
    pod 'TUSafariActivity'
    pod 'SVProgressHUD'
    pod 'JASidePanels'
    pod 'ISBackGesture', :git => 'https://github.com/ishkawa/ISBackGesture.git'
    pod 'TTTAttributedLabel', :git => 'git@github.com:mattt/TTTAttributedLabel.git'
    pod 'AFNetworking', '~> 1.3'
    pod 'ARChromeActivity'
    pod 'HatenaBookmarkSDK', :git => 'git@github.com:hatena/Hatena-Bookmark-iOS-SDK.git'
    pod 'MPNotificationView'
  end

  app.frameworks += [
    'Accounts',
    'AVFoundation',
    'AudioToolbox',
    'CFNetwork',
    'CoreData',
    'ImageIO',
    'MapKit',
    'MobileCoreServices',
    'QuartzCore',
    'Security',
    'Social',
    'StoreKit',
    'SystemConfiguration',
  ]

  app.weak_frameworks += [
    'MediaAccessibility',
    'WebKit'
  ]

  app.libs += %W(/usr/lib/libz.dylib /usr/lib/libsqlite3.dylib)

  app.icons = ["Icon-60@2x.png", "Icon-60@3x.png"]

  app.entitlements['keychain-access-groups'] = [
    app.seed_id + '.' + app.identifier
  ]

  ## Parse.com
  app.vendor_project(
    'vendor/Bolts.framework',
    :static,
    :products => ['Bolts'],
    :headers_dir => 'Headers'
  )
  app.vendor_project(
    'vendor/Parse.framework',
    :static,
    :products => ['Parse'],
    :headers_dir => 'Headers'
  )
end
