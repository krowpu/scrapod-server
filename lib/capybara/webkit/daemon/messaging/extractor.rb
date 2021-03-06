# frozen_string_literal: true

require 'capybara/webkit/daemon/messaging'

module Capybara
  module Webkit
    module Daemon
      module Messaging
        ##
        # Extracts high-level packages from wrapped text protocol.
        #
        class Extractor
          include Messaging

          STATES = %i(raw msg).freeze

          attr_reader :state

          def initialize(&block)
            self.state = :raw

            @block = block

            @raw = ''

            @message = nil
            @size    = nil
          end

          def call(s)
            scan s
            result = @raw
            @raw = ''
            result
          end

        private

          def raw(s)
            @raw += s
          end

          def message(s)
            @block&.(s)
          end

          def scan(s)
            start = 0

            s.length.times do |i|
              start = i + 1 if control_chr s, start, i
            end

            breaks s[start..-1]
          end

          def control_chr(s, start, i)
            case s[i]
            when START_CHR  then scan_msg_start s[start...i]
            when END_CHR    then scan_msg_end s[start...i]
            else
              return false
            end

            true
          end

          def scan_msg_start(s)
            raise unless state == :raw

            msg_starts s
          end

          def scan_msg_end(s)
            raise unless state == :msg
            msg_ends s
          end

          def msg_starts(s)
            raw s unless s.empty?

            self.state = :msg
            @message = ''
          end

          def msg_ends(s)
            message @message + s

            self.state = :raw
            @message = nil
            @size = nil
          end

          def breaks(s)
            return if s.empty?

            case state
            when :raw
              raw s
            when :msg
              @message += s
            end
          end

          def state=(sym)
            unless STATES.include? sym
              raise(
                ArgumentError,
                "invalid state #{sym.inspect}, possible are #{STATES.map(&:inspect).join(', ')}",
              )
            end

            @state = sym
          end
        end
      end
    end
  end
end
