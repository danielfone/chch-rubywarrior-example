module Eventable

  def trigger(event, *args)
    self.class.listeners[event].each do |method|
      send method, *args
    end
  end

  module ClassMethods

    def on(event, *methods)
      listeners[event] += Array(*methods)
    end

    def listeners
      @listeners ||= Hash.new []
    end

  end

  def self.included(base)
    base.extend  ClassMethods
  end
end
