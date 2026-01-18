# frozen_string_literal: true

module Products
  class StatusTransitionPolicy
    TRANSITIONS = {
      "approved" => [:designer, :client],
      "ordered" => [:designer],
      "delivered" => [:designer],
      "pending" => [:designer, :client]
    }.freeze

    def initialize(user:, project:)
      @user = user
      @project = project
    end

    def allowed?(new_status)
      allowed_roles = TRANSITIONS[new_status]
      return false unless allowed_roles

      user_roles.any? { |role| allowed_roles.include?(role) }
    end

    private

    attr_reader :user, :project

    def user_roles
      roles = []
      roles << :designer if user.designer_for_project?(project)
      roles << :client if user.client_for_project?(project)
      roles
    end
  end
end
