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

        # 診療記録に紐ついている録音 Visit に対して録音は1件しか紐づかない想定なので、ルートは単数 医療業界では録音に厳しい状況もあるため、更新はなしとする。
        resource :recording, only: [ :new, :create, :show, :destroy ]

        # 画像アップロード
        resources :documents, only: [ :index, :new, :create, :edit, :update, :destroy ]
      end

  # 質問テンプレを選択、検索
  resources :questions do
    collection do
      get :select # 質問を選ぶ
      get :search # 検索 (将来的にTurboを使用したい)
    end
  end

  # Chrome DevToolsが勝手に叩く .well-knownのリクエストを表示させないようにしたい
  match "/.well-known/*path", to: ->(env) { [ 204, { "Content-Type" => "text/plain" }, [ "" ] ] }, via: :all
end
