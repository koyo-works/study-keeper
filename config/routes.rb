# frozen_string_literal: true

Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root 'static_pages#top'
  get 'terms', to: 'static_pages#terms', as: :terms
  get 'privacy', to: 'static_pages#privacy', as: :privacy

  get  'learning_path', to: 'study_records#new', as: :learning
  post 'learning_path', to: 'study_records#create'

  get 'weekly', to: 'weekly#index', as: :weekly
  get 'monthly', to: 'monthly#index', as: :monthly
  get 'settings', to: 'settings#index', as: :settings

  get 'analytics_path', to: 'records#analytics', as: 'analytics_records'
  resources :records

  get 'share/daily/:token', to: 'share#daily', as: :share_daily
  get 'share/weekly/:token', to: 'share#weekly', as: :share_weekly

  get 'ogp/daily/:token', to: 'ogp#daily', as: :ogp_daily
  get 'ogp/weekly/:token', to: 'ogp#weekly', as: :ogp_weekly

  namespace :api do
    get "dashboard/today", to: "dashboard#today"
    get "activities", to: "activities#index"
    post "activities", to: "activities#create"
    patch "activities/:id", to: "activities#update"
    delete "activities/:id", to: "activities#destroy"
    post "dashboard/logs", to: "dashboard_logs#create"
    post "dashboard/stop", to: "dashboard_stop#create"
    get "weekly", to: "weekly#index"
    get "monthly", to: "monthly#index"
    get "days/:date", to: "days#show"
    get "settings", to: "settings#show"
    patch "settings", to: "settings#update"
    post "weekly_goals/upsert", to: "weekly_goals#upsert"
  end
end
