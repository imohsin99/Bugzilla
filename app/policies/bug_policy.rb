# frozen_string_literal: true

class BugPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      raise raise Pundit::NotAuthorizedError unless check_scope

      scope.bugs
    end

    private

    def check_scope
      if user.developer?
        scope.assigned_users.exists?(user.id)
      elsif user.manager?
        scope.manager == user
      else
        true
      end
    end
  end

  def show?
    if user.qa?
      check_qa?
    elsif user.manager?
      record.project.manager == user
    else
      record.project.assigned_users.exists?(user.id)
    end
  end

  def new?
    user.qa?
  end

  def edit?
    new? && record.creator == user
  end

  def create?
    new?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  def assign?
    user.developer?
  end

  def update_status?
    user.developer? && record.developer == user
  end

  private

  def check_qa?
    record.creator == user
  end
end
