class RecordingsController < ApplicationController
  before_action :set_visit

  def new
    @recording = @visit.build_recording # 診療をする際に、録音機能も作成します
  end

  def create
  end

  def show
  end

  def destroy
  end



  private

  def set_visit
    @visit = Visit.find(params[:visit_id])
  end
end


# 途中です
