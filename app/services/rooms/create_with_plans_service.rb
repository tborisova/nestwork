# frozen_string_literal: true

module Rooms
  class CreateWithPlansService
    Result = Struct.new(:success?, :room, :created?, :error, keyword_init: true)

    def initialize(project:, params:)
      @project = project
      @params = params
    end

    def call
      room_name = params.dig(:room, :name).to_s.strip
      return Result.new(success?: false, error: "Room name is required") if room_name.blank?

      room = project.rooms.find_or_initialize_by(name: room_name)
      is_new = room.new_record?

      if room.save && attach_plans(room)
        Result.new(success?: true, room: room, created?: is_new)
      else
        Result.new(success?: false, room: room, error: room.errors.full_messages.first)
      end
    end

    private

    attr_reader :project, :params

    def attach_plans(room)
      return true unless params[:room]

      update_params = {}
      update_params[:plan] = params[:room][:plan] if params[:room][:plan].present?
      update_params[:plan_with_products] = params[:room][:plan_with_products] if params[:room][:plan_with_products].present?

      update_params.empty? || room.update(update_params)
    end
  end
end
