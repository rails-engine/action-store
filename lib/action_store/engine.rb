# frozen_string_literal: true

module ActionStore
  class Engine < ::Rails::Engine
    isolate_namespace ActionStore
  end
end
