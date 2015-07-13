require 'digest/sha1'
require_relative './bencoding_decoder'
require_relative './bencoding_encoder'

class MetaInfo

  attr_accessor :data
  attr_reader   :pieces

  def initialize
    @decoder = BencodingDecoder.new
    @encoder = BencodingEncoder.new
  end

  def read(filename)
    file = IO.binread(filename)
    @data = @decoder.decode(file)
    @pieces = @data['info']['pieces'].scan(/.{20}/)
  end

  def files
    @data['info']['files'].map {|record| record['path']} if not @data.nil?
  end

  def announce
    @data['announce'] if not @data.nil?
  end

  def info_hash
    Digest::SHA1.hexdigest(@encoder.encode @data['info']) 
  end

end