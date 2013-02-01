> The blink of an eye, you know it's me.
> You keep the dagger close at hand.

# Daemon of the Fall

Start, restart and stop multiple instances of daemons that don't support that.

You can specify a command to be run, specify how much instances should be
started. You can then restart them one by one by sending a single USR2 signal
to the master process. Similar to processes like Unicorn.

Example:

    # start 10 workers:
    daemon_of_the_fall --pid /tmp/foo.pid --workers 10 --daemonize /some/daemon

    # restart them one by one:
    kill -USR2 `cat /tmp/foo.pid`

    # shut them all down:
    kill -TERM `cat /tmp/foo.pid`

## Installation

    $ gem install daemon_of_the_fall

## Usage

See `daemon_of_the_fall --help` for a list of options.

These are the signals daemon_of_the_fall responds to:

* `TERM` shuts down all workers and then the master
* `INT` does the same as `TERM`
* `HUP` will be simply forwarded to each worker
* `USR2` will restart each worker

## Testing

Run `rake` to run the tests.

If the integration test fails, you might need to clean up the orphaned
processes manually.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
