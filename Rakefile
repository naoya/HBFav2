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

  app.pods do
    pod 'SDWebImage'
  end

  app.frameworks += ['ImageIO', 'MapKit']

  ## Keychain
  # app.frameworks += ['Security']
  # app.vendor_project('vendor/GenericKeychain', :xcode,
  #   :headers_dir => 'GenericKeychain')
  # app.entitlements['keychain-access-groups'] = [
  #   app.seed_id + '.' + app.identifier
  # ]

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
