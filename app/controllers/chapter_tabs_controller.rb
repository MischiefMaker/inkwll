# The tabs of the player's open Chapters. The tab bar reloads itself from here
# whenever one of those Chapters changes.
class ChapterTabsController < ApplicationController
  def show
    render partial: "chapter_tabs/tabs", locals: { account: current_account }
  end
end
