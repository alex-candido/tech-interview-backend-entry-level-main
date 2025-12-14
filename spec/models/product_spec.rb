# frozen_string_literal: true

# == Schema Information
#
# Table name: products
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  unit_price :decimal(10, 2)   not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe Product, type: :model do
  context "when validating" do
    it "validates presence of name" do
      product = described_class.new(unit_price: 100)
      expect(product.valid?).to be_falsey
      expect(product.errors[:name]).to include("can't be blank")
    end

    it "validates presence of unit_price" do
      product = described_class.new(name: "name")
      expect(product.valid?).to be_falsey
      expect(product.errors[:unit_price]).to include("can't be blank")
    end

    it "validates numericality of unit_price" do
      product = described_class.new(unit_price: -1)
      expect(product.valid?).to be_falsey
      expect(product.errors[:unit_price]).to include("must be greater than or equal to 0")
    end
  end
end
