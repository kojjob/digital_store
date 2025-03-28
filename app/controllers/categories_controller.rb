class CategoriesController < ApplicationController
  include AdminAuthorization

  before_action :set_category, only: %i[ show edit update destroy ]
  before_action :load_categories_for_header, only: %i[ index show new edit create update ]

  # GET /categories or /categories.json
  def index
    @categories = Category.includes(:parent).order(position: :asc, name: :asc).all
  end

  # GET /categories/1 or /categories/1.json
  def show
    @products = @category.products.includes(:category).page(params[:page]).per(12) # Using Kaminari
    @subcategories = Category.where(parent_id: @category.id).order(position: :asc, name: :asc) if @category
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories or /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: "Category was successfully created." }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1 or /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: "Category was successfully updated." }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1 or /categories/1.json
  def destroy
    begin
      @category.destroy!
      respond_to do |format|
        format.html { redirect_to categories_path, notice: "Category was successfully destroyed." }
        format.json { head :no_content }
      end
    rescue ActiveRecord::DeleteRestrictionError => e
      respond_to do |format|
        format.html { redirect_to categories_path, alert: "Cannot delete category because it has associated products or subcategories." }
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = Category.find_by(id: params[:id]) || Category.find_by(slug: params[:id])

    unless @category
      redirect_to categories_path, alert: "Category not found" and return
    end
  end

  def load_categories_for_header
    @nav_categories = Category.where(visible: true).order(position: :asc).limit(6)
  end

  # Only allow a list of trusted parameters through.
  def category_params
    params.require(:category).permit(:name, :description, :slug, :parent_id, :position, :visible, :icon_name, :icon_color)
  end
end
