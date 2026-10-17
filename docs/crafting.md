# Crafting (Version 2.0, Theme 9)

**Status: [Proposed]** by Claude on 2026-10-17, for the owner to answer the
questions at the bottom. Nothing here is built. Once the owner answers, the
settled parts move to `decisions.md` and this page is updated to match.

Crafting comes after the Economy (`economy.md`) and builds on it. It's an
optional system a game switches on, like Grimoire (owner, 2026-10-17). Arx
is the starting point again, simplified (owner, 2026-10-17).

## What we learned from Arx

Arx's crafting (github.com/Arx-Game/arxcode, `world/crafting`) has:

- **Recipes** known by a character or an organisation, each tied to an
  ability and a skill, with a difficulty and a level.
- **Dozens of material types,** which a recipe needs in set amounts, plus a
  silver cost.
- **A roll that sets a quality number** from 0 to 11, which then changes the
  item's stats (armour, weapon damage, how much a container holds, where it's
  worn).
- **Refining:** paying again to re-roll for a better quality.
- **Adornments** (extra materials added for value), **forgeries** (one
  material passed off as another), **translated text** and **junking**
  (breaking an item down to get materials back).
- **Everything by command,** with a dozen switches on `craft`.

Most of that exists to feed combat stats and a strategy-style economy, which
Inkwll doesn't have. What's worth keeping is the core: a recipe, what it
uses, a Skill roll, and a named, described thing the player made, with the
maker's name on it.

## The idea in one line

Staff write recipes. A character with the right Skill uses one, spends the
items and money it needs, rolls once, and gets an item they name and
describe, which goes into their Belongings with their name on it as maker.

## Items first

Items were held back from the Economy step to come here (owner, 2026-10-17),
so this step builds them first:

- **Belongings tab on the character.** Everything the character owns, each
  with a name, a short description and an optional picture. Items can be
  single (a horse, a key to a flat) or stacked (12 arrows, 3 loaves).
  Everyone can see a character's Belongings (owner, 2026-10-17), so others
  can notice the sword on someone's hip.
- **Item catalogue (staff).** Items staff define once: name, description,
  picture, single or stacked, and a suggested price. Any catalogue item can
  be marked as a **material** that recipes use.
- **Shops in Places.** A Place can have a shop selling catalogue items. A Buy
  button takes the money and puts the item in Belongings. Each shop can also
  buy things back.
- **Give and Trade.** Items can be given like money. A Trade lets both
  characters put money and items into one offer, and it only goes through
  once both tick Agree. Changing the offer clears both ticks. In a Chapter,
  both show as a short Passage.
- **Inkling rewards** gain an "item" choice beside money and XP.

## Making things

- **Recipes (staff).** Each recipe has a name, what it makes (a kind of
  thing, such as "a dress" or "a healing draught"), what it uses (materials
  and money), which SOUL Skill it needs, a lowest rating, and a difficulty.
- **The Craft button.** On the character's Belongings tab, or in a Chapter.
  The player picks a recipe they can use, sees what it will use up, names
  and describes the result, and rolls the Skill, with their Boons and Banes
  ticked as for any roll.
- **The roll sets a quality word,** not stats:
  - exceptional success: *Masterwork*;
  - success: no word, just a well-made thing;
  - complicated success: *Flawed* (the player says how);
  - lucky failure or failure: nothing is made, and half the materials are
    used up (rounded down); the money is kept;
  - catastrophic failure: nothing is made and all the materials are used up.
- **The maker's mark.** Every made item shows who made it and when, and that
  stays with the item when it's given, traded or sold.
- **In a Chapter,** crafting shows as a Passage, like a roll: "Mara crafts a
  silk dress (Masterwork)".
- **With SOUL switched off,** there's no roll: making always succeeds, with
  no quality word.

## Switching it on and off

- **Admin → Features** gets "Use Crafting", off by default. It needs the
  Economy switched on, since recipes use money and items.
- Turning it off hides recipes and the Craft button. Items people already
  made stay in their Belongings.
- The code lives in its own part (`Crafting`, tables starting
  `crafting_`), like Grimoire.

## How it talks to SOUL and the Economy

- Rolls go through SOUL's public roll methods, the same way Grimoire casts a
  spell, so SOUL needs no changes.
- Money and items are spent through the Economy's ledger, so every craft
  shows as lines in the Purse and Belongings history.
- Crafting never makes money or XP by itself.

## What staff control (Admin → Crafting)

- The item catalogue and which items are materials.
- Recipes.
- Shops, under Admin → Economy.
- Give or take items from a character, always with a reason, logged like
  money.

## Left out on purpose (from Arx)

- Item stats (armour, damage, wear slots, containers).
- Refining and re-rolling for a better quality.
- Adornments, forgeries and translated text.
- Dozens of material types: a game makes only the materials it wants.
- Action points.

## Questions for the owner

1. **Items without Crafting:** items, Belongings, shops and Trade work
   whenever the Economy is on *(recommended, so a game can have shops
   without crafting)*, or only when Crafting is on.
2. **Who can use a recipe:** anyone with the Skill rating it asks for
   *(recommended, nothing extra to track)*, characters must learn each one
   with XP like Grimoire spells, or staff grant recipes to characters.
3. **Players propose recipes:** yes, staff approve them, like Grimoire spell
   proposals *(recommended)*, or only staff write recipes.
4. **What the player makes is described by:** the player, freely, and staff
   can edit it *(recommended)*, or staff approve each one first.
5. **A failed roll:** uses up half the materials *(recommended)*, uses up
   all of them, or uses up none.
6. **Getting materials:** buying, trading and rewards *(recommended to start)*,
   or also gathering once a day at Places staff mark (a forest gives herbs).
7. **Selling what you make:** by Give and Trade only *(recommended to
   start)*, or players can open their own shop in a Place.
