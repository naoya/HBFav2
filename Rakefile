# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler/setup'
Bundler.require :default

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'HBFav2'
  app.identifier = "org.bloghackers.net.HBFav2"
  app.provisioning_profile = '/Users/naoya/RubyMotion/HBFav2.mobileprovision'
  app.codesign_certificate='iPhone Developer: Naoya Ito (DCUZR42N2P)'

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
  end

  app.frameworks += ['ImageIO', 'MapKit', 'Security']

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

desc "Checks the syntax"
task :syntax do
  Motion::Project::App.setup do |app|
    app.files.each do |file|
      result = `macruby -c #{file}`.chomp
      raise "Syntax Error: #{file}" unless result == "Syntax OK"
    end
  end
end
