require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "guest? returns true for new record" do
    user = User.new

    assert user.guest?, 'guest? did not return true for a new record'
  end

  test "guest? returns false for an existing user" do
    user = users(:one)

    assert_not user.guest?, 'guest? returned true for an existing user'
  end

  test "verified! should set verified to true" do
    user = users(:one)
    user.verified!

    assert user.verified?, 'User was not set to verified'
    assert_nil user.activation_code
  end

  test "verfiy! should mark user needing verification" do
    user = users(:one)

    user.verify!

    assert_not user.verified?, 'User was set as verified'
    assert_not_nil user.activation_code
  end
end
