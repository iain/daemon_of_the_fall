exiting = false
trap("TERM") { exiting = true }

$PROGRAM_NAME = "test_daemon.rb daemon_test worker##{ENV["DAEMON_WORKER_NUMBER"]}"

until exiting
  sleep 0.1
end
