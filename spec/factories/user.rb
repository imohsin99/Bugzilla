# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.unique.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 6)}
    confirmed_at { Time.zone.now }
    traits_for_enum :user_type, { manager: 0, developer: 1, qa: 2 }
  end
end
