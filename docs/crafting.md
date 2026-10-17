# Crafting (Version 2.0, Theme 9)

**Status: Agreed** with the owner on 2026-10-17 (answers at the end and in
`decisions.md`). Nothing here is built. It comes after the Economy, and
waits for the owner's go.

Crafting comes after the Economy (`economy.md`) and builds on it. It's an
optional system a game switches on, like Grimoire.

## The owner's brief (2026-10-17)

- Start from Arx's crafting, but simplify it.
- Characters craft items for a starting cost.
- They add a description, pictures, and features that can affect rolls.
- Then they sell them for a profit.
- Items, Belongings, shops and Trade were held back from the Economy step to
  come here, and everyone can see a character's Belongings.

## What we learned from Arx

Arx's crafting (github.com/Arx-Game/arxcode, `world/crafting`) has recipes
tied to an ability and a skill, dozens of material types, a silver cost, a
roll that sets a quality number from 0 to 11 which changes the item's combat
stats, paying again to re-roll for better quality, adornments, forgeries,
translated text, breaking items down for materials, and a `craft` command
with a dozen switches.

Kept: paying to make something, a Skill roll, a named and described item
with the maker's name on it, and selling what you make. Dropped: materials,
quality numbers, combat stats, re-rolling, adornments and forgeries. Arx's
"quality changes stats" becomes **features**, which use SOUL's own Boons
and Banes instead of new numbers.

## The idea in one line

A character pays a starting cost, writes up the item with pictures, adds
features that help rolls (each adds to the cost), rolls their Skill once,
and gets an item with their name on it as maker, which they can keep, give,
trade or sell for whatever price they like.

## Items

- **Belongings tab on the character.** Everything the character owns: name,
  description, pictures, its features, and who made it. Items can be single
  (a sword) or stacked (12 arrows). Everyone can see a character's
  Belongings (owner, 2026-10-17), so others can notice the sword on
  someone's hip.
- **Item catalogue (staff).** Ready-made items staff define for shops and
  rewards, with a name, description, picture and price.
- **Shops in Places (staff).** A Place can have a shop selling catalogue
  items. A Buy button takes the money and puts the item in Belongings.
- **Give and Trade.** Items can be given like money. A Trade lets both
  characters put money and items into one offer, and it only goes through
  once both tick Agree. Changing the offer clears both ticks. In a Chapter,
  both show as a short Passage.
- **Inkling rewards** gain an "item" choice beside money and XP.

## Making things

**No materials** for now, unlike Arx. The cost is a straight price based on
what the finished item is worth, so anything that affects the game costs far
more than something only ornamental (owner, 2026-10-17).

- **Item types (staff).** What can be made, each with a starting cost and
  the SOUL Skill used to make it: a sword (40 crowns, Smithing), a dress
  (25 crowns, Tailoring), a healing draught (10 crowns, Herbalism).
- **Features (staff).** What an item can do for rolls. Each feature works
  like a SOUL Boon tied to one or more Skills, at a level (Minor or Major,
  and Legendary if staff allow). Its cost comes from its level and is set
  by staff, and it's meant to dwarf the starting cost: with a 40-crown
  sword, Minor might add 200, Major 600 and Legendary 2,000. For example,
  "Well-balanced" (Minor Boon to Swordplay) or "Concealed pocket" (Minor
  Boon to Sleight of hand). Staff say which item types
  each feature fits.
- **The Craft button,** on the Belongings tab or in a Chapter. The player
  picks an item type, writes the name and description, adds pictures, picks
  features, and sees the total cost. They then roll the Skill, with their
  own Boons and Banes ticked as for any roll. Each feature makes the roll a
  step harder.
- **What the roll does:**
  - exceptional success: a *Masterwork*, and the player gets back half the
    cost of the features;
  - success: the item as planned;
  - complicated success: the item is made, but with a Minor flaw, which
    works like a Bane on one of its Skills. The player says what the flaw
    is;
  - lucky failure or failure: nothing is made, and half the cost is lost;
  - catastrophic failure: nothing is made, and the whole cost is lost.
