# frozen_string_literal: true
module ActionStore
  class Engine < ::Rails::Engine
    isolate_namespace ActionStore

    initializer "action_store.init_action", after: :load_config_initializers do
      # Ensure eager_load Action model to init methods
      require "action"
    end
  end
end
