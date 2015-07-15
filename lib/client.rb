require 'CGI'
require 'socket'
require 'net/http'
require_relative 'meta_info'

class Client

  def initialize
     @debug = true

    meta = MetaInfo.new
    meta.read 'test.torrent'
    @announce_url = URI.encode meta.announce
    @info_hash  = meta.info_hash
    @peer_id    = '-DE13B0-K9I3wyKnA947' #generate_peer_id
    @port       = 6889
    @uploaded   = 0
    @downloaded = 0
    @left       = 2000
  end

  def request
    uri = create_request
    puts ">> uri: #{uri}" if @debug
    res = Net::HTTP.get_response(uri)
    res.body #if res.is_a?(Net::HTTPSuccess)
  end

  def server_request
    decoder = BencodingDecoder.new
    response = decoder.decode request
    puts ">> resp: #{response}" if @debug
    response
  end

  # TODO: Refactor to parse multiple ip-s.
  def binstring_to_ip(binstring)
    raise "ERROR: Can't parse binstring, the length is not multiple of 8."if binstring.length % 8 != 0
    bytes = binstring.scan(/.{8}/)
    ip = bytes[0...4].map {|s| s.to_i(2)}.join('.')
    port = bytes[4..6].join('').to_i(2)
    puts ">> addr: #{ip}:#{port}" if @debug
    return ip, port
  end

  def create_request
    uri = URI(@announce_url)
    params = {
      :info_hash => '%' + @info_hash.scan(/.{2}|.+/).join('%'),
      :peer_id   => @peer_id,
      :compact => '1',
      :numwant => '1'
    }
    uri.query = params.map{|k, v| [k.to_s, "=", v.to_s]}.map(&:join).join('&')
    uri
  end

  def handshake(ip, port)
    params = {
      :name_length => 19,
      :protocol_name => 'BitTorrent protocol',
      :reserved => 0,
      :info_hash => @info_hash[0...20],
      :peer_id => @peer_id
    }


    puts [params[:name_length]].pack('C').length
    puts params[:protocol_name].length
    puts ([params[:reserved]].pack('C') * 8).length
    puts params[:info_hash].unpack('b*')[0].length
    puts params[:peer_id].length

    request = [params[:name_length]].pack('C') + params[:protocol_name] +
      [params[:reserved]].pack('C') * 8 + params[:info_hash] +  params[:peer_id]
    puts request if @debug

    puts request.unpack('b*')

    #| Name Length | Protocol Name | Reserved | Info Hash | Peer ID |

    sock = TCPSocket.new(ip, port)
    sock.print request#write request
    puts 'sock'
    resp =  sock.read(68)
    puts ">> resp: #{resp.to_s}"
    sock.close
  end

  def establish_connection
    server_response = server_request
    bin = server_response['peers'].unpack('B*')[0]
    puts ">> bin: #{bin}" if @debug
    ip, port = binstring_to_ip bin
    return ip, port
  end

  def generate_peer_id
    (0...20).map { (65 + rand(26)).chr }.join
  end

end

def test
  puts 'start'
  client = Client.new
  ip, port = client.establish_connection
  client.handshake(ip, port)
  puts 'end'
end

test


# Working url
# 'http://torrent.fedoraproject.org:6969/announce?info_hash=%d1%1ea%0dQ%0d%ffL%3b%80%7c%f4%f0A%d7%1b%d4%9a%e7%eb&' +
# 'peer_id=-DE13B0-K9I3wyKnA947&compact=1' + 
# '&numwant=0&key=cdfde39a&event=started'))

# 01010100 10011001 11011101 10010010 11001000 11010101

1100100001000010100101100010111000101010111101100100111001001110101001100111011000101110000001000000111001001110111101100010111011110110110001101111011000110110000000000000000000000000000000000000000000000000000000000000000000100110100011001000110010100110011011001000110000001100001001101010110010001100000011000010011001100110011001100010110011000110110011000100011000011100000011001011010000100010101000101000110011001100010000100000110010110100110100101001110010010010110011001110111010011110110100100111011010000010100111000010110011101100