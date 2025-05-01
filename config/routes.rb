# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'customer/products#index'

  namespace :admin do
    root to: 'products#index'
    resources :products, only: %i[index show new create edit update destroy]
  end

  scope module: :customer do
    resources :products, only: %i[index show]
    resources :cart, only: %i[index] do
      collection do
        delete :destroy
      end
    end
    get '/cart', to: 'cart#index', as: 'customer_cart'
    post '/cart/add_item', to: 'cart#add_item', as: 'add_item_customer_cart'
    patch '/cart/update_item/:id', to: 'cart#update_item', as: 'update_item_customer_cart'
    delete '/cart/remove_item/:id', to: 'cart#remove_item', as: 'remove_item_customer_cart'
    delete '/cart', to: 'cart#destroy', as: 'clear_cart'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
end
