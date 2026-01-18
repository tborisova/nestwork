import { Controller } from "@hotwired/stimulus";
import {
  getCSRFToken,
  escapeHtml,
  formatCurrency,
  getProductStatusClass,
  getNextStatusAction,
} from "utils/dom_helpers";

export default class extends Controller {
  static targets = ["tab", "content"];
  static values = { projectId: Number, rooms: Array, isDesigner: Boolean, projectStatus: String };

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
    const activeClasses = ["bg-white/15", "text-white", "shadow-lg"];
    const inactiveClasses = [
      "bg-transparent",
      "text-white/60",
      "hover:bg-white/10",
      "hover:text-white",
    ];

    // Update tab styles
    this.tabTargets.forEach((t) => {
      t.classList.remove(...activeClasses, ...inactiveClasses);
      t.classList.add(
        "px-4",
        "py-2",
        "rounded-xl",
        "text-sm",
        "font-medium",
        "transition-all",
        "whitespace-nowrap"
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
      const escaped = escapeHtml(roomName);
      const projectId = this.projectIdValue;
      const addProductUrl = `/projects/${projectId}/pending_products/new?room=${encodeURIComponent(roomName)}`;

      const roomData = this.roomsValue.find((r) => r.name === roomName);
      const products = roomData ? roomData.products : [];
      const pendingProducts = roomData ? roomData.pending_products : [];

      // Products section (selected items)
      let productsHtml = "";
      if (products.length > 0) {
        productsHtml = `
          <div class="mb-8">
            <h3 class="text-white font-semibold mb-4 flex items-center gap-2">
              <svg class="w-5 h-5 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
              </svg>
              Selected Products
            </h3>
            <div class="overflow-x-auto">
              <table class="w-full">
                <thead>
                  <tr class="text-left text-white/40 text-xs uppercase tracking-wider border-b border-white/10">
                    <th class="pb-3 font-medium">Product</th>
                    <th class="pb-3 font-medium">Price</th>
                    <th class="pb-3 font-medium">Qty</th>
                    <th class="pb-3 font-medium">Status</th>
                    <th class="pb-3 font-medium text-right">Actions</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-white/5">
                  ${products
                    .map(
                      (p) => `
                    <tr class="group hover:bg-white/[0.02] transition-colors">
                      <td class="py-4">
                        <span class="text-white font-medium">${escapeHtml(p.name)}</span>
                      </td>
                      <td class="py-4">
                        <span class="text-white/70">${p.price ? "$" + p.price.toLocaleString() : "-"}</span>
                      </td>
                      <td class="py-4">
                        <span class="text-white/70">${p.quantity || 1}</span>
                      </td>
                      <td class="py-4">
                        <span class="inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold ${getProductStatusClass(p.status)}">${escapeHtml(p.status || "pending")}</span>
                      </td>
                      <td class="py-4">
                        <div class="flex items-center justify-end gap-3">
                          ${p.link ? `<a href="${escapeHtml(p.link)}" target="_blank" class="text-sky-400 hover:text-sky-300 text-sm font-medium transition-colors">View</a>` : ""}
                          <button type="button" class="inline-flex items-center gap-1.5 text-white/50 hover:text-white text-sm transition-colors" data-action="click->tabs#openComments" data-type="product" data-id="${p.id}" data-name="${escapeHtml(p.name)}">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
                            </svg>
                            ${p.comments_count > 0 ? `<span class="bg-gradient-to-r from-purple-500 to-pink-500 text-white text-xs rounded-full px-1.5 min-w-[18px] text-center font-semibold">${p.comments_count}</span>` : ""}
                          </button>
                          ${this.statusActionButton(p, projectId)}
                        </div>
                      </td>
                    </tr>
                  `
                    )
                    .join("")}
                </tbody>
              </table>
            </div>
          </div>
        `;
      }

      // Pending Products section (pending choices)
      let pendingProductsHtml = "";
      if (pendingProducts.length > 0) {
        pendingProductsHtml = `
          <div>
            <h3 class="text-white font-semibold mb-4 flex items-center gap-2">
              <svg class="w-5 h-5 text-amber-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              Pending Products
            </h3>
            <div class="space-y-4">
              ${pendingProducts
                .map((s) => {
                  const optionsHtml = s.options
                    .map(
                      (o) => `
                      <div class="flex items-center justify-between p-3 rounded-xl bg-white/[0.03] border border-white/10 hover:bg-white/[0.05] transition-colors">
                        <div class="flex-1">
                          <div class="text-white font-medium">${escapeHtml(o.name)}</div>
                          <div class="text-white/50 text-sm mt-0.5 flex items-center gap-2">
                            ${o.price ? `<span>$${o.price.toLocaleString()}</span>` : "<span>No price</span>"}
                            ${o.link ? `<span class="text-white/30">·</span> <a href="${escapeHtml(o.link)}" target="_blank" class="text-sky-400 hover:text-sky-300 transition-colors">View product</a>` : ""}
                          </div>
                        </div>
                        <form action="/projects/${projectId}/pending_products/${s.id}/select_option?option_id=${o.id}&room=${encodeURIComponent(roomName)}" method="post" class="inline ml-4">
                          <input type="hidden" name="authenticity_token" value="${getCSRFToken()}">
                          <button type="submit" class="text-sm px-4 py-2 rounded-xl bg-gradient-to-r from-emerald-500 to-cyan-500 hover:from-emerald-400 hover:to-cyan-400 text-white font-medium shadow-lg shadow-emerald-500/20 transition-all">Select</button>
                        </form>
                      </div>
                    `
                    )
                    .join("");

                  return `
                    <div class="rounded-2xl border border-amber-500/20 bg-gradient-to-br from-amber-500/5 to-orange-500/5 p-5">
                      <div class="flex items-center justify-between mb-4">
                        <div>
                          <div class="text-white font-semibold text-lg">${escapeHtml(s.name)}</div>
                          <div class="text-white/50 text-sm mt-1">Quantity: ${s.quantity || 1} · ${s.options.length} option${s.options.length !== 1 ? "s" : ""} available</div>
                        </div>
                        <div class="flex items-center gap-3">
                          <button type="button" class="inline-flex items-center gap-1.5 text-white/50 hover:text-white text-sm transition-colors" data-action="click->tabs#openComments" data-type="pending_product" data-id="${s.id}" data-name="${escapeHtml(s.name)}">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
                            </svg>
                            ${s.comments_count > 0 ? `<span class="bg-gradient-to-r from-purple-500 to-pink-500 text-white text-xs rounded-full px-1.5 min-w-[18px] text-center font-semibold">${s.comments_count}</span>` : ""}
                          </button>
                          <span class="inline-flex items-center gap-1.5 text-sm px-3 py-1.5 rounded-full bg-gradient-to-r from-amber-500 to-orange-500 text-white font-medium">
                            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            </svg>
                            Awaiting
                          </span>
                        </div>
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
      if (products.length === 0 && pendingProducts.length === 0) {
        emptyHtml = `
          <div class="text-center py-12">
            <div class="w-16 h-16 rounded-2xl bg-white/5 flex items-center justify-center mx-auto mb-4">
              <svg class="w-8 h-8 text-white/20" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/>
              </svg>
            </div>
            <p class="text-white/40 text-sm">No products in this room yet</p>
          </div>
        `;
      }

      const addProductButton = this.isDesignerValue && this.projectStatusValue !== "done"
        ? `<a href="${addProductUrl}" class="btn-primary-small inline-flex items-center gap-2 px-4 py-2.5 rounded-xl text-white font-medium text-sm shadow-lg shadow-purple-500/20" style="background: linear-gradient(135deg, #a855f7 0%, #ec4899 100%);">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
              </svg>
              Add Product
            </a>`
        : "";

      const roomCommentsButton = roomData && roomData.room_id
        ? `<button type="button" class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white/[0.05] hover:bg-white/10 text-white/70 hover:text-white border border-white/10 text-sm font-medium transition-all" data-action="click->tabs#openComments" data-type="room" data-id="${roomData.room_id}" data-name="${escaped}">
             <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
               <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/>
             </svg>
             Comments
             ${roomData.comments_count > 0 ? `<span class="bg-gradient-to-r from-purple-500 to-pink-500 text-white text-xs rounded-full px-1.5 min-w-[18px] text-center font-semibold">${roomData.comments_count}</span>` : ""}
           </button>`
        : "";

      const roomTotal = roomData ? roomData.total : 0;
      const roomTotalHtml = roomTotal > 0
        ? `<div class="flex items-center gap-2 px-4 py-2 rounded-xl bg-emerald-500/10 border border-emerald-500/20">
             <svg class="w-4 h-4 text-emerald-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
               <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
             </svg>
             <span class="text-emerald-300 font-semibold">$${roomTotal.toLocaleString()}</span>
           </div>`
        : "";

      // Room plan button - view if exists
      let roomPlanHtml = "";
      if (roomData && roomData.plan_url) {
        roomPlanHtml = `
          <a href="${roomData.plan_url}" target="_blank" class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-sky-500/10 hover:bg-sky-500/20 text-sky-300 hover:text-sky-200 border border-sky-500/20 text-sm font-medium transition-all">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"/>
            </svg>
            View Plan
          </a>`;
      }

      // Room plan with products button - view if exists (visible to all)
      let roomPlanWithProductsHtml = "";
      if (roomData && roomData.plan_with_products_url) {
        roomPlanWithProductsHtml = `
          <a href="${roomData.plan_with_products_url}" target="_blank" class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-violet-500/10 hover:bg-violet-500/20 text-violet-300 hover:text-violet-200 border border-violet-500/20 text-sm font-medium transition-all">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"/>
            </svg>
            Plan + Products
          </a>`;
      }

      // Upload buttons for designers
      let uploadPlanHtml = "";
      let uploadPlanWithProductsHtml = "";
      if (this.isDesignerValue) {
        uploadPlanHtml = `
          <label class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white/[0.05] hover:bg-white/10 text-white/70 hover:text-white border border-white/10 text-sm font-medium cursor-pointer transition-all">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"/>
            </svg>
            ${roomData && roomData.plan_url ? "Replace" : "Upload"} Plan
            <input type="file" class="hidden" accept="image/*,.pdf" data-action="change->tabs#uploadPlan" data-room-id="${roomData ? roomData.room_id : ""}" data-room-name="${escaped}" data-plan-type="plan">
          </label>`;

        uploadPlanWithProductsHtml = `
          <label class="inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white/[0.05] hover:bg-white/10 text-white/70 hover:text-white border border-white/10 text-sm font-medium cursor-pointer transition-all">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"/>
            </svg>
            ${roomData && roomData.plan_with_products_url ? "Replace" : "Upload"} Plan + Products
            <input type="file" class="hidden" accept="image/*,.pdf" data-action="change->tabs#uploadPlan" data-room-id="${roomData ? roomData.room_id : ""}" data-room-name="${escaped}" data-plan-type="plan_with_products">
          </label>`;
      }

      this.contentTarget.innerHTML = `
        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6 pb-6 border-b border-white/10">
          <div class="flex items-center gap-4">
            <h2 class="text-xl font-semibold text-white">${escaped}</h2>
            ${roomTotalHtml}
          </div>
          <div class="flex items-center gap-2 flex-wrap">
            ${roomCommentsButton}
            ${roomPlanHtml}
            ${roomPlanWithProductsHtml}
            ${uploadPlanHtml}
            ${uploadPlanWithProductsHtml}
            ${addProductButton}
          </div>
        </div>
        ${productsHtml}
        ${pendingProductsHtml}
        ${emptyHtml}
      `;
    }
  }

  statusActionButton(product, projectId) {
    const action = getNextStatusAction(product.status, this.isDesignerValue);
    if (!action) return "";

    return `
      <form action="/projects/${projectId}/products/${product.id}/update_status" method="post" class="inline">
        <input type="hidden" name="authenticity_token" value="${getCSRFToken()}">
        <input type="hidden" name="status" value="${action.nextStatus}">
        <button type="submit" class="text-sm px-3 py-1.5 rounded-lg text-white font-medium shadow-md transition-all hover:shadow-lg" style="${action.buttonStyle}">${action.buttonLabel}</button>
      </form>
    `;
  }

  openComments(event) {
    const type = event.currentTarget.dataset.type;
    const id = event.currentTarget.dataset.id;
    const name = event.currentTarget.dataset.name;

    // Dispatch custom event to open the comments panel
    this.dispatch("openCommentsPanel", {
      detail: { type, id, name },
      bubbles: true,
    });
  }

  uploadPlan(event) {
    const file = event.target.files[0];
    if (!file) return;

    const roomId = event.target.dataset.roomId;
    const roomName = event.target.dataset.roomName;
    const planType = event.target.dataset.planType || "plan";
    const projectId = this.projectIdValue;

    const formData = new FormData();
    formData.append(`room[${planType}]`, file);

    let url, method;
    if (roomId) {
      // Update existing room
      url = `/projects/${projectId}/rooms/${roomId}`;
      method = "PATCH";
    } else {
      // Create new room
      url = `/projects/${projectId}/rooms`;
      method = "POST";
      formData.append("room[name]", roomName);
    }

    fetch(url, {
      method: method,
      body: formData,
      headers: {
        "X-CSRF-Token": getCSRFToken(),
      },
    })
      .then((response) => {
        if (response.ok || response.redirected) {
          window.location.reload();
        } else {
          alert("Failed to upload plan");
        }
      })
      .catch(() => {
        alert("Failed to upload plan");
      });
  }
}
