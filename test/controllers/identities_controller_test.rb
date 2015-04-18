require 'test_helper'

class IdentitiesControllerTest < ActionController::TestCase
  setup do
    @identity = identities(:one)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should destroy identity" do
    assert_difference('Identity.count', -1) do
      delete :destroy, id: @identity
    end

    assert_redirected_to identities_path
  end
end
