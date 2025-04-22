# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

@products = [
      Product.new(name: "Fancy Product", price: "$40.00 - $80.00", image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg"),
      Product.new(name: "Special Item", price: 18.00, old_price: 20.00, rating: 5, on_sale: true, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg"),
      Product.new(name: "Sale Item", price: 25.00, old_price: 50.00, on_sale: true, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg"),
      Product.new(name: "Popular Item", price: 40.00, rating: 5, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg"),
      Product.new(name: "Sale Item", price: 25.00, old_price: 50.00, on_sale: true, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg"),
      Product.new(name: "Fancy Product", price: "$120.00 - $280.00", image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg"),
      Product.new(name: "Special Item", price: 18.00, old_price: 20.00, rating: 5, on_sale: true, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg"),
      Product.new(name: "Popular Item", price: 40.00, rating: 5, image_url: "https://dummyimage.com/450x300/dee2e6/6c757d.jpg")
    ]