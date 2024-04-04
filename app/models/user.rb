# frozen_string_literal: true

class User < ApplicationRecord
  has_many :projects, foreign_key: :manager_id, dependent: :destroy, inverse_of: :manager
  has_many :assignments, dependent: :delete_all
  has_many :projects_assigned, through: :assignments, source: :project
  has_many :bugs_created, foreign_key: :creator_id, class_name: 'Bug', inverse_of: :creator, dependent: :destroy
  has_many :bugs_assigned, foreign_key: :developer_id, class_name: 'Bug', inverse_of: :developer, dependent: :nullify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  enum user_type: { manager: 0, developer: 1, qa: 2 }

  validates :name, presence: true
  validates :user_type, inclusion: { in: %w[manager developer qa],
                                     message: :user_type_invalid }

  def name_with_email
    "#{email} (#{user_type})"
  end
end
