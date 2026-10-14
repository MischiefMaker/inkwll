# A player marking a staff warning as read.
class WarningsController < ApplicationController
  def update
    current_account.account_warnings.find(params[:id]).update!(read_at: Time.current)
    redirect_back_or_to root_path
  end
end
