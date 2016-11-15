class Models::RegistrationManager
  TOKEN_LOCATION = "#{APP_ROOT_PATH}/config/.slack-bot-test-auth.json"
  APP_UID = "TEST UID"
  APP_SECRET = "TEST SECRET"

  def set_token_info(code)
    # POST to "https://stage.cloud66.com/oauth/token"
    # with body  {"grant_type"=>"authorization_code", "code"=>"testfucks", "client_id"=>"b5de172cffa26c681954c96adb55fd8d5d7c5298bcc7669e4969241fa92b413f", "client_secret"=>"1d639bc0b2296aebdb7f0737645545ea2506ca8d20d0f9e34d976ba704debf23", :redirect_uri=>"urn:ietf:wg:oauth:2.0:oob"}
    # with response {"access_token"=>"a4765f2c879cab80a7742471465c714ac9be18a41cf4c19eac6c3aae93a40220", "token_type"=>"bearer", "scope"=>"public admin redeploy jobs users"}
    # The actual set_token_info function does `client.auth_code.get_token`, which performs an external oauth code
    # The result of that call is an OAuth2::AccessToken
    # To avoid webmocking an external gem, we just create the access token manually here
    client = OAuth2::Client.new(APP_UID, APP_SECRET, :site => 'https://example.com')
    self.access_token = OAuth2::AccessToken.new(client, code)
    warning = save_token_info(TOKEN_LOCATION)
  end


end