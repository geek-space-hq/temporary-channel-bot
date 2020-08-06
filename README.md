# Temporary room bot

This bot is developed for [Geek-Space](https://discord.com/invite/e9TftCK). / このBotは[Geek-Space](https://discord.com/invite/e9TftCK)のために開発されています。

This bot changes a channel topic to what you hope.
And only you can break the changed topic. / このBotはチャンネルのトピックをあなたが望むものに変えます。そして、あなたしかそのトピックを開放できません。

I call a right to change a topic 'key'. / 私はトピックの変更権を鍵と呼びます。

## Commands
| コマンド | 説明 |
|  ------  |  --  |
| `せんせー鍵 "用途"` | The bot gives the channel key. / チャンネルの鍵を与えます。 |
| `せんせー返す` | The bot takes the channel key. / チャンネルの鍵を取ります。 |
| `せんせー鍵どこ` | Send who has the key. / チャンネルの鍵の所有者を送信します。 |
| `せんせーこれ何` | Send the topic. / チャンネルの話題を送信します。 |
| `せんせー教えて` | Send this bot's commands. / このBotのコマンドを送信します。 |

## Setup

Clone this repository. / このリポジトリーを複製する。
```
$ git clone https://github.com/geek-space-hq/temporary-chat-bot
```

Install gems. / gemをインストールする。
```
$ bundle install
```

Set your Discord token / あなたのディスコードトークンを設定する。
```
$ export TEMPORARY_CHANNEL_BOT_TOKEN='your token'
```

Run / 実行する。
```
$ ruby main.rb
```
