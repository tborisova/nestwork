// Shared DOM utility functions for Stimulus controllers

/**
 * Get the CSRF token from the meta tag
 * @returns {string} The CSRF token
 */
export function getCSRFToken() {
  const meta = document.querySelector('meta[name="csrf-token"]');
  return meta ? meta.getAttribute("content") : "";
}

/**
 * Escape HTML to prevent XSS
 * @param {string} text - Text to escape
 * @returns {string} Escaped HTML string
 */
export function escapeHtml(text) {
  const el = document.createElement("div");
  el.textContent = text == null ? "" : String(text);
  return el.innerHTML;
}

/**
 * Format a date as a relative time string (e.g., "5m ago")
 * @param {string|Date} dateString - The date to format
 * @returns {string} Relative time string
 */
export function timeAgo(dateString) {
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

/**
 * Format a number as currency
 * @param {number} amount - The amount to format
 * @param {string} currency - Currency symbol (default: $)
 * @returns {string} Formatted currency string
 */
export function formatCurrency(amount, currency = "$") {
  if (amount == null) return "-";
  return `${currency}${amount.toLocaleString()}`;
}

/**
 * Get status CSS classes for product status badges
 * @param {string} status - The product status
 * @returns {string} CSS classes for the status badge
 */
export function getProductStatusClass(status) {
  const classes = {
    approved: "bg-emerald-500/20 text-emerald-300 border border-emerald-500/30",
    ordered: "bg-amber-500/20 text-amber-300 border border-amber-500/30",
    delivered: "bg-sky-500/20 text-sky-300 border border-sky-500/30",
    rejected: "bg-rose-500/20 text-rose-300 border border-rose-500/30",
  };
  return classes[status] || "bg-white/10 text-white/60 border border-white/10";
}

/**
 * Get the next status action for a product
 * @param {string} currentStatus - Current product status
 * @param {boolean} isDesigner - Whether user is a designer
 * @returns {object|null} Object with nextStatus, buttonLabel, buttonStyle or null
 */
export function getNextStatusAction(currentStatus, isDesigner) {
  const status = currentStatus || "pending";

  if (status === "pending") {
    return {
      nextStatus: "approved",
      buttonLabel: "Approve",
      buttonStyle: "background: linear-gradient(135deg, #10b981 0%, #34d399 100%);",
    };
  }

  if (status === "approved" && isDesigner) {
    return {
      nextStatus: "ordered",
      buttonLabel: "Mark Ordered",
      buttonStyle: "background: linear-gradient(135deg, #f59e0b 0%, #fbbf24 100%);",
    };
  }

  if (status === "ordered" && isDesigner) {
    return {
      nextStatus: "delivered",
      buttonLabel: "Mark Delivered",
      buttonStyle: "background: linear-gradient(135deg, #0ea5e9 0%, #06b6d4 100%);",
    };
  }

  return null;
}
