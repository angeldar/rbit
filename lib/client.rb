require 'CGI'
require 'socket'
require 'net/http'
require_relative 'meta_info'
require_relative 'handshake_helper'

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
    @left       = 91715004

    @handshake_helper = HandshakeHelper.new(@info_hash, @peer_id)

    # States, each dictionary contains IP as key, and bool as value
    # Should fill after successfull handshake
    @choked_peers
    @interested_peers
    @choked_by_peers
    @interested_in_peers
  end

  def request
    #This message has ID 6 and a payload of length 12. The payload is 3 integer values
    #indicating a block within a piece that the sender is interested in downloading from 
    #the recipient. The recipient MUST only send piece messages to a sender that has
    #already requested it, and only in accordance to the rules given above about the choke
    #and interested states. The payload has the following structure:
    #| Piece Index | Block Offset | Block Length |
    length = 12
    id = 6
    piece_index = 0
    block_offset = 0
    payload = [piece_index, block_offset, meta.piece_length]
    data = [length, id] + payload
    message = data.map {|n| [n].pack('C')}.join
  end

  def server_request
    decoder = BencodingDecoder.new
    uri = create_request
    puts ">> uri: #{uri}" if @debug
    resp = Net::HTTP.get_response(uri)
    puts ">> server resp: #{resp.body}" if @debug
    decoder.decode resp.body #if res.is_a?(Net::HTTPSuccess)
  end

  def binstring_to_ip(binstring)
    raise "ERROR: Can't parse binstring, the length is not multiple of 8." if binstring.length % 8 != 0

    bin_addreses = binstring.scan(/.{48}/)

    addreses = []
    bin_addreses.each do |bin_addr|
      bytes = bin_addr.scan(/.{8}/)
      ip = bytes[0...4].map {|s| s.to_i(2)}.join('.')
      port = bytes[4..6].join('').to_i(2)
      # puts ">> addr: #{ip}:#{port}" if @debug
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
      :numwant => 1,

      :port => @port,
      :uploaded => @uploaded,
      :downloaded => @downloaded,
      :left => @left,
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

  def handshake(addr, port)
    @handshake_helper.handshake(addr, port)
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
    response = client.handshake(addr, port)
    puts response
  end
  puts 'end'
end

test
