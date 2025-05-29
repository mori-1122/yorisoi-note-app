import { Controller } from "@hotwired/stimulus"
import { Calendar } from "@fullcalendar/core"
import jaLocale from "@fullcalendar/core/locales/ja"
import dayGridPlugin from "@fullcalendar/daygrid"

export default class extends Controller {
  connect() {
    const calendar = new Calendar(this.element, {
      initialView: "dayGridMonth",
      locale: jaLocale,
      events: [
        { title: "通院", start: "2025-06-01" },
        { title: "検査", start: "2025-06-20" }
      ]
    })
    calendar.render()
  }
}
