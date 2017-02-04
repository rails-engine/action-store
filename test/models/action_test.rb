require 'test_helper'

class ActionTest < ActiveSupport::TestCase
  test ".user" do
    action = Action.new
    assert action.respond_to?(:user), true
  end

  test ".target" do
    action = Action.new
    assert action.respond_to?(:target), true
  end
end