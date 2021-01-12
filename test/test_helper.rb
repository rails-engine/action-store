# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "factory_bot"
FactoryBot.definition_file_paths = [File.expand_path("factories", __dir__)]

require "simplecov"
if ENV["CI"] == "true"
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
SimpleCov.start "rails" do
  add_filter "lib/action_store/version"
  add_filter "lib/generators"
end

require File.expand_path("../test/dummy/config/environment.rb", __dir__)

ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)
require "rails/test_help"
require "minitest/mock"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

FactoryBot.find_definitions

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  parallelize
end

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = "#{ActiveSupport::TestCase.fixture_path}/files"
  ActiveSupport::TestCase.fixtures :all
end
