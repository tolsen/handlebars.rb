require 'rhino'
require 'multi_json'


module Handlebars

	Rhino::Context.open do |cxt|
		cxt.load(File.expand_path(File.join(File.dirname(__FILE__), '..','js','lib','handlebars.js')))
		@context = cxt
		@handlebars = cxt['Handlebars']
		cxt['alert'] = lambda { |msg, obj| nil }#puts msg; puts obj.inspect }
	end

	class << self
		attr_reader :context
	end

	class CompiledTemplate

		def initialize(context, template)
			@context, @template = context, template
		end

		def call(data)
			json = MultiJson.encode(data)
			@context['template'] = @template
			@context.eval "template(#{json})"
		end

	end


	def compile(template, options=nil)
		Handlebars.module_eval do
			@context['template'] = template
			@context['options'] = options

			CompiledTemplate.new(@context, @context.eval('Handlebars.compile(template, options)'))
		end
	end
	module_function :compile


	def registerHelper(name, fn)
		Handlebars.module_eval do
			@context['name'] = name
			@context['fn'] = fn
			@context.eval('Handlebars.registerHelper(name, fn);')
		end
	end
	module_function :registerHelper

	def registerPartial(name, template)
		Handlebars.module_eval do
			@context['name'] = name
			@context['template'] = template
			@context.eval('Handlebars.registerPartial(name, template);')
		end
	end
	module_function :registerPartial
end
