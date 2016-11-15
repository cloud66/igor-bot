require 'spec_helper'

describe Lita::Handlers::Registrar, lita_handler: true, additional_lita_handlers: [Lita::Handlers::AbstractHandler] do

  #SUCCCESSFULL COMMANDS
  it "test to make sure we are unregistered before continuing" do
    send_command("deregister")
  end

  it "send command without being resgistered" do
    send_command("deregister")
    expect(replies).to eq([{:title=>"Not Authorized!", :text=>"To authorize this Cloud 66 Slack-Bot\n\n1) Get your access token from https://stage.cloud66.com/oauth/authorize?client_id=TEST+UID&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&scope=public+admin+redeploy+jobs+users\n2) Run: Lita register --code <access token>", :color=>:warning, :fallback=>"Authorization required!", :mrkdwn_in=>["text"], :pretext=>nil}])
  end

  it "send command to register" do
    send_command("register -c mytesttoken")
    expect(replies).to eq([{:title=>"Authorisation Saved!", :text=>"Authorization saved for this Cloud 66 Slack-Bot", :color=>:good, :fallback=>"Authorization saved for this Cloud 66 Slack-Bot", :mrkdwn_in=>["text"], :pretext=>nil}])
    file_contents = JSON.parse(File.read(Models::RegistrationManager::TOKEN_LOCATION))
    expect(file_contents).to eq({"local_token" => "mytesttoken"})
  end

  it "send command to unregister" do
    send_command("deregister")
    expect(replies).to eq([{:title=>"Authorisation Removed!", :text=>"Authorization removed for this Cloud 66 Slack-Bot", :color=>:good, :fallback=>"Authorization removed for this Cloud 66 Slack-Bot", :mrkdwn_in=>["text"], :pretext=>nil}])
    Models::RegistrationManager.instance.delete_token_info
    expect(File.exists?(Models::RegistrationManager::TOKEN_LOCATION)).to be(false)
  end

  it "send command to register" do
    send_command("register -c mytesttoken")
    expect(replies).to eq([{:title=>"Authorisation Saved!", :text=>"Authorization saved for this Cloud 66 Slack-Bot", :color=>:good, :fallback=>"Authorization saved for this Cloud 66 Slack-Bot", :mrkdwn_in=>["text"], :pretext=>nil}])
    file_contents = JSON.parse(File.read(Models::RegistrationManager::TOKEN_LOCATION))
    expect(file_contents).to eq({"local_token" => "mytesttoken"})
  end
end
