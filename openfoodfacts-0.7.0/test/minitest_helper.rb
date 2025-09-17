$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'openfoodfacts'

require 'minitest/autorun'

require 'webmock/minitest'
require 'vcr'

# Avoid OpenSSL certificate verify failed error
if ENV.has_key?('APPVEYOR') && Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.4')
  require 'openssl'
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end

VCR.configure do |c|
  c.cassette_library_dir = "test/fixtures"
  c.hook_into :webmock
end
