# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'customer/products#index'

  namespace :admin do
    root to: 'products#index'
    resources :products, only: %i[index show new create edit update destroy]
  end

  scope module: :customer do
    resources :products, only: %i[index show]
    resources :cart, only: %i[index destroy] do
      member do # cartのidを使用
        patch :update_item
        delete :remove_item
      end
      collection do # 不使用。商品のidで
        post :add_item
      end
    end
    # add_item_customer_cart_path ヘルパーを明示的に定義
    post '/cart/add_item', to: 'cart#add_item', as: 'add_item_customer_cart'

    # カート一覧ページへのルートとヘルパーを明示的に定義
    get '/cart', to: 'cart#index', as: 'customer_cart'
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
end
