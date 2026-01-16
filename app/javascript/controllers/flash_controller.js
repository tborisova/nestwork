import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 5000 }
  }

  connect() {
    this._timeoutId = setTimeout(() => this.dismiss(), this.timeoutValue)
  }

  disconnect() {
    if (this._timeoutId) clearTimeout(this._timeoutId)
  }

  dismiss(event) {
    if (event) event.preventDefault()
    // Simple removal; could be enhanced with transitions if desired
    this.element.remove()
  }
}

