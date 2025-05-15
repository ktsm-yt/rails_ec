class OrderMailer < ApplicationMailer
  def order_confirmation_email(checkout)
    @checkout = checkout
    @cart_items = @checkout.cart.cart_items

    mail(to: @checkout.email, subject: '購入明細')
  end
end
