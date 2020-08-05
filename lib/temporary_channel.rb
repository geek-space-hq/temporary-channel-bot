# frozen_string_literal: true

class TemporaryChannel
  attr_reader :user, :topic

  def initialize(id, user = nil, topic = '')
    @id = id
    @user = user
    @topic = topic
  end

  def use(user, topic)
    TemporaryChannel.new(@id, user, topic)
  end

  def leave
    TemporaryChannel.new(@id)
  end

  def busy?
    !user.nil?
  end
end
