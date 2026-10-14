# Adding and removing a character's relationships.
class Characters::RelationshipsController < Characters::BaseController
  limit_posting to: 20

  def create
    relationship = @character.relationships.new(params.expect(relationship: [ :other_character_name, :kind, :note ]))
    relationship.position = @character.relationships.maximum(:position).to_i + 1
    if relationship.save
      redirect_to character_path(@character, tab: "relationships"), notice: "Relationship added."
    else
      redirect_to character_path(@character, tab: "relationships"), alert: relationship.errors.full_messages.to_sentence
    end
  end

  def destroy
    @character.relationships.find(params[:id]).destroy
    redirect_to character_path(@character, tab: "relationships"), notice: "Relationship removed."
  end
end
