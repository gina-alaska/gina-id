class IdentitiesController < ApplicationController
  before_action :set_identity, only: [:destroy]

  # GET /identities/new
  def new
    # @identity = Identity.new
    @identity = env['omniauth.identity'] || Identity.new
  end

  # DELETE /identities/1
  # DELETE /identities/1.json
  def destroy
    @identity.destroy
    respond_to do |format|
      format.html { redirect_to identities_url, notice: 'Identity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def create
    # NOTE: this gets called after omniauth-identity has created our information
    @identity = env['omniauth.identity'] || Identity.new

    UserMailer.new_user_notifications(@identity).deliver_later
    redirect_to root_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_identity
      @identity = Identity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def identity_params
      params.require(:identity).permit(:name, :email, :password_digest)
    end
end
