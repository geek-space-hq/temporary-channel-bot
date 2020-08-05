# Temporary room bot

This bot is developed for [Geek-Space](https://discord.com/invite/e9TftCK).

This bot changes a channel topic to what you hope.
And only you can break the changed topic.

I call a right to change a topic 'key'.

## Commands
| コマンド | 説明 |
|  ------  |  --  |
| `せんせー鍵 "用途"` | The bot gives the channel key. |
| `せんせー返す` | The bot takes the channel key. |
| `せんせー誰` | Send who has the key. |

## Setup

Clone this repository.
```
$ git clone https://github.com/geek-space-hq/temporary-chat-bot
```

Install gems.
```
$ bundle install
```

Set your Discord token
```
$ export TEMPORARY_CHANNEL_BOT_TOKEN='your token'
```

Run
```
$ ruby main.rb
```
