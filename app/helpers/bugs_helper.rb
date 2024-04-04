# frozen_string_literal: true

module BugsHelper
  def statuses_for_bugs(bug)
    Bug.statuses.reject do |key|
      (key == 'completed' && bug.bug_type == 'bug') or (key == 'resolved' && bug.bug_type == 'feature') or key == 'fresh'
    end
  end
end
