# Tool provides a posibility to store running configuration within a single file

require 'dotenv'
# Loads from: System Env Variables, then from: local.env, then from: ci.env 
Dotenv.load 'local.env', 'ci.env'

# Overloading missing needs with defaults
ENV['BROWSER_TYPE'] ||= "chrome" # we definitelly need to run some browser

ENV['RESULTS_PATH'] ||= File.join __dir__, '..', 'results'

Dotenv.require_keys 'RESULTS_PATH', 'BROWSER_TYPE', 'BASE_PAGE', 'BASE_API_URI'
