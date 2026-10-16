# Admin → Import a world: sets up this game's world from a world pack file
# (see WorldPack and docs/world-packs.md). Only the Founder, because a pack
# can change every Area, Place, Path and the game's whole look.
#
# Uploading shows what would change first. The file waits in storage until
# Import is pressed, then it is deleted.
class Admin::WorldImportsController < Admin::BaseController
  before_action :require_founder

  def show
  end

  # Reads the uploaded pack and shows what importing it would do.
  def create
    file = params[:pack]
    return redirect_to(admin_world_import_path, alert: "Choose a world pack file first.") unless file.respond_to?(:read)
    return redirect_to(admin_world_import_path, alert: "The file is bigger than #{WorldPack::MAX_SIZE / 1.megabyte} MB.") if file.size > WorldPack::MAX_SIZE

    text = file.read
    @pack = WorldPack.parse(text)
    @remove_unlisted = params[:remove_unlisted] == "1"
    @changes = @pack.preview(remove_unlisted: @remove_unlisted)
    @upload = ActiveStorage::Blob.create_and_upload!(io: StringIO.new(text), filename: file.original_filename.presence || "world-pack.json", content_type: "application/json")
    render :preview
  rescue WorldPack::Invalid => error
    redirect_to admin_world_import_path, alert: error.message
  end

  def apply
    blob = ActiveStorage::Blob.find_signed(params[:upload])
    return redirect_to(admin_world_import_path, alert: "That upload has expired. Choose the file again.") unless blob

    pack = WorldPack.parse(blob.download)
    pack.import!(by: current_account, remove_unlisted: params[:remove_unlisted] == "1")
    blob.purge_later
    redirect_to root_path, notice: "Imported #{pack.name}."
  rescue WorldPack::Invalid, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotDestroyed => error
    redirect_to admin_world_import_path, alert: "Nothing was imported: #{error.message}"
  end
end
