# frozen_string_literal: true

Rails.application.routes.draw do
  if Rails.env.development?
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
    # 開発環境でのメール確認用 Letter Opener Web
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
  end

  root to: 'customer/products#index'

  namespace :admin do
    root to: 'products#index'
    resources :products
    resources :orders, only: %i[index show]
  end

  scope module: :customer do
    resources :products, only: %i[index show]

    resource :cart, only: %i[show destroy], controller: 'cart' do
      post :add_item
      patch 'update_item/:id', action: :update_item, as: :update_item # pathが文字列なのでaction明示
      delete 'remove_item/:id', action: :remove_item, as: :remove_item

      post 'save_checkout_draft', on: :collection
      post :apply_promo_code, on: :collection
    end

    resource :checkout, only: [:create]
  end
end
