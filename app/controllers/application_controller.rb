# frozen_string_literal: true
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  # 404 ステータスコード
  def record_not_found
    head :not_found
  end
end
