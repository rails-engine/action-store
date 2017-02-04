require "action_store/version"
require "action_store/configuration"
require "action_store/engine"
require "action_store/model"

module ActionStore
  class << self
    def config
      return @config if defined?(@config)
      @config = Configuration.new
      @config.user_class = 'User'
      @config
    end

    def configure(&block)
      config.instance_exec(&block)
    end
  end
end