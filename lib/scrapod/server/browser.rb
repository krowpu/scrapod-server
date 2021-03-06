# frozen_string_literal: true

require 'capybara'
require 'capybara/webkit/browser'

require 'scrapod/server/connection'

module Scrapod
  module Server
    class Browser < Capybara::Webkit::Browser
      attr_reader :configuration
      attr_reader :connection

      def initialize(configuration:)
        @configuration = configuration

        set_connection

        @active = true
      end

      def active?
        @active
      end

      def close
        close_mutex.synchronize do
          return unless active?

          @active = false

          close_connection
        end
      end

    private

      def close_mutex
        @close_mutex ||= Mutex.new
      end

      def set_connection
        @connection = Scrapod::Server::Connection.new configuration: configuration
      end

      def close_connection
        connection.close
        @connection = nil
      end
    end
  end
end
