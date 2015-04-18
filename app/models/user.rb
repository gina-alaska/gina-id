class User < ActiveRecord::Base
  include GinaAuthentication::UserModel
  has_many :approvals, dependent: :destroy

  def guest?
    new_record?
  end

  def activation_code
    self[:activation_code] || make_activation_code!
  end

  def make_activation_code!
    self.update_attribute(:activation_code, Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join ))
    self.activation_code
  end

  def activate!
    self.update_attribute(:activation_code, '')
  end

  def activated?
    self[:activation_code].blank?
  end
end
