import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tab", "content"];

  connect() {
    // Ensure an initial active tab
    const activeTab =
      this.tabTargets.find((t) => t.dataset.active === "true") ||
      this.tabTargets[0];
    if (activeTab) this.setActive(activeTab);
  }

  select(event) {
    event.preventDefault();
    const target = event.currentTarget;
    this.setActive(target);
  }

  setActive(tabEl) {
    const activeClasses = ["bg-white/20", "text-white"];
    const inactiveClasses = [
      "bg-white/10",
      "text-white/80",
      "hover:bg-white/20",
      "hover:text-white",
    ];

    // Update tab styles
    this.tabTargets.forEach((t) => {
      t.classList.remove(...activeClasses, ...inactiveClasses);
      t.classList.add(
        "px-3",
        "py-1.5",
        "rounded-md",
        "text-sm",
        "border",
        "border-white/10"
      );
      if (t === tabEl) {
        t.dataset.active = "true";
        t.classList.add(...activeClasses);
      } else {
        t.dataset.active = "false";
        t.classList.add(...inactiveClasses);
      }
    });

    // Update content
    const roomName = tabEl.dataset.room;
    if (this.hasContentTarget) {
      const escaped = this.escape(roomName);
      this.contentTarget.innerHTML = `
        <div class="flex items-center justify-between">
          <div class="text-white/80 text-sm">looking at room ${escaped}</div>
          <button type="button" class="inline-flex items-center px-3 py-1.5 rounded-md bg-emerald-700 hover:bg-emerald-600 text-white border border-white/10">
            Add new product
          </button>
        </div>
      `;
    }
  }

  escape(text) {
    const el = document.createElement("div");
    el.textContent = text == null ? "" : String(text);
    return el.innerHTML;
  }
}
