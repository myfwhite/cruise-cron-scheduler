$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH << File.dirname(__FILE__)

require 'cron_scheduler'
require 'cron_parser'

Project.plugin :cron_scheduler