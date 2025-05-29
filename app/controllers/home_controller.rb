class HomeController < ApplicationController
  def index
    redirect_to calendars_path if user_signed_in?
  end
end
