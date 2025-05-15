class PurchaseMailer < ApplicationMailer
  def purchase_confirmation_email(checkout)
    @checkout = checkout
    @cart_items = @checkout.cart.cart_items

    mail(to: @checkout.email, subject: '購入明細')
  end
end
