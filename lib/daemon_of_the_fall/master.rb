require 'thread'
require 'fileutils'

Thread.abort_on_exception = true

module DaemonOfTheFall
  class Master

    attr_reader :command, :options

    def initialize(command, options)
      @command = command
      @options = options
      update_program_name("booting")
    end

    def start
      Dir.chdir(root)
      write_pid
      at_exit { clean_pid_file }
      trap_signals
      start_workers
      update_program_name
      wait_until_done
      puts "Stopped #{$PROGRAM_NAME} (pid: #{Process.pid})"
    end

    def restart
      update_program_name("restarting")
      pool.restart
      update_program_name
    end

    def stop
      update_program_name("shutting down")
      pool.stop
    end

    private

    def write_pid
      FileUtils.mkdir_p(File.dirname(pid_file))
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
      trap("USR2") { puts "USR2 received!"; restart }
      trap("TERM") { puts "TERM received!"; stop }
      trap("INT")  { puts "INT received!";  stop }
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
      options[:pid]
    end

    def update_program_name(additional = nil)
      if additional
        $PROGRAM_NAME = "#{options[:name]} master (#{additional})"
      else
        $PROGRAM_NAME = "#{options[:name]} master"
      end
    end


  end
end
