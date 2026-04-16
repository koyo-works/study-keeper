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
end