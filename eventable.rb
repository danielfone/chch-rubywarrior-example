module Eventable
  module ClassMethods
    def listeners
      @listeners
    end

    def listeners=(val)
      @listeners = val
    end

    def on(event, *methods)
      listeners[event] += Array(methods)
    end
  end

  module InstanceMethods
    def trigger(event, *args)
      self.class.listeners[event].each do |method|
        send method, *args
      end
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
    receiver.listeners = Hash.new []
  end
end
