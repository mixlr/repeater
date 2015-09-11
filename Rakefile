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

class TestExceptionHandling < Mixlr::Repeater::Base
  def interval
    3
  end

  protected

  def perform_task
    raise 'Goodbye world'
  end
end

desc 'Run test'
task :run do
  Mixlr::Repeater.logger = Logger.new(STDOUT)

  Mixlr::Repeater::Base.on_exception { |e| Mixlr::Repeater.logger.info("Exception caught successfully: #{e.message}") }

  runner = Mixlr::Repeater::Runner.new
  runner.add_repeater(TestRepeater.new)
  runner.add_repeater(TestExceptionHandling.new)
  runner.run
end
task :default => :run
