require_relative '../spec_helper.rb'

# class Models::RegistrationManager
#   def is_registered?
#     return true
#   end
# end

@@stack_started_redeploy_queued_state = STACK_STARTED_REDEPLOY_QUEUED_FALSE

describe Lita::Handlers::Deployer, lita_handler: true, additional_lita_handlers: Lita::Handlers::AbstractHandler do

  #DEPLOY COMMANDS
  it "order to deploy a stack without option" do
    send_command("deploy")
    expect(replies).to eq([{:title=>nil, :text=>"*Usage:* _deploy <options>_\n  -s, --stack=<s>          Stack name\n  -e, --environment=<s>    Environment\n  -v, --services=<s>       Services (multiple allowed)\n  -w, --wait               Wait for the stack to become available (if it is\n                           busy)\n  -h, --help               Show this message\n", :color=>:warning, :fallback=>"*Usage:* _deploy <options>_\n  -s, --stack=<s>          Stack name\n  -e, --environment=<s>    Environment\n  -v, --services=<s>       Services (multiple allowed)\n  -w, --wait               Wait for the stack to become available (if it is\n                           busy)\n  -h, --help               Show this message\n", :mrkdwn_in=>["text"], :pretext=>nil}])
  end

  it "order to display help for deploy" do
    send_command("deploy -h")
    expect(replies.first[:title]).to match(/Help for deploy/)
  end

  it "order to deploy an existing stack with command 'deploy'" do
    stack_name = "pm-good_stack-drupal"
    send_command("deploy -s #{stack_name}")
    expect(replies).to eq([{:title=>nil, :text=>get_text_message(stack_name, :deploy_started), :color=>"#0000ff", :fallback=>get_text_message(stack_name, :deploy_started), :mrkdwn_in=>["text"], :pretext=>nil}, {:title=>nil, :text=>get_text_message(stack_name, :deploy_complete), :color=>:danger, :fallback=>get_text_message(stack_name, :deploy_complete), :mrkdwn_in=>["text"], :pretext=>nil}])
  end

  it "order to deploy an existing stack with command 'deploy' wrong environment" do
    stack_name = "pm-good_stack-drupal"
    send_command("deploy -s #{stack_name} -e staging")
    expect(replies).to eq([{:title=>"No matching stacks", :text=>nil, :color=>:danger, :fallback=>"No matching stacks", :mrkdwn_in=>["text"], :pretext=>nil}])
  end


  it "order to deploy an existing busy stack with command 'deploy'" do
    stack_name = "busy_to_good_forever_stack_wait_loop"
    send_command("deploy -s #{stack_name}")
    expect(replies).to eq([{:title=>nil, :text=>"*busy_to_good_forever_stack_wait_loop* - busy (_Cloud 66_ checkup); Queued for later deploy", :color=>:good, :fallback=>"*busy_to_good_forever_stack_wait_loop* - busy (_Cloud 66_ checkup); Queued for later deploy", :mrkdwn_in=>["text"], :pretext=>nil}, {:title=>nil, :text=>"*busy_to_good_forever_stack_wait_loop* - deploy started", :color=>"#0000ff", :fallback=>"*busy_to_good_forever_stack_wait_loop* - deploy started", :mrkdwn_in=>["text"], :pretext=>nil}, {:title=>nil, :text=>"*good_to_good_forever_stack* - deploy complete", :color=>:danger, :fallback=>"*good_to_good_forever_stack* - deploy complete", :mrkdwn_in=>["text"], :pretext=>nil}])
  end

  it "order to deploy an existing busy stack with command 'deploy'" do
    stack_name = "busy_to_good_forever_stack_wait_loop -w"
    send_command("deploy -s #{stack_name}")
    expect(replies).to eq([{:title=>nil, :text=>"*busy_to_good_forever_stack_wait_loop* - busy (_Cloud 66_ checkup); Exiting", :color=>:warning, :fallback=>"*busy_to_good_forever_stack_wait_loop* - busy (_Cloud 66_ checkup); Exiting", :mrkdwn_in=>["text"], :pretext=>nil}])
  end

  it "order to deploy an existing stack with a non existant service" do
    send_command("deploy -s pm-good_stack-drupal -v randomservice")
    expect(replies).to eq([{:title=>nil, :text=>"*pm-good_stack-drupal (_randomservice_)* -  services not found", :color=>:danger, :fallback=>"*pm-good_stack-drupal (_randomservice_)* -  services not found", :mrkdwn_in=>["text"], :pretext=>nil}])
  end

  it "order to deploy an existing stack with a non existant service" do
    send_command("deploy -s pm-good_stack-drupal -v ubuntu")
    expect(replies).to eq([{:title=>nil, :text=>"*pm-good_stack-drupal (_ubuntu_)* -  deploy started", :color=>"#0000ff", :fallback=>"*pm-good_stack-drupal (_ubuntu_)* -  deploy started", :mrkdwn_in=>["text"], :pretext=>nil}, {:title=>nil, :text=>"*pm-good_stack-drupal (_ubuntu_)* -  deploy complete", :color=>:danger, :fallback=>"*pm-good_stack-drupal (_ubuntu_)* -  deploy complete", :mrkdwn_in=>["text"], :pretext=>nil}])
  end

  it "order to deploy an existing stack with command 'redeploy'" do
    stack_name = "pm-good_stack-drupal"
    send_command("redeploy -s pm-good_stack-drupal")
    expect(replies).to eq([{:title=>nil, :text=>get_text_message(stack_name, :deploy_started), :color=>"#0000ff", :fallback=>get_text_message(stack_name, :deploy_started), :mrkdwn_in=>["text"], :pretext=>nil}, {:title=>nil, :text=>get_text_message(stack_name, :deploy_complete), :color=>:danger, :fallback=>"*pm-good_stack-drupal* - deploy complete", :mrkdwn_in=>["text"], :pretext=>nil}])
  end

  it "order to deploy a non existing stack" do
    send_command("deploy -s pm-nonexistant-drupal")
    expect(replies).to eq([{:title=>get_text_message("",:no_matching_stacks), :text=>nil, :color=>:danger, :fallback=>get_text_message("",:no_matching_stacks), :mrkdwn_in=>["text"], :pretext=>nil}])
  end


  it "order to deploy a non busy stack with command 'deploy'" do
    send_command("deploy -s pm-good_stack-drupal")
    expect(replies).to eq([{:title=>nil, :text=>"*pm-good_stack-drupal* - deploy started", :color=>"#0000ff", :fallback=>"*pm-good_stack-drupal* - deploy started", :mrkdwn_in=>["text"], :pretext=>nil}, {:title=>nil, :text=>"*pm-good_stack-drupal* - deploy complete", :color=>:danger, :fallback=>"*pm-good_stack-drupal* - deploy complete", :mrkdwn_in=>["text"], :pretext=>nil}])
  end

  it "order to deploy a stack when environment is redeploying" do
    @@stack_started_redeploy_queued_state = STACK_STARTED_REDEPLOY_QUEUED_TRUE
    send_command("deploy -s pm-good_stack-drupal")
    expect(replies).to eq([{:title=>nil, :text=>"*pm-good_stack-drupal* - deploy was enqueued at Cloud 66 (as another deploy had just started); unable to track status", :color=>:warning, :fallback=>"*pm-good_stack-drupal* - deploy was enqueued at Cloud 66 (as another deploy had just started); unable to track status", :mrkdwn_in=>["text"], :pretext=>nil}])
    @@stack_started_redeploy_queued_state = STACK_STARTED_REDEPLOY_QUEUED_FALSE # Set back to normal for the rest of the tests
  end


  #CANCEL COMMANDS
  it "order to cancel a non active stack (status  = :none)" do
    send_command("cancel -s pm-good_stack-drupal")
    expect(replies).to eq([{:title=>nil, :text=>"*pm-good_stack-drupal* - not currently queued", :color=>:good, :fallback=>"*pm-good_stack-drupal* - not currently queued", :mrkdwn_in=>["text"], :pretext=>nil}])
  end

  it "order to cancel stack which is queued (means able to being cancel" do
    stack = Stack.new(GOOD_STACK)
    stack.set_local_status(Lita::Handlers::Deployer::REDIS_PREFIX, Lita::Handlers::Deployer::WAIT_TIMEOUT, :queued)
    send_command("cancel -s pm-good_stack-drupal")
    expect(replies).to eq([{:title=>nil, :text=>"*pm-good_stack-drupal* - trying to cancel deployment", :color=>"#0000ff", :fallback=>"*pm-good_stack-drupal* - trying to cancel deployment", :mrkdwn_in=>["text"], :pretext=>nil}])
  end

  it "order to cancel stack which is deploying (means unable to being cancel" do
    stack = Stack.new(GOOD_STACK)
    stack.set_local_status(Lita::Handlers::Deployer::REDIS_PREFIX, Lita::Handlers::Deployer::WAIT_TIMEOUT, :deploying)
    send_command("cancel -s pm-good_stack-drupal")
    expect(replies).to eq([{:title=>nil, :text=>"*pm-good_stack-drupal* - stack already started deploying", :color=>:warning, :fallback=>"*pm-good_stack-drupal* - stack already started deploying", :mrkdwn_in=>["text"], :pretext=>nil}])
  end

  it "order to cancel stack which is already cancelling" do
    stack = Stack.new(GOOD_STACK)
    stack.set_local_status(Lita::Handlers::Deployer::REDIS_PREFIX, Lita::Handlers::Deployer::WAIT_TIMEOUT, :cancelling)
    send_command("cancel -s pm-good_stack-drupal")
    expect(replies).to eq([{:title=>nil, :text=>"*pm-good_stack-drupal* - still being cancelled (please wait)", :color=>:warning, :fallback=>"*pm-good_stack-drupal* - still being cancelled (please wait)", :mrkdwn_in=>["text"], :pretext=>nil}])
  end

  it "order to deploy stack which has been cancelled" do
    stack = Stack.new(GOOD_STACK)
    stack.set_local_status(Lita::Handlers::Deployer::REDIS_PREFIX, Lita::Handlers::Deployer::WAIT_TIMEOUT, :none)
    send_command("deploy -s busy_to_good_forever_stack_set_local_status_to_cancelling_busy")
    expect(replies).to eq([{:title=>nil, :text=>"*busy_to_good_forever_stack_set_local_status_to_cancelling_busy* - busy (_Cloud 66_ checkup); Queued for later deploy", :color=>:good, :fallback=>"*busy_to_good_forever_stack_set_local_status_to_cancelling_busy* - busy (_Cloud 66_ checkup); Queued for later deploy", :mrkdwn_in=>["text"], :pretext=>nil}, {:title=>nil, :text=>"*busy_to_good_forever_stack_set_local_status_to_cancelling_busy* - deploy cancelled", :color=>:good, :fallback=>"*busy_to_good_forever_stack_set_local_status_to_cancelling_busy* - deploy cancelled", :mrkdwn_in=>["text"], :pretext=>nil}])
  end
end

#The fallbacks should not contain any markup
def get_text_message(stack_name, type)
  case type
    when :deploy_started
      return "*#{stack_name}* - deploy started"
    when :deploy_complete
      return "*#{stack_name}* - deploy complete"
    when :no_matching_stacks
      return "No matching stacks"
    when :deploy_started_fallback
      return "#{stack_name} - deploy started"
    when :deploy_complete_fallback
      return "#{stack_name} - deploy complete"
  end
end
