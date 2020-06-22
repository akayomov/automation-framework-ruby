# This tool allows to use pageobjects without instantiating them directly
# so "on PageObjectName do |page|" instead of "page = PageObjectName.new(@browser)"
class BasePage
	def initialize(browser, additional={})
		@browser = browser
		@additional = additional
	end
	
	def open
		full_url = ENV['BASE_PAGE']
		full_url += @additional[:url] unless @additional[:url].nil?
		@browser.goto full_url

		self.wait_for_load if self.methods.include? :wait_for_load

		return self
	end

	def self.printout(methods)
		methods.push :open unless methods.include?(:open)
		methods.each do |name|
			m = instance_method(name)
			define_method(name) do |*args, &block|
				arguments = args.reduce{|res,item|res.to_s+" "+item.to_s}
				arguments = "(#{arguments})" if arguments
				logger.pom "#{name} #{arguments}"
				m.bind(self).(*args, &block)
			end
		end
	end
end

Dir[File.join(__dir__, '..', 'pages', '**', '*.rb')].each { |file| require file }

module ClassFactory
	def on (used_class, additions={}, &block)
		used_class = used_class.split('::').inject(object) {|m,c|m.const_get(c)} if used_class.is_a? String
		instance = used_class.new(@browser, additions)
		block.call instance if block
		instance
	end
end
