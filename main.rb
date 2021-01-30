# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv'

require_relative './lib/topic_manager'

Dotenv.load

normal_chat = ENV['NORMAL_CHAT'].to_i
guide_room = ENV['GUIDE_ROOM'].to_i

bot = TopicManager.new token: ENV['BOT_TOKEN']
bot.redis = Redis.new(url: ENV['REDIS_URL'])
bot.message do |event|
  channel = event.channel
  case event.content
  when '?register' then channel.send bot.register_channel(channel)
  when '?unset' then channel.send bot.reset_topic(channel)
  when '?index' then channel.send bot.show_topics
  when '?topic' then channel.send bot.show_current_topic(channel)
  when /\?(alloc|set) .+/
    command = event.content.split[0]
    topic = event.content.delete_prefix(command + ' ')
    message = if command == '?alloc'
                bot.alloc_topic(topic)
              else
                bot.set_topic(channel, topic)
              end

    event.respond message
    bot.channel(normal_chat).send message unless message == '空きチャンネルがないんよ'
    bot.channel(guide_room).send bot.show_topics unless message == '空きチャンネルがないんよ'
  end
end

bot.run
