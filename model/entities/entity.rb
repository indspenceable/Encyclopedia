module Model
  class Entity
    # react_to sym, condition, proc/block
    def self.react_to event, action = event
      raise "Event must be a symbol signaling th event type" unless event.is_a?(Symbol) || event.is_a?(Array)
      if event.is_a? Array
        event.each { |e| react_to(e,action) }
        return
      end
      action_hash = self.instance_variable_get(:@actions)

      if action.is_a? Proc
        define_method(event, action)
        action = event
      end
      action_hash[event] = action
    end
    def self.inherited(subclass)
      #make sure that this class has an action_hash
      subclass.instance_variable_set(:@actions, Hash.new)
    end
    def handle event_type, *args
      action_hash = self.class.instance_variable_get(:@actions)
      if action_hash.key? event_type
        action = action_hash[event_type]
        self.send(action, *args)
      end
    end
    def flag sym
      (@flags ||= Set.new) << sym
    end
    def flag? sym
      (@flags ||= Set.new).include? sym
    end
    def unflag sym
      (@flags ||= Set.new).delete(sym)
    end
  end
end
