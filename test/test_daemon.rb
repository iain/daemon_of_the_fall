exiting = false
trap("TERM") { exiting = true }

until exiting
  sleep 0.1
end
