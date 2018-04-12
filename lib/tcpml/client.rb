require 'socket'
class TcpMlClient

  def initialize(host, port, keep_alive = false, keep_alive_idle = nil, keep_alive_cnt = nil, keep_alive_intvl = nil)
    @mutex = Mutex.new
    @host = host
    @port = port
    @keep_alive = keep_alive
    @keep_alive_idle = keep_alive_idle
    @keep_alive_cnt = keep_alive_cnt
    @keep_alive_intvl = keep_alive_intvl
    @socket = nil
  end

  def connect
    connect_retry_count = 0
    connect_retry_limit = 2
    connect_retry_interval = 1
    @mutex.synchronize do
      begin
        @socket.close if @socket
        @socket = TCPSocket.new(@host, @port)
        if @keep_alive
          @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
          @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_KEEPIDLE, @keep_alive_idle) if @keep_alive_idle
          @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_KEEPCNT, @keep_alive_cnt) if @keep_alive_cnt
          @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_KEEPINTVL, @keep_alive_intvl) if @keep_alive_intvl
        end
        # if @tls
        #   require 'openssl'
        #   context = OpenSSL::SSL::SSLContext.new(@ssl_method)
        #   context.ca_file = @ca_file if @ca_file
        #   context.verify_mode = @verify_mode if @verify_mode
        # 
        #   @socket = OpenSSL::SSL::SSLSocket.new(@tcp_socket, context)
        #   @socket.connect
        #   @socket.post_connection_check(@remote_hostname)
        #   raise "verification error" if @socket.verify_result != OpenSSL::X509::V_OK
        # else
        #   @socket = @tcp_socket
        # end
      rescue
        raise if connect_retry_limit >= connect_retry_count
        sleep connect_retry_interval
        connect_retry_count += 1
        retry
      end
    end
  end

  def disconnect
    @socket.close if @socket
  end

  def transmit(s)
    @socket.write(s)
  end
end
