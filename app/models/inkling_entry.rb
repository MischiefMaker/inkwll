# One numbered entry in an Inkling. Shown as "<inkling id>.<sequence>".
class InklingEntry < ApplicationRecord
  KINDS = %w[ public private gm personal roll reward system ].freeze

  belongs_to :inkling
  belongs_to :account, optional: true
  belongs_to :character, optional: true
  belongs_to :private_to, class_name: "Character", optional: true
  belongs_to :soul_roll, class_name: "Soul::Roll", optional: true
  belongs_to :scene, optional: true

  validates :kind, inclusion: { in: KINDS }
  validates :body, presence: true, length: { maximum: 20_000 }

  def reference = "#{inkling_id}.#{sequence}"
  def mine?(account) = account_id == account.id

  def visible_to?(account)
    return false unless inkling.visible_to?(account)
    case kind
    when "personal" then mine?(account)
    when "gm" then inkling.staff_view?(account)
    when "private" then hidden_but_from_staff?(account)
    else private? ? hidden_but_from_staff?(account) : true
    end
  end

  private
    # Seen by whoever wrote it, staff, and the character it's addressed to
    # (staff address theirs, usually to the Inkling's own character).
    def hidden_but_from_staff?(account)
      mine?(account) || inkling.staff_view?(account) || private_to&.account_id == account.id
    end
end
