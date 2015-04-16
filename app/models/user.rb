class User < ActiveRecord::Base
  include GinaAuthentication::UserModel

  def guest?
    new_record?
  end
end
