# Pays every Domain's month on the 1st (docs/economy.md, "Domains").
class DomainIncomeJob < ApplicationJob
  def perform
    Domain.pay_month!
  end
end
