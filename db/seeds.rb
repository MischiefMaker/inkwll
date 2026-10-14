# Creates a starting map so a fresh game has somewhere to walk around: three
# top-level Areas (City, Country, Forest), three smaller Areas inside each, and
# two Settings in every small Area, all linked by Paths. Safe to run more than
# once. Rename, rewrite or replace any of it from the admin panel's Building
# section.

# Makes (or finds) an Area. Pass parent: for an Area inside another one.
def seed_area(name, description, position:, parent: nil)
  Area.find_or_create_by!(name: name) do |area|
    area.parent = parent
    area.position = position
    area.description = description
  end
end

# Makes (or finds) a Setting inside an Area.
def seed_room(area, name, description, starting: false)
  Room.find_or_create_by!(name: name) do |room|
    room.area = area
    room.description = description
    room.starting = starting
  end
end

# Links two Settings both ways: "there" is the Path name shown in the first
# Setting, "back" is the one shown in the second.
def seed_paths(here, there_name, there, back_name)
  Exit.find_or_create_by!(source_room: here, name: there_name) { |e| e.destination_room = there }
  Exit.find_or_create_by!(source_room: there, name: back_name) { |e| e.destination_room = here }
end

# ---------------------------------------------------------------------------
# The City
# ---------------------------------------------------------------------------

city = seed_area("City", <<~TEXT.squish, position: 0)
  Streetlamps, crowded pavements and more windows than anyone could count. The
  city never quite sleeps, and every neighbourhood has its own idea of what
  that means.
TEXT

uptown = seed_area("Uptown", <<~TEXT.squish, parent: city, position: 0)
  Wide avenues, polished brass and doormen who notice your shoes. Uptown is
  where the money lives, or at least where it likes to be seen.
TEXT

midtown = seed_area("Midtown", <<~TEXT.squish, parent: city, position: 1)
  The busy heart of the city, where everyone passes through on their way to
  somewhere else and half of them stop for coffee.
TEXT

downtown = seed_area("Downtown", <<~TEXT.squish, parent: city, position: 2)
  Older, louder and a good deal grimier. Downtown has the station, the market
  and the kind of alleys that people tell you not to walk down after dark.
TEXT

grand_avenue = seed_room(uptown, "Grand Avenue", <<~TEXT)
  Lined on both sides with tall, stately buildings of pale stone, Grand Avenue has the air of a street that knows exactly how much it is worth. Shop windows glitter with things nobody strictly needs, each display arranged just so, and the pavements are swept so often it seems a crime to walk on them at all. Plane trees stand in neat iron cages at regular intervals, offering a little shade to those who stop long enough to want it.

  The avenue runs straight and broad toward the busier streets of Midtown, the traffic thickening the further one goes, while at its quieter top end an old road slips out past the last grand houses toward the distant forest. Halfway along, a striped awning and a pair of revolving doors mark the entrance to the Ashcombe Hotel, a uniformed doorman standing ready to decide whether or not to open them for you.
TEXT

ashcombe = seed_room(uptown, "The Ashcombe Hotel", <<~TEXT)
  The lobby of the Ashcombe is all marble and gilt, a cavernous room designed to make guests feel important and everyone else feel slightly out of place. A chandelier the size of a small carriage hangs from the painted ceiling, throwing scattered light across the chequered floor, while deep velvet armchairs gather in quiet clusters around low tables, the perfect spot for being seen without appearing to want it.

  A long mahogany front desk stretches across the far wall, a bell and a ledger waiting at one end and a clerk with a practised smile at the other. Off to one side, a pair of glass doors opens onto a hushed little bar, and the revolving doors at the front lead back out onto Grand Avenue.
TEXT

central_square = seed_room(midtown, "Central Square", <<~TEXT, starting: true)
  Everything in the city seems to pass through Central Square sooner or later. A great stone fountain sits at its centre, its basin glinting with coins tossed in by the hopeful and the bored, and benches circle it for those with time to spare. Pigeons hold court on the steps of the old clock tower, entirely unbothered by the crowds hurrying around them, and a newspaper stand on the corner shouts the day's headlines to anyone who will listen.

  Streets branch off in every direction: uphill toward the quieter, richer avenues of Uptown, and down toward the noise and bustle of Downtown. On the eastern side of the square, a warm glow spills from the windows of the Lamplight Café.
TEXT

