# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler/setup'
Bundler.require :default

require 'sugarcube-attributedstring'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'HBFav'
  app.version = "2.0"
  app.short_version = "2"
  app.sdk_version = '6.1'
  app.deployment_target = '6.1'
  app.device_family = [:iphone]
  app.identifier = "HBFav"

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
    pod 'Base64'
    pod 'SVProgressHUD'
    pod 'SSKeychain'
    pod 'JASidePanels'
  end

  app.frameworks += ['ImageIO', 'MapKit', 'Security']
  app.icons = ["default_app_logo.png", "default_app_logo@2x.png"]

  app.entitlements['keychain-access-groups'] = [
    app.seed_id + '.' + app.identifier
  ]

  ## Pixate
  app.pixate.user = 'i.naoya@gmail.com'
  app.pixate.key = 'EQ618-LJDLI-B8GN3-QBBU3-8M0JM-QUITT-NJRFC-U10SL-RL43M-SETVQ-0OA4D-5S24R-6SNQH-02OR8-KNK7T-R6'
  app.pixate.framework = 'vendor/PXEngine.framework'

  ## Reveal
  # app.vendor_project(
  #   'vendor/Reveal.framework',
  #   :static,
  #   :products => %w{Reveal},
  #   :headers_dir => 'Headers'
  # )
end
