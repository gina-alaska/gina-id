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
end
