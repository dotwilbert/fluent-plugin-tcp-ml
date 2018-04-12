require 'helper'
require 'fluent/plugin/out_tcp_ml.rb'


class TcpMlOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

#  test "failure" do
#    flunk
#  end

  # Default configuration for test
  #  keep_alive true
  #  keep_alive_idle 60
  #  keep_alive_intvl 60 

  CONFIG = %[
    hostname 'container67.adaptiveplanning.com'
    host '127.0.0.1'
    port 2000
  ]

  sub_test_case 'configured with invalid configurations' do
    test 'host not provided' do
      assert_raise Fluent::ConfigError do
        create_driver(%[
          port 2000
        ])
      end
    end

    test 'port not provided' do
      assert_raise Fluent::ConfigError do
        create_driver(%[
          host '127.0.0.1'
        ])
      end
    end
  end

  sub_test_case 'test for write' do
    test '#write test' do
      svr = start_server('127.0.0.1', 2000, 1)
      d = create_driver
      t = event_time('2018-04-11 18:24:38 -07:00')
      d.run do
        d.feed('tag', [[t, { 'message' => 'this is a test message' }], [Fluent::EventTime.now, { 'message' => 'this is also a test message' }]])
      end
      results = svr.value
      results.each do |r|
        assert { r.match?(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2},\d{3}[+-]\d{2}:\d{2} [a-f0-9]{32} \d+ \d+ .*$/) }
      end
      # assert{ check_write_of_plugin_called_and_its_result() }
    end
  end

  private

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::TcpMlOutput).configure(conf)

  end

  def start_server(host, port, requestCount)
    require 'socket'
    req_ctr = 0
    requests = []
    Thread.new do
      server = TCPServer.new(host, port)
      while req_ctr < requestCount do
        socket = server.accept
        requests << socket.gets
        socket.close
        req_ctr += 1
      end
      requests
    end
  end
end
