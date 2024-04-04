# frozen_string_literal: true

class CreateBugs < ActiveRecord::Migration[5.2]
  def change
    create_table :bugs do |t|
      t.string :title, null: false
      t.string :description
      t.datetime :deadline
      t.string :bug_type, null: false
      t.integer :status, null: false, default: 0
      t.references :project, foreign_key: true
      t.references :creator
      t.references :developer

      t.timestamps
    end

    add_index :bugs, :title, unique: true
  end
end
