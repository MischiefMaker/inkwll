# The site-wide out-of-character chat.
class OocMessagesController < ApplicationController
  def index
  end

  def create
    @ooc_message = current_account.ooc_messages.new(params.expect(ooc_message: [ :body ]))
    @ooc_message.save
    # The new message reaches every open page (including this one) through the
    # live broadcast, so here we only need to reset the form.
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: ooc_messages_path }
    end
  end
end
