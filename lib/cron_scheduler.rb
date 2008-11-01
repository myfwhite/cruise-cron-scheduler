class CronScheduler < PollingScheduler
  def initialize(project)
    @project = project
    @custom_polling_interval = nil
    @last_build_loop_error_source = nil
    @last_build_loop_error_time = nil
  end

  def run
    while (true) do
      begin
        check_build_request_until_next_polling
        @project.request_build
        check_build_request_until_current_ends        
        clean_last_build_loop_error
        throw :reload_project #if @project.config_modified?
      rescue => e
        log_error(e) unless (same_error_as_before(e) and last_logged_less_than_an_hour_ago)
        sleep(Configuration.sleep_after_build_loop_error)
      end
    end
  end

  def check_build_request_until_next_polling
    while ! time_to_go?
      @project.build_if_requested
      sleep build_request_checking_interval
    end
  end

  def check_build_request_until_current_ends
    while time_to_go?
      sleep build_request_checking_interval
    end
  end

  def polling_interval
    @custom_polling_interval or Configuration.default_polling_interval
  end

  def build_request_checking_interval
    Configuration.build_request_checking_interval
  end

  def time_to_go?
    today = Time.now
    @times.include?({:hour => today.hour, :min => today.min, :wday => today.wday})
  end

  def polling_interval=(value)
    begin
      value = value.to_i
    rescue 
      raise "Polling interval value #{value.inspect} could not be converted to a number of seconds"
    end
    raise "Polling interval of #{value} seconds is too small (min. 5 seconds)" if value < 5.seconds
    raise "Polling interval of #{value} seconds is too big (max. 60 seconds)" if value > 60.seconds
    @custom_polling_interval = value
  end
  
  def cron=(cron_expression)
    @times = CronParser.parse(cron_expression)
  end
end