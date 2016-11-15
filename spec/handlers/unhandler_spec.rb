require 'spec_helper'

def is_registered?
  return true if @@need_to_always_be_registered == true
  return !self.access_token.nil? if @@need_to_always_be_registered == false
end

describe Lita::Handlers::Unhandler, lita_handler: true, additional_lita_handlers: Lita::Handlers::AbstractHandler do

#LIST COMMAND
  it{
    command = "listabcdefgh"
    send_command("listabcdefgh")
    expect(replies).to eq([{:title=>"Unknown command", :text=>"Sorry, I don’t understand this command! \"#{command}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!", :color=>:warning, :fallback=>"Sorry, I don't understand this command!", :mrkdwn_in=>["text"], :pretext=>nil}])
  }

  it{
    command = "abdefghlist"
    send_command("abdefghlist")
    expect(replies).to eq([{:title=>"Unknown command", :text=>"Sorry, I don’t understand this command! \"#{command}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!", :color=>:warning, :fallback=>"Sorry, I don't understand this command!", :mrkdwn_in=>["text"], :pretext=>nil}])
  }

  it{
    command = "abclistabc"
    send_command("abclistabc")
    expect(replies).to eq([{:title=>"Unknown command", :text=>"Sorry, I don’t understand this command! \"#{command}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!", :color=>:warning, :fallback=>"Sorry, I don't understand this command!", :mrkdwn_in=>["text"], :pretext=>nil}])
  }

#DEPLOY COMMAND

  it{
    command = "deployabcdefgh"
    send_command("deployabcdefgh")
    expect(replies).to eq([{:title=>"Unknown command", :text=>"Sorry, I don’t understand this command! \"#{command}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!", :color=>:warning, :fallback=>"Sorry, I don't understand this command!", :mrkdwn_in=>["text"], :pretext=>nil}])
  }

  it{
    command = "abdefghdeploy"
    send_command("abdefghdeploy")
    expect(replies).to eq([{:title=>"Unknown command", :text=>"Sorry, I don’t understand this command! \"#{command}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!", :color=>:warning, :fallback=>"Sorry, I don't understand this command!", :mrkdwn_in=>["text"], :pretext=>nil}])
  }

  it{
    command = "abcdeployabc"
    send_command("abcdeployabc")
    expect(replies).to eq([{:title=>"Unknown command", :text=>"Sorry, I don’t understand this command! \"#{command}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!", :color=>:warning, :fallback=>"Sorry, I don't understand this command!", :mrkdwn_in=>["text"], :pretext=>nil}])
  }

#CANCEL COMMAND

  it{
    command = "cancelabcdefgh"
    send_command("cancelabcdefgh")
    expect(replies).to eq([{:title=>"Unknown command", :text=>"Sorry, I don’t understand this command! \"#{command}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!", :color=>:warning, :fallback=>"Sorry, I don't understand this command!", :mrkdwn_in=>["text"], :pretext=>nil}])
  }

  it{
    command = "abdefghcancel"
    send_command("abdefghcancel")
    expect(replies).to eq([{:title=>"Unknown command", :text=>"Sorry, I don’t understand this command! \"#{command}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!", :color=>:warning, :fallback=>"Sorry, I don't understand this command!", :mrkdwn_in=>["text"], :pretext=>nil}])
  }

  it{
    command = "abccancelabc"
    send_command("abccancelabc")
    expect(replies).to eq([{:title=>"Unknown command", :text=>"Sorry, I don’t understand this command! \"#{command}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!", :color=>:warning, :fallback=>"Sorry, I don't understand this command!", :mrkdwn_in=>["text"], :pretext=>nil}])
  }

#REGISTER COMMAND

  it{
    command = "registerabcdefgh"
    send_command("registerabcdefgh")
    expect(replies).to eq([{:title=>"Unknown command", :text=>"Sorry, I don’t understand this command! \"#{command}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!", :color=>:warning, :fallback=>"Sorry, I don't understand this command!", :mrkdwn_in=>["text"], :pretext=>nil}])
  }

  it{
    command = "abdefghderegister"
    send_command("abdefghderegister")
    expect(replies).to eq([{:title=>"Unknown command", :text=>"Sorry, I don’t understand this command! \"#{command}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!", :color=>:warning, :fallback=>"Sorry, I don't understand this command!", :mrkdwn_in=>["text"], :pretext=>nil}])
  }

#RANDOM COMMAND

  it{
    command = "abcdefgh"
    send_command("abcdefgh")
    expect(replies).to eq([{:title=>"Unknown command", :text=>"Sorry, I don’t understand this command! \"#{command}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!", :color=>:warning, :fallback=>"Sorry, I don't understand this command!", :mrkdwn_in=>["text"], :pretext=>nil}])
  }

  it{
    command = "igordosomethingplz"
    send_command("igordosomethingplz")
    expect(replies).to eq([{:title=>"Unknown command", :text=>"Sorry, I don’t understand this command! \"#{command}\"\nPlease try one of the following: *deploy*, *cancel*, *list*!", :color=>:warning, :fallback=>"Sorry, I don't understand this command!", :mrkdwn_in=>["text"], :pretext=>nil}])
  }
end
