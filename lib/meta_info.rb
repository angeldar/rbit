require_relative './bencoding_decoder'

class MetaInfo

  attr_accessor :data
  attr_reader   :pieces

  def read(filename)
    f = IO.binread(filename)
    decoder = BencodingDecoder.new
    @data = decoder.decode(f)
    @pieces = @data['info']['pieces'].scan(/.{20}/)
  end

  def files
    @data['info']['files'].map {|record| record['path']} if not @data.nil?
  end

  def announce
    @data['announce'] if not @data.nil?
  end

end