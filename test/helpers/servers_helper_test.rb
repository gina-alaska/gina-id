require 'test_helper'

class ServersHelperTest < ActionView::TestCase
  setup do
    @user = users(:one)
    login_user(:one)
  end

  test "should return url for user" do
    assert_equal "/servers/#{@user.id}", url_for_user
  end

  def current_user
    @current_user ||= User.find(session[:user_id])
  end
end
