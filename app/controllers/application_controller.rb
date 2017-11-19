class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  after_filter :flash_to_headers
  
  protected
  
  def configure_permitted_parameters
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  def authenticate_user!
    if user_signed_in?
      super
    else
      flash[:warning] = "Only logged in users can access this page."
      redirect_to new_user_session_path
    end
  end

  def flash_to_headers
    return unless request.xhr?
    response.headers['X-Message'] = flash[:success]  unless flash[:success].blank?
    response.headers['X-Message'] = flash[:error]  unless flash[:error].blank?
  
    flash.discard  # don't want the flash to appear when you reload page
  end
end
