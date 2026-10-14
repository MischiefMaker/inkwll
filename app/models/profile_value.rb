# What a character's player wrote in one profile field.
class ProfileValue < ApplicationRecord
  belongs_to :character
  belongs_to :profile_field

  validates :value, length: { maximum: 20_000 }
  validate :dates_are_dates

  def as_date
    Date.iso8601(value) if value.present?
  rescue Date::Error
    nil
  end

  private
    def dates_are_dates
      errors.add(:value, "for #{profile_field.name} must be a date") if profile_field.date? && value.present? && as_date.nil?
    end
end
