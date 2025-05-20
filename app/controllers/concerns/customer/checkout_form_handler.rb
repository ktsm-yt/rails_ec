module Customer
  module CheckoutFormHandler
    extend ActiveSupport::Concern

    def set_location_data
      @united_states = Country.find_by(name: 'United States')
      @california = State.find_by(name: 'California', country: @united_states)
      @countries = [@united_states].compact # 中身がnilでも必ず配列を作成する
      @states = [@california].compact
    end

    # showメソッドからチェックアウトフォームを抽出
    def initialize_checkout_form
      # もしフォームにデータがあれば読み込む
      if session[:checkout_params]
        @checkout = Checkout.new(session[:checkout_params])
      else
        @checkout = Checkout.new
        @checkout.build_credit_card # has_oneのときの書き方。has_manyは.build
      end
      # CreditCardオブジェクトが存在しない場合にビルド
      @checkout.build_credit_card unless @checkout.credit_card
    end

    # セッションにチェックアウトデータを保存
    def save_checkout_data_to_session
      checkout_data = extract_checkout_data_from_params
      session[:checkout_params] = checkout_data if checkout_data.present?
    end

    private

    # パラメータからチェックアウトデータを抽出
    def extract_checkout_data_from_params
      checkout_data = {}
      # 基本フィールドの抽出
      %i[first_name
         last_name
         username
         email
         address1
         address2
         country_id
         state_id
         zip
         shipping_same_as_billing
         save_info_for_next_time].each do |field|
        checkout_data[field] = params[field] if params[field].present?
      end

      add_credit_card_attributes(checkout_data)

      checkout_data
    end

    # クレジットカード情報の抽出
    def add_credit_card_attributes(checkout_data)
      return checkout_data if params[:card_number].blank?

      checkout_data[:credit_card_attributes] = {
        name_on_card: params[:name_on_card],
        card_number: params[:card_number],
        expiration_month: params[:expiration_month],
        expiration_year: params[:expiration_year],
        cvv: params[:cvv]
      }.compact

      checkout_data
    end
  end
end
