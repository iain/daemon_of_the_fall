module DaemonOfTheFall
  class Pool

    attr_reader :command, :options

    attr_reader :pids

    def initialize(command, options)
      @command = command
      @options = options
    end

    def size
      options[:workers]
    end

    def start
      @pids = size.times.map { |n| start_worker(n) }
    end

    def restart
      pids.each.with_index do |pid, index|
        stop_worker(pid)
        new_pid = start_worker(index)
        pids[index] = new_pid
      end
    end

    def stop
      pids.each do |pid|
        stop_worker(pid)
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
      stop_worker(pids.shift)
    end

    private

    def start_worker(num)
      pid = Process.spawn({"DAEMON_WORKER_NUMBER" => num.to_s}, *Array(command), {:chdir => options[:dir]})
      until running?(pid)
        sleep 0.1
      end
      pid
    end

    def stop_worker(pid)
      Process.kill("TERM", pid)
      Process.waitpid(pid)
    end

    def running?(pid)
      Process.getpgid(pid) rescue false
    end

  end
end
