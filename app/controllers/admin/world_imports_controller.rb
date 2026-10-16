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

  # Keeps the uploaded pack and goes on to the preview. It redirects rather
  # than showing the preview straight away, because Turbo ignores a form
  # that answers with a page instead of a redirect.
  def create
    file = params[:pack]
    return redirect_to(admin_world_import_path, alert: "Choose a world pack file first.") unless file.respond_to?(:read)
    return redirect_to(admin_world_import_path, alert: "The file is bigger than #{WorldPack::MAX_SIZE / 1.megabyte} MB.") if file.size > WorldPack::MAX_SIZE

    text = file.read
    WorldPack.parse(text)
    upload = ActiveStorage::Blob.create_and_upload!(io: StringIO.new(text), filename: file.original_filename.presence || "world-pack.json", content_type: "application/json")
    redirect_to preview_admin_world_import_path(upload: upload.signed_id(expires_in: 1.day), remove_unlisted: params[:remove_unlisted] == "1" ? "1" : nil)
  rescue WorldPack::Invalid => error
    redirect_to admin_world_import_path, alert: error.message
  end

  # Shows what importing the uploaded pack would do.
  def preview
    @upload = ActiveStorage::Blob.find_signed(params[:upload])
    return redirect_to(admin_world_import_path, alert: "That upload has expired. Choose the file again.") unless @upload

    @pack = WorldPack.parse(@upload.download)
    @remove_unlisted = params[:remove_unlisted] == "1"
    @changes = @pack.preview(remove_unlisted: @remove_unlisted)
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
