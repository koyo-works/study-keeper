# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  protected
  
  def after_sign_in_path_for(resource)
    case resource.default_page
    when "weekly"  then weekly_path
    when "monthly" then monthly_path
    else                learning_path
    end
  end
end
