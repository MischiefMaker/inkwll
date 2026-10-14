class WikiPages::BaseController < ApplicationController
  include WikiRequired

  private
    def set_page
      @page = WikiPage.find_by!(slug: params[:wiki_page_slug])
    end
end
