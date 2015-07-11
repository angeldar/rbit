class BencodingDecoder

	def initialize()
		@string = ''
	end

	def decode(string)
		@string = string
		next_element
	end

private
	def decode_int
		encoded_int = @string
		end_idx = encoded_int.index('e')
		@string = @string[end_idx + 1 .. -1]
		encoded_int[1...end_idx].to_i
	end

	def decode_string
		encoded_string = @string
		delimiter_idx = encoded_string.index(':')
		str_len = encoded_string[0...delimiter_idx].to_i
		end_idx = delimiter_idx + str_len
		@string = @string[end_idx + 1 .. -1]
		encoded_string[delimiter_idx + 1 .. end_idx]
	end

	def decode_list
		@string = @string[1..-1]
		res_list = []
		while @string.length > 0 and @string[0] != 'e'
			res_list << next_element
		end
		@string = @string[1..-1] if @string[0] == 'e'
		res_list
	end

	def decode_dict
		@string = @string[1..-1]
		res_dict = {}
		while @string.length > 0 and @string[0] != 'e'
			key = decode_string
			res_dict[key] = next_element
		end
		@string = @string[1..-1] if @string[0] == 'e'
		res_dict
	end

	def determine_type(string)
		case string[0]
			when 'i'
				return :int
			when '0'..'9'
				return :string
			when 'l'
				return :list
			when 'd'
				return :dict
			else
				raise "Can't decode string, wrong format."
		end
	end

	def next_element
		type = determine_type(@string)
		case type
				when :int
					decode_int
				when :string
					decode_string
				when :list
					decode_list
				when :dict
					decode_dict
				else
					raise "Can't decode string, wrong format."
			end
	end

end