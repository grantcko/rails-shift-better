import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="loading-spin"
export default class extends Controller {
  connect() {
  }
  insertspin(event) {
    event.currentTarget.innerHTML=" <i class='fa-solid fa-cog fa-spin'></i>"
  }
}
