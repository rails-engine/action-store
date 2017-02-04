# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'factory_girl'
FactoryGirl.definition_file_paths = [File.expand_path('../factories', __FILE__)]

require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)

ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../../db/migrate', __FILE__)
require "rails/test_help"
require 'minitest/mock'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

FactoryGirl.find_definitions

# Load fixtures from the engine
class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end
