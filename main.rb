# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv'

require_relative './lib/topic_manager'
require_relative './lib/slash_commands'

Dotenv.load

token = ENV['BOT_TOKEN']
key = ENV['BOT_KEY']
redis_url = ENV['REDIS_URL']
normal_chat = ENV['NORMAL_CHAT'].to_i
guide_room = ENV['GUIDE_ROOM'].to_i

bot = TopicManager.new token: token
bot.redis = Redis.new(url: redis_url)

commands = [
  SlashCommands::Command.new('register', 'このチャンネルを我が支配下にする'),
  SlashCommands::Command.new('unset', 'このチャンネルの話題を消し去る'),
  SlashCommands::Command.new('index', '各チャンネルの話題を表示する'),
  SlashCommands::Command.new('topic', 'このチャンネルの話題を表示する'),
  SlashCommands::Command.new('alloc', '適当なチャンネルに話題を割り当てる', SlashCommands::Option.new(3, '話題', '話したいこと', true)),
  SlashCommands::Command.new('set', 'このチャンネルに話題を割り当てる', SlashCommands::Option.new(3, '話題', '話したいこと', true))
]

commands.each { _1.register token }

reciever = SlashCommands::Reciever.new(token, key)
reciever.on_recieve do |event|
  case event.command
  when 'register' then event.channel.send bot.register_channel(event.channel)
  when 'unset' then event.channel.send bot.reset_topic(event.channel)
  when 'topic' then event.channel.send bot.show_current_topic(event.channel)
  when 'index' then event.channel.send bot.show_topics
  when /(alloc|set)/
    topic = event.arguments['話題']
    message = if event.command == 'alloc'
                bot.alloc_topic(topic)
              else
                bot.set_topic(event.channel, topic)
              end

    event.channel.send message
    bot.channel(normal_chat).send message unless message == '空きチャンネルがないんよ'
    bot.channel(guide_room).send bot.show_topics unless message == '空きチャンネルがないんよ'
  end
end

reciever.run
