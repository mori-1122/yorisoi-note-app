Rails.application.routes.draw do
  devise_for :users # ユーザーのログイン・登録などに必要なルート
  get "up" => "rails/health#show", as: :rails_health_check
  root to: "home#index"

  # 診察記録と紐づく予定
  resources :visits do
        collection do
          get :by_date # 現在使用中
        end

        # 診察記録に紐づく質問選択・編集
        resources :question_selections, only: [ :index, :create, :update, :destroy ]

        # # 診療記録に紐ついている録音
        # resources :recordings, only: [ :new, :create, :show, :destroy ] do
        #   collection do
        #     get :test
        #     post :upload
        #   end
        # end


        # 診療記録に紐ついている録音
        resource :recording, only: [ :new, :create, :show, :destroy ]
      end

  # 質問テンプレを選択、検索
  resources :questions do
    collection do
      get :select # 質問を選ぶ
      get :search # 検索 (将来的にTurboを使用したい)
    end
  end
end
