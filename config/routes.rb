Rails.application.routes.draw do
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check

  root to: "home#index"

  # 診察記録と紐づく予定
  resources :visits, only: [ :index, :new, :create, :edit, :update, :destroy ] do
    collection do
      get :by_date
    end

    # 診察記録に紐づく質問選択・編集　visit にネストする
    resources :question_selections do
      collection do
        get :select # 質問選択画面
        post :confirm # 確認画面へ POST
        post :finalize # → /visits/:visit_id/question_selections/finalize
      end

      member do
        patch :toggle_answered
      end
    end
  end

  # 質問管理機能（マスタデータの質問一覧・管理）
  resources :questions, only: [ :index ] do
    collection do
      get :select_for_visit # 特定の visit に質問を追加する画面
    end
  end
end
