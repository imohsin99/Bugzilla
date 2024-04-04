# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if user.manager?
        scope.where(manager: user)
      elsif user.qa?
        scope.all
      else
        user.projects_assigned
      end
    end
  end

  def show?
    if user.developer?
      record.assigned_users.exists?(user.id)
    elsif user.manager?
      record.manager == user
    else
      true
    end
  end

  def new?
    user.manager?
  end

  def create?
    new?
  end

  def edit?
    user.manager? && user == record.manager
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  def remove_user?
    edit?
  end
end
