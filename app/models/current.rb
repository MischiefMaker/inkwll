class Current < ActiveSupport::CurrentAttributes
  attribute :session, :game_setting
  delegate :account, to: :session, allow_nil: true
end
