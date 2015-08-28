require 'spec_helper'

describe MetaInfo do
  
  let(:meta) { MetaInfo.new }
  subject { meta }

  it 'should read .torrent file' do
    meta.read File.join(File.dirname(__FILE__), './files/test.torrent')
  end

  it 'should return file list' do
    meta.read File.join(File.dirname(__FILE__), './files/test.torrent')
    expect(meta.files).to eq([['Fedora-Live-Design_suite-x86_64-22-3.iso'],
      ['Fedora-Spins-x86_64-22-CHECKSUM']])  
  end

  it 'should return announce' do
    meta.read File.join(File.dirname(__FILE__), './files/test.torrent')
    expect(meta.announce).to eq('http://torrent.fedoraproject.org:6969/announce')
  end

  it 'shoule return pieces' do
    meta.read File.join(File.dirname(__FILE__), './files/test.torrent')
    expect(meta.pieces.length).to     eq(6623)
    expect(meta.pieces[0].length).to  eq(20)
    expect(meta.pieces[-1].length).to eq(20)
  end

  # In program info_hash is used instead of info_hash_hex, wich is used for testing.
  it 'should return info_hash_hex' do
    meta.read File.join(File.dirname(__FILE__), './files/test.torrent')
    expect(meta.info_hash_hex).to eq('d11e610d510dff4c3b807cf4f041d71bd49ae7eb')
  end

  # it 'should print keys' do
  #   meta.read File.join(File.dirname(__FILE__), './files/test.torrent')
  #   puts "\n\n>> keys:"
  #   puts meta.data.keys
  # end

end