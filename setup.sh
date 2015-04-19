#/bin/sh

if [ ! -e ./lita_config.rb ]; then
	cat << _EOF_ > ./lita_config.rb
	Lita.configure do |config|
	  config.robot.log_level = :${LITA_INFO_LEVEL}
	  config.redis[:host] = "${REDIS_HOST}"
	  config.redis[:port] = ${REDIS_PORT}
	  config.robot.adapter = :slack
	  config.adapters.slack.token = "${SLACK_TOKEN}"
	end
_EOF_
fi

if [ ! -e ./Gemfile ]; then
	cat << _EOF_ > ./Gemfile
	source "https://rubygems.org"
	
	gem "lita"
	gem "lita-slack"
_EOF_
fi
