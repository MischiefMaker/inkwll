# Lets the game that started this Well see whether it has a Founder yet, so
# the Wells page can hide the first sign-up link. It says nothing else.
class WellStatusController < ApplicationController
  allow_unauthenticated_access

  def show
    expires_now
    render json: { founder: Account.exists?(founder: true) }
  end
end
