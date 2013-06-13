require 'minitest/autorun'
require "thread"

class TestIntegration < MiniTest::Unit::TestCase

  def test_integration

    # boot up
    master_pid = daemon_of_the_fall %Q|--workers 5 --pid tmp/test.pid --name daemon_test "ruby test/test_daemon.rb"|
    pids_of_workers = []
    wait_for {
      pids_of_workers = find_worker_pids
      pids_of_workers.size == 5
    }

    # restart
    signal "USR2", master_pid
    wait_for {
      new_pids_of_workers = find_worker_pids
      all_are_different?(new_pids_of_workers, pids_of_workers)
    }
    assert_equal 5, find_worker_pids.size

    # increase workers on the fly
    signal "TTIN", master_pid
    assert_equal 6, find_worker_pids.size

    # decrease workers on the fly
    signal "TTOU", master_pid
    assert_equal 5, find_worker_pids.size

    # monitor crashing workers
    pid_to_kill = find_worker_pids.first
    signal "TERM", pid_to_kill
    sleep 0.2
    assert_equal 5, find_worker_pids.size

    # shutdown
    signal "TERM", master_pid
    workers_remaining = []
    wait_for {
      workers_remaining = find_worker_pids
      workers_remaining.size == 0
    }

  end

  private

  SCRIPT_NAME = "test_daemon.rb"

  def spawned_commands
    @spawned_commands ||= []
  end

  def find_worker_pids
    find_pids_for(SCRIPT_NAME)
  end

  def daemon_of_the_fall(command)
    at_exit {
      spawned_commands.each { |pid| Process.kill("TERM", pid) }
    }
    FileUtils.mkdir_p("log")
    cmd = "./bin/daemon_of_the_fall #{command} --log log/test.log"
    puts "Running: #{cmd}"
    pid = spawn(cmd)
    spawned_commands << pid
    pid
  end

  def find_pids_for(filter)
    processes = `ps u`.split("\n")
    found = processes.select { |line| line.include?(filter) }
    found.map { |line| line.split(/\s+/, 4)[1].to_i }
  end

  def signal(type, pid)
    Process.kill(type, pid)
    sleep 0.1
  end

  def wait_for(timeout=2)
    deadline = Time.now + timeout
    until Time.now >= deadline
      result = yield
      if result
        return
      else
        sleep 0.1
      end
    end
    raise "Timeout expired, running now: #{find_worker_pids.inspect}"
  end

  def all_are_different?(one, two)
    (one & two).empty?
  end

end
