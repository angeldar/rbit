require 'spec_helper'

describe BencodingDecoder do
	
	let(:decoder) {BencodingDecoder.new}
	subject { decoder }

	it 'should decode int' do
		expect(decoder.decode 'i123e').to eq(123)
	end

	it 'should decode negative int' do
		expect(decoder.decode 'i-1734e').to eq(-1734)
	end

	it 'should decode string' do
		expect(decoder.decode '4:spam').to eq('spam')
	end

	it 'should decode long string' do
		expect(decoder.decode '12:HouseOfCards').to eq('HouseOfCards')
	end

	it 'should decode empty string' do
		expect(decoder.decode '0:').to eq('')
	end

	it 'should decode list' do
		expect(decoder.decode 'li123e4:teste').to eq([123, 'test'])
	end

	it 'should decode list with inner list' do
		expect(decoder.decode 'li123e4:testli456e3:catei42ee').to eq([123, 'test', [456, 'cat'], 42])
	end

	it 'should decode dict' do
		expect(decoder.decode 'd3:cow3:moo4:spam4:eggse').to eq({'cow' => 'moo', 'spam' => 'eggs'})
	end

	it 'should decode dict' do
		expect(decoder.decode 'd9:publisher3:bob17:publisher-webpage15:www.example.com18:publisher.location4:homee').
			to eq({'publisher' => 'bob', 'publisher-webpage' => 'www.example.com', 'publisher.location' => 'home'})
	end

	it 'should decode empty dict' do
	 expect(decoder.decode 'de').to eq({})
	end

	it 'should decode dict with inner dict' do
		expect(decoder.decode 'd4:testd3:dog3:wowee').to eq({'test' => {'dog' => 'wow'}})
	end

	it 'should decode dict with inner list' do
		 expect(decoder.decode 'd4:spaml1:a1:bee').to eq({'spam' => ['a', 'b']})
	end

	it 'should decode list with inner dict' do
		expect(decoder.decode 'ld3:cow3:moo4:spam4:eggsei42ee').to eq([{'cow' => 'moo', 'spam' => 'eggs'}, 42])
	end

	it 'should determine int' do
		expect(decoder.send(:determine_type, 'i123e')).to eq(:int)
	end

	it 'should determine string' do
		expect(decoder.send(:determine_type, '4:test')).to eq(:string)
	end

	it 'should determine list' do
		expect(decoder.send(:determine_type, 'li123e4:teste')).to eq(:list)
	end

	it 'should determine dict' do
		expect(decoder.send(:determine_type, 'd3:cow3:moo4:spam4:eggse')).to eq(:dict)
	end

end