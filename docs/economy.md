# Economy (Version 2.0, Theme 9)

**Status: [Proposed]** by Claude on 2026-10-17, for the owner to answer the
questions at the bottom. Nothing here is built. Once the owner answers, the
settled parts move to `decisions.md` and this page is updated to match.

Economy comes first and Crafting after it (owner, 2026-10-17). Crafting will
be planned in its own page, but the economy is shaped so crafting can plug
into it later: crafted things become items in the same Belongings, and they
can be sold and traded the same way.

## What we learned from Arx

There is no economy plugin to rebuild, so this one starts from scratch
(owner, 2026-10-17). Arx (github.com/Arx-Game/arxcode) is the starting point,
but the owner found it clunky. Looking at its code, the clunkiness comes from
how much there is to track at once:

- **Too many kinds of money.** Silver on hand, silver in a bank vault, three
  separate "resources" (economic, military, social), dozens of crafting
  material types, prestige, fame and legend.
- **Action points.** Most things cost AP as well as money, and `work` spends
  AP to earn resources for an organisation.
- **Domains and armies.** Land, castles, armies and weekly upkeep turned the
  economy into a strategy game running beside the roleplay.
- **Weekly sums.** Incomes and debts were added up every week behind the
  scenes, which was hard for players to follow.
- **Everything by command.** Each step was a MUSH command with switches.

Worth keeping from Arx:

- **Give** money or an item to another character.
- **Trade** where both characters put things on the table and both must
  agree before anything changes hands, so nobody gets cheated or makes a
  mistake.
- **Group treasuries,** so a family or guild can hold money together. This
  fits the groups and factions in Theme 4.
- **Regular income** such as wages or an allowance, but shown openly on a
  ledger rather than worked out out of sight.

## The idea in one line

One kind of money, one list of things a character owns, and a few simple
ways to get, spend and swap them, all done from buttons on the page and all
written on a ledger anyone involved can read back.

## What players see

- **A Purse tab on the character.** The character's money and a ledger of
  every change: who, how much and why, newest first.
- **A Belongings tab on the character.** The things the character owns, each
  with a name, a short description and an optional picture. Items can be
  plain (a horse, a key to a flat) or stackable (12 arrows, 3 loaves).
- **Shops in Places.** A Place can have a shop with a list of items and
  prices. A Buy button takes the money and puts the item in Belongings.
  Selling back to a shop is optional, per shop.
- **Give.** From a Chapter, or from the other character's profile: give money
  or an item, with an optional note. In a Chapter it also appears as a short
  Passage ("Mara hands Tom 5 crowns"), so the story shows it.
- **Trade.** Both characters add money and items to one offer, each ticks
  Agree, and it only goes through when both have agreed. Changing the offer
  clears both ticks.
- **Income.** A starting amount when the character is approved, and
  optionally a weekly allowance paid on the same Sunday run as weekly XP.

## What staff control (Admin → Economy)

- **The money's name** for this game, singular and plural (crown/crowns,
  Galleon/Galleons), and an optional symbol. Whole numbers only.
- **Starting amount** and **weekly allowance** (either can be 0).
- **The item catalogue:** items staff define once, with name, description,
  picture, stackable or not, and a suggested price. Shops and rewards use the
  catalogue. Players can't invent catalogue items (crafting may change this
  later).
- **Shops:** which Place, which items, at what price, and whether the shop
  buys things back.
- **Give or take** money or items from a character, always with a reason.
  These go on the character's ledger and the staff log, like XP changes.
- **Inkling rewards** gain two new choices beside XP: money and an item.
- **A Transactions page** listing recent gives, trades and purchases, so staff
  can spot problems such as one player feeding money to a friend's character.

## Switching it on and off

- **Admin → Features** gets a "Use Economy" switch beside SOUL, Inklings and
  Grimoire. It's off by default, so a new game has no money until staff
  choose it.
- Turning it off hides the Purse and Belongings tabs, shops, Give and Trade,
  and stops the allowance. Nothing is deleted, so turning it back on brings
  everything back as it was.
- It lives in its own part of the code (`Economy`, with tables starting
  `economy_`), the same way Grimoire does, so another game could swap it for
  a different economy later.

## How it talks to SOUL

SOUL and the economy stay separate, following the SOUL plugin's own rule that
other systems use SOUL's published hooks and never reach into its data.

- Money and XP never turn into each other. XP can't be bought.
- The economy only *asks* SOUL questions through the character's public
  methods (for example `rating_for` or which Boons a character has). SOUL
  never needs to know the economy exists.
- The one proposed link is optional (question 5): a Boon or Bane can be
  marked by staff as changing the weekly allowance, such as "Wealthy" adding
  10 or "Penniless" taking 5. Staff set this in Admin → Economy, not in SOUL.

## Other rules

- **Roster:** the Purse and Belongings go with the character, like Inklings.
- **Retired and Deceased characters** keep their Purse and Belongings, but
  get no allowance and can't trade. Staff can move things out if needed.
- **World packs** carry the money's name, the item catalogue and the shops,
  so a new Well can start with a ready-made economy. Character purses don't
  travel.
- **Every change is a ledger line** and never just a number being edited, so
  a mistake can always be traced and corrected with a reversing line.

## Left for later

- Group treasuries (with Theme 4's group pages and factions).
- Player-run shops and businesses.
- Wages tied to a job or group rank.
- Crafting: turning items into other items, possibly with a SOUL roll.

## Questions for the owner

1. **Belongings in the first step:** money and belongings with shops
   *(recommended)*, or money only to start.
2. **Who can see a character's Purse:** the player and staff only
   *(recommended)*, or everyone.
3. **Who can see Belongings:** everyone *(recommended, so others can notice
   the sword on someone's hip)*, or the player and staff only.
4. **Income:** a starting amount plus a weekly allowance *(recommended)*, or
   staff and Inkling rewards only.
5. **Wealth Boons and Banes:** yes, staff can mark some to change the
   allowance *(recommended)*, or no link to SOUL at all.
6. **Kinds of money:** one *(recommended)*, or several coins with exchange
   rates (gold, silver, copper).
7. **Does it need SOUL switched on:** no, it works on its own
   *(recommended)*, or yes, like Grimoire.
