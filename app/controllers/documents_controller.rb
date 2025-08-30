class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_visit

  def index
    @documents = @visit.documents.includes(:user)
  end

  def new
    @document = @visit.documents.build
  end

  def create
    @document = @visit.documents.build(document_params)
    @document.user = current_user

    if @document.save
      flash[:notice] = "画像をアップロードしました。"
      redirect_to visit_documents_path(@visit)
    else
      flash.now[:error] = "アップロードに失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_visit
    @visit = current_user.visits.find(params[:visit_id])
  end

  def document_params
    params.expect(document: %i[image doc_type])
  end
end
