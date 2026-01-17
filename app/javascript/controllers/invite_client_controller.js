import { Controller } from "@hotwired/stimulus";
import { getCSRFToken } from "utils/dom_helpers";

export default class extends Controller {
  static targets = ["modal", "select", "error", "submitBtn"];
  static values = { projectId: Number };

  open(event) {
    event.preventDefault();
    this.modalTarget.classList.remove("hidden");
    this.errorTarget.classList.add("hidden");
    this.selectTarget.value = "";
  }

  close(event) {
    if (event) event.preventDefault();
    this.modalTarget.classList.add("hidden");
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) {
      this.close();
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }

  async submit(event) {
    event.preventDefault();

    const clientId = this.selectTarget.value;
    if (!clientId) {
      this.showError("Please select a client");
      return;
    }

    this.submitBtnTarget.disabled = true;
    this.submitBtnTarget.textContent = "Adding...";

    try {
      const response = await fetch(`/projects/${this.projectIdValue}/add_client`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": getCSRFToken(),
          "Accept": "application/json"
        },
        body: JSON.stringify({ client_id: clientId })
      });

      if (response.ok) {
        window.location.reload();
      } else {
        const data = await response.json();
        this.showError(data.error || "Could not add client");
        this.submitBtnTarget.disabled = false;
        this.submitBtnTarget.textContent = "Add Client";
      }
    } catch (e) {
      console.error("Failed to add client:", e);
      this.showError("Failed to add client");
      this.submitBtnTarget.disabled = false;
      this.submitBtnTarget.textContent = "Add Client";
    }
  }

  showError(message) {
    this.errorTarget.textContent = message;
    this.errorTarget.classList.remove("hidden");
  }
}
