# Economy (Version 2.0, Theme 9)

**Status: Agreed** with the owner on 2026-10-17 (answers at the end and in
`decisions.md`). Nothing here is built. It waits for factions (Theme 4) and
the owner's go.

Economy comes first and Crafting after it (owner, 2026-10-17). Crafting gets
its own page later.

## The owner's brief (2026-10-17)

- Characters need money, and ways to move that money around.
- That includes automatic payments that go through at set intervals, such
  as a salary or an allowance.
- An optional taxes system, which also gives a faction a "bank". Taxes go
  into the bank and payments come out of it.
- A faction's bank is run by the players of characters marked with
  permission to manage it.
- There's no economy plugin to rebuild, so this is built from scratch. Arx is
  the starting point, but it was very clunky.

## What we learned from Arx

Arx's code (github.com/Arx-Game/arxcode) has most of these pieces, but there
is too much to track at once:

- **Too many kinds of money.** Silver on hand, silver in a bank vault, three
  "resources" (economic, military, social), dozens of crafting materials,
  prestige, fame and legend.
- **Action points.** Most things cost AP as well as money.
- **Domains and armies.** Land, castles and armies turned the economy into a
  strategy game beside the roleplay.
- **Hidden weekly sums.** Incomes and debts were totted up out of sight each
  week, so players couldn't easily see why their money changed.
- **Everything by command,** with switches to remember.

Kept from Arx: giving money, an organisation's own treasury, and regular
incomes. Arx's trade, where both sides must agree, comes back with items in
Crafting. Here they're all buttons on
the page, and every change is a line on a ledger people can read.

## The idea in one line

One kind of money. Every character has a Purse and every faction can have a
Bank. Money moves between them by one-off payments or scheduled payments,
taxes can skim a share into a faction's Bank, and every movement is a line on
a ledger. Items and shops come with Crafting.

## What players see

- **A Purse tab on the character.** The balance and a ledger of every change
  (who, how much, why), newest first. Below it, the character's scheduled
  payments, in and out.
- **Pay.** From a Chapter or from another character's profile: send money
  with an optional note. In a Chapter it also shows as a short Passage
  ("Mara hands Tom 5 crowns"), so the story records it.
- **Scheduled payments.** A character can set one up from their own Purse,
  for example a parent's allowance to a child: who to pay, how much, how
  often (every week, two weeks or month), and an optional end date. Either
  side can see it, the payer can stop it, and the payee can turn it down.
- **Faction Banks.** A faction's page gets a Bank tab: its balance, its
  ledger, its scheduled payments and its taxes. Members can read it, so
  nobody wonders where the money went. Outsiders can't, and a secret
  faction's Bank stays as secret as the faction.
- **Paying into a Bank.** Any member can pay into their faction's Bank, like
  paying a character.

## Running a faction's Bank (players)

Staff tick **Bank manager** on a character's membership of a faction. The
player of that character can then, from the Bank tab:

- pay any character or another faction's Bank, once, with a reason;
- set up, change and stop the Bank's scheduled payments to any character or
  faction, such as a salary for each guard or a monthly gift to an ally
  (owner, 2026-10-17);
- set the faction's taxes, if the game has taxes switched on;
- see who paid tax and who couldn't.

Every Bank action is signed with the manager's character name, so members
can see who did what. Staff can reverse any of it.

## Taxes (optional)

Taxes are a separate switch inside the economy, so a game can have money
without taxes. When it's on, each faction's managers can set:

- **Income tax:** a percentage of the scheduled payments a member receives,
  such as salaries and allowances. It's taken as the payment arrives and goes
  straight into the Bank, and the ledger shows both lines.
- **Dues:** a fixed amount each member pays on a schedule (every week, two
  weeks or month).

Staff can set the highest rate a faction may charge. A member who can't pay
their dues isn't pushed into debt. The payment is skipped, the managers see
it on the Bank's list, and what happens next is up to the story.

## Domains (land and the people on it)

**Why a separate system.** The owner's Draganic game is very stratified:
Realms hold Duchies, Duchies hold Counties, Counties hold Baronies, and each
level owes taxes to the level above. Most of the people paying at the bottom
are serfs who are NPCs, or really just numbers on a sheet (owner,
2026-10-17). Factions are guilds, families and social groups, and a
character can belong to many (owner, 2026-10-17), so they're the wrong
shape for a chain of land where each piece has exactly one liege. Domains
are a small system of their own inside the Economy, with their own switch,
and factions keep their member taxes and dues.

**What a Domain is.** A named piece of land, made by staff:

- **Name and rank:** the Duchy of Niwen; ranks are words staff set per game
  (Realm, Duchy, County, Barony).
- **Liege:** the one Domain it sits under, so the County of Aqagia sits under
  the Duchy of Niwen. Chains can be as deep as the game likes, but can't
  loop.
- **Holder:** usually the character who holds it (Baron Odde holds
  Everean). Staff can also let a faction hold it, such as a clan, in which
  case the money goes to that faction's Bank.
- **People:** a number, such as 1,200 serfs. They're not characters. Staff
  change the number as the story goes (a plague, a good harvest, new
  settlers).
- **Yield:** how much each head brings in per month, set by staff.
- **Tax to its liege:** a percentage, set by the liege Domain's holder within
  the staff limit.
- **Area (optional):** the Area on the grid it matches, so walking into the
  Duchy of Niwen's Area shows whose land it is.

**How the money flows, once a month:**

