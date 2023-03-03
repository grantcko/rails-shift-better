Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  get "pages/main", to: "pages#main"
  get "pages/about_us", to: "pages#about_us"
  get "pages/contact", to: "pages#contact"


  post "/days", to: "days#create_month"
  resources :days, only: %i[index create show] do
    resources :preferences, only: %i[new create]
  end
  resources :shifts, only: %i[show]
  resources :assignments, only: %i[update]
  resources :preferences, only: %i[index]
end
