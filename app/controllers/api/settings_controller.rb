class Api::SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
    categories = current_user.activities.map do |a|
      { id: a.id, name: a.name, icon: a.icon, active: a.active }
    end
    render json: {
      name:       current_user.name,
      email:      current_user.email,
      categories: categories
    }
  end
end
