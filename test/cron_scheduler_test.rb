require 'date'
require File.dirname(__FILE__) + '/test_helper'

class CronSchedulerTest < Test::Unit::TestCase

  def setup
    @mock_project = Object.new
    @scheduler = CronScheduler.new(@mock_project)
    @scheduler.cron=("1 1 * * *")
  end

  def test_polling_interval_default_value_and_overriding
    assert_equal Configuration.default_polling_interval, @scheduler.polling_interval
    @scheduler.polling_interval = 1.minute
    assert_equal 60, @scheduler.polling_interval
  end

  def test_polling_interval_limits
    assert_nothing_raised { @scheduler.polling_interval = 5.seconds }
    assert_raises(RuntimeError, "Polling interval of 4 seconds is too small (min. 5 seconds)") do
      @scheduler.polling_interval = 4.seconds
    end
    assert_nothing_raised { @scheduler.polling_interval = 60.seconds }
    assert_raises(RuntimeError, "Polling interval of 61 seconds is too big (max. 60 seconds)") do
      @scheduler.polling_interval = 61.seconds
    end
  end

  def test_last_logged_less_than_an_hour_ago
    assert !@scheduler.last_logged_less_than_an_hour_ago
  
    @scheduler.instance_eval("@last_build_loop_error_time = DateTime.new(2005, 1, 1)")

    time = DateTime.new(2005, 1, 1)

    Time.stubs(:now).returns(time + 1.hour)
    assert @scheduler.last_logged_less_than_an_hour_ago
    
    Time.stubs(:now).returns(time + 1.hour + 1.second)
    assert !@scheduler.last_logged_less_than_an_hour_ago
  end
  
  def test_check_build_request_until_next_polling
    @scheduler.stubs(:build_request_checking_interval).returns(0)
    Time.expects(:now).times(3).returns(Time.at(1.hour.to_i+0).utc, Time.at(1.hour.to_i+30).utc, Time.at(1.hour.to_i+60).utc)
    @mock_project.expects(:build_if_requested).times(2)

    @scheduler.check_build_request_until_next_polling
  end
  
  def test_check_build_request_until_current_ends
    @scheduler.stubs(:build_request_checking_interval).returns(0)
    Time.expects(:now).times(3).returns(Time.at(1.hour.to_i+60).utc, Time.at(1.hour.to_i+90).utc, Time.at(1.hour.to_i+120).utc)
    # @mock_project.expects(:build_if_requested).times(2)

    @scheduler.check_build_request_until_current_ends
  end
  
  def test_check_build_request_build_requested
    @scheduler.stubs(:build_request_checking_interval).returns(0)
    Time.expects(:now).times(3).returns(Time.at(1.hour.to_i+0).utc, Time.at(1.hour.to_i+30).utc, Time.at(1.hour.to_i+60).utc, Time.at(1.hour.to_i+61).utc)
    @mock_project.expects(:build_if_requested).times(2).returns(false, true)

    @scheduler.check_build_request_until_next_polling
  end

  def test_should_return_flag_to_reload_project_if_configurations_modified
    @scheduler.expects(:check_build_request_until_next_polling).returns(false)
    @mock_project.expects(:request_build).returns(true)
    # @mock_project.expects(:build_if_requested).times(1).returns(false, true)
    assert_throws(:reload_project) { @scheduler.run }
  end
  
  def test_time_to_go
    Time.expects(:now).times(4).returns(Time.at(1.hour.to_i+0).utc, Time.at(1.hour.to_i+30).utc, Time.at(1.hour.to_i+60).utc, Time.at(1.hour.to_i+120).utc)
    assert_equal false, @scheduler.time_to_go?
    assert_equal false, @scheduler.time_to_go?
    assert_equal true, @scheduler.time_to_go?
    assert_equal false, @scheduler.time_to_go?    
  end
  
end