lamplight = seed_room(midtown, "The Lamplight Café", <<~TEXT)
  Small, cramped and always a little too warm, the Lamplight is the sort of café that regulars refuse to tell anyone about and somehow everyone knows anyway. Mismatched tables crowd the narrow room, each with its own little lamp, and the walls are papered with old posters, postcards and notes pinned up by customers who never came back for them. The smell of coffee and something sweet from the oven hangs over everything.

  A scuffed counter runs along one wall, crowded with cake stands and a hissing coffee machine that seems to have a personality of its own. A battered piano sits in the back corner, rarely tuned but often played, and the door beside the window leads back out onto Central Square.
TEXT

union_station = seed_room(downtown, "Union Station", <<~TEXT)
  Built in a grander age and not much cared for since, Union Station is a vast hall of iron and soot-streaked glass. Pigeons roost in the girders high overhead, and the great arched roof catches every echo, so that announcements, footsteps and the shriek of brakes all blur together into one endless roar. Travellers hurry in every direction, dragging cases and children, while porters weave between them with practised indifference.

  A departures board clacks and rattles above the ticket windows, listing trains out to the country towns and back again. Wide steps lead up to the street and on toward Midtown, while a side door by the left-luggage office opens onto the clamour of the Harbour Market.
TEXT

harbour_market = seed_room(downtown, "Harbour Market", <<~TEXT)
  Stalls crowd every inch of this long, cobbled street, so close together that their canvas awnings overlap and turn the whole market into a kind of patchwork tunnel. Fishmongers shout over greengrocers, who shout over the man selling knives, who shouts over everyone. The ground is slick with things best not looked at too closely, and the air carries the mingled scents of salt, smoke and frying onions.

  At the far end, the street gives way to the grey water of the harbour, where gulls wheel above the moored boats and wait for someone to drop something. Narrow alleys slip away between the warehouses on either side, and the market's near end comes out by the side door of Union Station.
TEXT

seed_paths(grand_avenue, "Ashcombe Hotel", ashcombe, "Out")
seed_paths(central_square, "Lamplight Café", lamplight, "Out")
seed_paths(union_station, "Harbour Market", harbour_market, "Station")
seed_paths(grand_avenue, "Midtown", central_square, "Uptown")
seed_paths(central_square, "Downtown", union_station, "Midtown")

# ---------------------------------------------------------------------------
# The Country
# ---------------------------------------------------------------------------

country = seed_area("Country", <<~TEXT.squish, position: 1)
  Rolling fields, hedgerows and lanes too narrow for two carts to pass. Out
  here the days are slower, the nights are darker and everybody knows
  everybody's business.
TEXT

village = seed_area("The Village", <<~TEXT.squish, parent: country, position: 0)
  A cluster of stone cottages, a church, a pub and a green. Nothing much ever
  happens in the village, which is exactly why everyone notices when it does.
TEXT

farmland = seed_area("Farmland", <<~TEXT.squish, parent: country, position: 1)
  Patchwork fields stitched together with hedges and gates, where the work
  starts before dawn and the weather is always the main topic of conversation.
TEXT

riverside = seed_area("Riverside", <<~TEXT.squish, parent: country, position: 2)
  A slow, wide river winds its way through the valley, with willows trailing
  in the water and paths worn smooth along its banks.
TEXT

village_green = seed_room(village, "Village Green", <<~TEXT)
  A wide stretch of grass sits at the heart of the village, kept short by a pair of grumpy goats who belong to no one in particular. An ancient oak stands at one end, its lowest branch worn smooth by generations of children climbing it, and a weathered stone cross marks the other. Cottages of honey-coloured stone line the edges, their gardens overflowing with roses and runner beans, each one quietly competing with its neighbour.

  A little whitewashed halt stands at the bottom of the green, where the train from the city stops twice a day if it remembers to. The lane out of the village winds off toward the farms, and across the way, the crooked sign of the village pub creaks in the breeze.
TEXT

kettle = seed_room(village, "The Crooked Kettle", <<~TEXT)
  The Crooked Kettle has stood on the edge of the green for longer than anyone can say, and it has the sagging beams to prove it. The ceiling is low enough that taller visitors learn to duck the hard way, and the stone floor dips and rises like the countryside outside. A huge inglenook fireplace takes up most of one wall, a fire crackling in it whatever the season, with a sleepy dog sprawled in front of it.

  Worn wooden settles and stools are crowded around scarred tables, most of which have a regular who would very much like you to know it is theirs. Behind the bar, a row of dented copper kettles hangs from the beams, and the low front door leads back out onto the Village Green.
TEXT

farm_lane = seed_room(farmland, "Farm Lane", <<~TEXT)
  This rutted dirt lane winds between high hedgerows thick with brambles, hawthorn and the occasional nest. In summer the air hums with bees and smells of cut hay; in winter the ruts fill with water and the mud tries its best to keep your boots. Gates open here and there onto the fields beyond, where sheep regard passers-by with deep suspicion and the occasional cow leans over to see what's going on.

  One way, the lane wanders back toward the village; the other, it slopes down toward the river, the sound of water growing louder as it goes. Partway along, a five-bar gate leans open into a yard where a great old barn sits slumped against the sky.
