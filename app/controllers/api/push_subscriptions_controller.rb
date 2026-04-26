class Api::PushSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    sub = current_user.push_subscriptions.find_or_initialize_by(endpoint: params[:endpoint])
    sub.p256dh = params[:p256dh]
    sub.auth   = params[:auth]
    sub.save!
    head :ok
  end

  def destroy
    current_user.push_subscriptions.find_by(endpoint: params[:endpoint])&.destroy
    head :ok
  end
end
