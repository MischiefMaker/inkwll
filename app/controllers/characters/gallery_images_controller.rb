# Adding and removing pictures in a character's gallery.
class Characters::GalleryImagesController < Characters::BaseController
  limit_posting to: 20

  def create
    picture = @character.gallery_images.new(params.expect(gallery_image: [ :image, :caption ]))
    picture.position = @character.gallery_images.maximum(:position).to_i + 1
    if picture.save
      redirect_to character_path(@character, tab: "gallery"), notice: "Picture added."
    else
      redirect_to character_path(@character, tab: "gallery"), alert: picture.errors.full_messages.to_sentence
    end
  end

  def destroy
    @character.gallery_images.find(params[:id]).destroy
    redirect_to character_path(@character, tab: "gallery"), notice: "Picture removed."
  end
end
