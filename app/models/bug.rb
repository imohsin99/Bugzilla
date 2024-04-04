# frozen_string_literal: true

class Bug < ApplicationRecord
  belongs_to :project
  belongs_to :creator, class_name: 'User'
  belongs_to :developer, class_name: 'User', optional: true
  has_one_attached :screenshot

  delegate :title, to: :project, prefix: true
  delegate :email, to: :creator, prefix: true
  delegate :email, to: :developer, prefix: true

  enum status: { fresh: 0, started: 1, completed: 2, resolved: 3 }

  validates :title, :bug_type, :deadline, presence: true
  validates :title, uniqueness: true
  validates :bug_type, inclusion: { in: %w[feature bug], message: :bug_type_invalid }
  validate :validate_screenshot, :validate_creator, :validate_developer

  def check_status_param?(status)
    status.in?(Bug.statuses.keys)
  end

  private

  def validate_screenshot
    return unless screenshot.attached?

    errors.add(:screenshot, 'must be a png or gif') unless screenshot.content_type.in?(%w[image/png image/gif])
  end

  def validate_creator
    return unless creator

    errors.add(:creator, 'must be QA') unless creator.qa?
  end

  def validate_developer
    return unless developer

    errors.add(:developer, 'must be Developer') unless !developer || developer.developer?
  end
end
