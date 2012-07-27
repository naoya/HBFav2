# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'

require 'rubygems'
require 'bubble-wrap'
require 'bubble-wrap/http'
# require 'bubble-wrap/ui'
# require 'bubble-wrap/reactor'
require 'sugarcube'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'HBFav2'
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
