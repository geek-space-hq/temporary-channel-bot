# frozen_string_literal: true

require 'bundler/setup'
require 'discordrb'
require 'dotenv'
require 'redis'

Dotenv.load

redis = Redis.new(url: ENV['REDIS_URL'])

bot = Discordrb::Bot.new token: ENV['TEACHER_TOKEN']

bot.message(contains: /\?set .+/) do |event|
  topic = event.content.delete_prefix('?set ')

  redis.set(event.channel.id.to_s, topic)

  event.server.general_channel.send_message("#{event.channel.name} では #{topic} について話しています")
end

bot.message(content: '?what') do |event|
  topic = redis.get(event.channel.id.to_s)

  message = if topic
              "#{topic} について話しています"
            else
              '話題なし'
            end

  event.respond(message)
end

bot.run
