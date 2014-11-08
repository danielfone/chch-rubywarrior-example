module Eventable
  module ClassMethods
    def listeners
      @listeners
    end

    # I wouldn't normally put an setter, but ruby warrior does some weird
    # class reloading and we can't set this in the class defn
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
