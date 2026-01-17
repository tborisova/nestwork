# frozen_string_literal: true

# Presenter for preparing room data for views/JavaScript consumption.
# Extracts complex data transformation logic from controllers.
class RoomPresenter
  DEFAULT_ROOMS = ["Living room", "Kitchen", "Master bedroom", "Master bathroom"].freeze

  def initialize(project)
    @project = project
  end

  # Build the complete rooms data structure for the project
  def rooms_data
    room_names.map { |name| build_room_data(name) }
  end

  # Calculate the total cost across all rooms
  def project_total
    rooms_data.sum { |room| room[:total] }
  end

  private

  attr_reader :project

  # Get all room names (default + existing custom rooms)
  def room_names
    existing_names = project.rooms.pluck(:name)
    (DEFAULT_ROOMS + existing_names).uniq
  end

  # Find room by name from preloaded rooms
  def find_room(name)
    project.rooms.find { |r| r.name == name }
  end

  # Build data structure for a single room
  def build_room_data(name)
    room = find_room(name)

    {
      name: name,
      room_id: room&.id,
      comments_count: room ? room.comments.size : 0,
      total: calculate_room_total(room),
      plan_url: room_plan_url(room),
      plan_with_products_url: room_plan_with_products_url(room),
      products: build_products_data(room),
      selections: build_selections_data(room)
    }
  end

  # Build products data for a room
  def build_products_data(room)
    return [] unless room

    room.products.map do |product|
      {
        id: product.id,
        name: product.name,
        price: product.price,
        link: product.link,
        quantity: product.quantity,
        status: product.status,
        comments_count: product.comments.size
      }
    end
  end

  # Build selections data for a room
  def build_selections_data(room)
    return [] unless room

    room.selections.map do |selection|
      {
        id: selection.id,
        name: selection.name,
        quantity: selection.quantity,
        comments_count: selection.comments.size,
        options: build_selection_options_data(selection)
      }
    end
  end

  # Build selection options data
  def build_selection_options_data(selection)
    selection.selection_options.map do |option|
      {
        id: option.id,
        name: option.name,
        price: option.price,
        link: option.link
      }
    end
  end

  # Calculate total cost for a room
  def calculate_room_total(room)
    return 0 unless room

    room.products.sum do |product|
      (product.price || 0) * (product.quantity || 1)
    end
  end

  # Get the URL for the room plan attachment
  def room_plan_url(room)
    return nil unless room&.plan&.attached?

    Rails.application.routes.url_helpers.rails_blob_path(room.plan, only_path: true)
  end

  # Get the URL for the room plan with products attachment
  def room_plan_with_products_url(room)
    return nil unless room&.plan_with_products&.attached?

    Rails.application.routes.url_helpers.rails_blob_path(room.plan_with_products, only_path: true)
  end
end
