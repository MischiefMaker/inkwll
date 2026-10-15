# For records staff have to look at (applications, requests, reports). When
# one changes, the bell in every staff member's header is refreshed so its
# number stays right without a page reload.
module AffectsStaffQueue
  extend ActiveSupport::Concern

  included do
    after_commit { StaffWaiting.refresh_bells! }
  end
end
