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
  app.version = "2.7.4"
  app.short_version = "2.7.4"
  app.sdk_version = '8.1'
  app.deployment_target = '6.1'
  app.device_family = [:iphone]
  app.identifier = "HBFav"
  app.prerendered_icon = true
  app.status_bar_style = :light_content
  app.my_env.file = './config/environment.yaml'

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
    'AVFoundation',
    'AudioToolbox',
    'CFNetwork',
    'CoreData',
    'ImageIO',
    'MapKit',
    'MobileCoreServices',
    'QuartzCore',
    'Security',
    'StoreKit',
    'SystemConfiguration',
  ]

  app.weak_frameworks += ['MediaAccessibility']
  app.libs += %W(/usr/lib/libz.dylib /usr/lib/libsqlite3.dylib)

  app.icons = ["default_app_logo.png", "default_app_logo@2x.png"]

  app.entitlements['keychain-access-groups'] = [
    app.seed_id + '.' + app.identifier
  ]

  ## Parse.com
  app.vendor_project(
    'vendor/Parse 3.framework',
    :static,
    :products => ['Parse'],
    :headers_dir => 'Headers'
  )

  ## ParseDummy
  # http://stackoverflow.com/questions/15457136/parse-for-ios-errors-when-trying-to-run-the-app/18626232#18626232
  app.vendor_project(
    'vendor/ParseDummy',
    :static
  )
end
