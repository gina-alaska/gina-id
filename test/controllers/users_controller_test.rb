require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "updating user email should trigger verification" do
    login_user(:one)

    put :update, id: users(:one).id, user: { email: 'asdasdf@asdfasdf.com' }

    assert_not assigns(:user).verified?
    assert_not_nil assigns(:user).activation_code
  end

  test "should get index for logged in user" do
    login_user(:one)
    get :index

    assert_response :success
  end

  test "index should redirect to root when not logged in" do
    get :index
    assert_redirected_to root_path
  end

  test "should render update action" do
    put :update, id: users(:one).id, user: { name: 'Testing', email: 'foo@foo.com' }

    assert_not_nil assigns(:user)
    assert_redirected_to users_path
  end

  test "should render forgot password action" do
    get :forgot_password

    assert_response :success
  end

  test "should render send reset instructions action" do
    post :send_reset_instructions, email: 'test@test.com'

    assert_not_nil assigns(:user)
    assert_redirected_to root_path
  end

  test "should render reset password with code" do
    user = users(:one)
    user.create_password_reset_code!

    get :reset_password, reset_code: users(:one).reset_code

    assert_equal user, assigns(:user)
    assert assigns(:user).force_password_reset?, "User was not forced to change password"
    assert_response :success
  end

  test "should render reset password for signed in user" do
    login_user(:one)

    get :reset_password

    assert_equal users(:one), assigns(:user)
    assert_response :success
  end
end
