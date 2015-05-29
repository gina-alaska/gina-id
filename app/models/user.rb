class User < ActiveRecord::Base
  include GinaAuthentication::UserModel
  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :slug, uniqueness: true
  has_many :approvals, dependent: :destroy
  belongs_to :legacy_user

  def slug_candidates
    [
      :name,
      :email,
      [:id, :name],
      [:id, :email],
      [:id, :name, :email]
    ]
  end

  def guest?
    new_record?
  end

  def make_activation_code
    Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def verify!
    update_attributes(verified: false, activation_code: make_activation_code)
  end

  def verified!
    update_attributes(verified: true, activation_code: nil)
  end

  def set_legacy_user!
    return unless legacy_user.nil?

    self.legacy_user = LegacyUser.where(email: email, active: true).first
    save

    if legacy_user
      authorizations.build(provider: 'google', uid: legacy_user.identity_url)
      verified!
    end
    save
  end

  def self.create_from_legacy_user(legacy_user)
    user = User.new(legacy_user.as_json(only:[:email], methods: [:name]))
    user.slug = legacy_user.login
    user.save

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
