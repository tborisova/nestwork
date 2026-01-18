# frozen_string_literal: true

module PendingProducts
  class SelectOptionService
    Result = Struct.new(:success?, :product, :error, keyword_init: true)

    def initialize(pending_product:, option:)
      @pending_product = pending_product
      @option = option
    end

    def call
      ActiveRecord::Base.transaction do
        product = create_product
        pending_product.destroy!
        Result.new(success?: true, product: product)
      end
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success?: false, error: e.message)
    end

    private

    attr_reader :pending_product, :option

    def create_product
      Product.create!(
        room: pending_product.room,
        name: "#{pending_product.name} - #{option.name}",
        link: option.link,
        price: option.price,
        quantity: pending_product.quantity || 1,
        status: "pending"
      )
    end
  end
end
