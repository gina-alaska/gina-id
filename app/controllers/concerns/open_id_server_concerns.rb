require "openid"
require "openid/consumer/discovery"
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'

module OpenIdServerConcerns
  extend ActiveSupport::Concern

  include ServersHelper
  include OpenID::Server

  included do
  end

  protected

  def server
    if @server.nil?
      # server_url = url_for :action => 'index', :only_path => false
      dir = Rails.root.join('db').join('openid-store')
      store = OpenID::Store::Filesystem.new(dir)
      @server = Server.new(store, servers_url)
    end
    return @server
  end

  def approved(trust_root)
    return current_user.approvals.where(trust: trust_root).first.present?
  end

  def is_authorized(identity_url, trust_root)
    return (signed_in? && (identity_url == url_for_user) and self.approved(trust_root))
  end

  def render_xrds(types)
    type_str = ""

    types.each { |uri|
      type_str += "<Type>#{uri}</Type>\n      "
    }

    yadis = <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<xrds:XRDS
    xmlns:xrds="xri://$xrds"
    xmlns="xri://$xrd*($v*2.0)">
  <XRD>
    <Service priority="0">
      #{type_str}
      <URI>#{servers_url}</URI>
    </Service>
  </XRD>
</xrds:XRDS>
EOS

    render :text => yadis, :content_type => 'application/xrds+xml'
  end

  def add_sreg(oidreq, oidresp)
    # check for Simple Registration arguments and respond
    sregreq = OpenID::SReg::Request.from_openid_request(oidreq)

    return if sregreq.nil?
    # In a real application, this data would be user-specific,
    # and the user should be asked for permission to release
    # it.
    sreg_data = {
      'nickname' => current_user.name,
      'fullname' => current_user.name,
      'email' => current_user.email
    }

    sregresp = OpenID::SReg::Response.extract_response(sregreq, sreg_data)
    oidresp.add_extension(sregresp)
  end

  def add_pape(oidreq, oidresp)
    papereq = OpenID::PAPE::Request.from_openid_request(oidreq)
    return if papereq.nil?
    paperesp = OpenID::PAPE::Response.new
    paperesp.nist_auth_level = 0 # we don't even do auth at all!
    oidresp.add_extension(paperesp)
  end

  def render_response(oidresp)
    if oidresp.needs_signing
      signed_response = server.signatory.sign(oidresp)
    end
    web_response = server.encode_response(oidresp)

    case web_response.code
    when HTTP_OK
      render :text => web_response.body, :status => 200
    when HTTP_REDIRECT
      redirect_to web_response.headers['location']
    else
      render :text => web_response.body, :status => 400
    end
  end
end
