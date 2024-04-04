# frozen_string_literal: true

class CreateAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :assignments do |t|
      t.belongs_to :user
      t.belongs_to :project

      t.timestamps
    end
  end
end
