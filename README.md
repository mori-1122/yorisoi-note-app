### はじめに
- 本リポジトリはRuby、Rails学習者の[「千葉」](https://qiita.com/Chiba_67)が作成したWebアプリに関するものです。
- ご利用いただくことでのトラブル等は一切の責任を負いかねます。

# よりそいノート（Yorisoi Note）
「記録が、寄り添いになる。」
受診予定や質問、診察内容の録音をまとめて管理し、あなたと医療をやさしくつなぐWebアプリです。

## アプリURL

**アプリURL**: [https://www.yorisoi-note.com/](https://www.yorisoi-note.com/)

# デモ動画
## カレンダーから受診予定を登録できます
[![demo1](https://github.com/user-attachments/assets/5dd9f194-cbd4-4b4c-bbf1-988a4c1c82a0)](https://github.com/user-attachments/assets/5dd9f194-cbd4-4b4c-bbf1-988a4c1c82a0)

## 事前質問の登録・確認
[![demo2](https://github.com/user-attachments/assets/ec24f2d1-4426-49f0-a957-3d19aff582e6)](https://github.com/user-attachments/assets/ec24f2d1-4426-49f0-a957-3d19aff582e6)

## 録音機能（MP3変換・再生対応）
[![demo3](https://github.com/user-attachments/assets/8391122e-96bb-4f3b-b518-472cc07deece)](https://github.com/user-attachments/assets/8391122e-96bb-4f3b-b518-472cc07deece)

## 書類アップロードと一元管理
[![demo4](https://github.com/user-attachments/assets/f6f884bf-2e57-4d37-a653-f035452c161f)](https://github.com/user-attachments/assets/f6f884bf-2e57-4d37-a653-f035452c161f)

## プロフィールを記入できます
[![demo5](https://github.com/user-attachments/assets/e0f93625-fe07-43b9-99b3-6548f84b2009)](https://github.com/user-attachments/assets/e0f93625-fe07-43b9-99b3-6548f84b2009)

## 受診予定を登録すると、予定登録直後と、受診日前日の午前９時に、ご登録いただいたメールアドレスにお知らせ通知がきます
<img width="935" height="394" alt="スクリーンショット 2025-10-25 22 25 55" src="https://github.com/user-attachments/assets/eece6cbd-cc74-435c-b17b-f02ad17a055d" />



## 特徴

- 📅 **受診予定の可視化**：FullCalendarで予定を一目で確認
- ✉️ **通知機能**：受診日前日に自動リマインドメールを送信
- 🎙 **録音機能**：診察内容やメモをブラウザ上で録音・保存・再生
- 🧠 **質問テンプレート機能**：受診前に話したい内容を整理
- 👤 **プロフィール**：自分の身長体重や、既往歴、内服薬などをまとめて確認・管理
- 🏥 **家族・医療者連携を意識**：共有できるノートとして今後拡張予定

## 開発の背景

現役の看護師として医療現場で働く中で、患者さんやご家族が抱える課題を間近に感じてきました。

### 医療環境が抱える問題

- 少子高齢化による医療需要の増加
- 核家族化の進行による家族支援の減少
- 医療従事者の人手不足（特に地方や過疎地では診療体制の維持が困難）
- 認知症の患者が一人で受診するケースの増加
- 遠方に住む家族が、付き添いのために頻繁に来院できない現実
- 医療費や保険料の増加による病院経営の悪化、地域医療機関の減少

こうした背景から、患者さんが、平等に正しい医療を受けられるように支援したいという想いが強まりました。

### 開発への想い

> **「誰もが平等に、安心して医療を受けられる社会をつくりたい」**

その思いを形にするために、患者・家族・医療者の距離を少しでも近づけるべく「よりそいノート」を開発しました。

## 主なページ

| ページ | 内容 |
|--------|------|
| 🏠 トップページ | サービスの紹介とログイン導線 |
| 👤 ユーザー登録 / ログイン | Deviseを使用した認証機能 |
| 📅 カレンダー | FullCalendarで予定を管理・編集 |
| ✉️ 通知一覧 | 登録した受診予定に基づくリマインド送信履歴 |
| 🎙 録音ページ | MediaRecorderで録音・再生可能 |
| ⚙️ プロフィール編集 | 名前・メール・パスワード変更、退会機能 |
| 🧾 質問選択ページ | 受診時に聞きたいことをテンプレートから選択 |

## 技術スタック
| 分類            | 使用技術                                                                 |
| ------------- | -------------------------------------------------------------------- |
| **フレームワーク**   | Ruby on Rails 8                                                      |
| **言語**        | Ruby 3.2 / JavaScript (ES6)                                          |
| **フロントエンド**   | HTML / SCSS / Bootstrap Icons / Turbo                                |
| **データベース**    | PostgreSQL                                                           |
| **非同期ジョブ**    | ActiveJob / Sidekiq / Sidekiq-Cron                                   |
| **キャッシュ・キュー** | Redis                                                                |
| **メール配信**     | ActionMailer + SendGrid（本番） / Letter Opener（開発）                      |
| **録音処理**      | MediaRecorder API + ffmpeg + Open3                                   |
| **インフラ**      | Heroku（アプリケーションホスティング） + AWS S3（ActiveStorage） + Cloudflare（SSL・CDN） |
| **テスト**       | RSpec / FactoryBot                                                   |
| **CI/CD**     | GitHub Actions                                                       |
| **その他**       | Importmap管理 / Turbo部分利用                                              |

## ER図
<img width="1258" height="1276" alt="Untitled" src="https://github.com/user-attachments/assets/cf4a95d1-ae29-41d2-9651-b25329d0c937" />


## クイックスタート

### 条件

- Ruby 3.3.9
- Rails 8.0.2.1
- Node.js 18.20.6
- PostgreSQL 15 以上
- Redis（Sidekiq用）
- yarn

## セットアップ手順

### 1.リポジトリのクローン
```bash
git clone git@github.com:mori-1122/yorisoi-note-app.git
cd yorisoi-note-app
```

### 2. Ruby環境の準備
```
rbenv install $(cat .ruby-version)
rbenv local $(cat .ruby-version)
bundle install
```

### 3. JavaScript / CSS環境のセットアップ
```
yarn install
```

### 4. データベースのセットアップ
```
brew services start postgresql
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

### 5.アプリケーションの起動
```
bin/dev
```
### 6.アクセス
```
ブラウザでhttp://localhost:3000を開いてください。
```

### 医療現場に基づいた質問テンプレートデータ

本アプリ「寄り添いノート」では、**実際の医療・福祉現場で使用されている質問内容**をもとにしたテンプレートデータを実装しています。  
患者さんが受診時に抱く疑問や不安を整理し、医師やスタッフとの対話を支援することを目的としています。

---

### 診療科ごとの質問例
- 内科: 
  「この症状はどのような病気の可能性がありますか？」  
  「今飲んでいる薬は、この症状に合っていますか？」

- 外科:
  「手術が必要になる可能性はありますか？」  
  「この痛みで生活に支障が出ています。改善方法はありますか？」

- 小児科: 
  「子どものこの症状はよくあることですか？」  
  「発熱・鼻水などが長引いていますが大丈夫ですか？」

- 皮膚科: 
  「湿疹やかゆみの原因は何が考えられますか？」  
  「市販薬を使っても大丈夫ですか？」

- 心療内科:
  「気分の落ち込みがあります」  
  「夜眠れないことが増えています」

など、13診療科（内科・外科・小児科・皮膚科・耳鼻咽喉科・眼科・整形外科・泌尿器科・循環器科・脳神経外科・心療内科・リハビリテーション科・産婦人科）に対応しています。

---

### カテゴリ別質問例

診療科とは別に、以下のカテゴリでも質問を分類しています
- 薬: 「飲み忘れたときはどうすればいいですか？」  
- 検査: 「検査の結果を詳しく教えてください」  
- 通院:「次はいつ来ればいいですか？」  
- 生活:「食事や運動についてアドバイスをもらえますか？」  
- アレルギー: 「アレルギー源を避けるにはどうすればいいですか？」  
- 緊急度:「この症状は緊急性がありますか？」

---

## データ実装方法

初期データ（Seed）として、`db/seeds.rb` に以下のように登録しています：

```ruby
# 診療科登録
department_names = %w[内科 外科 小児科 ... 産婦人科]
department_names.each { |name| Department.find_or_create_by!(name: name) }

# カテゴリ登録
category_names = %w[薬 検査 生活 通院 アレルギー 緊急度]
category_names.each { |name| QuestionCategory.find_or_create_by!(category_name: name) }

# 質問テンプレート作成
create_question("内科", nil, "この症状はどのような病気の可能性がありますか？")
create_question(nil, "薬", "飲み忘れたときはどうすればいいですか？")
```

実際の医療現場で使える質問テンプレートをDBに自動登録しています。

---

### 背景
本データは、医療・福祉分野で10年以上の経験を持つ開発者が、現場での患者支援・問診業務・家族対応などの知見をもとに設計しました。  
現実的かつ実用的な質問が中心となっています。

---

### 目的

- 受診前に患者が「聞きたいこと」を整理できる  
- 医師や看護師との対話をスムーズにする  
- 家族や支援者が同行できない場合でも、適切に情報共有できる  

---

### 特徴

| 項目 | 内容 |
|------|------|
| データ形式 | Ruby (seedデータ) |
| 登録方法 | `bin/rails db:seed` 実行時に自動登録 |
| カバレッジ | 13診療科 × 6カテゴリ |
| カスタマイズ | 管理者画面やseed修正により簡単に追加可能 |

---


### アプリケーションの使用方法について

1. ユーザー登録を行う
2. カレンダーから受診予定を登録
3. 予定に基づき通知メールが自動送信されます
4. 診察時に録音を活用
5. マイページで記録を振り返り


### 環境変数
| 変数名 | 用途 |
|--------|------|
| `MAILER_SENDER` | 通知メール送信元アドレス |
| `SENDGRID_API_KEY` | SendGridのAPIキー |
| `AWS_ACCESS_KEY_ID` | AWSのアクセスキー（本番環境のみ） |
| `AWS_SECRET_ACCESS_KEY` | AWSのシークレットキー（本番環境のみ） |
| `REDIS_URL` | SidekiqのRedis接続URL |
| `HOST_NAME` | メール通知などで使用するアプリURL |
| `S3_BUCKET_NAME` | ActiveStorageで使用するS3バケット名 |
| `AWS_REGION` | S3リージョン（例：ap-northeast-1） |

## テスト
```bash
# テストを実行
bundle exec rspec
```
### 制約
- 通知メール機能は、実際の運用環境（SendGridキー設定済み）でのみ動作します。
- 開発環境では LetterOpener によるメールプレビューが動作します。
- 録音機能はブラウザ（MediaRecorder API）に依存しています。
- ActiveStorage（S3アップロード）は本番環境のみ有効です。
- ローカル環境では /storage にファイル保存されます。
- SidekiqジョブはRedis接続が必要です。Redisが未起動の場合、通知メールは送信されません。

### 今後の実装予定
- 共有機能の拡張
家族・医療者とノート内容を共有できる機能を検討中。
- セーブ・バックアップ機能
個人データを暗号化してエクスポート・インポート可能に。
- Sentry導入によるエラー監視
本番環境における例外監視とパフォーマンス測定をSentryで実施予定。  
エラーの早期検知と安定稼働を目的としています。

## Special Thanks
本アプリの設計・開発にあたって、メンターよりレビューをいただきました。
丁寧なご指摘・温かいサポートに心より感謝いたします。  
今後も改善を重ねていきます。
