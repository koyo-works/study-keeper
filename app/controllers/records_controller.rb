class RecordsController < ApplicationController
  before_action :authenticate_user!

  def analytics
    respond_to do |format|
      format.html do
        @week_study_count = week_activity_counts["勉強する"].to_i
        @week_recorded_days = calculate_week_recorded_days
        @week_study_ratio = calculate_week_study_ratio
        @today_records = today_records_timeline
      end

      format.json do
        render json: {
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
  end

  def today_records_timeline
    current_user.records
                .includes(:activity)
                .where(created_at: Time.zone.now.all_day)
                .order(created_at: :desc)
  end

  def chart_data_for_week
    data = current_user.records
      .where(created_at: Time.current.beginning_of_week..Time.current.end_of_week)
      .joins(:activity)
      .group("activities.name")
      .count

    {
      labels: data.keys,
      counts: data.values
    }
  end

  # 今週の記録日数
  def calculate_week_recorded_days
    current_user.records
                .where(created_at: Time.zone.now.all_week)
                .select(:created_at)
                .map { |r| r.created_at.to_date }
                .uniq
                .count
  end

  # 今週「勉強する」を選択した割合
  def calculate_week_study_ratio
    counts = week_activity_counts
    return 0 if counts.empty?

    study_count = counts["勉強する"].to_i
    total_count = counts.values.sum  # 全体の行動回数
    
    return 0 if total_count.zero?
    
    (study_count.to_f / total_count * 100).round(1)  # パーセンテージ
  end

end
