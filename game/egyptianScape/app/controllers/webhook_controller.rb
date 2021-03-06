require 'BotMessageDispatcher'

class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token
  @@dispatcher = nil

  def callback
  	if(@@dispatcher == nil)
      @@dispatcher = dispatcher.new(webhook, user)
  	end
  	@@dispatcher.user = user
  	@@dispatcher.message = webhook
    @@dispatcher.process
    render nothing: true, head: :ok
  end

  def webhook
    params['webhook']
  end

  def dispatcher
    BotMessageDispatcher
  end

  def from
    webhook[:message][:from]
  end

  def user
    @user ||= User.find_by(telegram_id: from[:id]) || register_user
  end

  def register_user
    @user = User.find_or_initialize_by(telegram_id: from[:id])
    @user.update_attributes!(first_name: from[:first_name], last_name: from[:last_name])
    #@@dispatcher = dispatcher.new(webhook, @user)
    @user
  end

end