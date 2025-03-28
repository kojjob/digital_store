class Api::ProductQuestionsController < ApplicationController
  before_action :authenticate_user!, only: [ :create ]

  def index
    product = Product.find(params[:product_id])
    per_page = (params[:per_page] || 5).to_i
    page = (params[:page] || 1).to_i

    questions = ProductQuestion.where(product_id: product.id)
                              .order(created_at: :desc)
                              .page(page)
                              .per(per_page)

    total_pages = (ProductQuestion.where(product_id: product.id).count.to_f / per_page).ceil

    render json: {
      questions: questions.map { |q| format_question(q) },
      total_pages: total_pages,
      current_page: page
    }
  end

  def create
    @question = ProductQuestion.new(question_params)
    @question.user = current_user
    @question.asked_by = current_user.full_name

    if @question.save
      render json: { success: true, question: format_question(@question) }
    else
      render json: { success: false, error: @question.errors.full_messages.join(", ") }, status: :unprocessable_entity
    end
  end

  private

  def question_params
    params.require(:product_question).permit(:product_id, :question)
  end

  def format_question(question)
    {
      id: question.id,
      product_id: question.product_id,
      question: question.question,
      asked_by: question.asked_by,
      asked_at: question.created_at,
      answer: question.answer,
      answered_by: question.answered_by,
      answered_at: question.answered_at
    }
  end
end