TEXT

hay_barn = seed_room(farmland, "The Hay Barn", <<~TEXT)
  Built of dark timber gone silver with age, the old barn is far bigger inside than it looks from the lane. Hay is stacked in great golden bales almost to the rafters, leaving narrow passages between them that seem made for hiding in, and dust hangs glittering in the bars of light that slip through the gaps in the boards. Swallows dart in and out through the open loft door high above.

  Rusting tools and bits of harness hang from nails along the walls, and a wooden ladder, missing at least one rung, climbs up into the hayloft. The wide double doors stand propped open onto the lane, letting in the smell of the fields and the occasional curious hen.
TEXT

stone_bridge = seed_room(riverside, "The Stone Bridge", <<~TEXT)
  A humped old bridge of mossy grey stone arches over the river here, just wide enough for a cart and not much else. Its parapets are low enough to sit on, and many have, judging by the initials carved into the stone. Below, the water runs clear and slow over smooth pebbles, and the odd trout can be seen holding steady against the current in the shadow of the arches.

  The lane climbs up from the farms to cross the bridge, and on the far side the land rises gently toward the dark line of the forest. A narrow path leads down from the end of the bridge to the riverbank itself.
TEXT

riverbank = seed_room(riverside, "The Riverbank", <<~TEXT)
  Willows lean out over the water here, their long branches trailing in the current and turning the bank into a series of green, rustling hideaways. The grass is soft and the ground gently sloping, perfect for picnics, fishing, or simply lying about and doing nothing at all. Dragonflies skim the surface, and somewhere upstream a moorhen complains about something.

  A little wooden jetty, more than a little rickety, juts out into the river, a battered rowing boat tied to its end. The path follows the water downstream into the reeds and back up the slope toward the Stone Bridge.
TEXT

seed_paths(village_green, "Crooked Kettle", kettle, "Out")
seed_paths(farm_lane, "Hay Barn", hay_barn, "Out")
seed_paths(stone_bridge, "Riverbank", riverbank, "Bridge")
seed_paths(village_green, "Farm Lane", farm_lane, "Village")
seed_paths(farm_lane, "River", stone_bridge, "Farms")

# ---------------------------------------------------------------------------
# The Forest
# ---------------------------------------------------------------------------

forest = seed_area("Forest", <<~TEXT.squish, position: 2)
  Mile upon mile of old trees, deep shadow and paths that don't always go where
  they used to. Locals keep to the trails, and those who don't tend to come
  back with stories.
TEXT

forest_edge = seed_area("Forest's Edge", <<~TEXT.squish, parent: forest, position: 0)
  Where the fields give up and the trees take over. Sunlight still reaches the
  ground here, and the trails are well marked, for now.
TEXT

deep_woods = seed_area("Deep Woods", <<~TEXT.squish, parent: forest, position: 1)
  The heart of the forest, where the canopy closes overhead and the quiet
  becomes the kind you start to listen to.
TEXT

lakeshore = seed_area("Lakeshore", <<~TEXT.squish, parent: forest, position: 2)
  A wide, dark lake cradled by the trees, still as glass on calm days and
  restless when the wind comes down off the hills.
TEXT

trailhead = seed_room(forest_edge, "The Trailhead", <<~TEXT)
  The open fields end abruptly here at a ragged wall of trees, as though someone drew a line and told the forest not to cross it. A weathered signpost stands at the start of the trail, its arms pointing in several directions at once and its lettering long since worn to guesses. A wooden stile crosses the old fence, and a noticeboard nailed to a post is layered with faded warnings, lost-dog notices and one or two things that make less sense.

  Behind, the land rolls back down toward the river and its bridge. Ahead, the trail plunges into the green gloom of the woods, and just off to the side, a thin curl of smoke rises from the chimney of a small cabin.
TEXT

cabin = seed_room(forest_edge, "The Ranger's Cabin", <<~TEXT)
  Built of rough logs and stubbornness, this one-room cabin has clearly weathered more than its share of storms. A pot-bellied stove sits in one corner, almost always lit and almost always with a kettle on, and the walls are crowded with maps, snowshoes, coils of rope and a stuffed owl with an expression of deep disapproval. A narrow cot is pushed beneath the single window.

  A big table takes up the middle of the room, strewn with logbooks, lanterns and half-mended gear, with a couple of chairs pulled up to it for visitors. The door, which sticks in wet weather, leads back out to the Trailhead.
