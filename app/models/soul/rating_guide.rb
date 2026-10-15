# One line of the guide to what ratings mean, such as "7-8: Exceptional".
# Staff write them in Admin → SOUL; the SOUL sheet shows them behind an
# "i" icon. The ranges are for reading only: they change nothing in play.
class Soul::RatingGuide < ApplicationRecord
  scope :ordered, -> { order(:low, :high, :id) }

  validates :name, presence: true, length: { maximum: 40 }
  validates :description, length: { maximum: 500 }
  validates :low, :high, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :high_is_not_below_low

  def range_text = low == high ? low.to_s : "#{low}–#{high}"

  private
    def high_is_not_below_low
      errors.add(:high, "can't be lower than the first number") if low && high && high < low
    end
end
