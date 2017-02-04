module ActionStore
  module Model
    extend ActiveSupport::Concern

    included do
      belongs_to :target, polymorphic: true
      belongs_to :user, class_name: ActionStore.config.user_class
    end

    module ClassMethods
      attr_reader :allowed_actions

      def action_for(action_type, name, opts = {})
        opts ||= {}
        klass_name = opts[:class_name] || name
        klass = klass_name.to_s.classify.constantize
        action_type = action_type.to_s
        if opts[:counter_cache] == true
          opts[:counter_cache] = "#{action_type.pluralize}_count"
        end
        if opts[:user_counter_cache] == true
          opts[:counter_cache] = "#{action_type.pluralize}_count"
        end

        @allowed_actions ||= []
        @allowed_actions << {
          name: name.to_s,
          action_type: action_type,
          klass: klass,
          opts: opts
        }

        # Action.likes, Action.stars
        scope action_type.pluralize, -> { where(action_type: action_type) }
      end

      def allow?(action_type, name)
        action_type = action_type.to_s
        name = name.to_s.singularize.underscore
        allowed_actions.count { |a| a[:action_type] == action_type && a[:name] == name } > 0
      end

      def create_action(opts)
        opts ||= {}
        if opts[:user]
          opts[:user_id] = opts[:user].id
        end
        if opts[:target]
          opts[:target_type] = opts[:target].class.name
          opts[:target_id] = opts[:target].id
        end

        return false if !allow?(opts[:action_type], opts[:target_type])

        where_opts = opts.extract!(:action_type, :target_type, :target_id, :user_id)
        action = find_or_create_by(where_opts)
        if opts[:action_option]
          action.update_attribute(action_option: opts[:action_option])
        end
        action
      end
    end
  end
end