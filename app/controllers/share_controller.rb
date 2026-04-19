class ShareController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def daily
    @share_link = ShareLink.find_by(token: params[:token], share_type: :daily)
    return render file: 'public/404.html', status: :not_found unless @share_link
  
    date = @share_link.target_date
    logs = @share_link.user.records
                      .where(logged_at: date.beginning_of_day..date.end_of_day)
                      .includes(:activity)
    
    @date = date
    @summary = WeeklySummaryService.new(logs).call
    @total_minutes = @summary.sum { |s| s[:total_minutes] }
    @top_category = @summary.first

    @og_title = "#{@date.strftime('%Y年%-m月%-d日')}の記録 - Study-keeper"
    desc_parts = @summary.first(3).map { |s| "#{s[:activity_name]} #{s[:total_minutes]}分" }
    @og_desc = @summary.empty? ? "この日の記録はありません" : "合計#{@total_minutes / 60}時間#{@total_minutes % 60}分 / #{desc_parts.join(' / ')}"
  end

  def weekly
    @share_link = ShareLink.find_by(token: params[:token], share_type: :weekly)
    return render file: 'public/404.html', status: :not_found unless @share_link
  
    date = @share_link.target_date
    @week_start = date.beginning_of_week(:monday)
    @week_end = date.end_of_week(:monday)
    logs = @share_link.user.records
                      .where(logged_at: @week_start.beginning_of_day..@week_end.end_of_day)
                      .includes(:activity)
    
    @summary = WeeklySummaryService.new(logs).call
    @total_minutes = @summary.sum { |s| s[:total_minutes] }
    @top_categories = @summary.first(3)

    user = @share_link.user
    @streak = user.streak

    weekly_goal = WeeklyGoal.find_by(user: user, week_start: @week_start)
    if weekly_goal
      goal_activity = @summary.find { |s| s[:db_id] == weekly_goal.activity_id }
      @goal = {
        activity_name: goal_activity&.fetch(:activity_name),
        target_percentage: weekly_goal.percentage,
        actual_percentage: goal_activity ? goal_activity[:percentage] : 0
      }
    end

    week_range = "#{@week_start.strftime('%-m/%-d')} - #{@week_end.strftime('%-m/%-d')}"
    @og_title = "#{week_range}の記録 - Study-keeper"
    desc_parts = @top_categories.map { |s| "#{s[:activity_name]} #{s[:total_minutes] / 60}時間#{s[:total_minutes] % 60}分(#{s[:percentage]}%)" }
    @og_desc = @summary.empty? ? "この週の記録はありません" : "合計#{@total_minutes / 60}時間#{@total_minutes % 60}分 / #{desc_parts.join(' / ')}"
  end

end