require 'airborne'
require 'net/http'

Airborne.configure do |config|
	config.base_url = ENV['BASE_API_URI']
end

module Airborne
	module RestClientRequester
		alias original_make_request make_request

		def make_request(method, url, options = {})
			logger.api "Request #{method.upcase} to #{url}"
			logger.api_d "Request Headers:\n"+options[:headers].to_s if options[:headers]
			logger.api_d "Request Body:\n"+JSON.pretty_generate(options[:body]) if options[:body]

			btime = Time.now.to_f
			response = original_make_request method, url, options
			ftime = Time.now.to_f

			begin
				response_body = JSON.pretty_generate(JSON.parse(response.body, symbolize_names: true))
			rescue
				response_body = response.body
			end

			logger.api "Responsed #{response.code} after #{(ftime-btime).round(2)} seconds"
			logger.api_d "Response body:\n" + response_body if response_body

			response
		end
	end
end
