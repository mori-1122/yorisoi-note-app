class DocumentsController < ApplicationController
  before_action :set_visit
  before_action :set_document, only: [ :edit, :update, :destroy ]

  def index
    @documents = @visit.documents.includes(:user).order(created_at: :desc)
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

  def edit
  end

  def update
    if @document.update(document_params)
      redirect_to visit_documents_path(@visit), notice: "画像を更新しました。"
    else
      flash.now[:error] = "更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @document.destroy
    redirect_to visit_documents_path(@visit), notice: "画像を削除しました。"
  end

  private

  def set_visit
    @visit = current_user.visits.find(params[:visit_id])
  end

  def document_params
    params.expect(document: %i[image doc_type])
  end

  def set_document
    @document = @visit.documents.find(params[:id])
  end
end
