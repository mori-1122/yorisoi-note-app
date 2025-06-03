Rails.application.routes.draw do
  devise_for :users # #ユーザーのログイン・登録などに必要なルート
  get "up" => "rails/health#show", as: :rails_health_check
  root to: "home#index" # #トップページ（/）にアクセス


  resources :visits, only: [ :index, :create ] do # #visitsリソースに関するルート
    collection do
      get "by_date"
    end
  end
end
