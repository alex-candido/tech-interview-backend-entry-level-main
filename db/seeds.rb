# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

# Clears existing data to ensure idempotency when rerunning seeds
puts "Clearing existing data..."
CartItem.destroy_all
Cart.destroy_all
Product.destroy_all
puts "Existing data cleared."

# Creates a few products using FactoryBot
puts "Creating products..."
products = FactoryBot.create_list(:product, 10) # Creates 10 random products
puts "Created #{products.count} products."

puts "Seed process finished."
