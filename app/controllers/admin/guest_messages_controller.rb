# Clearing away a guest's OOC Chat messages, usually spam, by address.
class Admin::GuestMessagesController < Admin::BaseController
  require_job :ban

  def destroy
    messages = OocMessage.from_guests.where(ip_address: params[:ip])
    count = messages.count
    messages.destroy_all
    redirect_to admin_bans_path, notice: "Removed #{count} guest #{"message".pluralize(count)}."
  end
end
