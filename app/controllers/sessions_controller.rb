class SessionsController < ApplicationController
  protect_from_forgery :except => [:create, :failure]
  include GinaAuthentication::Sessions

  def new
  end
end
