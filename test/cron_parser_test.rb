require 'date'
require File.dirname(__FILE__) + '/test_helper'

class CronParserTest < Test::Unit::TestCase

  def setup
    @parser = CronParser.new
  end

  def test_parse
    assert_equal [:min => 1, :hour => 2, :wday => 3], CronParser.parse("1 2 * * 3")
  end

  def test_parse_with_white_space
    assert_equal [:min => 1, :hour => 2, :wday => 3], CronParser.parse(" 1   2    *   *     3")
  end

  def test_parse_limits
    assert_raises(RuntimeError, "Cron expression requires minutes, hours, mday, month, wday") do
      CronParser.parse("1 2 3 4")
    end    
    assert_raises(RuntimeError, "Cron expression requires minutes, hours, mday, month, wday") do
      CronParser.parse("1 2 3 4 5 6")
    end    
  end

  def test_parse_limits_for_characters
    assert_raises(RuntimeError, "Cron expression only allows minutes, hours and weekday to be set") do
      CronParser.parse("1 2 3 * *")
    end    
    assert_raises(RuntimeError, "Cron expression only allows minutes, hours and weekday to be set") do
      CronParser.parse("1 2 * 4 *")
    end
      CronParser.parse("1 2 * * 5")
  end

  def test_parse_with_all_splats
    schedule = []
    # 7.times do |k|
      60.times do |j|  
        24.times do |i|
          schedule << {:min => j, :hour => i, :wday => 1}
        end
      end
    # end  
    assert_equal schedule, CronParser.parse("* * * * 1")
  end

  def test_parse_with_hour_splat
    schedule = []
    24.times do |i|
      schedule << {:min => 1, :hour => i, :wday => 1}
    end  
    assert_equal schedule, CronParser.parse("1 * * * 1")
  end

  def test_parse_with_min_splat
    schedule = []
    60.times do |i|
      schedule << {:min => i, :hour => 1, :wday => 1}
    end  
    assert_equal schedule, CronParser.parse("* 1 * * 1")
  end

  def test_parse_with_commas
    schedule = [ {:min => 0, :hour => 1, :wday => 1},
      {:min => 0, :hour => 2, :wday => 1},      
      {:min => 30, :hour => 1, :wday => 1},
      {:min => 30, :hour => 2, :wday => 1}]
      assert_equal schedule, CronParser.parse("0,30 1,2 * * 1")
  end

  def test_parse_with_range
    schedule = []
    4.times do |j|  
      8.times do |i|
        schedule << {:min => j*15, :hour => i*3, :wday => 1}
      end
    end
    assert_equal schedule, CronParser.parse("*/15 */3 * * 1")
  end

  def test_parse_pattern
    assert_equal ["*", 15], @parser.parse_pattern("*/15")    
  end

  def test_parse_pattern_with_range
    assert_equal ["10,15,20,25,30,35,40"], @parser.parse_pattern("10-40/5")    
  end

  def test_collect_values
    collector = @parser.collect_values(:hour, [{}])
    assert_equal [{:hour=>2}], collector.call(2)
  end

  def test_collect_values_with_existing
    collector = @parser.collect_values(:hour, [{:min => 3}, {:min => 4}])
    assert_equal([{:min=>3, :hour=>2}, {:min=>4, :hour=>2}], collector.call(2))
  end
end