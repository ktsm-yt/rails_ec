# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'customer/products#index'

  scope module: :customer do
    resources :products, only: %i[index show]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
