class Customer::CartController < ApplicationController
  before_action :set_current_cart
  before_action :set_cart_item, only: %i[update_item remove_item]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def show
    @cart_items = @current_cart.cart_items.includes(:product).order(created_at: :asc)
    set_location_data
    initialize_checkout_form
  end

  # current_cartは現在のユーザーセッションに関連付けられているCartのobj
  def add_item
    product = Product.find(params[:product_id]) # Product.objを見つけ
    quantity = params[:quantity].present? ? params[:quantity].to_i : 1 # nilなら1に

    @current_cart.add_product(product, quantity) # 数量を渡してCartクラスのadd_productを呼び出し
    @current_cart.save # DBへ保存し,カートを離れても有効に

    redirect_to root_path, notice: "「#{product.name}」をカートに追加しました"
  end

  # カートの数値の直接更新
  def update_item
    quantity = params[:quantity].to_i

    return unless update_cart_item_quantity(quantity)

    save_checkout_data_to_session
    redirect_to cart_path
  end

  def remove_item
    @cart_item.destroy
    redirect_to cart_path, notice: 'カートから商品を削除しました'
  end

  def destroy
    @current_cart.cart_items.destroy_all
    redirect_to root_path, notice: 'カートを空にしました'
  end

  def apply_promo_code
    promo_code = params[:promo_code]

    # 有効なcodeを探す
    promotion_code = PromotionCode.find_by(code: promo_code, active: true, used: false)
    if promotion_code 
      @current_cart.apply_discount(promotion_code.discount_amount)
      # カートにコードの文字列を保存
      @current_cart.update_column(:promotion_code, promotion_code.code)
      promotion_code.update(used: true) # DB更新 一度だけ
      flash[:notice] = 'プロモーションコードを適用しました！'
    else
      flash[:alert] = '無効なプロモーションコードです'
    end

    redirect_to cart_path
  end

  private

  # 必然性のある項目なので例外の出るfindをあえて利用
  def set_cart_item
    @cart_item = @current_cart.cart_items.find(params[:id])
  end

  # Product.find または CartItem.find で ActiveRecord::RecordNotFound が発生した場合
  def handle_record_not_found
    redirect_to cart_path, alert: '指定されたアイテムは見つかりませんでした'
  end

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

  def update_cart_item_quantity(quantity)
    if quantity.positive?
      if @cart_item.update(quantity: quantity)
        flash[:notice] = '数量を更新しました'
      else
        flash[:alert] = @cart_item.errors.full_messages.join(', ') # エラーメッセージを表示
      end
    else
      @cart_item.destroy
      flash[:notice] = 'カートから商品を削除しました'
    end

    true # 処理完了
  end

  # 数量更新に成功/失敗、あるいはアイテム削除された後
  # チェックアウトフォームの入力内容を保持するため、セッションに保存する
  def save_checkout_data_to_session
    checkout_data = extract_checkout_data_from_params
    session[:checkout_params] = checkout_data if checkout_data.present?
  end

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
