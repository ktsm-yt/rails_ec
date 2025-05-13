class Customer::CartController < ApplicationController
  before_action :set_current_cart
  before_action :set_cart_item, only: %i[update_item remove_item]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def show
    @cart_items = @current_cart.cart_items.includes(:product).order(created_at: :asc)

    @united_states = Country.find_by(name: 'United States')
    @california = State.find_by(name: 'California', country: @united_states) 
    # 中身がnilでも必ず配列を作成する
    @countries = [@united_states].compact
    @states = [@california].compact

    # もしフォームにデータがあれば読み込む
    if session[:checkout_params]
      @checkout = Checkout.new(session[:checkout_params])
      # 一度利用したsessionを無駄に保持するとエラーの温床なのでクリアして更新に備える
      session.delete(:checkout_params)
    else
      @checkout = Checkout.new
      @checkout.build_credit_card # has_oneのときの書き方。普通は.build
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
      # 数量更新に変換したquantityを使用 キーワード引数省略
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

  def set_current_cart
    @current_cart = Cart.find_or_create_by(session_id: session.id.to_s)
  end

  # Product.find または CartItem.find で ActiveRecord::RecordNotFound が発生した場合
  def handle_record_not_found
    redirect_to cart_path, alert: '指定されたアイテムは見つかりませんでした'
  end
end
