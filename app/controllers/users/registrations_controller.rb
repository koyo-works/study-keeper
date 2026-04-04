# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    learning_path
  end

  def after_update_path_for(resource)
    settings_path
  end
end
