# frozen_string_literal: true

require "test_helper"

module ActionStore
  class ModelTest < ActiveSupport::TestCase
    test ".user" do
      action = Action.new
      assert_equal true, action.respond_to?(:user)
    end

    test ".target" do
      action = Action.new
      assert_equal true, action.respond_to?(:target)
    end
  end
end
