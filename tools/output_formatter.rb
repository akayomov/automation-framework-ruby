module RSpec
	class Output
		require 'rspec/core/formatters/console_codes'
		ENV['LOG_BACKTRACE'] ||= 'short' # short|extended

		RSpec::Core::Formatters.register self, 
			:example_started, :example_passed, :example_failed, 
			:example_pending, :dump_pending, :dump_failures, :dump_summary

		def initialize output
			@backtracer = RSpec::Core::BacktraceFormatter.new
			@backtracer.filter_gem 'watir' if ENV['LOG_BACKTRACE'] == 'short'
			@backtracer.filter_gem 'page-object' if ENV['LOG_BACKTRACE'] == 'short'
			@backtracer.filter_gem 'selenium-webdriver' if ENV['LOG_BACKTRACE'] == 'short'
			@backtracer.filter_gem 'airborne' if ENV['LOG_BACKTRACE'] == 'short'
		end

		def example_started notification
			start_string = notification.example.id+ ": " + notification.example.full_description + "."
			logger.runner start_string
		end

		def example_passed notification
			logger.runner colored(colored("Status: ", :default), :bold)+colored(colored("PASSED", :success), :bold)
		end

		def example_failed notification
			if notification.example.metadata[:pending]
				logger.runner colored(colored("Status: ", :default), :bold)+colored(colored("FIXED", :fixed), :bold)
			else
				logger.runner colored(colored("Status: ", :default), :bold)+colored(colored("FAILED", :failure), :bold)
			end
		end

		def example_pending notification
			logger.runner colored(colored("Status: ", :default), :bold)+colored(colored("PENDING", :pending), :bold)
		end

		def dump_pending notification
			unless notification.pending_examples.empty?
				pendings = notification.pending_examples.map do |example|
					pend_output = "\n"
					pend_output += " "*4+colored("[ #{example.location} ]", :pending)+"\n"
					pend_output += " "*4+colored(colored(example.full_description, :pending), :bold)+"\n"
					pend_output += " "*6+ colored(example.execution_result.pending_message, :bold)+"\n"
					pend_output
				end
				logger.runner colored(colored("PENDINGS:", :pending), :bold) + pendings.join("")
			end
		end

		def dump_failures notification # ExamplesNotification
			failed_examples = notification.failed_examples.select {|example| !example.metadata[:pending]}
			fixed_examples = notification.failed_examples.select {|example| example.metadata[:pending]}

			unless fixed_examples.empty?
				fixes = fixed_examples.map do |example|
					fix_output = "\n"
					fix_output += " "*4+colored("[ #{example.location} ]", :fixed)+"\n"
					fix_output += " "*4+colored(colored(example.full_description, :fixed), :bold)+"\n"
					fix_output
				end
				logger.runner colored(colored("FIXES:", :fixed), :bold) + fixes.join("")
			end

			unless failed_examples.empty?
				fails = failed_examples.map do |example|
					fail_output = "\n"
					fail_output += " "*4+colored("[ #{example.location} ]", :failure)+"\n"
					fail_output += " "*4+colored(colored(example.full_description, :failure), :bold)+"\n"

					fail_output += example.execution_result.exception.message.split("\n").map { |line| " "*6+line.strip }.join("\n")+"\n"

					backtrace = @backtracer.format_backtrace(example.execution_result.exception.backtrace)
					fail_output += "\n"+backtrace.map { |line| " "*4+colored(line, :bold) }.join("\n")+"\n"+"-"*40
					fail_output
				end
				logger.runner colored(colored("FAILURES:", :failure), :bold) + fails.join("")
			end
		end

		def dump_summary notification
			logger.runner colored("Finished in ", :default)+
				colored(colored("#{RSpec::Core::Formatters::Helpers.format_duration(notification.duration)}.", :default), :bold)

			summary_string = ""
			passed_count = notification.examples.count - notification.failed_examples.count - notification.pending_examples.count
			summary_string +=colored("Passed:"+colored(passed_count.to_s, :bold), :success)+" "
			failed_count = notification.failed_examples.select{|example| !example.metadata[:pending]}.count
			summary_string +=colored("Failed:"+colored(failed_count.to_s, :bold), :failure)+" "
			pending_count = notification.pending_examples.count
			summary_string +=colored("Pending:"+colored(pending_count.to_s, :bold), :pending)+" " if pending_count > 0
			fixed_count = notification.failed_examples.select{|example| example.metadata[:pending]}.count
			summary_string +=colored("Fixed:"+colored(fixed_count.to_s, :bold), :fixed) if fixed_count > 0
			logger.runner summary_string
		end

		private

		def colored string, symbol
			RSpec::Core::Formatters::ConsoleCodes.wrap(string, symbol)
		end
	end
end
