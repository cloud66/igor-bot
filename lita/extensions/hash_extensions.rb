class Hash
	def stringify_keys
		inject({}) do |options, (key, value)|
			options[key.to_s] = value
			options
		end
	end

	def symbolize_keys
		inject({}) do |options, (key, value)|
			options[key.to_s.to_sym] = value
			options
		end
	end
end

