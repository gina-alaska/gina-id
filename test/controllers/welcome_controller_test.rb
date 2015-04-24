require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should get index for logged out user" do
    get :index

    assert_response :success
  end

  test "should get index for logged in user" do
    login_user(:one)

    get :index
    assert_response :success
  end

  test "should get index for verified user" do
    user = users(:one)
    user.verified!

    login_user(:one)

    get :index
    assert_response :success    
  end
end
