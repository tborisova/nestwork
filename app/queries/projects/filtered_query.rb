# frozen_string_literal: true

module Projects
  class FilteredQuery
    attr_reader :base_scope, :params

    def initialize(base_scope, params)
      @base_scope = base_scope
      @params = params
    end

    def execute
      scope = base_scope
      scope = scope.where(status: params[:status]) if params[:status].present?
      scope = scope.where("projects.name LIKE ?", "%#{params[:name].strip}%") if params[:name].present?

      designer_ids = normalize_ids(params[:designer_ids])
      scope = scope.joins(:designers).where(designers: { id: designer_ids }) if designer_ids.present?

      client_ids = normalize_ids(params[:client_ids])
      scope = scope.joins(:clients).where(clients: { id: client_ids }) if client_ids.present?

      scope.includes(:designers, :clients, :firm)
    end

    private

    def normalize_ids(param) =  Array(param).reject(&:blank?).map(&:to_i)
  end
end
