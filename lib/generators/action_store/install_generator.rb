# frozen_string_literal: true

require "rails/generators"
module ActionStore
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Create ActionStore's base files"
      source_root File.expand_path("../../../../", __FILE__)

      def add_initializer
        template "config/initializers/action_store.rb", "config/initializers/action_store.rb"
      end

      def add_migrations
        exec("rake action_store:install:migrations")
      end
    end
  end
end
