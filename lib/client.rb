require 'CGI'
require 'socket'
require 'net/http'
require_relative 'meta_info'

# List of id-s
CHOKE = 0
UNCHOKE = 1
INTERESTED = 2
UNINTERESTED = 3
HAVE = 4
BITFIELD = 5
REQUEST = 6
PIECE = 7
CANCEL = 8

class Client

  def initialize
    @debug = true

    meta = MetaInfo.new
    meta.read 'test4.torrent'

    @announce_url = URI.encode meta.announce
    @info_hash    = meta.info_hash
    @peer_id    = '-DE13B0-W-uYy2y2Dzpd' #generate_peer_id
    @port       = 6889
    @uploaded   = 0
    @downloaded = 0
    @left       = 2000

    # States, each dictionary contains IP as key, and bool as value
    # Should fill after successfull handshake
    @choked_peers
    @interested_peers

    @choked_by_peers
    @interested_in_peers
  end

  def request
    uri = create_request
    puts ">> uri: #{uri}" if @debug
    res = Net::HTTP.get_response(uri)
    puts ">> res: #{res.body}" if @debug
    res.body #if res.is_a?(Net::HTTPSuccess)
  end

  def server_request
    decoder = BencodingDecoder.new
    response = decoder.decode request
    # puts ">> resp: #{response}" if @debug
    response
  end

  def binstring_to_ip(binstring)
    raise "ERROR: Can't parse binstring, the length is not multiple of 8." if binstring.length % 8 != 0

    bin_addreses = binstring.scan(/.{48}/)

    addreses = []
    bin_addreses.each do |bin_addr|
      bytes = bin_addr.scan(/.{8}/)
      ip = bytes[0...4].map {|s| s.to_i(2)}.join('.')
      port = bytes[4..6].join('').to_i(2)
      puts ">> addr: #{ip}:#{port}" if @debug
      addreses << [ip, port]
    end
    addreses
  end

  def create_request
    uri = URI.parse(@announce_url)

    params = {
      :info_hash => URI.encode(@info_hash),
      :peer_id => @peer_id,
      :compact => '1',
      :numwant => 20,

      :port => 50527,
      :uploaded => 0,
      :downloaded => 0,
      :left => 91715004,
      :corrupt => 0,
      :redundant => 0,
      :key => 'e6d94dd6',
      :no_peer_id => 1,
      :supportcrypto => 1,
      :event => 'started'
    }

    uri.query = (uri.query ? uri.query + '&' : '') + params.map{|k, v| [k.to_s, "=", v.to_s]}.map(&:join).join('&')
    uri
  end

  def handshake(ip, port)
    params = {
      :name_length => 19,
      :protocol_name => 'BitTorrent protocol',
      :reserved => 0,
      :info_hash => @info_hash,
      :peer_id => @peer_id
    }

    request = [params[:name_length]].pack('C') + params[:protocol_name] +
      [params[:reserved]].pack('C') * 8 + params[:info_hash] +  params[:peer_id]

    begin
      puts ">> trying: #{ip}:#{port}" if @debug
      sock = TCPSocket.new(ip, port)
      sock.print request
      resp =  sock.read(68)
      puts ">> resp: #{resp} #{resp[0].unpack('B*')[0].to_i(2)}" if not resp.nil?

      # TODO: split resp by logical parts.

      sock.close
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

  def get_peers
    puts ">> Trying to get peers" if @debug
    server_response = server_request
    bin = server_response['peers'].unpack('B*')[0]
    peers = binstring_to_ip bin
  end

  def generate_peer_id
    (0...20).map { (65 + rand(26)).chr }.join
  end

end

def test
  puts 'start'
  client = Client.new
  peers = client.get_peers
  peers.each do |addr, port|
    client.handshake(addr, port)
  end
  puts 'end'
end

test
