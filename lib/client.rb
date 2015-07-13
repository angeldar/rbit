require 'net/http'
require 'CGI'
require_relative 'meta_info'

class Client

  def initialize
    meta = MetaInfo.new
    meta.read 'test.torrent'
    @announce_url = URI.encode meta.announce
    @info_hash  = '%' + meta.info_hash.scan(/.{2}|.+/).join('%')
    @peer_id    = generate_peer_id
    @port       = 6889
    @uploaded   = 0
    @downloaded = 0
    @left       = 2000
  end

  def request
    uri = create_request
    puts ">> uri: #{uri}"

    # res = Net::HTTP.get(URI.parse(
      # 'http://torrent.fedoraproject.org:6969/announce?info_hash=%d1%1ea%0dQ%0d%ffL%3b%80%7c%f4%f0A%d7%1b%d4%9a%e7%eb&' +
      # 'peer_id=-DE13B0-K9I3wyKnA947&compact=1' + 
      # '&numwant=0&key=cdfde39a&event=started'))


    # puts res

    res = Net::HTTP.get_response(uri)
    puts res.body #if res.is_a?(Net::HTTPSuccess)
  end

  def create_request
    uri = URI(@announce_url)
    params = {
      :info_hash => @info_hash,
      :peer_id   => '-DE13B0-K9I3wyKnA947',
      # :uploaded  => @uploaded,
      # :downloaded => @downloaded,
      # :left     => 180879515,
      :compact => '1',
      :numwant => '20',
      # :event   => 'started',
    }
    uri.query = params.map{|k, v| [k.to_s, "=", v.to_s]}.map(&:join).join('&')#URI.encode_www_form(params)
    uri
  end

  def generate_peer_id
    (0...20).map { (65 + rand(26)).chr }.join
  end

end

def test
  puts 'start'
  client = Client.new
  client.request
  puts 'end'
end

test

# d11e610d510dff4c3b807cf4f041d71bd49ae7eb
# http://torrent.fedoraproject.org:6969/announce?info_hash=%d1%1ea%0dQ%0d%ffL%3b%80%7c%f4%f0A%d7%1b%d4%9a%e7%eb&peer_id=-DE13B0-K9I3wyKnA947&port=51824&uploaded=0&downloaded=1107738&left=1808795152&corrupt=0&redundant=0&compact=1&numwant=0&key=cdfde39a&no_peer_id=1&supportcrypto=1&event=stopped
#'/announce?info_hash=%fc%8a%15%a2%fa%f2sM%bb%1d%c5%f7%af%dc%5c%9b%ea%eb%1fY&peer_id=-DE13B0-(aiepaQEcBw-&port=64381&uploaded=0&downloaded=0&left=1150844928&corrupt=0&redundant=0&compact=1&numwant=200&key=b05d376a&no_peer_id=1&supportcrypto=1&event=started'