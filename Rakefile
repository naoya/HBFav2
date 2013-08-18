# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler/setup'
Bundler.require :default

require 'sugarcube-attributedstring'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'HBFav'
  app.version = "2.1"
  app.short_version = "2.1"
  app.sdk_version = '6.1'
  app.deployment_target = '6.1'
  app.device_family = [:iphone]
  app.identifier = "HBFav"
  app.prerendered_icon = true

  ## TestFlight
  # % bundle exec rake testflight notes="..."
  app.testflight.sdk = 'vendor/TestFlightSDK2.0.0'
  app.testflight.notify = true
  app.testflight.api_token = "05ca7592a6f65e7ca7bbe2e87dd20571_MjI5Njc"
  app.testflight.team_token = "356d6f74354332874463abf23d7875dc_MjU5MzUzMjAxMy0wOC0xNCAwNDo0ODozMC4yNzA1Njk"

  app.testflight.distribution_lists = ['testers']
  app.development do
    app.provisioning_profile = '/Users/naoya/RubyMotion/HBFav2.mobileprovision'
    app.codesign_certificate='iPhone Developer: Naoya Ito (DCUZR42N2P)'
  end

  app.release do
    app.provisioning_profile = '/Users/naoya/RubyMotion/HBFav_for_production.mobileprovision'
    app.codesign_certificate='iPhone Distribution: Naoya Ito (KC9234ZWM8)'
  end

  app.interface_orientations = [:portrait]

  app.info_plist['CFBundleURLTypes'] = [
    {
      'CFBundleURLName' => 'net.bloghackers.app',
      'CFBundleURLSchemes' => ['hbfav2']
    },
    {
      'CFBundleURLName' => 'com.getpocket.sdk',
      'CFBundleURLSchemes' => ['pocketapp16058']
    }
  ]

  app.pods do
    pod 'SDWebImage'
    pod 'PocketAPI'
    pod 'NSDate+TimeAgo'
    pod 'TUSafariActivity'
    pod 'SVProgressHUD'
    pod 'SSKeychain'
    pod 'JASidePanels'
    pod 'ISBackGesture', :git => 'https://github.com/ishkawa/ISBackGesture.git'
    pod 'BugSense'
    pod 'TTTAttributedLabel'
    pod 'NJKWebViewProgress'
  end

  app.frameworks += ['ImageIO', 'MapKit', 'Security', 'AVFoundation']
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

  ## Reveal
  # app.vendor_project(
  #   'vendor/Reveal.framework',
  #   :static,
  #   :products => %w{Reveal},
  #   :headers_dir => 'Headers'
  # )
end
