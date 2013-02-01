require 'thread'
require 'fileutils'
Thread.abort_on_exception = true

module DaemonOfTheFall
  class Master

    attr_reader :command, :options

    def initialize(command, options)
      @command = command
      @options = options
      $PROGRAM_NAME = "#{options[:name]} master"
    end

    def start
      write_pid
      at_exit { clean_pid_file }
      trap_signals
      start_workers
      wait_until_done
      puts "Stopped #{$PROGRAM_NAME} (pid: #{Process.pid})"
    end

    private

    def write_pid
      if File.exist?(pid_file)
        existing_pid = File.open(pid_file, 'r').read.chomp
        running = Process.getpgid(existing_pid) rescue false
        if running
          puts "Error: PID file already exists at `#{pid_file}` and a process with PID `#{existing_pid}` is running"
          exit 1
        else
          puts "Warning: cleaning up stale pid file at `#{pid_file}`"
          write_pid!
        end
      else
        write_pid!
      end
    end

    def write_pid!
      File.open(pid_file, 'w') { |f| f.write(Process.pid) }
    end

    def start_workers
      pool.start
    end

    def pool
      @pool ||= Pool.new(command, options)
    end

    def trap_signals
      trap("USR2") { puts "USR2 received!"; pool.restart }
      trap("TERM") { puts "TERM received!"; pool.stop }
      trap("INT")  { puts "INT received!";  pool.stop }
    end

    def wait_until_done
      until pool.empty?
        sleep 0.1
      end
    end

    def clean_pid_file
      if File.exist?(pid_file)
        existing_pid = File.open(pid_file, 'r').read.chomp
        if existing_pid == Process.pid.to_s
          puts "Cleaning up my own pid file at `#{pid_file}`"
          FileUtils.rm(pid_file)
        else
          puts "Pid file `#{pid_file}` did not belong to me. I am #{Process.pid}, and the pid file says #{existing_pid}"
        end
      else
        puts "Pid file disappeared from `#{pid_file}`"
      end
    end

    def root
      options[:dir]
    end

    def pid_file
      File.join(root, options[:pid])
    end

  end
end
