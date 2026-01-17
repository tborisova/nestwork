import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tab", "content"];
  static values = { projectId: Number, rooms: Array, isDesigner: Boolean };

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
      const projectId = this.projectIdValue;
      const addProductUrl = `/projects/${projectId}/selections/new?room=${encodeURIComponent(roomName)}`;

      const roomData = this.roomsValue.find((r) => r.name === roomName);
      const products = roomData ? roomData.products : [];
      const selections = roomData ? roomData.selections : [];

      // Products section (selected items)
      let productsHtml = "";
      if (products.length > 0) {
        productsHtml = `
          <div class="mb-6">
            <h3 class="text-white font-medium mb-3">Selected Products</h3>
            <table class="w-full">
              <thead>
                <tr class="text-left text-white/60 text-xs uppercase tracking-wide border-b border-white/10">
                  <th class="pb-2">Name</th>
                  <th class="pb-2">Price</th>
                  <th class="pb-2">Qty</th>
                  <th class="pb-2">Status</th>
                  <th class="pb-2"></th>
                </tr>
              </thead>
              <tbody>
                ${products
                  .map(
                    (p) => `
                  <tr class="border-b border-white/5">
                    <td class="py-2 text-white">${this.escape(p.name)}</td>
                    <td class="py-2 text-white/80">${p.price ? "$" + p.price : "-"}</td>
                    <td class="py-2 text-white/80">${p.quantity || 1}</td>
                    <td class="py-2">
                      <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-medium ${this.statusClass(p.status)}">${this.escape(p.status || "pending")}</span>
                    </td>
                    <td class="py-2 text-right flex items-center justify-end gap-2">
                      ${p.link ? `<a href="${this.escape(p.link)}" target="_blank" class="text-sky-400 hover:text-sky-300 text-xs">View</a>` : ""}
                      ${this.statusActionButton(p, projectId)}
                    </td>
                  </tr>
                `
                  )
                  .join("")}
              </tbody>
            </table>
          </div>
        `;
      }

      // Selections section (pending choices)
      let selectionsHtml = "";
      if (selections.length > 0) {
        selectionsHtml = `
          <div>
            <h3 class="text-white font-medium mb-3">Pending Selections</h3>
            <div class="space-y-4">
              ${selections
                .map((s) => {
                  const optionsHtml = s.options
                    .map(
                      (o) => `
                    <div class="flex items-center justify-between p-2 rounded-lg bg-white/5 border border-white/10">
                      <div class="flex-1">
                        <div class="text-white text-sm">${this.escape(o.name)}</div>
                        <div class="text-white/60 text-xs mt-0.5">
                          ${o.price ? "$" + o.price : "No price"}
                          ${o.link ? ` · <a href="${this.escape(o.link)}" target="_blank" class="text-sky-400 hover:text-sky-300">View</a>` : ""}
                        </div>
                      </div>
                      <form action="/projects/${projectId}/selections/${s.id}/select_option?option_id=${o.id}&room=${encodeURIComponent(roomName)}" method="post" class="inline">
                        <input type="hidden" name="authenticity_token" value="${this.getCSRFToken()}">
                        <button type="submit" class="text-xs px-3 py-1.5 rounded bg-emerald-700 hover:bg-emerald-600 text-white border border-white/10">Select</button>
                      </form>
                    </div>
                  `
                    )
                    .join("");

                  return `
                    <div class="rounded-lg border border-amber-500/30 bg-amber-900/10 p-3">
                      <div class="flex items-center justify-between mb-3">
                        <div>
                          <div class="text-white font-medium">${this.escape(s.name)}</div>
                          <div class="text-white/60 text-xs mt-0.5">Qty: ${s.quantity || 1} · ${s.options.length} option${s.options.length !== 1 ? "s" : ""}</div>
                        </div>
                        <span class="text-xs px-2 py-1 rounded bg-amber-600 text-white">Awaiting selection</span>
                      </div>
                      <div class="space-y-2">
                        ${optionsHtml}
                      </div>
                    </div>
                  `;
                })
                .join("")}
            </div>
          </div>
        `;
      }

      // Empty state
      let emptyHtml = "";
      if (products.length === 0 && selections.length === 0) {
        emptyHtml = `<div class="text-white/50 text-sm py-4">No products in this room yet.</div>`;
      }

      const addProductButton = this.isDesignerValue
        ? `<a href="${addProductUrl}" class="inline-flex items-center px-3 py-1.5 rounded-md bg-emerald-700 hover:bg-emerald-600 text-white border border-white/10">
              Add new product
            </a>`
        : "";

      this.contentTarget.innerHTML = `
        <div class="flex items-center justify-between mb-4">
          <div class="text-white/80 text-sm">${escaped}</div>
          <div class="flex items-center gap-2">
            <button type="button" class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-md bg-sky-700 hover:bg-sky-600 text-white border border-white/10">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"/>
              </svg>
              Show room's plan
            </button>
            ${addProductButton}
          </div>
        </div>
        ${productsHtml}
        ${selectionsHtml}
        ${emptyHtml}
      `;
    }
  }

  escape(text) {
    const el = document.createElement("div");
    el.textContent = text == null ? "" : String(text);
    return el.innerHTML;
  }

  statusClass(status) {
    switch (status) {
      case "approved":
        return "bg-emerald-700 text-white";
      case "ordered":
        return "bg-amber-600 text-white";
      case "delivered":
        return "bg-sky-600 text-white";
      default:
        return "bg-white/20 text-white/80";
    }
  }

  statusActionButton(product, projectId) {
    const status = product.status || "pending";
    let nextStatus = null;
    let buttonLabel = null;
    let buttonClass = "";

    // Determine next status and button based on current status and role
    if (status === "pending") {
      // Both clients and designers can approve
      nextStatus = "approved";
      buttonLabel = "Approve";
      buttonClass = "bg-emerald-700 hover:bg-emerald-600";
    } else if (status === "approved" && this.isDesignerValue) {
      // Only designers can mark as ordered
      nextStatus = "ordered";
      buttonLabel = "Mark Ordered";
      buttonClass = "bg-amber-600 hover:bg-amber-500";
    } else if (status === "ordered" && this.isDesignerValue) {
      // Only designers can mark as delivered
      nextStatus = "delivered";
      buttonLabel = "Mark Delivered";
      buttonClass = "bg-sky-600 hover:bg-sky-500";
    }

    if (!nextStatus) return "";

    return `
      <form action="/projects/${projectId}/products/${product.id}/update_status" method="post" class="inline">
        <input type="hidden" name="authenticity_token" value="${this.getCSRFToken()}">
        <input type="hidden" name="status" value="${nextStatus}">
        <button type="submit" class="text-xs px-2 py-1 rounded ${buttonClass} text-white border border-white/10">${buttonLabel}</button>
      </form>
    `;
  }

  getCSRFToken() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.getAttribute("content") : "";
  }
}
