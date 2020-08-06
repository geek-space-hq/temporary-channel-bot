# frozen_string_literal: true

require 'discordrb'
require_relative 'temporary_channel'

class TemporaryChannelBot
  def initialize
    @token = ENV['TEMPORARY_CHANNEL_BOT_TOKEN']
    @bot = Discordrb::Bot.new token: (@token || '')
    @channels = {}
  end

  def give_channel(channel, user, topic)
    @channels[channel.id] = TemporaryChannel.new(channel.id, user, topic)
  end

  def take_channel(channel)
    @channels[channel.id] = @channels[channel.id].leave
  end

  def busy_channel?(channel)
    @channels[channel.id] && @channels[channel.id].busy?
  end

  def give_channel_command(message)
    return "先生は鍵じゃありません！\n`せんせー鍵 用途` こう言いましょう。" unless message.content.match?(/せんせー鍵[ 　]\S+?/)

    channel = message.channel
    topic = message.content.split[1]

    return "#{@channels[channel.id].user.username} さんが鍵を持っています。" if busy_channel?(channel)

    give_channel(channel, message.author, topic)
    "#{message.author.mention}さん、話題を#{topic}にしましたよ。大切に使ってくださいね。"
  end

  def take_channel_command(message)
    channel = @channels[message.channel.id]
    user = message.user

    return 'ふふふ、面白い冗談ですね。' unless channel.busy? && channel.user.id == user.id

    take_channel(message.channel)
    "#{message.author.mention}さん、わざわざどうも。"
  end

  def who_has_channel_command(message)
    channel = @channels[message.channel.id]
    if channel && channel.busy?
      "#{channel.user.mention} さんが鍵を持っています。"
    else
      'この教室は空いてますよ。'
    end
  end

  def whats_topic_command(message)
    channel = @channels[message.channel.id]
    if channel && channel.busy?
      "#{channel.topic}について話し合う場所です。"
    else
      'ここは空き教室です。先生に言ってくれたら使ってもいいですよ。'
    end
  end

  def set_give_channel_command
    @bot.message(start_with: 'せんせー鍵') do |event|
      message = give_channel_command(event.message)
      event.send_message(message)
    end
  end

  def set_take_channel_command
    @bot.message(content: 'せんせー返す') do |event|
      message = take_channel_command(event.message)
      event.send_message(message)
    end
  end

  def set_who_has_channel_command
    @bot.message(content: 'せんせー誰') do |event|
      message = who_has_channel_command(event.message)
      event.send_message(message)
    end
  end

  def set_whats_topic_command
    @bot.message(content: 'せんせーこれ何') do |event|
      message = whats_topic_command(event.message)
      event.send_message(message)
    end
  end

  def prepare
    set_give_channel_command
    set_take_channel_command
    set_who_has_channel_command
    set_whats_topic_command
  end

  def run
    prepare

    if @token.nil?
      puts 'Set the Discord bot token on TEMPORARY_CHANNEL_BOT_TOKEN'
    else
      @bot.run
    end
  end
end
