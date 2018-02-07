# frozen_string_literal: true
require "test_helper"

class ActionTest < ActiveSupport::TestCase
  test "work" do
    action = Action.new
    assert_kind_of Action, action
  end
end
