# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'customer/products#index'

  namespace :admin do
    root to: 'products#index'
    resources :products
  end

  scope module: :customer do
    resources :products, only: %i[index show]

    resource :cart, only: %i[show destroy] do # 単数形でidなしの通常ルート
      collection do # idなしカスタムアクション
        post :add_item
        patch 'update_item/:id', action: :update_item # pathが文字列なのでaction明示
        delete 'remove_item/:id', action: :remove_item
      end
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
end
