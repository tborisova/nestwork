# frozen_string_literal: true

module Projects
  class DetailedQuery
    ASSOCIATIONS = [
      :designers,
      :clients,
      {
        rooms: [
          { products: :comments },
          { pending_products: [:pending_product_options, :comments] },
          :comments,
          { plan_attachment: :blob },
          { plan_with_products_attachment: :blob }
        ]
      }
    ].freeze

    def initialize(base_scope)
      @base_scope = base_scope
    end

    def find(id)
      base_scope.includes(*ASSOCIATIONS).find(id)
    end

    private

    attr_reader :base_scope
  end
end