- **The maker's mark.** Every made item shows who made it and when, and that
  stays with it when it's given, traded or sold.
- **In a Chapter,** crafting shows as a Passage, like a roll: "Mara crafts a
  silk dress (Masterwork)".

## Items in rolls

Some items are only ornamental, and some work in the game world, such as a
weapon that should count in a roll (owner, 2026-10-17). An item with no
features is ornamental: it has a name, description and pictures, and does
nothing in rolls. An item with features counts in rolls:

- When a character rolls a Skill, the features of items in their
  Belongings that are tied to that Skill show as tick boxes in the roll box,
  beside their Boons and Banes, and work the same way (the 2026-10-17 roll
  decision). Flaws show as Banes and are ticked automatically.
- Storyteller-judged rolls treat item features like Boons: the Storyteller
  marks each one as must count, the player's choice, or doesn't count.
- An item that's given, traded or sold takes its features with it.

## Selling for a profit

- **Set a price.** Any item a character owns can be put up for sale at a
  price the player chooses, and taken down again.
- **The Market.** Items for sale are listed on one Market page for the
  whole game, with the seller, price, pictures and features, so it's easy to
  browse.
- **Buying** takes the money from the buyer's Purse, pays the seller, and
  moves the item. Both see it on their ledgers.
- **Taxes:** if the seller's faction has income tax, a sale counts as
  income.

## Switching it on and off

- **Admin → Features** gets "Use Crafting", off by default. It needs the
  Economy switched on, since everything costs money.
- Items, Belongings, staff shops, Give and Trade work whenever the Economy
  is on, even with Crafting off, so a game can have shops without crafting.
  They're built in this step, but live under the Economy switch.
- Turning it off hides the Craft button, the Market and item features in
  rolls. Items
  people already own stay in their Belongings.
- The code lives in its own part (`Crafting`, tables starting
  `crafting_`), like Grimoire.

## How it talks to SOUL and the Economy

- **Crafting rolls** go through SOUL's public roll methods, the same way
  Grimoire casts a spell.
- **Item features in rolls** need one small, general addition to SOUL: a
  published hook where other systems can offer extra Boons and Banes for a
  character's roll on a Skill. Crafting offers its item features through
  it, and SOUL never needs to know what an item is. Other systems could use
  the same hook later.
- **With SOUL off,** there's no roll (making always succeeds, with no
  Masterwork or flaw), and features are just descriptions.
- **Money and items** move through the Economy's ledger, so every craft and
  sale shows in the Purse history.

## What staff control (Admin → Crafting)

- Item types, their starting costs and Skills.
- Features: their Skills, levels, extra costs and which item types they fit.
- The highest feature level players can choose, and how many features one
  item can have (3 to start, and staff can raise it as far as unlimited).
- New features players propose, which staff approve or turn down with a
  reason, like Grimoire spell proposals.
- The item catalogue and shops (under Admin → Economy).
- Give, take or edit items, always with a reason, logged like money.

## Next version

- **Applying for an item to add a Boon or Bane:** a player applies for an
  item to give a real Boon or Bane on the character's SOUL sheet, for staff
  to approve (owner, 2026-10-17). Left for the version after this one.

## Left out on purpose (from Arx)

- Materials, recipes, quality numbers and combat stats.
- Refining and re-rolling.
- Adornments, forgeries and translated text.
- Action points.

## The owner's answers (2026-10-17)

1. **Items, Belongings, shops and Trade** work whenever the Economy is on.
2. **Players write up their items freely,** and staff can edit them later.
3. **Crafted items are sold on one Market page** for the whole game.
4. **Sales count as income** for faction income tax.
5. **Features per item:** staff set a limit, starting at 3, which they can
   raise as far as unlimited.
6. **Players can propose new features,** which staff approve.
7. **Features count in a roll whenever the item is owned.**
8. **Features reach rolls as tick boxes** that go with the item. SOUL's
   Boons and Banes list is untouched.