1. Each Domain earns people × yield.
2. Its tax to its liege is paid out of that, upwards, a level at a time, so a
   Barony pays its County, which pays its Duchy, which pays its Realm, which
   pays the Crown.
3. What's left goes to the holder's Purse (or the holding faction's Bank).

Each step is a line on the ledgers, so a holder can see what their land
earned, what they owed and what they kept. Domains never go into debt: a
Domain only pays tax on what it earned.

**What players see.** A Domains page shows the tree of land (Realm down to
Barony) with each holder, much like Draganic's "Lands & Fiefdoms" wiki page
but kept up to date by the game. A holder sees their Domain's people, yield
and earnings; the size of other people's earnings stays private, like
Purses.

**What holders control.** The tax rate their own vassal Domains pay them,
within the staff limit. Everything else (people, yield, who holds what) is
staff's, because it's the story.

**Left out on purpose (from Arx's domains):** armies, castles, buildings,
harvest rolls, and action points.

## Scheduled payments, in detail

- Payments run once a day on a schedule in real time, like weekly XP. Due
  payments go through in the order they were set up.
- If the payer can't cover a payment, it's skipped, not part-paid, and both
  sides get a notice. It tries again on its next date.
- A retired character's scheduled payments, in and out, stop. Roster
  characters keep theirs, since the next player inherits the character.
- Every payment that goes through, or is skipped, leaves a ledger line.

## Where money comes from and goes

Money only appears from **staff**, so the amount in the game stays under
their control:

- a **starting amount** when a character is approved (can be 0);
- **game payments:** scheduled payments from "the game" that staff set up,
  such as a weekly allowance for everyone, or a stipend for one faction's
  Bank;
- **staff awards** with a reason, and **Inkling rewards** (a new "money"
  choice beside XP).

The usual weekly allowance is simply a game payment to every approved
character. **Wealth Boons and Banes** can change it: staff mark a Boon or
Bane in Admin → Economy as adding to or taking from the allowance, such as
"Wealthy" adding 10 or "Penniless" taking 5.

Money leaves when staff take it with a reason. Shops, the main way money will
leave, come with Crafting.

## What staff control (Admin → Economy)

- **The money's name**, singular and plural (crown/crowns, Galleon/Galleons),
  and an optional symbol. Whole numbers only.
- **Starting amount** and the **game payments**, including the weekly
  allowance and which Boons and Banes change it.
- **Taxes:** on or off, and the highest rate.
- **Give or take** money from any Purse or Bank, always with a reason. These
  go on the ledger and the staff log, like XP changes.
- **Bank managers:** who manages each faction's Bank.
- **A Transactions page** of recent payments, so staff can spot problems,
  such as one player feeding money to a friend's character.

## Switching it on and off

- **Admin → Features** gets a "Use Economy" switch beside SOUL, Inklings and
  Grimoire, off by default.
- Turning it off hides Purses, Banks, Pay and taxes, and pauses scheduled
  payments. Nothing is deleted, and turning it back on picks up where it
  left off. Payments missed while it was off are not back-paid.
- The code lives in its own part (`Economy`, with tables starting
  `economy_`), the same way Grimoire does, so a game could swap in another
  economy later.

## How it talks to SOUL

- SOUL and the economy stay separate, following the SOUL plugin's rule that
  other systems use SOUL's published hooks and never reach into its data.
- Money and XP never turn into each other. XP can't be bought.
- The economy doesn't need SOUL to be switched on (owner, 2026-10-17).
- The one link is Wealth Boons and Banes changing the allowance. The economy
  asks SOUL which Boons and Banes a character has, through the character's
  public methods, and SOUL never needs to know the economy exists. With SOUL
  off, the allowance is just the plain amount.

## How it fits with factions

Faction Banks hang off the factions planned in Theme 4, which come before
this theme. A character can be in several factions, each with its own Bank,
taxes and managers. Until factions exist, nothing here is built.

## Left for later

- **With Crafting:** items, a Belongings tab (which everyone can see, so
  others can notice the sword on someone's hip), shops in Places, giving
  items, a Trade both sides must agree to, and items as Inkling rewards.
- Loans and debts.
- Player-run businesses.
- Banks for things other than factions.

## The owner's answers (2026-10-17)

- **One kind of money.**
- **Items and shops** come with Crafting, so the Economy step is money only.
  (The owner first said they belonged here, then changed their mind.)
- **A character's Purse** is seen by the player and staff only.
- **Belongings,** when they arrive with Crafting, can be seen by everyone.
- **Income** is a starting amount plus a weekly allowance.
- **Wealth Boons and Banes** can change the allowance.
- **It doesn't need SOUL** switched on.
- **Scheduled payments** run on real-world days: every week, two weeks or
  month.
- **Taxes** come in both kinds: income tax and dues.
- **A faction's taxes** are set by its Bank managers, within the staff limit.
- **A character in several factions** is taxed by each faction separately.
- **Characters can set up their own scheduled payments** from their own
  Purse.
- **Domains** carry the land-based tax chain (Realm, Duchy, County,
  Barony), as their own system with their own switch inside the Economy.
  Factions are guilds, families and social groups that characters can
  belong to many of, so factions don't tax each other; they keep their
  member taxes and dues.
- **A Domain is usually held by a character,** with the option of a faction
  such as a clan holding it.
- **A Domain can be linked to an Area** on the grid, optionally.
- **Faction Banks can pay** any character or another faction's Bank, once
  or on a schedule.
