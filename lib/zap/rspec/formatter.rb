require 'rspec/core'
require 'rspec/core/formatters/base_formatter'
require 'json'

module Zap
  module RSpec
    # @private
    class Formatter < ::RSpec::Core::Formatters::BaseFormatter
      ::RSpec::Core::Formatters.register self,
                                         :message,
                                         :example_started,
                                         :example_passed,
                                         :example_failed,
                                         :example_pending

      def example_started(notification)
        example = notification.example
        stream_example(example, event: :started, status: :running)
      end

      def example_pending(notification)
        example = notification.example
        stream_example(example, event: :completed, status: :skipped)
      end

      def example_failed(notification)
        example = notification.example
        stream_example(example, event: :completed, status: :failed)
      end

      def example_passed(notification)
        example = notification.example
        stream_example(example, event: :completed, status: :passed)
      end

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
          content: [
            format_example_description(example)
          ]
        }
      end

      def format_example_description(example)
        {
          message: example.full_description,
          source: {
            file: example.metadata[:file_path],
            start: example.metadata[:line_number]
          }
        }
      end
    end
  end
end
