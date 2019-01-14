# frozen_string_literal: true
module ActionStore
  module Mixin
    extend ActiveSupport::Concern

    included do
    end

    def find_action(action_type, opts)
      opts[:user] = self
      self.class.find_action(action_type, opts)
    end

    def create_action(action_type, opts)
      opts[:user] = self
      self.class.create_action(action_type, opts)
    end

    def destroy_action(action_type, opts)
      opts[:user] = self
      self.class.destroy_action(action_type, opts)
    end

    module ClassMethods
      attr_reader :defined_actions

      def find_defined_action(action_type, target_type)
        action_type = action_type.to_s
        name = target_type.to_s.singularize.underscore
        defined_actions.find do |a|
          a[:action_type] == action_type && (a[:action_name] == name || a[:target_type] == target_type)
        end
      end

      def action_store(action_type, name, opts = {})
        opts ||= {}
        klass_name = opts[:class_name] || name.to_s.classify
        target_klass = klass_name.constantize
        action_type = action_type.to_s
        if opts[:counter_cache] == true
          # @post.stars_count
          opts[:counter_cache] = "#{action_type.pluralize}_count"
        end
        if opts[:user_counter_cache] == true
          # @user.star_posts_count
          opts[:user_counter_cache] = "#{action_type}_#{name.to_s.pluralize}_count"
        end

        @defined_actions ||= []
        action = {
          action_name: name.to_s,
          action_type: action_type,
          target_klass: target_klass,
          target_type: target_klass.name,
          counter_cache: opts[:counter_cache],
          user_counter_cache: opts[:user_counter_cache]
        }
        @defined_actions << action

        define_relations(action)
      end

      def find_action(action_type, opts)
        opts[:action_type] = action_type
        opts = safe_action_opts(opts)
        return nil if opts[:user_id].blank? || opts[:user_type].blank?
        return nil if opts[:target_id].blank? || opts[:target_type].blank?

        defined_action = find_defined_action(opts[:action_type], opts[:target_type])
        return nil if defined_action.nil?

        Action.find_by(where_opts(opts))
      end

      def create_action(action_type, opts)
        opts[:action_type] = action_type
        opts = safe_action_opts(opts)
        return false if opts[:user_id].blank? || opts[:user_type].blank?
        return false if opts[:target_id].blank? || opts[:target_type].blank?

        defined_action = find_defined_action(opts[:action_type], opts[:target_type])
        return false if defined_action.nil?

        # create! for raise RecordNotUnique
        begin
          action = Action.find_or_create_by!(where_opts(opts))
          action.update(action_option: opts[:action_option]) if opts.key?(:action_option)
        rescue ActiveRecord::RecordNotUnique
          # update action_option on exist
          action = Action.where(where_opts(opts)).take
          action.update(action_option: opts[:action_option]) if opts.key?(:action_option)
        end

        reset_counter_cache(action, defined_action)
        true
      end

      def destroy_action(action_type, opts)
        opts[:action_type] = action_type
        opts = safe_action_opts(opts)
        return false if opts[:user_id].blank? || opts[:user_type].blank?
        return false if opts[:target_id].blank? || opts[:target_type].blank?

        defined_action = find_defined_action(opts[:action_type], opts[:target_type])
        return false if defined_action.nil?

        action = Action.where(where_opts(opts)).first
        return true if !action
        action.destroy
        reset_counter_cache(action, defined_action)
        true
      end

      def reset_counter_cache(action, defined_action)
        return false if action.blank?
        if defined_action[:counter_cache] && action.target.present?
          target_count = Action.where(
            action_type: defined_action[:action_type],
            target_type: action.target_type,
            target_id: action.target_id
          ).count
          action.target.update_attribute(defined_action[:counter_cache], target_count)
        end
        if defined_action[:user_counter_cache] && action.user.present?
          user_count = Action.where(
            action_type: defined_action[:action_type],
            target_type: action.target_type,
            user_type: action.user_type,
            user_id: action.user_id
          ).count
          action.user.update_attribute(defined_action[:user_counter_cache], user_count)
        end
      end

      private

        def define_relations(action)
          target_klass = action[:target_klass]
          action_type = action[:action_type]
          action_name = action[:action_name]

          user_klass = self

          # user, person
          user_name = user_klass.table_name.underscore.singularize

          # like_topic, follow_user
          full_action_name = [action_type, action_name].join("_")
          # like_user, follow_user
          full_action_name_for_target = [action_type, "by", user_name].join("_")
          # unlike_topic, unfollow_user
          unaction_name = "un#{full_action_name}"

          # @target.like_topic_actions, @target.follow_user_actions
          has_many_name = [full_action_name, "actions"].join("_").to_sym
          # @target.like_topics, @target.follow_users
          has_many_through_name = full_action_name.pluralize.to_sym

          # @user.like_by_user_actions, @user.follow_by_user_actions
          has_many_name_for_target = [full_action_name_for_target, "actions"].join("_").to_sym
          # @user.like_by_users, @user.follow_by_users
          has_many_through_name_for_target = full_action_name_for_target.pluralize.to_sym

          has_many_scope = -> {
            where(action_type: action_type, target_type: target_klass.name, user_type: user_klass.name)
          }

          # User has_many :like_topic_actions
          user_klass.send :has_many, has_many_name, has_many_scope,
            class_name: "Action",
            foreign_key: "user_id"
          # User has_many :like_topics
          user_klass.send :has_many, has_many_through_name,
            through: has_many_name,
            source: :target,
            source_type: target_klass.name

          # Topic has_many :like_user_actions
          target_klass.send :has_many, has_many_name_for_target, has_many_scope,
            foreign_key: :target_id,
            class_name: "Action"
          # Topic has_many :like_users
          target_klass.send :has_many, has_many_through_name_for_target,
            through: has_many_name_for_target,
            source_type: user_klass.name,
            source: :user

          # @user.like_topic
          user_klass.send(:define_method, full_action_name) do |target_or_id|
            target_id = target_or_id.is_a?(target_klass) ? target_or_id.id : target_or_id
            result = user_klass.create_action(action_type, target_type: target_klass.name,
                                                           target_id: target_id,
                                                           user: self)
            target_or_id.reload if target_or_id.is_a?(target_klass)
            self.reload
            result
          end

          # @user.like_topic?
          user_klass.send(:define_method, "#{full_action_name}?") do |target_or_id|
            target_id = target_or_id.is_a?(target_klass) ? target_or_id.id : target_or_id
            result = user_klass.find_action(action_type, target_type: target_klass.name,
                                                         target_id: target_id,
                                                         user: self)
            result.present?
          end

          # @user.unlike_topic
          user_klass.send(:define_method, unaction_name) do |target_or_id|
            target_id = target_or_id.is_a?(target_klass) ? target_or_id.id : target_or_id
            result = user_klass.destroy_action(action_type, target_type: target_klass.name,
                                                            target_id: target_id,
                                                            user: self)
            target_or_id.reload if target_or_id.is_a?(target_klass)
            self.reload
            result
          end
        end

        def safe_action_opts(opts)
          opts ||= {}
          if opts[:user]
            opts[:user_id] = opts[:user].id
            opts[:user_type] = opts[:user].class.name
          end
          if opts[:target]
            opts[:target_type] = opts[:target].class.name
            opts[:target_id] = opts[:target].id
          end
          opts
        end

        def where_opts(opts)
          opts.extract!(:action_type, :target_type, :target_id, :user_id, :user_type)
        end
    end
  end
end
