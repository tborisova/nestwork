import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["panel", "title", "list", "input", "form"];
  static values = { projectId: Number };

  connect() {
    this.commentableType = null;
    this.commentableId = null;
    this.commentsUrl = null;
  }

  open(event) {
    const { type, id, name } = event.detail;
    this.commentableType = type;
    this.commentableId = id;
    this.commentsUrl = this.buildUrl(type, id);

    this.titleTarget.textContent = name;
    this.panelTarget.classList.remove("translate-x-full");
    this.loadComments();
  }

  close() {
    this.panelTarget.classList.add("translate-x-full");
    this.listTarget.innerHTML = "";
    this.inputTarget.value = "";
  }

  buildUrl(type, id) {
    const projectId = this.projectIdValue;
    const typeMap = {
      product: "products",
      selection: "selections",
      room: "rooms",
    };
    return `/projects/${projectId}/${typeMap[type]}/${id}/comments`;
  }

  async loadComments() {
    this.listTarget.innerHTML =
      '<div class="text-white/50 text-sm py-4">Loading comments...</div>';

    try {
      const response = await fetch(this.commentsUrl, {
        headers: { Accept: "application/json" },
      });
      if (response.ok) {
        const comments = await response.json();
        this.renderComments(comments);
      } else {
        this.listTarget.innerHTML =
          '<div class="text-rose-400 text-sm py-4">Failed to load comments</div>';
      }
    } catch (e) {
      console.error("Failed to load comments:", e);
      this.listTarget.innerHTML =
        '<div class="text-rose-400 text-sm py-4">Failed to load comments</div>';
    }
  }

  renderComments(comments) {
    if (comments.length === 0) {
      this.listTarget.innerHTML =
        '<div class="text-white/50 text-sm py-4">No comments yet. Be the first to add one!</div>';
      return;
    }

    this.listTarget.innerHTML = comments.map((c) => this.commentHtml(c)).join("");
  }

  commentHtml(comment) {
    const resolvedClass = comment.resolved
      ? "bg-emerald-900/20 border-emerald-800/30"
      : "bg-white/5 border-white/10";
    const resolvedBadge = comment.resolved
      ? '<span class="inline-flex items-center rounded px-1.5 py-0.5 text-xs bg-emerald-700 text-white">Resolved</span>'
      : "";
    const deleteBtn = comment.can_delete
      ? `<button type="button" class="p-1 rounded hover:bg-white/10 text-white/60 hover:text-rose-400" data-action="click->comments-panel#deleteComment" data-comment-id="${comment.id}" title="Delete">
           <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
             <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
           </svg>
         </button>`
      : "";

    const resolveIcon = comment.resolved
      ? `<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
           <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
         </svg>`
      : `<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
           <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
         </svg>`;

    return `
      <div class="p-3 rounded-lg ${resolvedClass} border" id="comment_${comment.id}" data-resolved="${comment.resolved}">
        <div class="flex items-start justify-between gap-2">
          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-2 mb-1 flex-wrap">
              <span class="text-white/90 text-sm font-medium">${this.escape(comment.user_name)}</span>
              <span class="text-white/40 text-xs">${this.timeAgo(comment.created_at)}</span>
              ${resolvedBadge}
            </div>
            <p class="text-white/80 text-sm break-words">${this.escape(comment.comment)}</p>
          </div>
          <div class="flex items-center gap-1 shrink-0">
            <button type="button" class="p-1 rounded hover:bg-white/10 text-white/60 hover:text-white" data-action="click->comments-panel#toggleResolved" data-comment-id="${comment.id}" title="${comment.resolved ? "Mark unresolved" : "Mark resolved"}">
              ${resolveIcon}
            </button>
            ${deleteBtn}
          </div>
        </div>
      </div>
    `;
  }

  async submitComment(event) {
    event.preventDefault();
    const commentText = this.inputTarget.value.trim();
    if (!commentText) return;

    try {
      const response = await fetch(this.commentsUrl, {
        method: "POST",
        body: JSON.stringify({ comment: { comment: commentText } }),
        headers: {
          "X-CSRF-Token": this.getCSRFToken(),
          "Content-Type": "application/json",
          Accept: "application/json",
        },
      });

      if (response.ok) {
        const comment = await response.json();
        this.inputTarget.value = "";
        // Prepend new comment to list
        const html = this.commentHtml(comment);
        if (
          this.listTarget.querySelector(".text-white\\/50") ||
          this.listTarget.querySelector(".text-rose-400")
        ) {
          this.listTarget.innerHTML = html;
        } else {
          this.listTarget.insertAdjacentHTML("afterbegin", html);
        }
        // Dispatch event to update badge count
        this.dispatch("commentAdded", {
          detail: { type: this.commentableType, id: this.commentableId },
        });
      } else {
        const error = await response.json();
        alert(error.errors?.[0] || "Could not add comment");
      }
    } catch (e) {
      console.error("Comment submission failed:", e);
      alert("Failed to submit comment");
    }
  }

  async toggleResolved(event) {
    const commentId = event.currentTarget.dataset.commentId;
    const commentEl = document.getElementById(`comment_${commentId}`);
    const isResolved = commentEl.dataset.resolved === "true";

    try {
      const response = await fetch(`${this.commentsUrl}/${commentId}`, {
        method: "PATCH",
        body: JSON.stringify({ comment: { resolved: !isResolved } }),
        headers: {
          "X-CSRF-Token": this.getCSRFToken(),
          "Content-Type": "application/json",
          Accept: "application/json",
        },
      });

      if (response.ok) {
        const comment = await response.json();
        commentEl.outerHTML = this.commentHtml(comment);
      }
    } catch (e) {
      console.error("Toggle resolved failed:", e);
    }
  }

  async deleteComment(event) {
    if (!confirm("Delete this comment?")) return;

    const commentId = event.currentTarget.dataset.commentId;

    try {
      const response = await fetch(`${this.commentsUrl}/${commentId}`, {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": this.getCSRFToken(),
          Accept: "application/json",
        },
      });

      if (response.ok) {
        document.getElementById(`comment_${commentId}`).remove();
        // Check if list is empty
        if (this.listTarget.children.length === 0) {
          this.listTarget.innerHTML =
            '<div class="text-white/50 text-sm py-4">No comments yet. Be the first to add one!</div>';
        }
        // Dispatch event to update badge count
        this.dispatch("commentRemoved", {
          detail: { type: this.commentableType, id: this.commentableId },
        });
      }
    } catch (e) {
      console.error("Delete failed:", e);
    }
  }

  escape(text) {
    const el = document.createElement("div");
    el.textContent = text == null ? "" : String(text);
    return el.innerHTML;
  }

  timeAgo(dateString) {
    const date = new Date(dateString);
    const now = new Date();
    const seconds = Math.floor((now - date) / 1000);

    if (seconds < 60) return "just now";
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes}m ago`;
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `${hours}h ago`;
    const days = Math.floor(hours / 24);
    if (days < 30) return `${days}d ago`;
    const months = Math.floor(days / 30);
    return `${months}mo ago`;
  }

  getCSRFToken() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.getAttribute("content") : "";
  }
}
