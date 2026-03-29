class Api::ActivitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    activities = Activity.order(:id)

    render json: activities.map { |a| 
      {
        id: a.public_id,
        name: a.name,
        icon: a.icon
      }
    }
  end

  def create
    activity = current_user.activities.build(activity_params)
    if activity.save
      render json: { id: activity.id, name: activity.name, icon: activity.icon, active: activity.active }, status: :created
    else
      render json: { errors: activity.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def activity_params
    params.require(:activity).permit(:name, :icon)
  end
end