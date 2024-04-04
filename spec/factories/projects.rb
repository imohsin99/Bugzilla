# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph_by_chars }
  end
end
