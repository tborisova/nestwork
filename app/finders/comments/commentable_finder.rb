# frozen_string_literal: true

module Comments
  class CommentableFinder
    TYPES = {
      product_id: Product,
      pending_product_id: PendingProduct,
      room_id: Room
    }.freeze

    def initialize(params)
      @params = params
    end

    def call
      TYPES.each do |param_key, model|
        id = params[param_key]
        return model.find_by(id: id) if id.present?
      end
      nil
    end

    def self.belongs_to_project?(commentable, project)
      case commentable
      when Product, PendingProduct
        commentable.room.project_id == project.id
      when Room
        commentable.project_id == project.id
      else
        false
      end
    end

    private

    attr_reader :params
  end
end
