# fluent-plugin-tcp-ml

[Fluentd](https://fluentd.org/) output plugin for output to a remote tcp port with multiline support.

Incoming log events will be outputted as split in embedded lines and outputted according to the following format:

* timestamp
    ISO8601 with millisecond precision and 4 digit timezone designator
* hostname
    identifier for the emitting host.
* event id
    identifier to group lines together when line count > 1
* line number
    Line number in the current log event to order lines in the event
* line count
    Number of lines in the current log event

## Installation

### RubyGems

There is currently no other way to install than to clone the repo and issue
```
$ gem build fluent-plugin-tcp-ml.gemspec
.......
.......
$ gem build fluent-plugin-tcp-ml-<version>.gem
```

## Configuration

* See also: [Output Plugin Overview](https://docs.fluentd.org/v1.0/articles/output-plugin-overview)

## Fluent::Plugin::TcpMlOutput

* **hostname** (string) (optional): Host name to include in message
  * Default value: `-`.
* **appname** (string) (optional): Application name to include in message
  * Default value: `-`.
* **host** (string) (required): Remote TCP host
* **port** (integer) (required): Remote TCP port
* **keep_alive** (bool) (optional): Enable keep alive on the socket
    * Default value: false
* **keep_alive_idle** (integer) (optional): TCP_KEEPIDLE: The time (in seconds) the connection needs to remain idle before TCP starts sending keepalive probes
* **keep_alive_cnt** (integer) (optional): TCP_KEEPCNT: The maximum number of keepalive probes TCP should send before dropping the connection
* **keep_alive_intvl** (integer) (optional): TCP_KEEPINTVL: The time (in seconds) between individual keepalive probes

### \<buffer\> section (optional) (multiple)

* **flush_mode** () (optional): 
  * Default value: `interval`.
* **flush_interval** () (optional): 
  * Default value: `5`.
* **flush_thread_interval** () (optional): 
  * Default value: `0.5`.
* **flush_thread_burst_interval** () (optional): 
  * Default value: `0.5`.

[ Generated with: `$ fluent-plugin-config-format -c -f markdown output tcp_ml` ]

## Copyright

* Copyright(c) 2018- dotwilbert
* License
  * Apache License, Version 2.0