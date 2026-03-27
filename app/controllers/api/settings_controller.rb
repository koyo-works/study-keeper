class Api::SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: { name: current_user.name, email: current_user.email}
  end
end