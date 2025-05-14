# frozen_string_literal: true

class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  
  def set_current_cart
    @current_cart = Cart.find_or_create_by(session_id: session.id.to_s)
  end

  private

  # 404 ステータスコード 後の機能追加を見越して汎用的に
  def record_not_found
    head :not_found
  end
end
