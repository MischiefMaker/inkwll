# Pays every approved character being played their weekly allowance, once
# per week, like weekly XP. Retired and roster characters get none.
class EconomyAllowanceJob < ApplicationJob
  def perform(now = Time.current)
    Economy.pay_allowances!(now)
  end
end
