class SellersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_seller, only: %i[ show edit update destroy ]
  before_action :ensure_seller_owner, only: %i[ edit update destroy ]
  before_action :set_seller_from_current_user, only: %i[ dashboard products new_product edit_product ]
  before_action :set_product, only: %i[ edit_product update_product destroy_product ]
  before_action :check_seller_status, except: %i[ new create thanks index show ]

  # GET /sellers or /sellers.json
  def index
    @sellers = Seller.all
  end

  # GET /sellers/1 or /sellers/1.json
  def show
    @seller_products = @seller.products.where(published: true).limit(8) rescue []
  end

  # GET /sellers/new
  def new
    # Check if the current user already has a seller account
    if current_user.seller?
      redirect_to sellers_dashboard_path, notice: "You already have a seller account."
      return
    end

    @seller = Seller.new
  end

  # GET /sellers/1/edit
  def edit
  end

  # POST /sellers or /sellers.json
  def create
    @seller = Seller.new(seller_params)
    @seller.user = current_user

    # Set default values
    @seller.verified = false
    @seller.commission_rate = 10.0
    @seller.acceptance_rate = 0
    @seller.average_response_time = 0

    respond_to do |format|
      if @seller.save
        format.html { redirect_to thanks_sellers_path, notice: "Your seller application was submitted successfully and is pending review." }
        format.json { render :show, status: :created, location: @seller }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @seller.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sellers/1 or /sellers/1.json
  def update
    respond_to do |format|
      if @seller.update(seller_params)
        format.html { redirect_to @seller, notice: "Seller was successfully updated." }
        format.json { render :show, status: :ok, location: @seller }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @seller.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sellers/1 or /sellers/1.json
  def destroy
    @seller.destroy!

    respond_to do |format|
      format.html { redirect_to sellers_path, notice: "Seller was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # GET /seller/dashboard
  def dashboard
    @recent_orders = current_user.seller.orders.order(created_at: :desc).limit(5) rescue []
    @product_count = current_user.seller.products.count rescue 0
    @total_sales = current_user.seller.orders.sum(:total_amount) rescue 0
  end

  # GET /seller/products
  def products
    @products = current_user.seller.products.order(created_at: :desc)
  end

  # GET /seller/products/new
  def new_product
    @product = current_user.seller.products.build
  end

  # GET /seller/products/:id/edit
  def edit_product
    @categories = Category.where(visible: true).order(:position)
  end

  # POST /seller/products
  def create_product
    @product = current_user.seller.products.build(product_params)

    if @product.save
      redirect_to sellers_products_path, notice: "Product was successfully created."
    else
      @categories = Category.where(visible: true).order(:position)
      render :new_product, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /seller/products/:id
  def update_product
    if @product.update(product_params)
      redirect_to sellers_products_path, notice: "Product was successfully updated."
    else
      @categories = Category.where(visible: true).order(:position)
      render :edit_product, status: :unprocessable_entity
    end
  end

  # DELETE /seller/products/:id
  def destroy_product
    @product.destroy!
    redirect_to sellers_products_path, notice: "Product was successfully deleted."
  end

  def thanks
    # Render the thanks view
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_seller
      # Check if id is 'help' and redirect to help page
      if params[:id] == "help"
        redirect_to help_path
        return
      end

      @seller = Seller.find_by(id: params[:id])
      unless @seller
        redirect_to sellers_path, alert: "Seller not found."
        nil
      end
    end

    def set_seller_from_current_user
      @seller = current_user.seller

      unless @seller
        redirect_to become_seller_path, alert: "You need to register as a seller first."
        return false
      end
      true
    end

    def set_product
      @product = current_user.seller.products.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to sellers_products_path, alert: "Product not found."
    end

    def ensure_seller_owner
      unless @seller.user == current_user || (current_user && current_user.admin?)
        redirect_to sellers_path, alert: "You don't have permission to perform this action."
        return false
      end
      true
    end

    def check_seller_status
      unless current_user && current_user.seller?
        redirect_to root_path, alert: "You don't have permission to access this page."
        return false
      end
      true
    end

    # Only allow a list of trusted parameters through.
    def seller_params
      params.require(:seller).permit(
        :business_name,
        :description,
        :location,
        :country,
        :phone_number,
        :bank_account_details,
        :mobile_money_details,
        :business_logo,
        :verification_document
      )
    end

    def product_params
      params.require(:product).permit(
        :name, :sku, :description, :price, :sale_price,
        :category_id, :stock_quantity, :published,
        :available_in_ghana, :available_in_nigeria,
        :meta_title, :meta_description
      )
    end
end
