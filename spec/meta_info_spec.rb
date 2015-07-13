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

  it 'should print keys' do
    meta.read File.join(File.dirname(__FILE__), './files/test.torrent')
    puts "\n\n>> keys:"
    puts meta.data.keys
  end

end