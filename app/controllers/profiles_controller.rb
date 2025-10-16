class ProfilesController < ApplicationController
  before_action :set_profile

  def edit
    @profile = current_user.profile || current_user.build_profile
  end

  def update
    if @profile.update(profile_params)
      redirect_to edit_profile_path, notice: "プロフィールを更新しました。"
    else
      flash.now[:error] = "更新できませんでした。"
      render :edit, status: :unprocessable_entity
    end
  end


  private

  def set_profile
    @profile = current_user.profile || current_user.build_profile
  end

  def profile_params
    # expectではテストでエラーが出るため
    params.require(:profile).permit(
      :birthday,
      :gender,
      :height,
      :weight,
      :blood_type,
      :allergy_details,
      :medical_history,
      :current_medication
    )
  end
end
