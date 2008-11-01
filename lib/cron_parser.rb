class CronParser

  class << self
    def parse expression       
      rules = expression.strip.split(/\s+/)
      raise "Cron expression requires minutes, hours, mday, month, wday" if rules.size != 5
      raise "Cron expression only allows minutes, hours and weekday to be set" if rules[2] != "*" || rules[3] != "*"# || rules[4] != "*"    
      CronParser.new.parse_rules rules
    end

  end

  def lengths; [60, 24, 31, 12, 7]; end
  def labels; [:min, :hour, :mday, :month, :wday]; end

  def parse_rules(rules, schedule=[{}])
    return schedule if rules.size == 0
    rule = rules.pop
    case rules.size
    when 2,3
      parse_rules rules, schedule
    when 0,1,4
      parse_rules rules, parse_rule(rule, schedule, rules.size)
    end  
  end

  def parse_rule rule, schedule, index
    collector = collect_values labels[index], schedule
    new_times = []
    pattern, step = parse_pattern rule
    if pattern == "*"
      (lengths[index]/step).times do |value|
        new_times.concat collector.call(value*step) 
      end
    else
      pattern.split(",").each do |value|
        new_times.concat collector.call(value) 
      end
    end
    new_times
  end

  def parse_pattern rule
    pattern, step = rule.split("/")
    step = step ? step.to_i : 1
    range = pattern.split("-")
    if range.size > 1
      steps = []
      (range[0]..range[1]).step(step) do |i|
        steps << i
      end
      [steps.join(",")]
    else
      [range[0], step]
    end
  end

  def collect_values label, schedule
    return Proc.new do |value|
      schedule.collect do |p|
        p[label] = value.to_i
        p.clone
      end
    end
  end

end