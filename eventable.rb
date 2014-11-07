module Eventable
  module ClassMethods
    def listeners
      @listeners ||= Hash.new []
    end

    def on(event, *methods)
      listeners[event] += Array(methods)
    end
  end

  module InstanceMethods
    def trigger(event, *args)
      self.class.listeners[event].each do |methods|
        send methods, *args
      end
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end