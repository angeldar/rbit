require_relative '../lib/bencoding_decoder'
require_relative '../lib/bencoding_encoder'
require_relative '../lib/meta_info'
require_relative '../lib/client'

RSpec.configure do |config|
	# Use color in STDOUT
	config.color = true

	# Use color not only in STDOUT but also in pagers and files
	config.tty = true

	# Use the specified formatter
	config.formatter = :documentation
end