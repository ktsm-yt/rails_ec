# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'customer/products#index'

  namespace :admin do
    root to: 'products#index'
    resources :products, only: %i[index show new create edit update destroy]
  end

  scope module: :customer do
    resources :products, only: %i[index show]
    resources :cart, only: [:index]
    post 'carts/add_item/:product_id',to: 'carts#add_item', as: :add_item
    patch 'carts/update_item/:id', to: 'carts#update_item', as: :update_item
    delete 'cart/remove_item/:id', to: 'carts#remove_item', as: :remove_item
    delete 'cart', to: 'carts#destroy', as: :empty_cart
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
end
