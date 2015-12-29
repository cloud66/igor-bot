require 'singleton'
require 'json'
require 'fileutils'

module Models
	class RegistrationManager
		include ::Singleton
		attr_accessor :access_token,
					  :refresh_token,
					  :expiry,
					  :extra

		TOKEN_STORAGE = '/etc/cloud66/c66_slack_bot.json'
		APP_UID = 'ab35a76976dfe9eadfd27d244e7e53793c0391ec0734012f0a520d85d3e5dc64'
		APP_SECRET = 'a5b9ee72d0fceb9c1091e995f867d80e9abf28c164621569a8f3d704e8b5905c'
		AUTH_URL = 'https://app.cloud66.com/oauth/authorize?client_id=72677fe32373ec3351a64424a5129718fc9d06715cdbc8af16f5a412713e3b5c&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code'


		def initialize
			load_token_info(TOKEN_STORAGE)
		end

		def is_registered?
			return !self.access_token.nil?
		end

		def set_token_info(access_token:)
			token_hash = { access_token: access_token,
						   refresh_token: nil,
						   expiry: nil,
						   extra: nil }
			set_local_tokens(token_hash)
			errors = save_token_info(TOKEN_STORAGE)
			return errors.nil? ? nil : "Warning: Persisting your token to disk failed due to: #{errors}"
		end

		def delete_token_info
			set_local_tokens({})
			save_token_info(TOKEN_STORAGE)
		end

		private

		def load_token_info(token_storage)
			if File.exist?(token_storage)
				token_hash = JSON.parse(File.read(token_storage))
				set_local_tokens(token_hash)
			end
		end

		def save_token_info(token_storage)
			FileUtils.mkdir_p(File.dirname(token_storage))
			File.open(token_storage, 'w') do |f|
				token_hash = { access_token: self.access_token,
							   refresh_token: self.refresh_token,
							   expiry: self.expiry,
							   extra: self.extra }
				f.write(token_hash.to_json)
			end
			return nil
		rescue => exc
			return exc.message
		end

		def set_local_tokens(token_hash)
			token_hash = token_hash.symbolize_keys
			self.access_token = token_hash[:access_token]
			self.refresh_token = token_hash[:refresh_token]
			self.expiry = token_hash[:expiry]
			self.extra = token_hash[:extra]
		end
	end
end