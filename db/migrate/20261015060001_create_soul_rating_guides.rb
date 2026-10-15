# A guide to what the ratings mean (what's normal, what's superhuman), set
# by staff in Admin → SOUL and shown on the SOUL sheet behind an "i" icon.
class CreateSoulRatingGuides < ActiveRecord::Migration[8.1]
  def up
    create_table :soul_rating_guides do |t|
      t.integer :low, null: false
      t.integer :high, null: false
      t.string :name, null: false
      t.text :description
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    Soul::RatingGuide.reset_column_information
    StarterContent.install_rating_guide! if Room.exists?
  end

  def down
    drop_table :soul_rating_guides
  end
end
