require 'minitest/autorun'

class TestIntegration < MiniTest::Unit::TestCase

  def test_integration

    master_pid = daemon_of_the_fall %Q|--workers 5 --pid tmp/test.pid --name daemon_test "ruby test/test_daemon.rb"|

    pids_of_workers = []

    wait_for {
      pids_of_workers = find_worker_pids
      pids_of_workers.size == 5
    }

    signal "USR2", master_pid

    wait_for {
      new_pids_of_workers = find_worker_pids
      all_are_different?(new_pids_of_workers, pids_of_workers)
    }

    assert_equal 5, find_worker_pids.size

    signal "TTIN", master_pid
    assert_equal 6, find_worker_pids.size

    signal "TTOU", master_pid
    assert_equal 5, find_worker_pids.size

    signal "TERM", master_pid

    workers_remaining = []

    wait_for {
      workers_remaining = find_worker_pids
      workers_remaining.size == 0
    }

  end

  private

  SCRIPT_NAME = "test_daemon.rb"

  def find_worker_pids
    find_pids_for(SCRIPT_NAME)
  end

  def daemon_of_the_fall(command)
    spawn("./bin/daemon_of_the_fall #{command}")
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
    raise "Timeout expired"
  end

  def all_are_different?(one, two)
    (one & two).empty?
  end

end
