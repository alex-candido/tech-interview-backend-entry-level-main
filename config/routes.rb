# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  resource :cart, only: [:show, :create] do
    post :add_item, to: "carts#update_item"
    delete ":product_id", to: "carts#remove_item"
  end

  resources :products

  mount Sidekiq::Web => "/sidekiq"
  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"
end
