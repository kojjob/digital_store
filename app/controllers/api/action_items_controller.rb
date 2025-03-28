# frozen_string_literal: true

module Api
  # ActionItemsController
  #
  # Controller for handling API requests related to action items.
  # This controller follows RESTful design principles and provides
  # endpoints for the JavaScript service to interact with.
  class ActionItemsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_action_item, only: [ :update, :destroy ]

    # GET /api/action_items
    def index
      @action_items = current_user.action_items.order(created_at: :desc)
      render json: @action_items
    end

    # POST /api/action_items
    def create
      @action_item = current_user.action_items.build(action_item_params)

      if @action_item.save
        render json: @action_item, status: :created
      else
        render json: { errors: @action_item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/action_items/:id
    def update
      if @action_item.update(action_item_params)
        render json: @action_item
      else
        render json: { errors: @action_item.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/action_items/:id
    def destroy
      @action_item.destroy
      head :no_content
    end

    private

    # Set action item from the params
    def set_action_item
      @action_item = current_user.action_items.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Action item not found" }, status: :not_found
    end

    # Only allow a list of trusted parameters through
    def action_item_params
      params.require(:action_item).permit(:title, :description, :priority, :due_date, :completed)
    end
  end
end
