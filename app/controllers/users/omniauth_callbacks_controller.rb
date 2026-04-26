class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    else
      session["devise.google_data"] = auth.except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join(", ")
    end
  end

  def github
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?
    else
      session["devise.github_data"] = auth.except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join(", ")
    end
  end

  def twitter
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "X") if is_navigational_format?
    else
      session["devise.twitter_data"] = auth.except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join(", ")
    end
  end

  def failure
    redirect_to new_user_session_path, alert: "ログインに失敗しました。"
  end
end
