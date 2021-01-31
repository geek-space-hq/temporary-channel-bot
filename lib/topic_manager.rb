# frozen_string_literal: true

require 'discordrb'
require 'redis'

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
    @redis.keys('*').sort.map { [channel(_1.to_i), @redis.get(_1)] }
  end
end
