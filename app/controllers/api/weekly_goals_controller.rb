class Api::WeeklyGoalsController < ApplicationController
  before_action :authenticate_user!

  def upsert
    week_start = Date.parse(params[:week_start])
    activity = Activity.find_by(public_id: params[:activity_id])
    return render json: { errors: ["カテゴリが見つかりません"] }, status: :not_found unless activity

    goal = current_user.weekly_goals.find_or_initialize_by(week_start: week_start)
    if goal.update(activity_id: activity.id, percentage: params[:percentage])
      render json: {
        activity_id:   goal.activity_id,
        activity_name: activity.name,
        activity_icon: activity.icon,
        percentage:    goal.percentage,
        week_start:    goal.week_start
      }
    else
      render json: { errors: goal.errors.full_messages }, status: :unprocessable_entity
    end
  end
end