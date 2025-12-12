# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # サインアップ時に name を許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    # アカウント編集時に name を更新
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
