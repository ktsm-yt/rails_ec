# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# seed.rbの修正版
require 'fileutils'
image_dir = Rails.root.join('db', 'seeds', 'images')

# 既存のデータをクリア
Product.destroy_all

products = [
  # Fancy Product: 通常価格 $40.00
  { name: "Fancy Product", price: 40.00, original_price: 40.00, image_filename: "dummy450.jpg", on_sale: false, description: "A fancy product for special occasions." },
  # Special Item: セール価格 \$18.00 (旧価格 \$20.00)
  { name: "Special Item", price: 18.00, original_price: 20.00, rating: 5, on_sale: true, image_filename: "dummy450.jpg", description: "A special item at a discounted price." },
  # Sale Item: セール価格 \$25.00 (旧価格 \$50.00)
  { name: "Sale Item", price: 25.00, original_price: 50.00, on_sale: true, image_filename: "dummy450.jpg", description: "Great item now on sale!" },
  # Popular Item: 通常価格 $40.00
  { name: "Popular Item", price: 40.00, original_price: 40.00, rating: 5, image_filename: "dummy450.jpg", on_sale: false, description: "Our most popular item." },
  # Sale Item: セール価格 \$25.00 (旧価格 \$50.00)
  { name: "Sale Item", price: 25.00, original_price: 50.00, on_sale: true, image_filename: "dummy450.jpg", description: "Another great item on sale!" },
  # Fancy Product: 通常価格 $120.00
  { name: "Fancy Product 2", price: 120.00, original_price: 120.00, image_filename: "dummy450.jpg", on_sale: false, description: "Premium fancy product with extra features." },
  # Special Item: セール価格 \$18.00 (旧価格 \$20.00)
  { name: "Special Item 2", price: 18.00, original_price: 20.00, rating: 5, on_sale: true, image_filename: "dummy450.jpg", description: "Another special item at a great price." },
  # Popular Item: 通常価格 $40.00
  { name: "Popular Item 2", price: 40.00, original_price: 40.00, rating: 5, image_filename: "dummy450.jpg", on_sale: false, description: "Another customer favorite." }
]


puts "Created #{Product.count} products."

products.each do |product_attrs|
  image_filename = product_attrs.delete(:image_filename) # ハッシュから画像ファイル名を取得し、属性リストからは削除
  image_path = image_dir.join(image_filename)

  # Productオブジェクトを作成 (まだ保存しない)
  product = Product.new(product_attrs)

  # 画像ファイルが存在するか確認
  if File.exist?(image_path)
    # ファイルを開いて画像をアタッチ
    product.image.attach(io: File.open(image_path), filename: image_filename)
    puts "Attaching image: #{image_filename} to #{product.name}"
  else
    puts "Warning: Image file not found at #{image_path}. Skipping image attachment for #{product.name}."
  end

   # バリデーションを実行して保存
   if product.save
    puts "Successfully created product: #{product.name}"
  else
    puts "Failed to create product: #{product.name}. Errors: #{product.errors.full_messages.join(', ')}"
    # エラーがあった場合、必要ならここで処理を中断するか、ログを詳細に残す
    # raise "Failed to save product: #{product.name}" # 例: エラーで停止する場合
  end
end

puts "Finished creating #{Product.count} products."