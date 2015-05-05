require 'json'
require 'yaml'
require 'hashie'
require 'vcr'

require 'minitest/autorun'
require 'minitest/reporters'

require 'simplecov' if ENV["COVERAGE"]

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'respoke'

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

TestConfig = if ENV['TRAVIS']
  Hashie::Mash.new(app_id: 'APP_ID', app_secret: 'APP_SECRET', role_id: 'ROLE_ID')
else
  Hashie::Mash.load(File.expand_path('test_config.yml', __dir__))
end

VCR.configure do |config|
  # Due to a bug in VCR faraday middleware we must use webmock. A fix has been
  # merged (https://github.com/vcr/vcr/pull/439) but it does not have a tagged
  # release yet.
  config.hook_into :webmock
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.default_cassette_options = { :record => :once }
  config.filter_sensitive_data('<APP_SECRET>') { TestConfig.app_secret }
end
