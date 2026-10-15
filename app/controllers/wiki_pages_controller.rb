# The wiki: pages anyone with an account can read and write. Locked pages
# only staff can change. Every save keeps a revision (see RevisionsController).
class WikiPagesController < ApplicationController
  include WikiRequired
  # Guests can read the wiki, but not edit it (owner).
  allow_previews only: %i[ index show ]
  limit_posting to: 10, within: 10.minutes, only: %i[ create update preview ]
  before_action :set_page, only: %i[ edit update destroy ]
  before_action :require_editable, only: %i[ edit update ]

  def index
    @tag = params[:tag].to_s.squish.downcase.first(30).presence
    @query = params[:q].to_s.squish.first(100).presence
    pages = WikiPage.order(:title)
    pages = pages.tagged(@tag) if @tag
    if @query
      like = "%#{WikiPage.sanitize_sql_like(@query)}%"
      pages = pages.where("title ILIKE :like OR body ILIKE :like", like: like)
    end
    @pages = pages.limit(500)
    @tags = WikiPage.pluck(:tags).flatten.tally.sort_by { |tag, count| [ -count, tag ] }.first(50).map(&:first)
  end

  # A link to a page that was renamed goes to its new address. A link to a
  # page nobody has written yet offers to start it.
  def show
    @page = WikiPage.find_by(slug: params[:slug])
    return if @page
    if (renamed = WikiPage.find_by_old_slug(params[:slug]))
      redirect_to wiki_page_path(renamed), status: :moved_permanently
    else
      render :missing, status: :not_found
    end
  end

  def new
    @page = WikiPage.new(title: params[:title].to_s.first(100))
  end

  def create
    @page = WikiPage.new(page_params)
    @page.save_revision!(by: current_account, summary: "Started the page")
    redirect_to wiki_page_path(@page), notice: "Page saved."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  def edit
  end

  # Shows the page as it will look, without saving. Same rendering (and the
  # same stripping of scripts) as a saved page.
  def preview
    render partial: "wiki_pages/preview", locals: { body: params[:body].to_s.first(100_000) }
  end

  def update
    @page.assign_attributes(page_params)
    if @page.changed?
      @page.save_revision!(by: current_account, summary: params[:summary])
      redirect_to wiki_page_path(@page), notice: "Page saved."
    else
      redirect_to wiki_page_path(@page), notice: "Nothing changed."
    end
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :unprocessable_entity
  end

  # Only Scribes and Wellkeepers delete pages. Everyone else can blank one,
  # which history can undo.
  def destroy
    return redirect_to(wiki_page_path(@page), alert: "Only Scribes and Wellkeepers can delete pages.") unless current_account.can?(:manage_staff)
    @page.destroy!
    redirect_to wiki_pages_path, notice: "Page deleted."
  end

  private
    def set_page
      @page = WikiPage.find_by!(slug: params[:slug])
    end

    def require_editable
      redirect_to wiki_page_path(@page), alert: "Only staff can change this page." unless @page.editable_by?(current_account)
    end

    def page_params
      permitted = %i[ title body tag_list ]
      permitted << :menu_position if current_account.staff?
      attrs = params.expect(wiki_page: permitted)
      attrs[:menu_position] = attrs[:menu_position].presence&.to_i&.clamp(0, 999) if attrs.key?(:menu_position)
      attrs
    end
end
