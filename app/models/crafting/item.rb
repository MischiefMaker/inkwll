# Something a character owns, in their Belongings, which everyone can see.
# Stacks (12 arrows) have a quantity. A made item keeps its maker's mark
# whoever owns it, and its features count in its owner's rolls.
class Crafting::Item < ApplicationRecord
  IMAGE_TYPES = %w[ image/png image/jpeg image/gif image/webp ].freeze
  MAX_PICTURES = 4

  belongs_to :character
  belongs_to :catalogue_item, class_name: "Crafting::CatalogueItem", optional: true
  belongs_to :item_type, class_name: "Crafting::ItemType", optional: true
  belongs_to :maker, class_name: "Character", optional: true
  has_many_attached :pictures
  has_many :events, class_name: "Crafting::ItemEvent", dependent: :nullify

  normalizes :name, with: ->(name) { name.squish }
  normalizes :flaw_name, with: ->(name) { name.squish.presence }
  validates :name, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 5000 }
  validates :flaw_name, length: { maximum: 60 }
  validates :quantity, numericality: { only_integer: true, in: 1..100_000 }
  validates :price, numericality: { only_integer: true, in: 1..10_000_000 }, allow_nil: true
  validate :pictures_are_reasonable

  scope :ordered, -> { order(:name, :id) }
  scope :for_sale, -> { where.not(listed_at: nil) }

  def features = Crafting::Feature.where(id: feature_ids).ordered
  def made? = made_at.present?
  def for_sale? = listed_at.present?

  # Moves some or all of a stack to another character. Taking part of a
  # stack splits it. Returns the item the other character now has. It comes
  # off the Market either way.
  def move_to!(new_owner, quantity: self.quantity)
    quantity = quantity.to_i
    raise Crafting::Error, "Pick between 1 and #{self.quantity}." unless quantity.between?(1, self.quantity)
    if quantity == self.quantity
      update!(character: new_owner, price: nil, listed_at: nil)
      withdraw_from_trades!
      self
    else
      update!(quantity: self.quantity - quantity)
      copy = dup
      copy.assign_attributes(character: new_owner, quantity: quantity, price: nil, listed_at: nil)
      copy.pictures.attach(pictures.blobs)
      copy.save!
      copy
    end
  end

  # Takes the item out of any open trade, clearing that trade's ticks, since
  # its owner has changed.
  def withdraw_from_trades!
    lines = Crafting::TradeItem.where(item_id: id)
    Crafting::Trade.open.where(id: lines.select(:trade_id)).update_all(from_agreed: false, to_agreed: false, updated_at: Time.current)
    lines.delete_all
  end

  private
    def pictures_are_reasonable
      errors.add(:pictures, "can be at most #{MAX_PICTURES}") if pictures.size > MAX_PICTURES
      return unless attachment_changes["pictures"]
      pictures.each do |picture|
        next if picture.persisted?
        errors.add(:pictures, "must be pictures (PNG, JPEG, GIF or WebP)") unless picture.content_type.in?(IMAGE_TYPES)
        errors.add(:pictures, "must each be smaller than 5 MB") if picture.blob.byte_size > DescribedWithImage::MAX_IMAGE_SIZE
      end
    end
end
