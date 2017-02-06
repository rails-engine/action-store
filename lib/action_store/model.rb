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
        target_klass = klass_name.to_s.classify.constantize
        action_type = action_type.to_s
        if opts[:counter_cache] == true
          opts[:counter_cache] = "#{action_type.pluralize}_count"
        end
        if opts[:user_counter_cache] == true
          opts[:user_counter_cache] = "#{action_type.pluralize}_count"
        end

        @defined_actions ||= []
        action = {
          action_name: name.to_s,
          action_type: action_type,
          target_klass: target_klass,
          counter_cache: opts[:counter_cache],
          user_counter_cache: opts[:user_counter_cache]
        }
        @defined_actions << action

        define_relations(action)
      end

      def find_defined_action(action_type, name)
        action_type = action_type.to_s
        name = name.to_s.singularize.underscore
        defined_actions.find { |a| a[:action_type] == action_type && a[:action_name] == name }
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
          action.update_attribute(:action_option, opts[:action_option])
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

      def define_relations(action)
        target_klass = action[:target_klass]
        action_type = action[:action_type]
        action_name = action[:action_name]

        action_klass = self
        user_klass = ActionStore.config.user_class.constantize

        # user, person
        user_name = ActionStore.config.user_class.underscore.singularize

        # like_topic, follow_user
        full_action_name = [action_type, action_name].join('_')
        # like_user, follow_user
        full_user_action_name = [action_type, user_name].join('_')
        # unlike_topic, unfollow_user
        unaction_name = "un#{full_action_name}"

        # like_topic_actions, follow_user_actions
        has_many_name = [full_action_name, 'actions'].join('_').to_sym
        # like_topics, follow_users
        has_many_through_name = full_action_name.pluralize.to_sym

        # like_user_actions, follow_user_actions
        has_many_user_name = [full_user_action_name, 'actions'].join('_').to_sym
        # like_users, follow_users
        has_many_through_user_name = full_user_action_name.pluralize.to_sym

        # Action.like_topics, Action.star_topics
        scope full_action_name.pluralize, -> { where(action_type: action_type) }

        has_many_scope = -> { where(action_type: action_type, target_type: target_klass.name) }
        # User has_many :like_topic_actions
        user_klass.send :has_many, has_many_name, has_many_scope, class_name: action_klass.name
        # User has_many :like_topics
        user_klass.send :has_many, has_many_through_name,
          through: has_many_name,
          source: :target,
          source_type: target_klass.name

        if target_klass != user_klass
          # Topic has_many :like_user_actions
          target_klass.send :has_many, has_many_user_name, has_many_scope,
            foreign_key: :target_id,
            class_name: action_klass.name
          # Topic has_many :like_users
          target_klass.send :has_many, has_many_through_user_name,
            through: has_many_user_name,
            source: :user
        end

        # @user.like_topic
        user_klass.send(:define_method, full_action_name) do |target_or_id|
          target_id = target_or_id.is_a?(target_klass) ? target_or_id.id : target_or_id
          action = action_klass.create_action(action_type, target_type: target_klass.name,
                                                           target_id: target_id,
                                                           user: self)
          self.reload
          action
        end

        # @user.unlike_topic
        user_klass.send(:define_method, unaction_name) do |target_or_id|
          target_id = target_or_id.is_a?(target_klass) ? target_or_id.id : target_or_id
          action = action_klass.destroy_action(action_type, target_type: target_klass.name,
                                                            target_id: target_id,
                                                            user: self)
          self.reload
          action
        end
      end

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