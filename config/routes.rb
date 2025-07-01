Rails.application.routes.draw do
  devise_for :users # #ユーザーのログイン・登録などに必要なルート
  get "question_selections/create"
  get "questions/select"
  get "questions/search"
  get "up" => "rails/health#show", as: :rails_health_check
  root to: "home#index" # #トップページ（/）にアクセス

  ## 質問テンプレを選択、検索
  resources :questions, only: [] do
    collection do
      get :select ## 質問を選ぶ
      get :search # #検索(turboを使用したい)
    end
  end

  ## 質問選択ほ保存確認記録をする
  resources :question_selections, only: [ :create ] do
    collection do
      get :summary # #選んだ質問リスト画面
      post :finalize # #質問を聞けたかどうかの最終確認
    end
  end


  resources :visits, only: [ :index, :new, :create, :edit, :update, :destroy ] do # #visitsリソースに関するルート
    collection do
      get "by_date"
    end
  end
end
