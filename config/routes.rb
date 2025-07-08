Rails.application.routes.draw do
  devise_for :users # #ユーザーのログイン・登録などに必要なルート
  get "question_selections/create"
  get "questions/select"
  get "questions/search"

  get "up" => "rails/health#show", as: :rails_health_check

  root to: "home#index"

  ## 質問テンプレを選択、検索
  resources :questions, only: [] do
    collection do
      get :select ## 質問を選ぶ
      get :search # #検索(turboを使用したい)
    end
  end

  ## 質問選択・保存確認記録
  resources :question_selections, only: [ :create ] do
    collection do
      get :summary # #選んだ質問リスト画面
      post :finalize # #質問を聞けたかどうかの最終確認
    end
  end

  # 診察記録と紐づく予定
  resources :visits, only: [ :index, :new, :create, :edit, :update, :destroy ] do
    collection do
      get :by_date
    end

    # 診察記録に紐づく質問選択・編集
    resources :question_selections do
      collection do
        get :select
        post :confirm
        post :finalize
      end

      member do
        patch :toggle_answered
      end
    end
  end

  # 質問管理機能（マスタデータの質問一覧・管理）
  resources :questions, only: [ :index ] do
    collection do
      get :select_for_visit
    end
  end
end
