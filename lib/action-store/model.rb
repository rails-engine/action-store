module ActionStore
  module Model
    extend ActiveSupport::Concern

    included do
      belongs_to :target, polymorphic: true
      belongs_to :user, class_name: ActionStore.config.user_class
    end

    module ClassMethods
      attr_reader :allowed_actions

      def allow_actions(actions)
        actions = actions.map(&:to_s)
        @allowed_actions = actions

        define_scopes_with_actions
      end

      def allow?(action)
        allowed_actions.include?(action.to_s)
      end

      def create_action(opts)
        opts ||= {}
        return false if !allow?(opts[:action_type])

        where_opts = opts.extract!(:action_type, :target_type, :target_id, :target, :user, :user_id)
        action = find_or_create_by(where_opts)
        if opts[:action_option]
          action.update_attribute(action_option: opts[:action_option])
        end
        action
      end

      private

      def define_scopes_with_actions
        allowed_actions.each do |key|
          scope key.pluralize, -> { where(action_type: key) }
        end
      end
    end
  end
end