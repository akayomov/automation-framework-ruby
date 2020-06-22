module DataGen
	def self.new(entity, init_obj={})
		require File.join(__dir__,'..','entities',entity.to_s+'.rb')

		@entities ||= {}
		@entities[entity] ||= []

		@entities[entity].push eval("#{entity.capitalize}Entity.new(init_obj)")
		@entities[entity].last
	end

	def self.use(entity)
		@entities[entity].last
	end

	def self.mark(type, context, entity=nil)
		@cleanup ||= {}
		@cleanup[context] ||= {}
		@cleanup[context][type] ||= []

		entity = @entities[type].last if entity.nil?
		@cleanup[context][type].push entity
	end

	def self.do_cleanup(context)
		@cleanup ||= {}
		@cleanup[context] ||= {}
		@cleanup[context].keys.each do |entity|
			@cleanup[context][entity] ||= []
			@cleanup[context][entity].each {|item|item.cleanup}
		end
	end
end

class Entity < Hash
	require 'airborne'
	require 'faker'
	include Airborne

	def initialize(init_object = {})
		super
		self.merge! init_object
	end
end
