require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should show login page" do
    get :new

    assert_response :success
  end
end
