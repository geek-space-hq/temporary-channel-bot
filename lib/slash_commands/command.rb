# frozen_string_literal: true

require 'json'
require 'rest-client'
require 'rbnacl'

module SlashCommands
  class Command
    attr_reader :name, :description, :options

    def initialize(name, description, *options)
      @name = name
      @description = description
      @options = options
    end

    def register(token)
      header = { Authorization: "Bot #{token}", 'Content-Type' => 'application/json' }
      id = JSON.parse((RestClient.get 'https://discord.com/api/v8/users/@me', header))['id']

      RestClient.post "https://discord.com/api/v8/applications/#{id}/commands", to_json, header
    end

    def to_h
      { name: @name, description: @description, options: @options }
    end

    def to_json(*)
      to_h.to_json
    end
  end
end
