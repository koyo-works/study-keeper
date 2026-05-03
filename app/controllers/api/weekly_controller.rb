class Api::WeeklyController < ApplicationController
  before_action :authenticate_user!

  def index
    base_date  = params[:week].present? ? Date.parse(params[:week]) : Date.current
    week_start = base_date.beginning_of_week(:monday)
    week_end   = base_date.end_of_week(:monday)

    logs    = current_user.records.in_week(base_date).includes(:activity).order(:logged_at)
    summary = WeeklySummaryService.new(logs).call
    streak  = StreakService.new(current_user, as_of: [week_end, Date.current].min).call

    prev_logs    = current_user.records.in_week(week_start - 1.week).includes(:activity).order(:logged_at)
    prev_summary = WeeklySummaryService.new(prev_logs).call

    total_seconds = summary.sum { |s| s[:total_seconds] }
    weekly_goal = current_user.weekly_goals.find_by(week_start: week_start)

    goal_activity = weekly_goal ? Activity.find_by(id: weekly_goal.activity_id) : nil

    share_link = ShareLink.find_or_create_by(
      user: current_user,
      share_type: :weekly,
      target_date: week_start
    )

    render json: {
      week_start:           week_start.iso8601,
      week_end:             week_end.iso8601,
      total_seconds:        total_seconds,
      summary:              summary,
      prev_summary:         prev_summary,
      streak_days:          streak,
      goal_activity_id:     weekly_goal&.activity_id,
      goal_activity_name:   goal_activity&.name,
      goal_activity_icon:   goal_activity&.icon,
      goal_percentage:      weekly_goal&.percentage || 50,
      share_token:          share_link.token
    }
  end
end
