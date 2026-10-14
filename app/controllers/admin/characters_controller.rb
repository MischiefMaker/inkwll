# Character list for staff. Only Wellkeepers can delete a character.
class Admin::CharactersController < Admin::BaseController
  require_job :delete_characters

  def index
    @characters = Character.includes(:account, :room).order(:name)
  end

  def destroy
    character = Character.find(params[:id])
    character.destroy!
    redirect_to admin_characters_path, notice: "#{character.name} has been deleted."
  end
end
