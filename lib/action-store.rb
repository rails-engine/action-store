# frozen_string_literal: true

require "action_store/version"
require "action_store/configuration"
require "action_store/engine"
require "action_store/model"
require "action_store/mixin"

module ActionStore
  class << self
    def config
      return @config if defined?(@config)

      @config = Configuration.new
      @config
    end

    def configure(&block)
      config.instance_exec(&block)
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include ActionStore::Mixin
end
