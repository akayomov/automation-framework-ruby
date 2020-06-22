require_relative '../tools/configuration_parser'
require_relative '../tools/logger'
require_relative '../tools/page_object_model'
require_relative '../tools/api_wrapper'
require_relative '../tools/datagen'
require_relative '../tools/output_formatter'

require 'webdrivers'
require 'watir'
require 'faker'

RSpec.configure do |config|
	config.include ClassFactory, :ui
	config.include Airborne, :api

	# config.seed = # Specify seed to reproduce randomizer
	logger.runner "Running with seed: #{config.seed}"
	Faker::Config.random = Random.new(config.seed)

	config.alias_example_group_to :suite
	config.alias_example_to :test

	config.formatter = RSpec::Output

	config.before :context, :ui do |example|
		Warning[:deprecated] = false
		case ENV['BROWSER_TYPE']
		when 'chrome'
			@browser = Watir::Browser.new :chrome
		else
			raise "Unknown browser type selected"
		end
		
	end

	config.after :example, :ui do |example|
		if example.exception
			path = File.join ENV['RESULTS_PATH'], 'screenshots'
			unless Dir.exists? path
				Dir.mkdir ENV['RESULTS_PATH'] unless Dir.exists? ENV['RESULTS_PATH']
				Dir.mkdir path
			end
			filepath = File.join path, "#{Time.new.strftime "%Y_%m_%d_%H_%M_%S_%L"}_#{example.full_description.gsub(' ','_').downcase}.png"
			@browser.screenshot.save filepath
		end
	end

	config.after(:context, :ui) { @browser.close }

	config.after(:context) { DataGen.do_cleanup :suite }
	config.after(:example) { DataGen.do_cleanup :test }
end
