require 'daemon_of_the_fall/logging'

module DaemonOfTheFall
  class Pool
    include Logging

    attr_reader :command, :options

    attr_reader :pids

    def initialize(command, options)
      @command = command
      @options = options
      @pids = []
    end

    def size
      options[:workers]
    end

    def start
      until enough_workers?
        increase
        yield if block_given?
      end
    end

    def restart
      pids.each.with_index do |pid, index|
        stop_worker(pid)
        new_pid = start_worker(index)
        pids[index] = new_pid
        yield if block_given?
      end
    end

    def stop
      pids.each do |pid|
        stop_worker(pid)
        yield if block_given?
      end
    end

    def empty?
      count == 0
    end

    def count
      pids.count { |pid| running?(pid) }
    end

    def increase
      pids << start_worker(pids.size)
    end

    def decrease
      stop_worker(pids.pop)
    end

    def monitor
      while index = missing_pid_index
        puts "Missing pid #{pids[index]} for worker #{index}"
        pids[index] = start_worker(index)
      end
    end

    def enough_workers?
      count >= size
    end

    def missing_pid_index
      pids.index { |pid| not running?(pid) }
    end

    private

    def start_worker(num)
      puts "Starting worker #{num}"
      pid = Process.spawn({"DAEMON_WORKER_NUMBER" => num.to_s}, *Array(command), {:chdir => options[:dir]})
      until running?(pid)
        sleep 0.1
      end
      pid
    end

    def stop_worker(pid)
      puts "Stopping worker #{pid}"
      Process.kill("TERM", pid)
      Process.waitpid(pid)
    end

    def running?(pid)
      Process.getpgid(pid) rescue false
    end

  end
end
