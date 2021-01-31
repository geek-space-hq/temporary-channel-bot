# frozen_string_literal: true

module SlashCommands
  class Event
    attr_reader :command, :arguments, :channel, :user
    def initialize(command, arguments, channel, user)
      @command = command
      @arguments = arguments
      @channel = channel
      @user = user
    end
  end
end
