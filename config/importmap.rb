# Pin npm packages by running ./bin/importmap

pin "application"
pin "fullcalendar", to: "fullcalendar.js"
pin "fullcalendar/ja", to: "ja.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", to: "bootstrap.bundle.min.js"
