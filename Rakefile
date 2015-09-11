require_relative 'lib/mixlr-repeater'
require 'logger'

class TestRepeater < Mixlr::Repeater::Base
  def interval
    2
  end

  protected

  def perform_task
    logger.info 'Hello world'
  end
end

desc 'Run test'
task :run do
  Mixlr::Repeater.logger = Logger.new(STDOUT)

  runner = Mixlr::Repeater::Runner.new
  runner.add_repeater(TestRepeater.new)
  runner.run
end
task :default => :run
