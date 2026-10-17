# Crafting offers item features to SOUL rolls through SOUL's published hook.
Rails.application.config.to_prepare do
  Soul.offer_roll_extras(:crafting) { |character| Crafting.roll_extras_for(character) }
end
