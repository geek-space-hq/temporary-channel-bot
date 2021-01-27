# frozen_string_literal: true

require 'bundler/setup'
require 'discordrb'
require 'dotenv'
require 'redis'

Dotenv.load

normal_chat = ENV['NORMAL_CHAT'].to_i
guide_room = ENV['GUIDE_ROOM'].to_i

class TopicManager < Discordrb::Bot
  attr_writer :redis

  def register_channel(channel)
    @redis.set(channel.id.to_s, 'none')
    "#{channel.name} を登録したよ"
  end

  def alloc_topic(topic)
    channel = all_channels.filter { _2 == 'none'}[0]

    return '空きチャンネルがないんよ' unless channel

    set_topic(channel[0], topic)
  end

  def set_topic(channel, topic)
    return 'は？' unless @redis.get(channel.id.to_s)

    @redis.set(channel.id.to_s, topic)
    "#{channel.mention} では #{topic} について話しています"
  end

  def reset_topic(channel)
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
    topics = all_channels.map { "#{_1.mention} のトピックは #{_2} です" }

    topics.join("\n")
  end

  def all_channels
    @redis.keys('*').map { [channel(_1.to_i), @redis.get(_1)] }
  end
end

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
