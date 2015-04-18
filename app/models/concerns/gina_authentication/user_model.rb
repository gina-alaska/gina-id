module GinaAuthentication
  module UserModel
    extend ActiveSupport::Concern

    included do
      attr_accessor :password, :password_confirmation, :current_password

      has_many :authorizations, dependent: :destroy

      validates :email, presence: true, uniqueness: true
      validates :password, confirmation: true
      validate :current_password_matches

      before_save :update_identity
    end

    def create_password_reset_code!
      self.update_attribute(:reset_code, SecureRandom.hex(13))
    end

    def clear_password_reset_code!
      self.update_attributes(reset_code: nil, force_password_reset: false)
    end

    def current_password_matches
      return if current_password.blank? or identity.nil?

      if !identity.authenticate(current_password)
        errors.add(:current_password, 'does not match')
      end
    end

    def validate_identity
      return if identity.nil?

      identity.valid?
    end

    def update_identity
      return if identity.nil?

      identity.update_attributes(email: email, password: password, password_confirmation: password_confirmation)
      identity.errors.each { |field,msg| errors.add(field, msg) } unless identity.valid?
    end

    def identity
      return nil unless auth = authorizations.where(provider: 'identity').first

      @identity ||= Identity.find(auth.uid)
    end

    def google_identity?
      authorizations.where(provider: 'google').count != 0
    end

    def update_from_hash!(hash)
      update_attributes(self.class.params_from_hash(hash))
    end

    def update_credentials(hash)
      update_attributes({
        token: hash['token'],
        expires_at: hash['expires_at']
      })
    end

    def clear_credentials
      # update_attributes({ token: nil, refresh_token: nil, expires_at: nil })
    end

    def to_s
      self.name
    end

    module ClassMethods
      def create_from_hash!(hash)
        user = create(params_from_hash(hash))
        user
      end

      def params_from_hash(hash)
        info = {
          name: hash['info']['name'],
          email: hash['info']['email']
        }
        info.merge!({ avatar: hash['info']['image'] }) unless hash['info']['image'].blank?
        info
      end
    end
  end
end
