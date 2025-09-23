pin "application", preload: true # Rails の標準構成で全ページに読み込まれる前提のためpreload: trueが必須。
pin "filter", to: "filter.js", preload: true # app/javascript/filter.jsをfilterという名前で登録
pin "question_status_toggle", to: "question_status_toggle.js" # 特定ページでしか使わないためpreload: trueを付けず、必要時に読み込まれるようにしている。

pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true # Rails7以降で標準的に利用する仕組みで、全ページで使うため preload: trueが必須。
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

pin "bootstrap", to: "bootstrap.bundle.min.js"
pin "recording", to: "recording.js" # 録音ページ限定で使うため、preload を外して「必要なページでだけ読み込む」ようにした。
pin "document_preview", to: "document_preview.js"
pin "guide_modal", to: "guide_modal.js"
