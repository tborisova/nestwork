import { Controller } from "@hotwired/stimulus";
import { getCSRFToken } from "utils/dom_helpers";

export default class extends Controller {
  static targets = ["menu", "current"];
  static values = { projectId: Number, currentStatus: String };

  connect() {
    // Close dropdown when clicking outside
    this.handleClickOutside = this.handleClickOutside.bind(this);
    document.addEventListener("click", this.handleClickOutside);
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside);
  }

  toggle(event) {
    event.stopPropagation();
    this.menuTarget.classList.toggle("hidden");
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden");
    }
  }

  async selectStatus(event) {
    event.preventDefault();
    const newStatus = event.currentTarget.dataset.status;

    if (newStatus === this.currentStatusValue) {
      this.menuTarget.classList.add("hidden");
      return;
    }

    try {
      const response = await fetch(`/projects/${this.projectIdValue}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": getCSRFToken(),
          "Accept": "application/json"
        },
        body: JSON.stringify({ project: { status: newStatus } })
      });

      if (response.ok) {
        // Reload the page to show the updated status
        window.location.reload();
      } else {
        const data = await response.json();
        alert(data.error || "Could not update status");
      }
    } catch (e) {
      console.error("Failed to update status:", e);
      alert("Failed to update status");
    }
  }
}
