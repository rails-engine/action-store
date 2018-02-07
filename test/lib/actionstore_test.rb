# frozen_string_literal: true
require "test_helper"

class ActionStoreTest < ActiveSupport::TestCase
  test ".config" do
    assert_kind_of ActionStore::Configuration, ActionStore.config
  end
end
