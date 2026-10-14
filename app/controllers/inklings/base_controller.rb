# Shared by the actions inside one Inkling.
class Inklings::BaseController < ApplicationController
  include InklingsRequired
  before_action :set_inkling

  private
    def set_inkling
      @inkling = Inkling.find(params[:inkling_id])
      raise ActiveRecord::RecordNotFound unless @inkling.visible_to?(current_account)
    end

    def back(**flash)
      redirect_to inkling_path(@inkling, anchor: "inkling-end"), **flash
    end

    def staff_view?
      @inkling.staff_view?(current_account)
    end

    def require_staff_view
      back(alert: "Only staff can do that.") unless staff_view?
    end
end
