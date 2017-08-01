require 'set'
require 'fileutils'

module Mixlr
  module Repeater
    def self.logger=(logger)
      @logger = logger
    end

    def self.logger
      @logger ||= Logger.new(STDOUT)
    end

    class Base
      LOG_TAG = 'AutoRepeater'
      DEFAULT_INTERVAL = 10

      def self.on_exception(&block)
        @@exception_block = block
      end

      def self.call_exception_block(exception)
        if defined? @@exception_block
          @@exception_block.call(exception)
        end
      end

      attr_reader :last_run_at

      def name
        self.class.name
      end

      def interval
        DEFAULT_INTERVAL
      end

      def seconds_since_run
        if last_run_at
          Time.now.to_f - last_run_at.to_f
        end
      end

      def ready_to_run?
        last_run_at.nil? || seconds_since_run >= interval
      end

      def run_if_ready
        if ready_to_run?
          run
        end
      end

      def run
        if ready_to_run?
          logger.info("[#{LOG_TAG}] running #{name}")

          start_time = Time.now.to_f
          @last_run_at = start_time

          success = true

          begin
            perform_task
          rescue => e
            success = false
            logger.error "[#{LOG_TAG}] exception inside #{name}: #{e.message}"
            puts e.message
            puts e.backtrace
            self.class.call_exception_block(e)
          ensure
            total_ms = Time.now.to_f - start_time

            msg = success ? :info : :error

            logger.send(msg, "[%s] %s took %.04f seconds to run" % [ LOG_TAG, name, total_ms ])
          end
        end
      end

      protected

      def perform_task
        raise 'This method should be overridden in a subclass before running this repeater.'
      end

      def logger
        Repeater.logger
      end
    end

    class Runner
      def initialize
        @repeaters = Set[]
      end

      def add_repeater(repeater)
        @repeaters << repeater
      end

      def run
        Repeater.logger.info "Running with repeaters: #{@repeaters.map(&:name).inspect}"

        loop do
          @repeaters.each do |repeater|
            if repeater.ready_to_run?
              repeater.run
            end
          end

          sleep 0.2
        end
      end
    end
  end
end

