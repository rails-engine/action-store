require 'rails/generators'
module ActionStore
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Create ActionStore's base files"
      source_root File.expand_path('../../../../', __FILE__)

      def add_initializer
        path = "#{Rails.root}/config/initializers/action_store.rb"
        template 'config/initializers/action_store.rb', path
      end

      def add_models
        path = "#{Rails.root}/app/models/action.rb"
        template 'app/models/action.rb', path
      end

      def add_migrations
        exec('rake action_store:install:migrations')
      end
    end
  end
end
