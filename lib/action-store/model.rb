module ActionStore
  module Model
    extend ActiveSupport::Concern

    included do
      belongs_to :target, polymorphic: true

      belongs_to :user, class_name: ActionStore.config.user_class
    end
  end
end