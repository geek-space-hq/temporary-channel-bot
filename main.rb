# frozen_string_literal: true

require 'bundler/setup'
require 'discordrb'
require 'dotenv'
Dotenv.load

bot = Discordrb::Bot.new token: ENV['TEACHER_TOKEN']

bot.message(contains: /\?set .+/) do |event|
  topic = event.content.delete_prefix('?set ')
  event.server.general_channel.send_message("#{event.channel.name} では #{topic} について話しています")
end

bot.run
