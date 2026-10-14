module ApplicationHelper
  # The word players see for one of Inkwll's things, from config/locales/en.yml.
  # term(:room) is "Setting"; term(:room, count: 2) is "Settings".
  def term(name, count: 1)
    t("terms.#{name}", count: count)
  end

  # Classes on <body> so a skin can style one page or kind of visitor:
  # "page-scenes page-scenes-show is-logged-in", or "page-admin-bans ... is-staff".
  def body_classes
    page = "page-#{controller_path.tr("/", "-")}"
    classes = [ page, "#{page}-#{action_name}" ]
    classes << (current_account ? "is-logged-in" : "is-guest")
    classes << "is-staff" if current_account&.staff?
    classes.join(" ")
  end
end
