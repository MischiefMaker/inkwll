# 0024: Review the starter world's Paths

- **Status:** Open
- **Hand off?:** No
- **Roadmap step:** 11. Going live
- **Created:** 2026-10-15

## Goal

The starter world's Paths (made by `db/seeds.rb`) make sense to a new player: each Path is named after the Setting it leads to, and Path types (Street, Building, Unit) are used where they fit.

## Background

Owner, 2026-10-15, after testing the live game: "I think the Paths should be named after the Setting you end up in instead of the Area (it's confusing to click Midtown and end up in Central Square instead of a Setting named Midtown). Granted, games can set up how they like, but for defaults, let's make a note to take a look at our paths."

Right now `seed_paths` names Paths between Areas after the Area (for example "Midtown"), but they lead to the Area's first Setting (for example "Central Square"). Every starter Path is also a Street, so nothing shows under "Go in" or as numbered doors.

The owner also noticed that Enter on an Area drops you into its default Setting without showing the Area's own text. They're not sure that's a problem ("maybe that's okay"). Leave it unless they decide otherwise.

## What to do

1. List every starter Path with its current name and where it leads, and propose new names and types.
2. Check the list with the owner before changing anything.
3. Update `db/seeds.rb`. Decide with the owner whether to also rename the Paths on the live game, since seeds only add what's missing.

## Done when

- [ ] Every starter Path's name matches the Setting it leads to, or the owner has OK'd an exception.
- [ ] The owner has agreed the list.
