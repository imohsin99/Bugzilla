# frozen_string_literal: true

module ProjectsHelper
  def assign_user_to_projects(project)
    User.where.not(user_type: 'manager').reject { |user| user.projects_assigned.exists?(project.id) }
  end

  def assign_selected_ids(project)
    users = project&.assigned_users
    users.ids
  end

  def fetch_user(assignment)
    assignment&.user
  end

  def unassign_bug(assignment, project)
    fetch_user(assignment).bugs_assigned.delete(Bug.where(project_id: project.id))
  end
end
