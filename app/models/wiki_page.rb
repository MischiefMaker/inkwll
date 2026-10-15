# A wiki page: rules, lore, plots, guides. Written in Markdown by any player.
# Every save keeps a revision, so any change can be undone. Staff can lock a
# page so only staff can change it, and list it in the Menu.
class WikiPage < ApplicationRecord
  has_many :revisions, -> { order(created_at: :desc, id: :desc) }, class_name: "WikiRevision",
    foreign_key: :page_id, dependent: :delete_all, inverse_of: :page
  belongs_to :updated_by, class_name: "Account", optional: true

  normalizes :title, with: ->(t) { t.squish }
  validates :title, presence: true, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: true
  validates :body, length: { maximum: 100_000 }
  validate :title_makes_a_slug

  before_validation { self.slug = self.class.slug_for(title) if title_changed? }
  # Renaming a page changes its address. The old one is remembered, so old
  # links and bookmarks still find the page (owner, 2026-10-14).
  before_save :remember_old_slug, if: -> { persisted? && slug_changed? }

  # The page at this address, or the page that used to be at it.
  def self.find_by_old_slug(slug)
    where("? = ANY(old_slugs)", slug).order(updated_at: :desc).first
  end

  scope :in_menu, -> { where.not(menu_position: nil).order(:menu_position, :title) }
  scope :tagged, ->(tag) { where("? = ANY(tags)", tag.to_s.downcase) }

  def self.enabled?
    GameSetting.current.wiki_enabled?
  end

  # "Rules of the Game" -> "rules-of-the-game"
  def self.slug_for(title)
    title.to_s.unicode_normalize(:nfkd).downcase.gsub(/[^a-z0-9]+/, "-").delete_prefix("-").delete_suffix("-").first(100)
  end

  def to_param = slug
  def locked? = locked_at.present?

  def editable_by?(account) = account.present? && (!locked? || account.staff?)

  def tag_list=(text)
    self.tags = text.to_s.split(",").map { |tag| tag.squish.downcase.first(30) }.compact_blank.uniq.first(20)
  end

  def tag_list = tags.join(", ")

  # Saves a change and keeps it as a revision.
  def save_revision!(by:, summary: nil)
    transaction do
      self.updated_by = by
      save!
      revisions.create!(account: by, title: title, body: body, summary: summary.to_s.squish.first(200).presence)
    end
  end

  private
    def remember_old_slug
      self.old_slugs = (old_slugs | [ slug_was ]) - [ slug ]
    end

    def title_makes_a_slug
      errors.add(:title, "needs some letters or numbers") if title.present? && slug.blank?
      errors.add(:title, "can't be just \"new\"") if slug == "new"
    end
end
