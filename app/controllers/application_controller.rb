# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name email password user_type])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name email password current_password])
  end

  def user_not_authorized
    flash[:alert] = I18n.t 'user_unauthorized'
    redirect_back fallback_location: root_path
  end

  def record_not_found
    flash[:alert] = I18n.t 'not_found'
    redirect_to root_path
  end
end
