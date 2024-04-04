# frozen_string_literal: true

FactoryBot.define do
  factory :bug do
    title { Faker::Lorem.sentence }
    bug_type { 'feature' }
    deadline { Time.now.utc + 20.days }
    project
  end
end
