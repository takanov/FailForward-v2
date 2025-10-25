Rails.application.routes.draw do
  devise_for :users

  # ホームページ
  get "pages/home", to: "pages#home"

  # Failures (失敗管理)
  resources :failures do
    member do
      patch :complete
    end
  end

  # フィルター用のショートカットルート
  get "/completed", to: "failures#index", defaults: { filter: "completed" }
  get "/pending", to: "failures#index", defaults: { filter: "pending" }
  get "/overdue", to: "failures#index", defaults: { filter: "overdue" }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root to: "failures#index"
end
