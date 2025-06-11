class HomeController < ApplicationController
  def index
    redirect_to visits_path if user_signed_in?
  end
end
