# frozen_string_literal: true

require 'bundler/setup'
require 'discordrb'
require 'dotenv'
require 'redis'

Dotenv.load

normal_chat = ENV['NORMAL_CHAT'].to_i
guide_room = ENV['GUIDE _ROOM'].to_i

class TopicManager < Discordrb::Bot
  attr_writer :redis

  def register_channel(channel)
    @redis.set(channel.id.to_s, 'none')
    "#{channel.name} を登録したよ"
  end

  def set_topic(channel, topic)
    return 'は？' unless @redis.get(channel.id.to_s)

    @redis.set(channel.id.to_s, topic)
    "#{channel.mention} では #{topic} について話しています"
  end

  def reset_topic(channel)
    return 'は？' unless @redis.get(channel.id.to_s)

    @redis.set(channel.id.to_s, 'none')
    '話題を消し去りました'
  end

  def show_current_topic(channel)
    topic = @redis.get(channel.id.to_s)

    if topic
      "#{topic} について話しています"
    else
      '話題なし'
    end
  end

  def show_topics
    topics = @redis.keys('*').map do
      channel = channel(_1.to_i)
      topic = @redis.get(_1)

      "#{channel.mention} のトピックは #{topic} です" if channel
    end.compact

    topics.join("\n")
  end
end

bot = TopicManager.new token: ENV['BOT_TOKEN']
bot.redis = Redis.new(url: ENV['REDIS_URL'])
bot.message do |event|
  channel = event.channel
  case event.content
  when '?register' then channel.send bot.register_channel(channel)
  when '?reset' then channel.send bot.reset_topic(channel)
  when '?index' then channel.send bot.show_topics
  when '?topic' then channel.send bot.show_current_topic(channel)
  when /\?set .+/
    topic = event.content.delete_prefix('?set ')
    message = bot.set_topic(channel, topic)

    event.respond message
    bot.channel(normal_chat).send message unless message == 'は？' # normal-chat
    bot.channel(guide_room).send bot.show_topics unless message == 'は？' # teacher-room
  end
end
bot.run
