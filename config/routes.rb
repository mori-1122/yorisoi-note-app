Rails.application.routes.draw do
  get "question_selections/create"
  get "questions/select"
  get "questions/search"
  devise_for :users # #ユーザーのログイン・登録などに必要なルート
  get "up" => "rails/health#show", as: :rails_health_check
  root to: "home#index" # #トップページ（/）にアクセス


  resources :visits, only: [ :index, :new, :create, :edit, :update, :destroy ] do # #visitsリソースに関するルート
    collection do
      get "by_date"
    end
  end

  resources :questions, only: [] do
    collection do
      get :select
      get :search
    end
  end

  resources :question_selections, only: [:create]
end
