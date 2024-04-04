# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :manager, class_name: 'User'
  has_many :assignments, dependent: :delete_all
  has_many :assigned_users, through: :assignments, source: :user, before_add: :validate_assign_user
  has_many :bugs, dependent: :destroy

  delegate :name, :email, to: :manager, prefix: true

  validate :validate_manager
  validates :title, :description, presence: true

  def assign_user(users)
    return unless users

    users.reject!(&:empty?)
    assigned_users << User.where(id: users)
  end

  private

  def validate_manager
    return unless manager

    errors.add(:manager_id, 'must be manager not developer or QA') unless manager.manager?
  end

  def validate_assign_user(assigned_user)
    return unless assigned_user.manager?

    raise ActiveRecord::Rollback
  end
end
