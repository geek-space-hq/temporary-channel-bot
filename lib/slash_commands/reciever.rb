# frozen_string_literal: true

require 'sinatra'
require 'rbnacl'

module SlashCommands
  class Reciever
    include Sinatra

    def initialize(key)
      @verify_key = RbNaCl::Signatures::Ed25519::VerifyKey.new convert_to_bytes(key)
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

      Base.post '/' do
        header = request.env.select { _1.start_with?('HTTP_') }
        content = JSON.parse(request.body.read)

        unless reciever.not_illegal?(header['HTTP_X_SIGNATURE_TIMESTAMP'], header['HTTP_X_SIGNATURE_ED25519'], content)
          return 401, 'invalid request signature'
        end

        return { type: '1' }.to_json if content['type'] == 1

        to_do.call(content)
      end
    end

    def run
      Application.run! if $!.nil?
    end
  end
end
