// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import * as Turbo from "@hotwired/turbo-rails"
window.Turbo = Turbo
import "controllers"
import * as bootstrap from "bootstrap"
import jquery from "jquery"
window.$ = jquery
import Rails from "@rails/ujs"
Rails.start()
