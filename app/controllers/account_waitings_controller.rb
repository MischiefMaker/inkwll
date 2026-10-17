# The page a new player sees until staff approve their account, in games
# that ask for that (Admin → Game settings).
class AccountWaitingsController < ApplicationController
  skip_before_action :hold_unapproved_player

  def show
    redirect_to root_path unless current_account.awaiting_approval?
  end
end
