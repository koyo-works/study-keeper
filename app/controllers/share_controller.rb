class ShareController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def daily
    @share_link = ShareLink.find_by(token: params[:token], share_type: :daily)
    render file: 'public/404.html', status: :not_found unless @share_link
  end
end