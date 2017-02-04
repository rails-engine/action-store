require 'test_helper'

class ActionStoreTest < ActiveSupport::TestCase
  test '.config' do
    assert_kind_of ActionStore::Configuration, ActionStore.config
    assert_equal 'User', ActionStore.config.user_class
  end
end
