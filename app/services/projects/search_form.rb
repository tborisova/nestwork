module Projects
  class SearchForm
    attr_reader :params, :user, :scope

    def initialize(user, params)
      @params = params
      @user = user
    end

    def execute
      @scope = user.designer? ? user.designer_projects : user.client_projects

      @scope = @scope.where(status: params[:status]) if params[:status].present?
      @scope = @scope.where("projects.name LIKE ?", "%#{params[:name].strip}%") if params[:name].present?

      designer_ids = normalize_ids(params[:designer_ids])
      if designer_ids.present?
        @scope = @scope.where(id: Project.joins(:designers).where(designers: { id: designer_ids }).select(:id))
      end

      client_ids = normalize_ids(params[:client_ids])
      if client_ids.present?
        @scope = @scope.where(id: Project.joins(:clients).where(clients: { id: client_ids }).select(:id))
      end

      @scope = @scope.includes(:designers, :clients, :firm)
    end

    def has_active_filters? = params.any { |key, value| value.present? }
    def designers_options = User.where(firm_id: user.firm_id).order(:name)
    def clients_options = User.joins(:firms_clients).where(firms_clients: { firm_id: user.firm_id }).distinct.order(:name)

    private

    def normalize_ids(param) =  Array(param).reject(&:blank?).map(&:to_i)
  end
end
