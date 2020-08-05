# frozen_string_literal: true

require 'discordrb'

class TemporaryChannelBot
  def initialize
    @token = ENV['TEMPORARY_CHANNEL_BOT_TOKEN']
    @bot = Discordrb::Bot.new token: (@token || '')
  end

  def run
    if @token.nil?
      puts 'Set the Discord bot token on TEMPORARY_CHANNEL_BOT_TOKEN'
    else
      @bot.run
    end
  end
end
