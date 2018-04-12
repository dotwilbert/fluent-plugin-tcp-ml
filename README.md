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

```
$ gem install fluent-plugin-tcp-ml
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-tcp-ml"
```

And then execute:

```
$ bundle
```

## Configuration

You can generate configuration template:

```
$ fluent-plugin-config-format output tcp_ml
```

You can copy and paste generated documents here.

## Copyright

* Copyright(c) 2018- TODO: Write your name
* License
  * Apache License, Version 2.0