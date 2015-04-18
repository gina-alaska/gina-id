module GinaAuthentication
  module AuthorizationModel
    extend ActiveSupport::Concern

    included do
      belongs_to :user

      validates_presence_of :user_id, :uid, :provider
      validates_uniqueness_of :uid, :scope => :provider
    end

    def new_user?
      !!@new_user
    end

    def new_user=(value)
      @new_user = value
    end

    module ClassMethods
      def find_from_hash(hash)
        where(provider: hash['provider'], uid: hash['uid']).first
      end

      def create_from_hash(hash, user = nil)
        if user.nil? or user.new_record?
          user = User.create_from_hash!(hash)
        # else
        #   user.update_from_hash!(hash)
        end

        auth = create(:user => user, :uid => hash['uid'], :provider => hash['provider'])
        auth.new_user = true

        auth
      end
    end
  end
end
