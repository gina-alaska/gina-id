class OmniAuth::Strategies::Identity
  def callback_phase
    # attempt to upgrade credentials
    upgrade_identity if record.nil? || !identity

    return fail!(:invalid_credentials) unless identity
    super
  end

  def record
    model.find_by(model.auth_key.to_sym => request["auth_key"])
  end

  def legacy_user
    @legacy_user ||= LegacyUser.authenticate(request['auth_key'], request['password'])
  end

  def upgrade_identity
    return if legacy_user.nil?

    Rails.logger.info "Attempting to upgrade user #{request['auth_key']}"

    attributes = options[:fields].inject({}){|h,k| h[k] = legacy_user.send(k.to_s); h}
    @identity = model.where(attributes).first_or_initialize do |identity|
      identity.password = request['password']
      identity.password_confirmation = request['password']
    end

    if @identity.save
      return if legacy_user.user.nil?
      legacy_user.user.authorizations.where(provider:'identity', uid: @identity.id).first_or_create
    else
      Rails.logger.info @identity.errors.full_messages
      @identity = nil
    end
  end
end
