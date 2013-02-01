require "daemon_of_the_fall/version"
require "daemon_of_the_fall/master"
require "daemon_of_the_fall/pool"

module DaemonOfTheFall

  def self.spawn(command, options)
    Master.new(command, options).start
  end

end
