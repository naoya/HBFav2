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
  app.version = "2.5"
  app.short_version = "2.5"
  app.sdk_version = '7.0'
  app.deployment_target = '6.1'
  app.device_family = [:iphone]
  app.identifier = "HBFav"
  app.prerendered_icon = true
  app.status_bar_style = :light_content

  app.my_env.file = './config/environment.yaml'

  ## TestFlight
  # % bundle exec rake testflight notes="..."
  app.testflight.sdk = 'vendor/TestFlightSDK2.0.0'
  app.testflight.notify = true
  app.testflight.api_token = "05ca7592a6f65e7ca7bbe2e87dd20571_MjI5Njc"
  app.testflight.team_token = "356d6f74354332874463abf23d7875dc_MjU5MzUzMjAxMy0wOC0xNCAwNDo0ODozMC4yNzA1Njk"

  app.testflight.distribution_lists = ['testers']
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

  app.pods do
    pod 'PocketAPI', :git => 'git@github.com:naoya/Pocket-ObjC-SDK.git', :branch => 'cocoapods-dependency'
    pod 'NSDate+TimeAgo'
    pod 'TUSafariActivity'
    pod 'SVProgressHUD'
    pod 'JASidePanels'
    pod 'ISBackGesture', :git => 'https://github.com/ishkawa/ISBackGesture.git'
    pod 'BugSense'
    pod 'TTTAttributedLabel', :git => 'git@github.com:mattt/TTTAttributedLabel.git'
    pod 'NJKWebViewProgress'
    pod 'AFNetworking', '~> 1.3'
    pod 'ARChromeActivity'
    pod 'HatenaBookmarkSDK', :git => 'git@github.com:hatena/Hatena-Bookmark-iOS-SDK.git'
    pod 'iVersion', :git => 'git@github.com:naoya/iVersion.git', :branch => 'fix/japanese'
    pod 'MPNotificationView'
    pod 'GoogleAnalytics-iOS-SDK'

    ## Parse.com SDK が依存してるけど本来必要ない。現状、解決されてない様子
    pod 'Facebook-iOS-SDK'
  end

  app.frameworks += ['ImageIO', 'MapKit', 'Security', 'AVFoundation']
  app.frameworks += %w(AudioToolbox CFNetwork MobileCoreServices QuartzCore StoreKit SystemConfiguration)
  app.weak_frameworks += ['MediaAccessibility']
  app.libs += %W(/usr/lib/libz.dylib /usr/lib/libsqlite3.dylib)

  app.icons = ["default_app_logo.png", "default_app_logo@2x.png"]

  app.entitlements['keychain-access-groups'] = [
    app.seed_id + '.' + app.identifier
  ]

  ## BugSense
  app.vendor_project(
    'vendor/Pods/BugSense/BugSense-iOS.framework',
    :static,
    :products => %w{BugSense-iOS},
    :headers_dir => 'Headers'
  )

  ## ChromeProgressBar
  app.vendor_project(
    'vendor/ChromeProgressBar',
    :static
  )

  ## Parse.com
  app.vendor_project(
    'vendor/Parse 3.framework',
    :static,
    :products => ['Parse'],
    :headers_dir => 'Headers'
  )

  ## Reveal
  # app.vendor_project(
  #   'vendor/Reveal.framework',
  #   :static,
  #   :products => %w{Reveal},
  #   :headers_dir => 'Headers'
  # )
end
