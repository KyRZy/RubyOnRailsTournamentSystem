Rails.application.routes.draw do
  resources :matches
  resources :participants
  resources :teams
  resources :tournaments
  devise_for :users
  get 'home/about'
  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
