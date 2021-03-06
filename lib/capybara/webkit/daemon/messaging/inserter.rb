# frozen_string_literal: true

require 'capybara/webkit/daemon/messaging'

module Capybara
  module Webkit
    module Daemon
      module Messaging
        ##
        # Inserts high-level packages to wrapped text protocol.
        #
        class Inserter
          include Messaging

          def initialize(&block)
            @block = block
          end

          def call(s)
            @block&.("#{START_CHR}#{s}#{END_CHR}")
          end
        end
      end
    end
  end
end
