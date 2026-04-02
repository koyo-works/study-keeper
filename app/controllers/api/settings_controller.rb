class Api::SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
    categories = current_user.activities.map do |a|
      { id: a.id, name: a.name, icon: a.icon, active: a.active }
    end
    render json: {
      name:       current_user.name,
      email:      current_user.email,
      categories: categories,
      default_page: current_user.default_page || "daily"
    }
  end

  def update
    if current_user.update(default_page: params[:default_page])
      render json: { default_page: current_user.default_page }
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
