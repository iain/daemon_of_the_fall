require 'logger'

module DaemonOfTheFall
  module Logging

    def puts(txt)
      logger.info { txt }
    end

    def logger
      @logger ||= ::Logger.new(options[:log] || STDOUT)
    end

  end
end
