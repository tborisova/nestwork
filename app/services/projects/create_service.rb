# frozen_string_literal: true

module Projects
  class CreateService
    Result = Struct.new(:success?, :project, :error, keyword_init: true)

    def initialize(firm:, params:)
      @firm = firm
      @params = params
    end

    def call
      project = firm.projects.build(project_attributes)

      ActiveRecord::Base.transaction do
        project.save!
        assign_members(project)
      end

      Result.new(success?: true, project: project)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(
        success?: false,
        project: e.record,
        error: e.record.errors.full_messages.first
      )
    end

    private

    attr_reader :firm, :params

    def project_attributes
      params.require(:project).permit(:name, :status)
    end

    def assign_members(project)
      client_ids.each { |id| project.projects_clients.create!(client_id: id) }
      designer_ids.each { |id| project.projects_designers.create!(designer_id: id) }
    end

    def client_ids
      normalize_ids(params.dig(:project, :client_ids))
    end

    def designer_ids
      normalize_ids(params.dig(:project, :designer_ids))
    end

    def normalize_ids(param)
      Array(param).reject(&:blank?).map(&:to_i)
    end
  end
end
