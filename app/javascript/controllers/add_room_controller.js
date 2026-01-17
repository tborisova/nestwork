import { Controller } from "@hotwired/stimulus";
import { getCSRFToken } from "utils/dom_helpers";

export default class extends Controller {
  static targets = ["modal", "input", "error"];
  static values = { projectId: Number };

  open(event) {
    event.preventDefault();
    this.modalTarget.classList.remove("hidden");
    this.inputTarget.value = "";
    this.errorTarget.classList.add("hidden");
    this.inputTarget.focus();
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
    } else if (event.key === "Enter") {
      event.preventDefault();
      this.submit();
    }
  }

  async submit(event) {
    if (event) event.preventDefault();

    const roomName = this.inputTarget.value.trim();
    if (!roomName) {
      this.showError("Please enter a room name");
      return;
    }

    try {
      const response = await fetch(`/projects/${this.projectIdValue}/rooms`, {
        method: "POST",
        body: JSON.stringify({ room: { name: roomName } }),
        headers: {
          "X-CSRF-Token": getCSRFToken(),
          "Content-Type": "application/json",
          Accept: "application/json",
        },
      });

      if (response.ok) {
        // Reload the page to show the new room
        window.location.reload();
      } else {
        const data = await response.json();
        this.showError(data.error || "Could not create room");
      }
    } catch (e) {
      console.error("Failed to create room:", e);
      this.showError("Failed to create room");
    }
  }

  showError(message) {
    this.errorTarget.textContent = message;
    this.errorTarget.classList.remove("hidden");
  }
}
