Rails.application.routes.draw do
  devise_for :users # ユーザー認証機能
  get "up" => "rails/health#show", as: :rails_health_check

  root to: "home#index"

  # 診察記録(visits)と紐づく予定
  resources :visits, only: [ :index, :new, :create, :edit, :update, :destroy ] do
    collection do
      get :by_date # 日付で絞り込む一覧取得
    end

    # 診察記録に紐づく質問選択・編集　visitにネストする
    resources :question_selections, only: [ :index, :create, :edit, :update ] do
      collection do
        get :select # 質問選択画面
        post :confirm # 確認画面へPOST送信する
        post :finalize   # 最終登録処理として
      end

      member do
        patch :toggle_answered # 質問個別に回答済み/未回答をトグルするため
      end
    end

    # 質問選択【とりあえずajax】
    get :search_questions, on: :collection
  end
end
