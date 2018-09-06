require 'rspec/core'
require 'rspec/core/formatters/base_formatter'
require 'json'

module Zap
  module RSpec
    # @private
    class Formatter < ::RSpec::Core::Formatters::BaseFormatter
      ::RSpec::Core::Formatters.register self,
                                         :start,
                                         :example_group_started,
                                         :example_started,
                                         :example_passed,
                                         :example_failed,
                                         :example_pending,
                                         :message,
                                         :stop,
                                         :start_dump,
                                         :dump_pending,
                                         :dump_summary,
                                         :seed,
                                         :close

      def start(*args); end

      def example_group_started(*args); end

      def example_started(notification)
        example = notification.example
        stream_example(example, event: :started, status: :running)
      end

      def example_passed(notification)
        example = notification.example
        stream_example(example, event: :completed, status: :passed)
      end

      def example_failed(notification)
        example = notification.example
        stream_example(example, event: :completed, status: :failed)
      end

      def example_pending(notification)
        example = notification.example
        stream_example(example, event: :completed, status: :skipped)
      end

      def message(*args); end

      def stop(*args); end

      def start_dump(*args); end

      def dump_pending(*args); end

      def dump_summary(*args); end

      def seed(*args); end

      def close(*args); end

      private

      def stream_example(example, **args)
        formatted = format_example(example, **args)
        output.puts formatted.to_json
      end

      def now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def format_example(example, status:, event:)
        {
          kind: :item,
          id: example.id,
          event: event,
          status: status,
          time: now,
          content: [*format_example_description(example),
                    *format_example_exception(example)]
        }
      end

      def format_example_description(example)
        [{
          message: example.full_description,
          source: {
            file: example.metadata[:file_path],
            start: example.metadata[:line_number]
          }
        }]
      end

      def format_example_exception(example)
        return [] unless example.exception

        file, line, *_rest = example.exception.backtrace.first.split(':')

        [{
          message: example.exception.message,
          source: {
            file: file,
            start: line.to_i
          }
        }]
      end
    end
  end
end
