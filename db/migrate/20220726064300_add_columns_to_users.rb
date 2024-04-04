# frozen_string_literal: true

class AddColumnsToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users, bulk: true do |t|
      t.string :name, null: false, default: ''
      t.integer :user_type, null: false, default: 0
    end
  end
end
