unless defined?(Project)
  class Project
    def self.plugin(*args)
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + "/../../../../test/test_helper")
require File.dirname(__FILE__) + '/../init.rb'
require 'test/unit'
require 'rubygems'
gem 'mocha'
require 'mocha'
require 'stubba'