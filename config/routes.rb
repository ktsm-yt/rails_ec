# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'customer/products#index'

  namespace :admin do
    root to: 'products#index'
    resources :products
  end

  scope module: :customer do
    resources :products, only: %i[index show]

    resource :cart, only: %i[show destroy], controller: 'cart' do # 単数形でidなしの通常ルート
      post :add_item
      patch 'update_item/:id', action: :update_item, as: :update_item # pathが文字列なのでaction明示
      delete 'remove_item/:id', action: :remove_item, as: :remove_item
    end

    resource :checkout, only: [:create] 
  end
end
