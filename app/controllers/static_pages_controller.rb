class StaticPagesController < ApplicationController
  def top;
    redirect_to learning_path if user_signed_in?
  end
end
