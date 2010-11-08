module Model
  class Entity
    attr_reader :event_state

    # react_to sym, condition, proc/block
    def self.react_to event, action = event, conditions = nil
      raise "Event must be a symbol signaling th event type" unless event.is_a?(Symbol) || event.is_a?(Array)
      if event.is_a? Array
        event.each { |e| react_to(e,action,conditions) }
        return
      end
      action_hash = self.instance_variable_get(:@actions)

      # a condition is a symbol or a list of symbols.
      # if its
      if conditions == nil
        conditions = ->(ent){ true }
      else
        old_conds = conditions
        old_conds = [old_conds] unless old_conds.is_a? Symbol
        condition = ->(ent){
          old_conds.include? ent.event_state
        }
      end
      if action.is_a? Proc
        define_method(event, action)
        action = event
      end
      #puts "CONDITION IS #{conditions}"
      action_hash[event] = [conditions, action]
    end
    def self.inherited(subclass)
      #make sure that this class has an action_hash
      subclass.instance_variable_set(:@actions, Hash.new)
    end
    def handle event_type, *args
      @event_state ||= :global
      action_hash = self.class.instance_variable_get(:@actions)
      if action_hash.key? event_type
        condition, action = action_hash[event_type]
        if condition.call(self)
          self.send(action, *args)
        end
      end
    end

  end

end
