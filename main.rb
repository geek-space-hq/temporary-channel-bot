# frozen_string_literal: true

require 'bundler/setup'
require 'discordrb'
require 'dotenv'
require 'redis'

Dotenv.load

class TopicManager < Discordrb::Bot
  attr_writer :redis

  def set_topic(channel, topic)
    @redis.set(channel.id.to_s, topic)
    "#{channel.name} では #{topic} について話しています"
  end

  def reset_topic(channel)
    @redis.del(channel.id.to_s)
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
  normal_chat = bot.channel(406357894427312151)
  reply_to = event.content.match?(/\?set .+/) ? normal_chat : channel
  reply_to.send case event.content
                when /\?set .+/
                  topic = event.content.delete_prefix('?set ')
                  bot.set_topic(channel, topic)
                when '?reset' then bot.reset_topic(channel)
                when '?index' then bot.show_topics
                when '?what' then bot.show_current_topic(channel)
                end
end
bot.run
