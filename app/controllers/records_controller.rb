class RecordsController < ApplicationController
  before_action :authenticate_user!

  def analytics
    respond_to do |format|
      format.html
      format.json do
        render json: {
          today_activity_counts: today_activity_counts,
          today_total: today_activity_counts.values.sum,
          week: week_activity_counts,
          chart: chart_data_for_week
        }
      end
    end
  end

  private

  def week_activity_counts
    records = current_user.records
                          .joins(:activity)
                          .where(created_at: Time.zone.now.all_week)
                          .group("activities.name")
                          .count
    
    records                   
  end

  def today_records_timeline
    current_user.records
                .includes(:activity)
                .where(created_at: Time.zone.now.all_day)
                .order(created_at: :desc)
                .map do |record|
                  {
                    time: record.created_at.strftime("%H:%M"),
                    activity: record.activity.name,
                    memo: record.memo
                  }
                end
  end

  def today_activity_counts
    current_user.records
      .where(created_at: Time.zone.today.all_day)
      .joins(:activity)
      .group('activities.name')
      .count
  end

  def chart_data_for_week
    data = Record
      .where(created_at: Time.current.beginning_of_week..Time.current.end_of_week)
      .joins(:activity)
      .group("activities.name")
      .count

    {
      labels: data.keys,
      counts: data.values
    }
  end

  def calculate_week_summary
    counts = week_activity_counts
    return "今週はまだ記録がありません。" if counts.empty?

    total = counts.values.sum
    max_count = counts.values.max

    top_activities = counts.select { |_, v| v == max_count }.keys

    activity_text =
      if top_activities.size == 1
        "「#{top_activities.first}」"
      else
        top_activities.map { |a| "「#{a}」" }.join("、")
      end

    "今週は#{activity_text}を#{max_count}回行いました。全体では#{total}回の記録があります。"
  end

end
