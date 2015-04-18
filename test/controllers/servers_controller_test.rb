require 'test_helper'

class ServersControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should render show" do
    get :show

    assert_response :success
  end
end
