# This will monkey patch puts method to be used as debug
module Kernel
	require 'logging'
	ENV['LOG_LEVEL'] ||= 'api_d'

	Logging.init :'api_d', :api, :pom, :debug, :data, :runner, :warn, :error

	Logging.color_scheme(
		'custom',
		levels: {
			api_d: :yellow,
			api: :yellow,
			pom: :magenta,
			data: :red,
			runner: :green,
			debug: :white,
			warn: [:red, :on_yellow],
			error: [:white, :on_red]
		},
		date: :blue,
		logger: :cyan
	)

	Logging.appenders.stdout(
		'stdout',
		layout: Logging.layouts.pattern(
			pattern: '[%d] %-6l %c: %m\n',
			date_pattern: '%Y-%m-%d %H:%M:%S',
			color_scheme: 'custom'
		)
	)

	def logger()
		@logger ||= Logging.logger[self]
		@logger.level = ENV['LOG_LEVEL'].downcase.to_sym
		@logger.add_appenders 'stdout'
		@logger
	end

	def debug(*args)
		@logger ||= Logging.logger[self]
		@logger.level = ENV['LOG_LEVEL'].downcase.to_sym
		@logger.add_appenders 'stdout'
		@logger.debug args.reduce {|res,arg|res+=" "+arg.inspect.to_s}
	end

	def puts(*args)
		logger.debug args.reduce {|res,arg|res+=" "+arg.inspect.to_s}
		logger.warn "Usage of puts is deprecated. Please use debug or other correct logger methods instead."
	end

	def warn(*args)
		logger.warn args.reduce {|res,arg|res+=" "+arg.inspect.to_s}
	end

	alias original_sleep sleep

	def sleep(duration, reason=nil)
		if reason.nil?
			ignore = [
				"Timeout",
				"Watir::Wait",
				"Selenium::WebDriver::SocketPoller",
				"ChildProcess::Unix::ForkExecProcess"
			].reduce(false) {|result, name| result ? true : name == logger.name }
			logger.warn "Sleeping for #{duration} seconds without a reason." unless ignore
		else
			logger.debug "Sleeping for #{duration} seconds due to: #{reason}"
		end
		original_sleep duration
	end

	def breakpoint()
		if ENV['AVOID_BREAKPOINTS'] == 'true'
			logger.error "Breakpoint ignored. It should never reach CI execution."
		else
			logger.warn "Execution stopped due to breakpoint.\nPress 'ENTER' to continue..."
			STDIN.gets
			logger.runner "Continue executing."
		end
	end
end
