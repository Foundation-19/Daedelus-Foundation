// Site53 map mob stubs - Bay/VORE mob types that don't exist in /tg/
// Stub types so the map loads; map-spawned instances become generic parent mobs

/mob/living/simple_animal/hostile/scarybat
	name = "scary bat"
	icon_state = "bat"

/mob/living/simple_animal/friendly/cat/fluff/scp529
	name = "SCP-529"
	desc = "A small cat with only the front half present."

/mob/living/simple_animal/friendly/cat/fluff/scp529/Initialize()
	. = ..()
	var/mob/living/simple_animal/scp529/real_529 = new(get_turf(src))
	if(mind)
		mind.transfer_to(real_529)
	qdel(src)

/mob/living/simple_animal/friendly/retaliate/scp066
	name = "SCP-066"
	desc = "Eric's Toy - a small metal sphere."

/mob/living/simple_animal/friendly/scp131
	name = "SCP-131"
	desc = "A teardrop-shaped creature."

/mob/living/simple_animal/friendly/scp131/scp131A
	name = "SCP-131-A"
	desc = "An orange teardrop-shaped creature."

/mob/living/simple_animal/friendly/scp131/scp131A/Initialize()
	. = ..()
	new /mob/living/simple_animal/scp131/a(get_turf(src))
	qdel(src)

/mob/living/simple_animal/friendly/scp131/scp131B
	name = "SCP-131-B"
	desc = "A yellow teardrop-shaped creature with a large eye."

/mob/living/simple_animal/friendly/scp131/scp131B/Initialize()
	. = ..()
	new /mob/living/simple_animal/scp131/b(get_turf(src))
	qdel(src)

/mob/living/simple_animal/tindalos
	name = "Hound of Tindalos"

/mob/living/simple_animal/yithian
	name = "Yithian"

/mob/living/exosuit/premade/powerloader/old
	name = "old power loader"

/mob/living/bot/cleanbot
	name = "cleanbot"

/mob/living/bot/medbot
	name = "medbot"
