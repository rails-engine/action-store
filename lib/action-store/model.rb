module ActionStore
  module Model
    extend ActiveSupport::Concern

    included do
      belongs_to :target, polymorphic: true
      belongs_to :user, class_name: ActionStore.config.user_class
    end

    module ClassMethods
      attr_reader :defined_actions

      def action_for(action_type, name, opts = {})
        opts ||= {}
        klass_name = opts[:class_name] || name
        klass = klass_name.to_s.classify.constantize
        action_type = action_type.to_s
        if opts[:counter_cache] == true
          opts[:counter_cache] = "#{action_type.pluralize}_count"
        end
        if opts[:user_counter_cache] == true
          opts[:user_counter_cache] = "#{action_type.pluralize}_count"
        end

        @defined_actions ||= []
        @defined_actions << {
          name: name.to_s,
          action_type: action_type,
          klass: klass,
          counter_cache: opts[:counter_cache],
          user_counter_cache: opts[:user_counter_cache]
        }

        # Action.likes, Action.stars
        scope action_type.pluralize, -> { where(action_type: action_type) }
      end

      def find_defined_action(action_type, name)
        action_type = action_type.to_s
        name = name.to_s.singularize.underscore
        defined_actions.find { |a| a[:action_type] == action_type && a[:name] == name }
      end

      def find_action(action_type, opts)
        opts[:action_type] = action_type
        opts = safe_action_opts(opts)

        defined_action = find_defined_action(opts[:action_type], opts[:target_type])
        return nil if defined_action.nil?

        find_by(where_opts(opts))
      end

      def create_action(action_type, opts)
        opts[:action_type] = action_type
        opts = safe_action_opts(opts)

        defined_action = find_defined_action(opts[:action_type], opts[:target_type])
        return false if defined_action.nil?

        action = find_or_create_by(where_opts(opts))
        if opts[:action_option]
          action.update_attribute(action_option: opts[:action_option])
        end
        reset_counter_cache(action, defined_action)
        action
      end

      def destroy_action(action_type, opts)
        opts[:action_type] = action_type
        opts = safe_action_opts(opts)

        defined_action = find_defined_action(opts[:action_type], opts[:target_type])
        return false if defined_action.nil?

        action = where(where_opts(opts)).first
        action.destroy
        reset_counter_cache(action, defined_action)
      end

      def reset_counter_cache(action, defined_action)
        return false if action.blank?
        if defined_action[:counter_cache] && action.target.present?
          target_count = where({ action_type: defined_action[:action_type], target: action.target }).count
          action.target.update_attribute(defined_action[:counter_cache], target_count)
        end
        if defined_action[:user_counter_cache] && action.user.present?
          user_count = where({ action_type: defined_action[:action_type], user: action.user }).count
          action.user.update_attribute(defined_action[:user_counter_cache], user_count)
        end
      end

      private

      def safe_action_opts(opts)
        opts ||= {}
        if opts[:user]
          opts[:user_id] = opts[:user].id
        end
        if opts[:target]
          opts[:target_type] = opts[:target].class.name
          opts[:target_id] = opts[:target].id
        end
        opts
      end

      def where_opts(opts)
        opts.extract!(:action_type, :target_type, :target_id, :user_id)
      end
    end
  end
end