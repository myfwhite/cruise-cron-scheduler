unless defined?(Project)
  class Project
    def self.plugin(*args)
    end
  end
end

unless defined?(PollingScheduler)
  class PollingScheduler
    def last_logged_less_than_an_hour_ago
      @last_build_loop_error_time and @last_build_loop_error_time >= 1.hour.ago
    end
    def same_error_as_before(error)
      @last_build_loop_error_source and (error.backtrace.first == @last_build_loop_error_source)
    end
    def log_error(error)
       begin
         CruiseControl::Log.error(error)
       rescue
         STDERR.puts(error.message)
         STDERR.puts(error.backtrace.map { |l| " #{l}"}.join("\n"))
       end
       @last_build_loop_error_source = error.backtrace.first
       @last_build_loop_error_time = Time.now
     end    
  end
  def clean_last_build_loop_error
    @last_build_loop_error_source = @last_build_loop_error_time = nil
  end  
end

unless defined?(Configuration)
  class Configuration
    def self.default_polling_interval
      20.seconds      
    end
  end
end

# require File.expand_path(File.dirname(__FILE__) + "/../../../../test/test_helper")
require File.dirname(__FILE__) + '/../init.rb'
require 'test/unit'
require 'rubygems'
require 'mocha'
require 'activesupport'