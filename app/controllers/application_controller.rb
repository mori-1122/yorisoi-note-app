class ApplicationController < ActionController::Base # すべてのコントローラの親クラス。アプリ全体の共通処理を書く場所。
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  helper_method :current_user, :user_signed_in? # #メソッドをビューでも使えるようにする
  before_action :set_locale # #日本語表示されなかったため、対応
  before_action :configure_permitted_parameters, if: :devise_controller? # #Deviseがコントローラとして動作しているとき（ログイン・新規登録など）だけ、configure_permitted_parameters メソッドを実行するように設定。
  before_action :authenticate_user!

  protected # #コントローラーの中で使用

  def set_locale # #日本語表示されなかったため、対応
    I18n.locale = :ja
  end

  def configure_permitted_parameters # #許可するパラメータを追加設定するためのメソッド
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ]) # #新規登録（sign_up）時に、:nameパラメータを受け入れる
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  # ログインした後のリダイレクト先
  def after_sign_in_path_for(resource)
    visits_path
  end

  # 新規登録した際のリダイレクト先
  def after_sign_up_path_for(resource)
    visits_path
  end
end
