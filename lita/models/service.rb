class Service
	attr_accessor :name

	def initialize(service_hash)
		@name = service_hash['name']
	end
end
