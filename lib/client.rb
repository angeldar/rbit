require 'net/http'
require_relative 'meta_info'

class Client

  def initialize
    meta = MetaInfo.new
    meta.read 'test4.torrent'
    @announce_url = meta.announce
    @info_hash  = meta.pieces[0]
    @peer_id    = generate_peer_id
    @port       = 6889
    @uploaded   = 0
    @downloaded = 0
    @left       = 2000
  end

  def request
    uri = create_request
    puts ">> uri: #{uri}"
    res = Net::HTTP.get_response(uri)
    puts res.body #if res.is_a?(Net::HTTPSuccess)
  end

  def create_request
    uri = URI(@announce_url)
    params = {
      :info_hash => @info_hash,
      :peer_id   => 'QJIPIQFOOBUZCSJKMOVP',
      # :port      => @port,
      :uploaded  => @uploaded,
      :downloaded => @downloaded,
      :left     => 10000000,
      # :event    => 'started'
      :compact => 0
    }
    uri.query = URI.encode_www_form(params)
    uri
  end

  def generate_peer_id
    (0...20).map { (65 + rand(26)).chr }.join
  end

end

def test
  client = Client.new
  client.request
end

# test

#'/announce?info_hash=%fc%8a%15%a2%fa%f2sM%bb%1d%c5%f7%af%dc%5c%9b%ea%eb%1fY&peer_id=-DE13B0-(aiepaQEcBw-&port=64381&uploaded=0&downloaded=0&left=1150844928&corrupt=0&redundant=0&compact=1&numwant=200&key=b05d376a&no_peer_id=1&supportcrypto=1&event=started'