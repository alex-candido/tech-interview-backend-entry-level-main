# frozen_string_literal: true

# == Schema Information
#
# Table name: carts
#
#  id           :bigint           not null, primary key
#  total_price  :decimal(10, 2)   default(0.0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  status       :integer          default("active"), not null
#  abandoned_at :datetime
#
FactoryBot.define do
  factory :cart do
    total_price { 0.0 }
    status { :active }
    abandoned_at { nil }

    trait :abandoned do
      status { :abandoned }
      abandoned_at { Faker::Time.backward(days: 10) }
    end

    trait :inactive do
      status { :inactive }
      abandoned_at { nil }
    end
  end
end
