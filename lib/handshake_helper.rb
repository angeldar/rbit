require 'socket'
require 'net/http'

# TODO: Write tests

class HandshakeData

  attr_reader :name_length, :protocol_name, :reserved, :info_hash, :peer_id

  def initialize(options = {})
    @name_length = options[:name_length] || 19
    @protocol_name = options[:protocol_name] || 'BitTorrent protocol'
    @reserved = options[:reserved] || [0].pack('C') * 8
    @info_hash = options[:info_hash]
    @peer_id = options[:peer_id]
  end

  def to_s
    puts ">> name_length: #{@name_length}"
    puts ">> protocol_name: #{@protocol_name}"
    puts ">> reserve: #{@reserved}"
    puts ">> info_hash #{@info_hash}"
    puts ">> peer_id #{@peer_id}"
  end

end

class HandshakeHelper

  def initialize(info_hash, peer_id)
    @debug = true
    @request_data = HandshakeData.new(info_hash: info_hash, peer_id: peer_id)
    @request = create_request(@request_data)
  end

  def handshake(ip, port)
    begin
      puts ">> trying: #{ip}:#{port}" if @debug
      sock = TCPSocket.new(ip, port)
      sock.print @request
      resp = sock.read(68)
      puts ">> resp: #{resp} " if not resp.nil? and @debug

      sock.close

      return parse_response(resp)

    rescue Errno::ETIMEDOUT
      p 'timeout'
    rescue Errno::ECONNRESET
      p 'econnreset'
    rescue Errno::ECONNREFUSED
      p 'econnrefused'
    rescue Errno::EADDRNOTAVAIL
      p 'eaddrnotavail'
    end
  end

  def parse_response(resp)
    client_resp = HandshakeData.new(
      name_length: resp[0].unpack('B*')[0].to_i(2),
      protocol_name: resp[1..19],
      reserved: resp[20..27],
      info_hash: resp[28..47],
      peer_id: resp[48..68]
    )
    client_resp
  end

  def create_request(handshake_data)
    [handshake_data.name_length].pack('C') + handshake_data.protocol_name +
      handshake_data.reserved + handshake_data.info_hash + handshake_data.peer_id
  end

end