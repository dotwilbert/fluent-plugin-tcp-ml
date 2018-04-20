#
# Copyright 2018 Wilbert van de Pieterman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fluent/plugin/output'
require 'socket'
require 'tcpml/client'
require 'uuidtools'

module Fluent
  module Plugin
    class TcpMlOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("tcp_ml", self)

      # Load helpers
      # helpers :thread

      desc 'Host name to include in message'
      config_param :hostname, :string, default: '-'
      desc 'Application name to include in message'
      config_param :appname, :string, default: '-'
      desc 'Remote TCP host'
      config_param :host, :string
      desc 'Remote TCP port'
      config_param :port, :integer

      # config_param :timeout,           :time,    default: nil
      # config_param :timeout_exception, :bool,    default: false
      config_param :keep_alive,        :bool,    default: false
      config_param :keep_alive_idle,   :integer, default: nil
      config_param :keep_alive_cnt,    :integer, default: nil
      config_param :keep_alive_intvl,  :integer, default: nil

      config_section :buffer do
        config_set_default :flush_mode, :interval
        config_set_default :flush_interval, 5
        config_set_default :flush_thread_interval, 0.5
        config_set_default :flush_thread_burst_interval, 0.5
      end

      def configure(conf)
        super
        @clients = []
        if @host.nil? || @port.nil?
          raise ConfigError, 'both host and port are required'
        end
        # Test socket capabilities
        socket_capability_keep_alive = Socket.const_defined?(:SOL_SOCKET) &&
                                       Socket.const_defined?(:SO_KEEPALIVE) &&
                                       Socket.const_defined?(:IPPROTO_TCP) &&
                                       Socket.const_defined?(:TCP_KEEPIDLE)
        socket_capability_keep_alive_idle = Socket.const_defined?(:TCP_KEEPIDLE)
        socket_capability_keep_alive_cnt = Socket.const_defined?(:TCP_KEEPCNT)
        socket_capability_keep_alive_intvl = Socket.const_defined?(:TCP_KEEPINTVL)
        @keep_alive = socket_capability_keep_alive ? conf['keep_alive'] : false
        @keep_alive_idle = socket_capability_keep_alive_idle ? conf['keep_alive_idle'] : nil
        @keep_alive_cnt = socket_capability_keep_alive_cnt ? conf['keep_alive_cnt'] : nil
        @keep_alive_intvl = socket_capability_keep_alive_intvl ? conf['keep_alive_intvl'] : nil
      end

      def close
        super
        @clients.each { |c| c.disconnect if c }
        @clients.clear
      end

      def multi_workers_ready?
        true
      end

      def format(_tag, _time, record)
        ts = DateTime.now.strftime('%FT%T,%L%:z')
        eventid = UUIDTools::UUID.timestamp_create.hexdigest
        msg = record['message']
        lines = msg.split(/\r?\n/)
        nol = lines.length
        out_msg = ''
        lines.each_with_index do |line, idx|
          out_msg += format_line(ts, @hostname, @appname, eventid, idx, nol, line)
        end
        out_msg
      end

      def write(chunk)
        return if chunk.empty?

        host_port = "#{@host}:#{@port}"
        Thread.current[host_port] ||= create_client
        client = Thread.current[host_port]

        begin
          chunk.open do |io|
            io.each_line do |msg|
              client.transmit(msg)
            end
          end
        rescue
          if Thread.current[host_port]
            Thread.current[host_port].disconnect
            @clients.delete(Thread.current[host_port])
            Thread.current[host_port] = nil
          end
          raise
        end
      end

      private

      def create_client
        c = TcpMlClient.new(@host, @port, @keep_alive, @keep_alive_idle, @keep_alive_cnt, @keep_alive_intvl)
        c.connect
        @clients << c
        c
      end

      def format_line(timestamp, hostname, appname, eventid, idx, count, msg)
        "#{timestamp} #{hostname} #{appname} #{eventid} #{idx} #{count} #{msg}\n"
      end
    end
  end
end
