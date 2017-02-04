require "action-store/version"
require "action-store/configuration"
require "action-store/engine"
require "action-store/model"

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