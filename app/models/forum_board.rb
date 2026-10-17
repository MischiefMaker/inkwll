# A forum board, for things that suit a forum better than a Chapter: news,
# advertising, wanted ads and so on. Staff make the boards and choose, for
# each one, who may start threads and who may reply. Shown on the front
# page after the Areas.
class ForumBoard < ApplicationRecord
  # Like an Area card: a small icon beside the name and a large banner.
  PICTURES = %i[ icon image ].freeze
  PICTURES.each do |picture|
    has_one_attached picture
    attribute :"remove_#{picture}", :boolean, default: false
    after_save { send(picture).purge_later if send(:"remove_#{picture}") && send(picture).attached? }
  end
  validate :pictures_are_reasonable

  # Who may post, from most open to most closed. "nobody" is only for replies,
  # for a board such as News where threads are announcements.
  POSTERS = %w[ everyone staff senior_staff nobody ].freeze
  STARTERS = POSTERS - %w[ nobody ]
  # A character group's own board: only the group's characters post.
  GROUP_POSTERS = %w[ group_members ].freeze

  belongs_to :character_group, optional: true
  has_many :topics, class_name: "ForumTopic", foreign_key: :board_id, inverse_of: :board, dependent: :destroy

  validates :name, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 1_000 }
  validates :who_can_start, inclusion: { in: STARTERS + GROUP_POSTERS }
  validates :who_can_reply, inclusion: { in: POSTERS + GROUP_POSTERS }

  scope :ordered, -> { order(:position, :name) }
  # The boards staff make, listed on the front page; group boards live on
  # their group's page instead.
  scope :general, -> { where(character_group_id: nil) }

  # On an in-character board people post as one of their characters: approved
  # and still played. On a group's board, only its members.
  def characters_for(account)
    return Character.none unless account
    characters = account.characters.active.order(:name)
    characters = characters.where(character_group_id: character_group_id, on_roster_at: nil) if character_group_id
    characters.select(&:can_play?)
  end

  def may_start_topic?(account)
    allowed?(who_can_start, account)
  end

  def may_reply?(account)
    allowed?(who_can_reply, account)
  end

  # The newest post anywhere on this board, for the front page.
  def latest_post
    ForumPost.joins(:topic).where(forum_topics: { board_id: id })
      .includes(:account, :topic).order(created_at: :desc).first
  end

  # Thread order on the board: pinned threads first, then the most recently
  # active.
  def ordered_topics
    topics.order(Arel.sql("pinned_at IS NULL"), pinned_at: :desc, last_posted_at: :desc)
  end

  private
    def pictures_are_reasonable
      PICTURES.each do |picture|
        file = send(picture)
        next unless file.attached? && attachment_changes[picture.to_s]
        errors.add(picture, "must be a picture (PNG, JPEG, GIF or WebP)") unless file.content_type.in?(%w[ image/png image/jpeg image/gif image/webp ])
        errors.add(picture, "must be smaller than 5 MB") if file.blob.byte_size > DescribedWithImage::MAX_IMAGE_SIZE
      end
    end

    def allowed?(who, account)
      return false unless account
      case who
      when "everyone" then true
      when "staff" then account.staff?
      when "senior_staff" then account.scribe? || account.wellkeeper?
      when "group_members" then characters_for(account).any?
      else false
      end
    end
end
