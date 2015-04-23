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

  def legacy_user
    @legacy_user ||= LegacyUser.where(email: email).first
  end

  def self.create_from_legacy_user(legacy_user)
    user = User.create(legacy_user.as_json(only:[:email], methods: [:name]))
    identity = Identity.new(user.as_json(only: [:name, :email]))
    p = SecureRandom.hex
    identity.password = p
    identity.password_confirmation = p
    identity.save

    user.authorizations.create(provider: 'identity', uid: identity.id)
    user.force_password_reset!
    user
  end
end
