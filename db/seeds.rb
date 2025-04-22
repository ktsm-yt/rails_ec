# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
Product.destroy_all

Product.create!([
  # Fancy Product: 通常価格 $40.00 (価格範囲ではなくなった)
  # original_price は nil か price と同じ値にする
  { name: "Fancy Product", price: 40.00, original_price: 40.00, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg", on_sale: false },
  # Special Item: セール価格 $18.00 (旧価格 $20.00)
  { name: "Special Item", price: 18.00, original_price: 20.00, rating: 5, on_sale: true, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg" },
  # Sale Item: セール価格 $25.00 (旧価格 $50.00)
  { name: "Sale Item", price: 25.00, original_price: 50.00, on_sale: true, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg" },
  # Popular Item: 通常価格 $40.00
  { name: "Popular Item", price: 40.00, original_price: 40.00, rating: 5, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg", on_sale: false },
  # Sale Item: セール価格 $25.00 (旧価格 $50.00)
  { name: "Sale Item", price: 25.00, original_price: 50.00, on_sale: true, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg" },
  # Fancy Product: 通常価格 $120.00 (価格範囲ではなくなった)
  { name: "Fancy Product", price: 120.00, original_price: 120.00, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg", on_sale: false },
  # Special Item: セール価格 $18.00 (旧価格 $20.00)
  { name: "Special Item", price: 18.00, original_price: 20.00, rating: 5, on_sale: true, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg" },
  # Popular Item: 通常価格 $40.00
  { name: "Popular Item", price: 40.00, original_price: 40.00, rating: 5, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg", on_sale: false }
])

puts "Created #{Product.count} products."