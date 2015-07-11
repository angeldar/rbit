require 'spec_helper'

describe BencodingEncoder do

	let(:encoder) {BencodingEncoder.new}
	subject { encoder }

	it 'should encode int' do
		expect(encoder.encode 123).to eq('i123e')
	end

	it 'should encode negative int' do
		expect(encoder.encode -1734).to eq('i-1734e')
	end

	it 'should encode string' do
		expect(encoder.encode 'HouseOfCards').to eq('12:HouseOfCards')
	end

	it 'should encode empty string' do
		expect(encoder.encode '').to eq('0:')
	end

	it 'should encode list' do
		expect(encoder.encode [123, 'test']).to eq('li123e4:teste')
	end

	it 'should encode list with inner list' do
		expect(encoder.encode [123, 'test', [456, 'cat'], 42]).to eq('li123e4:testli456e3:catei42ee')
	end

	it 'should encode dict' do
		expect(encoder.encode ({'cow' => 'moo', 'spam' => 'eggs'})).to eq('d3:cow3:moo4:spam4:eggse')
	end

	it 'should encode dict' do
		expect(encoder.encode ({'publisher' => 'bob', 'publisher-webpage' => 'www.example.com', 'publisher.location' => 'home'})).
			to eq('d9:publisher3:bob17:publisher-webpage15:www.example.com18:publisher.location4:homee')
	end

	it 'should encode empty dict' do
	 expect(encoder.encode ({})).to eq('de')
	end

	it 'should encode dict with inner dict' do
		expect(encoder.encode ({'test' => {'dog' => 'wow'}})).to eq('d4:testd3:dog3:wowee')
	end

	it 'should encode dict with inner list' do
		 expect(encoder.encode ({'spam' => ['a', 'b']})).to eq('d4:spaml1:a1:bee')
	end

	it 'should encode list with inner dict' do
		expect(encoder.encode [{'cow' => 'moo', 'spam' => 'eggs'}, 42]).to eq('ld3:cow3:moo4:spam4:eggsei42ee')
	end

end