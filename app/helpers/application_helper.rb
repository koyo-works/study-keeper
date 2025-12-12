# frozen_string_literal: true

module ApplicationHelper
  def logo_link_path
    user_signed_in? ? learning_path : root_path
  end
end
