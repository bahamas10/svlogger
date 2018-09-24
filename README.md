`svlogger`
==========

`svlogger` is a generic `svlogd` wrapper for runit services that is meant to be
symlinked to `/.../<service-name>/log/run`.

This script will automatically figure out the service name under which it is
running and write out logs to a file under a directory with that service name
using `svlogd`.

Alternatively, this script can be called with an optional first argument to
specify the service log base directory; the default is `/tmp/sv/log`.

Installation
------------

`svlogger` is a standalone bash script that can be put anywhere on your system.
I personally use this script on Void Linux and put it in `/etc/sv`.  You
can do this with:

    $ sudo make install
    cp svlogger /etc/sv

Usage
-----

To enable logs for a single service:

    # mkdir -p /etc/sv/my-service/log
    # ln -s /etc/sv/svlogger /etc/sv/my-service/log/run

Within 5 seconds `runit` will start the logger service and `svlogd` will write
logs to `/tmp/sv/log/my-service`:

    $ tail /tmp/sv/log/my-service/current
    2018-09-19_21:52:51.30654 starting...
    2018-09-19_21:52:52.30754 tick
    2018-09-19_21:52:53.30926 tick
    2018-09-19_21:52:54.31068 tick

To enable logs for *all* active services that don't currently have a logger:

    cd /var/service
    for d in */; do
        sudo mkdir -p "$d/log"
        [[ -e $d/log/run ]] || sudo ln -s /etc/sv/svlogger "$d/log/run"
    done

You can then view all of the logs generated with:

    # tail -f /tmp/sv/log/*/current
    ...

To log to a directory other than `/tmp/sv`, you can edit the script or pass a
directory name as the first argument.  If you choose to pass a directory name as
an argument you cannot symlink `svlogger` and instead will need to create a
small wrapper script for `svlogger`.  For example:

`/etc/sv/my-service/log/run`

``` sh
#!/bin/sh
exec /etc/sv/svlogger /var/log/sv
```

This will cause `my-service` to output it's logs to the newly created
`/var/log/sv/my-service` directory.

Notes / FAQ
-----------

### Not everything is being logged / I only see `stdout` in my logs

With `runit`, `stdout` will go to the logger program (if it is set) and `stderr`
will show up in the command line of the `runsvdir` program.

To log `stderr`, you need to redirect `stderr` to `stdout` in your service's
`run` script.  You can add an `exec` line like this to the top of your
service's `run` script:

    #!/bin/sh
    exec 2>&1
    ...

Contributing
------------

This project uses:

- Bash Style Guide: https://www.daveeddy.com/bash/
- `shellcheck`: https://github.com/koalaman/shellcheck

Ensure any code contributions pass `make check`:

```
$ make check
awk 'length($0) > 80 { exit(1); }' README.md
awk 'length($0) > 80 { exit(1); }' svlogger
shellcheck svlogger
```

License
-------

MIT License
