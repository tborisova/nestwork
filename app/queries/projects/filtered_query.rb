# frozen_string_literal: true

module Projects
  class FilteredQuery
    def initialize(base_scope, params)
      @base_scope = base_scope
      @params = params
    end

    def call
      scope = base_scope
      scope = scope.by_status(params[:status])
      scope = scope.search_by_name(params[:name])
      scope = filter_by_designers(scope)
      scope = filter_by_clients(scope)
      scope.includes(:designers, :clients, :firm).distinct.ordered_by_status
    end

    private

    attr_reader :base_scope, :params

    def filter_by_designers(scope)
      ids = normalize_ids(params[:designer_ids])
      ids.any? ? scope.with_designer(ids) : scope
    end

    def filter_by_clients(scope)
      ids = normalize_ids(params[:client_ids])
      ids.any? ? scope.with_client(ids) : scope
    end

    def normalize_ids(param)
      Array(param).reject(&:blank?).map(&:to_i)
    end
  end
end
