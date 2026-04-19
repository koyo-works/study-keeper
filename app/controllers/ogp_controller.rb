class OgpController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def daily
    share_link = ShareLink.find_by(token: params[:token], share_type: :daily)
    return render file: "public/404.html", status: :not_found unless share_link

    date = share_link.target_date
    logs = share_link.user.records
                     .where(logged_at: date.beginning_of_day..date.end_of_day)
                     .includes(:activity)

    summary = WeeklySummaryService.new(logs).call
    total_minutes = summary.sum { |s| s[:total_minutes] }

    tmpfile = DailyOgpImageService.new(
      date: date,
      summary: summary,
      total_minutes: total_minutes
    ).call

    data = File.binread(tmpfile.path)
    send_data data, type: "image/png", disposition: "inline"
  ensure
    tmpfile&.close
    tmpfile&.unlink
  end

  def weekly
    share_link = ShareLink.find_by(token: params[:token], share_type: :weekly)
    return render file: "public/404.html", status: :not_found unless share_link

    date = share_link.target_date
    week_start = date.beginning_of_week(:monday)
    week_end = date.end_of_week(:monday)
    logs = share_link.user.records
                     .where(logged_at: week_start.beginning_of_day..week_end.end_of_day)
                     .includes(:activity)

    summary = WeeklySummaryService.new(logs).call
    total_minutes = summary.sum { |s| s[:total_minutes] }

    tmpfile = WeeklyOgpImageService.new(
      week_start: week_start,
      week_end: week_end,
      summary: summary,
      total_minutes: total_minutes
    ).call

    data = File.binread(tmpfile.path)
    send_data data, type: "image/png", disposition: "inline"
  ensure
    tmpfile&.close
    tmpfile&.unlink
  end
end
