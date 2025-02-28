# frozen_string_literal: true

require 'openhab/log/logger'

module OpenHAB
  module DSL
    module Rules
      #
      # Module holds rule triggers
      #
      module Triggers
        include OpenHAB::Log

        #
        # Struct capturing data necessary for a conditional trigger
        #
        TriggerDelay = Struct.new(:to, :from, :duration, :timer, :tracking_to, keyword_init: true) do
          def timer_active?
            timer&.is_active
          end
        end

        #
        # Creates a trigger item, group and thing changed
        #
        # @param [Object] items array of objects to create trigger for
        # @param [to] to state for object to change for
        # @param [from] from <description>
        # @param [OpenHAB::Core::Duration] for Duration to delay trigger until to state is met
        #
        # @return [Trigger] OpenHAB trigger
        #
        def changed(*items, to: nil, from: nil, for: nil)
          separate_groups(items).map do |item|
            logger.trace("Creating changed trigger for entity(#{item}), to(#{to}), from(#{from})")
            # for is a reserved word in ruby, so use local_variable_get :for
            if (wait_duration = binding.local_variable_get(:for))
              changed_wait(item, to: to, from: from, duration: wait_duration)
            else
              # Place in array and flatten to support multiple to elements or single or nil
              [to].flatten.map do |to_state|
                [from].flatten.map { |from_state| create_changed_trigger(item, from_state, to_state) }
              end
            end
          end.flatten
        end

        private

        #
        # Create a TriggerDelay for for an item or group that is changed for a specific duration
        #
        # @param [Object] item to create trigger delay for
        # @param [OpenHAB::Core::Duration] duration to delay trigger for until condition is met
        # @param [Item State] to OpenHAB Item State item or group needs to change to
        # @param [Item State] from OpenHAB Item State item or group needs to be coming from
        #
        # @return [Trigger] OpenHAB trigger
        #
        def changed_wait(item, duration:, to: nil, from: nil)
          trigger = create_changed_trigger(item, nil, nil)
          logger.trace("Creating Changed Wait Change Trigger for #{item}")
          @trigger_delays[trigger.id] = TriggerDelay.new(to: to, from: from, duration: duration)
          trigger
        end

        #
        # Create a changed trigger
        #
        # @param [Object] item to create changed trigger on
        # @param [String] from state to restrict trigger to
        # @param [String] to state restrict trigger to
        #
        #
        def create_changed_trigger(item, from, to)
          trigger, config = case item
                            when OpenHAB::DSL::Items::GroupItem::GroupMembers
                              create_group_changed_trigger(item, from, to)
                            when Thing then create_thing_changed_trigger(item, from, to)
                            else create_item_changed_trigger(item, from, to)
                            end
          append_trigger(trigger, config)
        end

        #
        # Create a changed trigger for a thing
        #
        # @param [Thing] thing to detected changed states on
        # @param [String] from state to restrict trigger to
        # @param [String] to state to restrict trigger to
        #
        # @return [Array<Hash,String>] first element is a String specifying trigger type
        #  second element is a Hash configuring trigger
        #
        def create_thing_changed_trigger(thing, from, to)
          trigger_for_thing(thing, Trigger::THING_CHANGE, to, from)
        end

        #
        # Create a changed trigger for an item
        #
        # @param [Item] item to detected changed states on
        # @param [String] from state to restrict trigger to
        # @param [String] to to restrict trigger to
        #
        # @return [Array<Hash,String>] first element is a String specifying trigger type
        #  second element is a Hash configuring trigger
        #
        def create_item_changed_trigger(item, from, to)
          config = { 'itemName' => item.name }
          config['state'] = to.to_s if to
          config['previousState'] = from.to_s if from
          trigger = Trigger::ITEM_STATE_CHANGE
          [trigger, config]
        end

        #
        # Create a changed trigger for group items
        #
        # @param [Group] group to detected changed states on
        # @param [String] from state to restrict trigger to
        # @param [String] to to restrict trigger to
        #
        # @return [Array<Hash,String>] first element is a String specifying trigger type
        #  second element is a Hash configuring trigger
        #
        def create_group_changed_trigger(group, from, to)
          config = { 'groupName' => group.group.name }
          config['state'] = to.to_s if to
          config['previousState'] = from.to_s if from
          trigger = Trigger::GROUP_STATE_CHANGE
          [trigger, config]
        end
      end
    end
  end
end
