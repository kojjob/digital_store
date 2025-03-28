class ProductsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_product, only: %i[ show edit update destroy ]
  before_action :ensure_seller_owns_product, only: %i[ edit update destroy ]

  # GET /products or /products.json
  def index
    @categories = Category.where(visible: true).order(:position)

    @products = Product.includes(:seller, :category, :product_images)
                      .where(published: true)
                      .order(created_at: :desc)

    # Filter by category if param exists
    if params[:category_id].present?
      @category = Category.find_by(id: params[:category_id])
      @products = @products.where(category_id: params[:category_id]) if @category
    end

    # Filter by country availability
    if params[:country] == "ghana"
      @products = @products.where(available_in_ghana: true)
    elsif params[:country] == "nigeria"
      @products = @products.where(available_in_nigeria: true)
    end

    # Filter by price range
    if params[:min_price].present? && params[:max_price].present?
      @products = @products.where(price: params[:min_price].to_f..params[:max_price].to_f)
    end

    # Filter by search term
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @products = @products.where("name ILIKE ? OR description ILIKE ?", search_term, search_term)
    end

    # Pagination
    @products = @products.page(params[:page]).per(12)
  end

  def show
    @related_products = Product.where(category_id: @product.category_id).where.not(id: @product.id).limit(4)
    @categories = Category.where(visible: true).order(:position) # Load categories for the header
  end
  # GET /products/new
  def new
    @product = Product.new
    @categories = Category.where(visible: true).order(:position) # Load categories for the header
    unless current_user.seller?
      redirect_to become_seller_path, alert: "You need to become a seller before creating products" and return
    end
    @product.seller_id = current_user.seller.id
  end

  # GET /products/1/edit
  def edit
    @categories = Category.where(visible: true).order(:position) # Load categories for the header
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)
    @product.seller_id = current_user.seller.id unless product_params[:seller_id].present?

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        @categories = Category.where(visible: true).order(:position) # Load categories for the header
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        @categories = Category.where(visible: true).order(:position) # Load categories for the header
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
    @product = Product.find_by(id: params[:id])
    unless @product
      redirect_to products_path, alert: "Product not found" and return
    end
  end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:name, :description, :price, :discounted_price, :stock_quantity, :sku, :barcode, :weight, :dimensions, :condition, :brand, :featured, :currency, :country_of_origin, :available_in_ghana, :available_in_nigeria, :shipping_time, :category_id, :seller_id, :published, :published_at, :meta_title, :meta_description)
    end

    # Ensure current user is the owner of the product
    def ensure_seller_owns_product
      unless current_user.admin? || (current_user.seller? && current_user.seller.id == @product.seller_id)
        redirect_to products_path, alert: "You are not authorized to perform this action." and return
      end
    end
end
