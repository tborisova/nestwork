import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["display", "form", "input"];

  edit() {
    this.displayTarget.classList.add("hidden");
    this.formTarget.classList.remove("hidden");
    this.inputTarget.focus();
    this.inputTarget.select();
  }

  cancel() {
    this.formTarget.classList.add("hidden");
    this.displayTarget.classList.remove("hidden");
  }

  submitOnEnter(event) {
    if (event.key === "Enter") {
      event.preventDefault();
      this.formTarget.requestSubmit();
    } else if (event.key === "Escape") {
      this.cancel();
    }
  }
}
