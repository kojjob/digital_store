class Admin::ProductQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin_or_seller
  before_action :set_product_question, only: [ :show, :edit, :update, :destroy ]

  def index
    # Base query
    query = ProductQuestion.includes(:product, :user).order(created_at: :desc)

    # Filter by answer status
    if params[:q].present?
      if params[:q][:answer_null] == "1"
        query = query.where(answer: nil)
      elsif params[:q][:answer_not_null] == "1"
        query = query.where.not(answer: nil)
      end

      # Search in question or answer
      if params[:q][:question_or_answer_cont].present?
        search_term = params[:q][:question_or_answer_cont]
        query = query.where("question ILIKE :term OR answer ILIKE :term", term: "%#{search_term}%")
      end
    end

    # Paginate results
    @product_questions = query.page(params[:page]).per(20)

    # For the view to keep working with existing params structure
    @q = params[:q] || {}
  end

  def show
  end

  def edit
  end

  def update
    @product_question.assign_attributes(product_question_params)
    @product_question.answered_by = current_user.full_name
    @product_question.answered_at = Time.current

    if @product_question.save
      redirect_to admin_product_question_path(@product_question), notice: "Answer was successfully saved."
    else
      render :edit
    end
  end

  def destroy
    @product_question.destroy
    redirect_to admin_product_questions_path, notice: "Question was successfully deleted."
  end

  private

  def set_product_question
    @product_question = ProductQuestion.find(params[:id])

    # Ensure the current user has access to this question
    unless current_user.admin? || (current_user.seller? && current_user.seller.id == @product_question.product.seller_id)
      redirect_to root_path, alert: "You do not have permission to access this resource."
    end
  end

  def product_question_params
    params.require(:product_question).permit(:answer)
  end

  def ensure_admin_or_seller
    unless current_user.admin? || current_user.seller?
      redirect_to root_path, alert: "You do not have permission to access this resource."
    end
  end
end
