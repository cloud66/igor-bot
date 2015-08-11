Lita.configure do |config|
  config.robot.log_level = :${LITA_INFO_LEVEL}
  config.redis[:host] = "${REDIS_HOST}"
  config.redis[:port] = ${REDIS_PORT}
  config.robot.adapter = :slack
  config.adapters.slack.token = "${SLACK_TOKEN}"
end
