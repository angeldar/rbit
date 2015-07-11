class BencodingEncoder

	def encode(value)
		case value.class.name
			when 'Fixnum', 'Bignum'
				encode_int value
			when 'String'
				encode_string value
			when 'Array'
				encode_list value
			when 'Hash'
				encode_dict value
			else
				raise "Can't encode value, wrong type."
		end
	end

private

	def encode_int value
		"i#{value}e"
	end

	def encode_string value
		"#{value.length}:#{value}"
	end

	def encode_list list
		res = 'l'
		list.each {|value| res += encode value}
		res + 'e'
	end

	def encode_dict dict
		res = 'd'
		dict.each do |key, value|
			res += encode(key)
			res += encode(value)
		end
		res + 'e'
	end

end