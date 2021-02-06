# frozen_string_literal: true

require 'discordrb'
require 'redis'

class TopicManager < Discordrb::Bot
  attr_writer :redis

  def register_channel(channel)
    @redis.set(channel.id.to_s, 'none')
    "#{channel.name} を登録したよ"
  end

  def unregister_channel(channel)
    @redis.del(channel.id.to_s)
    "#{channel.name} は話題を設定できなくなったよ"
  end

  def alloc_topic(topic, guild_channel)
    hungry_channels = all_channels.filter { _2 == 'none'}.map{ _1[0] }

    target_channel = if hungry_channels.empty?
                       new_one = create_channel(guild_channel)
                       register_channel(new_one)
                       new_one
                     else hungry_channels[0]
                     end

    set_topic(target_channel, topic)
  end

  def set_topic(channel, topic)
    return 'は？' unless @redis.get(channel.id.to_s)

    @redis.set(channel.id.to_s, topic)
    channel.name = topic
    "#{channel.mention} では #{topic} について話しています"
  end

  def reset_topic(channel)
    @redis.set(channel.id.to_s, 'none')
    channel.name = 'マサチューセッチュ❣️'
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

  def create_channel(guild_channel)
    guild_channel.server.create_channel('マサチューセッチュ❣️', topic: 'なかよくつかおうね', parent: guild_channel.parent_id)
  end

  def show_topics
    topics = all_channels.map do
      topic = if _2 == 'none'
                'ない'
              else _2
              end

      "#{_1.mention} のトピックは #{topic} です"
    end

    topics.join("\n")
  end

  def all_channels
    @redis.keys('*').sort.map { [channel(_1.to_i), @redis.get(_1)] }
  end
end
