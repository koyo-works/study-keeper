class Api::SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
    categories = current_user.activities.map do |a|
      { id: a.id, name: a.name, icon: a.icon, active: a.active }
    end
    render json: {
       name: current_user.name,
       email: current_user.email, 
       categories: categories,
       goal_activity_id: current_user.goal_activity_id,
       goal_percentage: current_user.goal_percentage 
      }
  end

  def update
    if current_user.update(goal_activity_id: params[:goal_activity_id], goal_percentage: params[:goal_percentage])
      render json: { goal_activity_id: current_user.goal_activity_id, goal_percentage: current_user.goal_percentage }
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

end