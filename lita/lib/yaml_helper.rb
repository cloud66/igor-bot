require 'yaml'
class YamlHelper

	def self.safe_load_file(path)
		#read in the contents
		file_contents = IO.read(path)
		self.safe_load(file_contents, path)
	end

	def self.safe_load(text, path = '')
		#define regex for anything "[space]!" Note: "!!" is allowed as these are simple types
		custom_data_type_regex = /\s+![^!]/
		#do the contents contain any custom datatypes
		if text =~ custom_data_type_regex
			if path.blank?
				raise 'This YAML will not be loaded. This is due to the presence of custom data types in the file (which are banned due to YAML parsing vulnerabilities)'
			else
				raise "The file: \"#{path}\" will not be loaded. This is due to the presence of custom data types in the file (which are banned due to YAML parsing vulnerabilities)"
			end
		end

		begin
			YAML.load(text)
		rescue Psych::SyntaxError => syn_exc
			raise "Error during parsing '#{File.basename(path)}' due to '#{syn_exc.message}'"
		rescue => exc
			raise "Error during parsing '#{File.basename(path)}' due to '#{exc}'"
		rescue Object => obj_exc
			#catch non-StandardErrors
			raise "Error during parsing YAML file '#{File.basename(path)}'"
		end
	end
end