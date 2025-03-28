class Admin::ProductQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin_or_seller
  before_action :set_product_question, only: [ :show, :edit, :update, :destroy ]

  def index
    @q = ProductQuestion.ransack(params[:q])
    @product_questions = @q.result.includes(:product, :user)
                          .order(created_at: :desc)
                          .page(params[:page])
                          .per(20)
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
