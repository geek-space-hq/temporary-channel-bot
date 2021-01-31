# frozen_string_literal: true

require 'json'

module SlashCommands
  class Option
    def initialize(type, name, description, required = false, choices = [], options = [])
      @type = type
      @name = name
      @description = description
      @required = required
      @choices = choices
      @options = options
    end

    def to_h
      { type: @type, name: @name, description: @description, required: @required, choices: @choices, options: @options }
    end

    def to_json(*)
      to_h.to_json
    end
  end
end
