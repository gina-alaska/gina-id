class ServersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  include OpenIdServerConcerns
  layout nil

  def index
    begin
      oidreq = server.decode_request(params)
    rescue ProtocolError => e
      # invalid openid request, so just display a page with an error message
      render :text => e.to_s, :status => 500
      return
    end

    # no openid.mode was given
    unless oidreq
      render :text => "This is an OpenID server endpoint."
      return
    end

    oidresp = nil

    if oidreq.kind_of?(CheckIDRequest)

      identity = oidreq.identity

      if oidreq.id_select
        if oidreq.immediate
          oidresp = oidreq.answer(false)
        elsif !signed_in?
          # The user hasn't logged in.
          save_current_location
          redirect_to signin_path
          # show_decision_page(oidreq)
          return
        else
          # Else, set the identity to the one the user is using.
          identity = url_for_user
        end
      end

      if oidresp
        nil
      elsif self.is_authorized(identity, oidreq.trust_root)
        oidresp = oidreq.answer(true, nil, identity)

        # add the sreg response if requested
        add_sreg(oidreq, oidresp)
        # ditto pape
        add_pape(oidreq, oidresp)

      elsif oidreq.immediate
        server_url = url_for :action => 'index'
        oidresp = oidreq.answer(false, server_url)

      else
        oidresp = approve(oidreq)
      end

    else
      oidresp = server.handle_request(oidreq)
    end

    self.render_response(oidresp)
  end

  def create
    index
  end

  def show_decision_page(oidreq, message="Do you trust this site with your identity?")
    oidreq_cache = OidRequest.create(request: oidreq)
    session[:last_oidreq] = oidreq_cache.to_global_id.to_s
    @oidreq = oidreq

    if message
      flash[:notice] = message
    end

    if !signed_in?
      redirect_to signin_path
    else
      render 'decide', layout: 'application'
    end
  end

  def show
    # Yadis content-negotiation: we want to return the xrds if asked for.
    accept = request.env['HTTP_ACCEPT']

    # This is not technically correct, and should eventually be updated
    # to do real Accept header parsing and logic.  Though I expect it will work
    # 99% of the time.
    if accept and accept.include?('application/xrds+xml')
      user_xrds
      return
    end

    user = User.friendly.find(params[:id])
    # content negotiation failed, so just render the user page
    xrds_url = user_xrds_server_url(params[:id])
    identity_page = <<EOS
<html><head>
<meta http-equiv="X-XRDS-Location" content="#{xrds_url}" />
<link rel="openid.server" href="#{servers_url}" />
</head><body><p>OpenID identity page for #{user.try(:name)}</p>
</body></html>
EOS

    # Also add the Yadis location header, so that they don't have
    # to parse the html unless absolutely necessary.
    response.headers['X-XRDS-Location'] = xrds_url
    render :text => identity_page
  end

  def user_xrds
    types = [
             OpenID::OPENID_2_0_TYPE,
             OpenID::OPENID_1_0_TYPE,
             OpenID::SREG_URI
            ]

    render_xrds(types)
  end

  def xrds
    types = [ OpenID::OPENID_IDP_2_0_TYPE ]

    render_xrds(types)
  end

  def approve(oidreq)
    identity = url_for_user
    current_user.approvals.where(trust: oidreq.trust_root).first_or_create

    oidresp = oidreq.answer(true, nil, identity)
    add_sreg(oidreq, oidresp)
    add_pape(oidreq, oidresp)

    oidresp
  end

  def decision
    oidreq_cache = GlobalID::Locator.locate(session[:last_oidreq])
    oidreq = oidreq_cache.try(:request)

    oidreq_cache.destroy
    session[:last_oidreq] = nil

    if params[:yes].nil?
      redirect_to oidreq.cancel_url
      return
    else
      id_to_send = current_user.id
      identity = oidreq.identity
      if oidreq.id_select
        if id_to_send and id_to_send != ""
          # session[:username] = id_to_send
          # session[:approvals] = []
          identity = url_for_user
          logger.info identity
        else
          msg = "You must enter a username to in order to send " +
            "an identifier to the Relying Party."
          show_decision_page(oidreq, msg)
          return
        end
      end

      current_user.approvals.where(trust: oidreq.trust_root).first_or_create

      oidresp = oidreq.answer(true, nil, identity)
      add_sreg(oidreq, oidresp)
      add_pape(oidreq, oidresp)
      return self.render_response(oidresp)
    end
  end


end
