# The tabs of the player's open Chapters. The tab bar reloads itself from here
# whenever one of those Chapters changes.
class ChapterTabsController < ApplicationController
  def show
    render partial: "chapter_tabs/tabs", locals: { account: current_account }
  end

  # The X on a finished Chapter's tab: it stays in My Chapters and the
  # Archives, but stops taking up room in the tab bar. Only your own tabs,
  # and only once the Chapter is finished.
  def close
    participant = SceneParticipant.where(character: current_account.characters).find(params[:participant_id])
    participant.update!(tab_closed: true) if participant.scene.finished?
    current_account.broadcast_chapter_tabs
    redirect_back fallback_location: my_chapters_path, status: :see_other
  end
end
