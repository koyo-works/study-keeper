class Api::DashboardStopController < ApplicationController
  before_action :authenticate_user!

  def create
    current_log = current_user.records
                               .where(ended_at: nil)
                               .order(logged_at: :desc)
                               .first

    if current_log.nil?
      render json: { ok: false, error: "計測中の記録がありません" }, status: :unprocessable_entity
      return
    end

    current_log.update!(ended_at: Time.current)

    render json: { ok: true }, status: :ok
  end
end