TEXT

clearing = seed_room(deep_woods, "Old Oak Clearing", <<~TEXT)
  Deep in the forest, the trees draw back to leave a rough circle of open ground, and in the middle of it stands an oak so vast and so old it seems less a tree than a landmark. Its roots break the earth in great twisted knots, and its lowest branches sprawl out far enough to shade the whole clearing. Moss carpets everything, and the light that filters through the leaves is green and gold and never quite still.

  Paths lead off between the trees in several directions, though not all of them seem to be the same from one day to the next. The widest winds back toward the edge of the forest, while a narrower, damper trail drops down into a hollow choked with ferns.
TEXT

fern_hollow = seed_room(deep_woods, "Fern Hollow", <<~TEXT)
  The ground falls away here into a deep, damp hollow, so thick with ferns that they brush at the waist and swallow the path completely in places. A tiny stream trickles somewhere beneath them, more often heard than seen, and the banks are crowded with toadstools in colours that don't look entirely safe. Everything is very quiet, the kind of quiet that makes a person want to whisper.

  A fallen tree, long since hollowed out by rot and beetles, lies across the bottom of the dip, large enough to crawl inside. The slope climbs back up to the Old Oak Clearing, and through a gap in the trees, the silver gleam of water hints at the lake beyond.
TEXT

beach = seed_room(lakeshore, "Shingle Beach", <<~TEXT)
  The trees part to reveal a narrow beach of grey stones, worn smooth and round by the endless lapping of the lake. The water is clear in the shallows and darkens quickly to an inky black further out, and on still days the reflection of the forest is so perfect it's hard to tell which way is up. Driftwood lies bleached and twisted along the tideline, and the remains of an old campfire sit in a ring of blackened stones.

  The shore curves away in both directions, hemmed in by the forest. A path climbs back into the trees toward the hollow, and a little way along the beach, a weathered boathouse sits half on land and half on the water.
TEXT

boathouse = seed_room(lakeshore, "The Boathouse", <<~TEXT)
  Half built on the shore and half on stilts sunk into the lake, the boathouse creaks and sighs with every ripple. Inside, the light is dim and shifting, reflected up off the water that slaps against the pilings beneath the slatted floor. A couple of rowing boats bob in the open bay, tied to iron rings, while oars, nets and old lifebelts hang from hooks along the walls.

  A rickety ladder leads up to a small loft beneath the eaves, where someone once left a blanket, a lantern and a stack of mouldering novels. The wide doors at the front open back onto the stones of Shingle Beach.
TEXT

seed_paths(trailhead, "Ranger's Cabin", cabin, "Out")
seed_paths(clearing, "Fern Hollow", fern_hollow, "Clearing")
seed_paths(beach, "Boathouse", boathouse, "Out")
seed_paths(trailhead, "Deep Woods", clearing, "Forest's Edge")
seed_paths(fern_hollow, "Lake", beach, "Hollow")

# ---------------------------------------------------------------------------
# Getting between them: the train links the City and Country, the old bridge
# road reaches the Forest, and an old road through the woods comes out at
# the top of Grand Avenue in Uptown.
# ---------------------------------------------------------------------------

seed_paths(union_station, "Train to the Country", village_green, "Train to the City")
seed_paths(stone_bridge, "Forest Road", trailhead, "Bridge")
seed_paths(clearing, "Old Road to the City", grand_avenue, "Forest Road")

# Where players arrive when they open each Area.
{
  city => central_square, uptown => grand_avenue, midtown => central_square, downtown => union_station,
  country => village_green, village => village_green, farmland => farm_lane, riverside => stone_bridge,
  forest => trailhead, forest_edge => trailhead, deep_woods => clearing, lakeshore => beach
}.each do |area, room|
  area.update!(entrance_room: room) if area.entrance_room.nil?
end

# ---------------------------------------------------------------------------
# Forum boards, listed on the front page after the Areas. Change them, or who
# may post on them, under Admin → Boards.
# ---------------------------------------------------------------------------

[
  [ "News", "Announcements from staff. Everyone can reply.", "staff", "everyone" ],
  [ "Advertising", "Tell people about your character, a plot you're running or something you'd like to play.", "everyone", "everyone" ],
  [ "Wanted ads", "Looking for a friend, a rival, a sibling or a whole family? Post here.", "everyone", "everyone" ]
].each_with_index do |(name, description, start, reply), position|
  ForumBoard.find_or_create_by!(name: name) do |board|
    board.description = description
    board.position = position
    board.who_can_start = start
    board.who_can_reply = reply
  end
end
