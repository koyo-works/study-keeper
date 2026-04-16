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
  end
end