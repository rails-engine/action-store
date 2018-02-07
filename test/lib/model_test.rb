# frozen_string_literal: true
require "test_helper"

class ActionStore::ModelTest < ActiveSupport::TestCase
  test ".user" do
    action = Action.new
    assert_equal true, action.respond_to?(:user)
  end

  test ".target" do
    action = Action.new
    assert_equal true, action.respond_to?(:target)
  end
end
