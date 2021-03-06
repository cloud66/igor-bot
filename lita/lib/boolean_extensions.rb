class TrueClass
	def to_bool
		return self
	end
end

class FalseClass
	def to_bool
		return self
	end
end

class String
	def to_bool
		return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
		return false if self == false || self.blank? || self =~ (/(false|f|no|n|0)$/i)
		raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
	end
end