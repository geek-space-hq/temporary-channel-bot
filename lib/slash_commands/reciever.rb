# frozen_string_literal: true

require 'sinatra'
require 'rbnacl'
require 'discordrb'
require 'json'
require_relative './event'

module SlashCommands
  class Reciever
    include Sinatra

    def initialize(token, key)
      @verify_key = RbNaCl::Signatures::Ed25519::VerifyKey.new convert_to_bytes(key)
      @client = Discordrb::Bot.new token: token
    end

    def convert_to_bytes(signature)
      signature.scan(/../).map(&:hex).map(&:chr).join
    end

    def not_illegal?(timestamp, signature, content)
      @verify_key.verify(convert_to_bytes(signature).force_encoding('utf-8'), "#{timestamp}#{content.to_json}")
    rescue RestClient::RequestFailed
      false
    end

    def on_recieve(&to_do)
      reciever = self
      client = @client

      Base.post '/' do
        header = request.env.select { _1.start_with?('HTTP_') }
        content = JSON.parse(request.body.read)

        unless reciever.not_illegal?(header['HTTP_X_SIGNATURE_TIMESTAMP'], header['HTTP_X_SIGNATURE_ED25519'], content)
          return 401, 'invalid request signature'
        end

        return { type: '1' }.to_json if content['type'] == 1

        command = content['data']['name']
        arguments = if content['data']['options']
                      content['data']['options'].map { [_1['name'], _1['value']] }.to_h
                    else
                      {}
                    end

        channel = client.channel(content['channel_id'])
        user = client.user(content['member']['user']['id'])

        response = to_do.call Event.new(command, arguments, channel, user)

        response = [response] unless response.class == Array

        return {
          type: 4,
          data: {
            'tts': false,
            content: response[0],
            embeds: response[1..].map(&:to_hash),
            allowed_mentions: []
          }
        }.to_json
      end
    end

    def run
      Application.run! if $!.nil?
    end
  end
end
