# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# seed.rbの修正版

# 既存のデータをクリア
Product.destroy_all

# Tasksの参照を削除（Tasksモデルが存在しない）
# Tasks.destroy_all の行を削除

products = [
  # Fancy Product: 通常価格 $40.00
  { name: "Fancy Product", price: 40.00, original_price: 40.00, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg", on_sale: false, description: "A fancy product for special occasions." },
  # Special Item: セール価格 \$18.00 (旧価格 \$20.00)
  { name: "Special Item", price: 18.00, original_price: 20.00, rating: 5, on_sale: true, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg", description: "A special item at a discounted price." },
  # Sale Item: セール価格 \$25.00 (旧価格 \$50.00)
  { name: "Sale Item", price: 25.00, original_price: 50.00, on_sale: true, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg", description: "Great item now on sale!" },
  # Popular Item: 通常価格 $40.00
  { name: "Popular Item", price: 40.00, original_price: 40.00, rating: 5, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg", on_sale: false, description: "Our most popular item." },
  # Sale Item: セール価格 \$25.00 (旧価格 \$50.00)
  { name: "Sale Item", price: 25.00, original_price: 50.00, on_sale: true, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg", description: "Another great item on sale!" },
  # Fancy Product: 通常価格 $120.00
  { name: "Fancy Product 2", price: 120.00, original_price: 120.00, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg", on_sale: false, description: "Premium fancy product with extra features." },
  # Special Item: セール価格 \$18.00 (旧価格 \$20.00)
  { name: "Special Item 2", price: 18.00, original_price: 20.00, rating: 5, on_sale: true, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg", description: "Another special item at a great price." },
  # Popular Item: 通常価格 $40.00
  { name: "Popular Item 2", price: 40.00, original_price: 40.00, rating: 5, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg", on_sale: false, description: "Another customer favorite." }
]

# 各商品を作成
products.each do |product_attrs|
  # バリデーションを有効にしながら保存するか、必要ならバリデーションをスキップ
  product = Product.new(product_attrs)
  # 必要に応じてバリデーションをスキップ（descriptionを追加してあるのでおそらく不要）
  # product.save(validate: false)
  product.save!(validate: false)
end

puts "Created #{Product.count} products."