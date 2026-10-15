module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_account

    # Guests connect too, so they see the OOC Chat live. They only ever get
    # the stream names printed on the pages they can open.
    def connect
      set_current_account
    end

    private
      def set_current_account
        if session = Session.find_by(id: cookies.signed[Authentication::LOGIN_COOKIE])
          self.current_account = session.account
        end
      end
  end
end
