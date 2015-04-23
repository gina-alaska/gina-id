require 'test_helper'

class ServersControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should render error for non openid request to index" do
    get :index

    assert_response :error
  end

  test "should render error for non openid request to create" do
    get :create

    assert_response :error
  end

  test "should render show" do
    get :show, id: users(:one)

    assert_response :success
  end
end
