class Customer::CartController < ApplicationController
  before_action :set_current_cart
  before_action :set_cart_item, only: %i[update_item remove_item]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def show
    @cart_items = @current_cart.cart_items.includes(:product).order(created_at: :asc)

    @united_states = Country.find_by(name: 'United States')
    @california = State.find_by(name: 'California', country: @united_states)
    @countries = [@united_states].compact # 中身がnilでも必ず配列を作成する
    @states = [@california].compact

    # もしフォームにデータがあれば読み込む
    if session[:checkout_params]
      @checkout = Checkout.new(session[:checkout_params])
      # 一度利用したsessionを無駄に保持するとエラーの温床なのでクリアして更新に備える
      # session.delete(:checkout_params)
    else
      @checkout = Checkout.new
      @checkout.build_credit_card # has_oneのときの書き方。has_manyは.build
    end
    # なぜかリダイレクト後にpayment以下が消えちゃう
    # CreditCardオブジェクトが存在しない場合にビルド
    @checkout.build_credit_card unless @checkout.credit_card
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

    if quantity.positive?
      # 数量更新に上記で変換したquantityを使用 キーワード引数省略
      if @cart_item.update(quantity:)
        flash[:notice] = '数量を更新しました'
      else
        # 更新に失敗したとき
        flash[:alert] = @cart_item.errors.full_messages.join(', ') # エラーメッセージを表示
      end
    else
      @cart_item.destroy
      flash[:notice] = 'カートから商品を削除しました'
    end

    checkout_data = extract_checkout_data_from_params
    session[:checkout_params] = checkout_data if checkout_data.present?
    # 数量更新に成功/失敗、あるいはアイテム削除された後
    # チェックアウトフォームの入力内容を保持するため、セッションに保存する
    if params[:checkout].present?
      session[:checkout_params] = checkout_data
    end

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

  private

  # 必然性のある項目なので例外の出るfindをあえて利用
  def set_cart_item
    @cart_item = @current_cart.cart_items.find(params[:id])
  end

  # Product.find または CartItem.find で ActiveRecord::RecordNotFound が発生した場合
  def handle_record_not_found
    redirect_to cart_path, alert: '指定されたアイテムは見つかりませんでした'
  end

  def extract_checkout_data_from_params
    checkout_data = {}
    
    # 基本フィールドの抽出
    [:first_name,
     :last_name,
     :username,
     :email,
     :address1,
     :address2,
     :country_id,
     :state_id,
     :zip,
     :shipping_same_as_billing,
     :save_info_for_next_time].each do |field|
      checkout_data[field] = params[field] if params[field].present?
    end
    
    # クレジットカード情報の抽出
    if params[:card_number].present?
      checkout_data[:credit_card_attributes] = {
        name_on_card: params[:name_on_card],
        card_number: params[:card_number],
        expiration_month: params[:expiration_month],
        expiration_year: params[:expiration_year]
      }.compact
    end
    
    checkout_data
  end
end
