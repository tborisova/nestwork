# frozen_string_literal: true

module StatusHelper
  # Project status configuration
  PROJECT_STATUSES = {
    "new" => { label: "New", css_class: "badge-new" },
    "in_progress" => { label: "In Progress", css_class: "badge-progress" },
    "waiting_for_approval" => { label: "Waiting", css_class: "badge-waiting" },
    "done" => { label: "Done", css_class: "badge-done" }
  }.freeze

  # Product status configuration
  PRODUCT_STATUSES = {
    "pending" => { label: "Pending", css_class: "bg-white/10 text-white/60 border border-white/10" },
    "approved" => { label: "Approved", css_class: "bg-emerald-500/20 text-emerald-300 border border-emerald-500/30" },
    "rejected" => { label: "Rejected", css_class: "bg-rose-500/20 text-rose-300 border border-rose-500/30" },
    "ordered" => { label: "Ordered", css_class: "bg-amber-500/20 text-amber-300 border border-amber-500/30" },
    "delivered" => { label: "Delivered", css_class: "bg-sky-500/20 text-sky-300 border border-sky-500/30" }
  }.freeze

  # Render a project status badge
  def project_status_badge(status)
    config = PROJECT_STATUSES[status.to_s] || { label: status.to_s.humanize, css_class: "bg-white/20" }
    content_tag(:span, config[:label], class: "badge text-white #{config[:css_class]}")
  end

  # Render a product status badge
  def product_status_badge(status)
    config = PRODUCT_STATUSES[status.to_s] || { label: status.to_s.humanize, css_class: "bg-white/10 text-white/60" }
    content_tag(:span, config[:label], class: "inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold #{config[:css_class]}")
  end
end
