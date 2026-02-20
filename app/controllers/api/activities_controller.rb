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
end