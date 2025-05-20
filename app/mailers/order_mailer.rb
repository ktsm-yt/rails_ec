class OrderMailer < ApplicationMailer
  def order_confirmation_email(order)
    @order = order
    @cart_items = @order.order_items

    mail(to: @order.customer_email, subject: '注文内容のご確認')
  end
end
