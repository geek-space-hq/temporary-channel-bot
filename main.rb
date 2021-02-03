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
  SlashCommands::Command.new('unregister', 'このチャンネルを管理下から外す'),
  SlashCommands::Command.new('alloc', '適当なチャンネルに話題を割り当てる', SlashCommands::Option.new(3, 'topic', 'talk about...', true)),
  SlashCommands::Command.new('set', 'このチャンネルに話題を割り当てる', SlashCommands::Option.new(3, 'topic', 'talk about...', true)),
  SlashCommands::Command.new('unset', 'このチャンネルの話題を消し去る'),
  SlashCommands::Command.new('index', '各チャンネルの話題を表示する'),
  SlashCommands::Command.new('topic', 'このチャンネルの話題を表示する')
]

commands.each { _1.register token }

reciever = SlashCommands::Reciever.new(token, key)
reciever.on_recieve do |event|
  case event.command
  when 'register' then bot.register_channel(event.channel)
  when 'unregister' then bot.unregister_channel(event.channel)
  when 'unset' then bot.reset_topic(event.channel)
  when 'topic' then bot.show_current_topic(event.channel)
  when 'index' then bot.show_topics
  when /(alloc|set)/
    topic = event.arguments['topic']
    message = if event.command == 'alloc'
                bot.alloc_topic(topic)
              else
                bot.set_topic(event.channel, topic)
              end

    bot.channel(normal_chat).send message unless ['空きチャンネルがないんよ', 'は？'].include? message
    bot.channel(guide_room).send_embed { _1.description = bot.show_topics } unless ['空きチャンネルがないんよ', 'は？'].include? message
    message
  end
end

bot.message do |event|
  channel = event.channel
  case event.content
  when '?register' then channel.send bot.register_channel(channel)
  when '?unregister' then channel.send bot.unregister_channel(channel)
  when '?unset' then channel.send bot.reset_topic(channel)
  when '?index' then channel.send bot.show_topics
  when '?topic' then channel.send bot.show_current_topic(channel)
  when '?help' then channel.send "```\n" + commands.map { "#{_1.name}: #{_1.description}" }.join("\n") + '```'
  when /\?(alloc|set) .+/
    command = event.content.split[0]
    topic = event.content.delete_prefix(command + ' ')
    message = if command == '?alloc'
                bot.alloc_topic(topic)
              else
                bot.set_topic(channel, topic)
              end

    event.respond message
    bot.channel(normal_chat).send message unless ['空きチャンネルがないんよ', 'は？'].include? message
    bot.channel(guide_room).send bot.show_topics unless ['空きチャンネルがないんよ', 'は？'].include? message
  end
end

Thread.new { bot.run }

reciever.run
