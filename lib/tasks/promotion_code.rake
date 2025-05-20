# admin権限に
namespace :promotion_code do # 名称一致
  desc "Generate 10 promotion codes"
  task generate: :environment do
    10.times do
      code = SecureRandom.alphanumeric(7).upcase
      discount = rand(100..1000) # 100円から1000円でランダムに
      PromotionCode.create!(code: code, discount_amount: discount, active: true, used: false)
      puts "Generated code: #{code}, Discount: #{discount} JPY"
    end
    puts "Generated 10 promotion codes."
  end
end