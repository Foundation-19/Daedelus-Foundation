/obj/effect/turf_decal/tile
	name = "tile decal"
	icon_state = "tile_corner"
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110

/// Automatically generates all subtypes for a decal with the given path.
#define TILE_DECAL_SUBTYPE_HELPER(path)\
##path/opposingcorners {\
	icon_state = "tile_opposing_corners";\
}\
##path/half {\
	icon_state = "tile_half";\
}\
##path/half/contrasted {\
	icon_state = "tile_half_contrasted";\
}\
##path/anticorner {\
	icon_state = "tile_anticorner";\
}\
##path/anticorner/contrasted {\
	icon_state = "tile_anticorner_contrasted";\
}\
##path/fourcorners {\
	icon_state = "tile_fourcorners";\
}\
##path/full {\
	icon_state = "tile_full";\
}\
##path/diagonal_centre {\
	icon_state = "diagonal_centre";\
}\
##path/diagonal_edge {\
	icon_state = "diagonal_edge";\
}

/// Blue tiles
/obj/effect/turf_decal/tile/blue
	name = "blue tile decal"
	color = "#52B4E9"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/blue)

/// Dark blue tiles
/obj/effect/turf_decal/tile/dark_blue
	name = "dark blue tile decal"
	color = "#486091"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/dark_blue)

/// White tiles
/obj/effect/turf_decal/tile/white
	name = "white tile decal"
	color = "#FFFFFF"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/white)

/// Beige tiles
/obj/effect/turf_decal/tile/beige
	name = "beige tile decal"
	color = "#a37d4e"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/beige)

/// Green tiles
/obj/effect/turf_decal/tile/green
	name = "green tile decal"
	color = "#9FED58"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/green)

/// Dark Green tiles
/obj/effect/turf_decal/tile/dark_green
	name = "dark green tile decal"
	color = "#439C1E"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/dark_green)

/// Yellow tiles
/obj/effect/turf_decal/tile/yellow
	name = "yellow tile decal"
	color = "#EFB341"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/yellow)

/// Red tiles
/obj/effect/turf_decal/tile/red
	name = "red tile decal"
	color = "#DE3A3A"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/red)

/// Dark Red tiles
/obj/effect/turf_decal/tile/dark_red
	name = "dark red tile decal"
	color = "#B11111"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/dark_red)

/// Bar tiles
/obj/effect/turf_decal/tile/bar
	name = "bar tile decal"
	color = "#791500"
	alpha = 130

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/bar)

/// Purple tiles
/obj/effect/turf_decal/tile/purple
	name = "purple tile decal"
	color = "#D381C9"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/purple)

/// Brown tiles
/obj/effect/turf_decal/tile/brown
	name = "brown tile decal"
	color = "#A46106"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/brown)

/// Neutral tiles
/obj/effect/turf_decal/tile/neutral
	name = "neutral tile decal"
	color = "#D4D4D4"
	alpha = 50

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/neutral)

/// Dark tiles
/obj/effect/turf_decal/tile/dark
	name = "dark tile decal"
	color = "#0e0f0f"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/dark)

/// Random tiles
/obj/effect/turf_decal/tile/random // so many colors
	name = "colorful tile decal"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/tile/random/Initialize(mapload)
	color = "#[random_short_color()]"
	. = ..()

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/random)

/*
/// SCP-SPECIFIC TILE COLORS BEYOND THIS POINT.
*/

/// LCZ SCP tiles
/obj/effect/turf_decal/tile/lcz_tan
	name = "lcz tile decal"
	color = "#E0C276"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/lcz_tan)

/// EZ SCP tiles
/obj/effect/turf_decal/tile/ez_orange
	name = "ez tile decal"
	color = "#ce8245"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/ez_orange)

/// CDCZ SCP tiles
/obj/effect/turf_decal/tile/cdcz_orange
	name = "cdcz tile decal"
	color = "#ce620a"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/cdcz_orange)

/// ScD SCP tiles
/obj/effect/turf_decal/tile/science_blue
	name = "science tile decal"
	color = "#0545B5"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/science_blue)

/// Safe SCP tiles
/obj/effect/turf_decal/tile/safe
	name = "safe tile decal"
	color = "#365034"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/safe)

/// Euclid SCP tiles
/obj/effect/turf_decal/tile/euclid
	name = "euclid tile decal"
	color = "#635424"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/euclid)

/// Keter SCP tiles
/obj/effect/turf_decal/tile/keter
	name = "keter tile decal"
	color = "#65261e"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/keter)

/// Thaumiel SCP trimlines
/obj/effect/turf_decal/tile/thaumiel
	name = "thaumiel tile decal"
	color = "#2A3856"

TILE_DECAL_SUBTYPE_HELPER(/obj/effect/turf_decal/tile/thaumiel)

#undef TILE_DECAL_SUBTYPE_HELPER

/// Trimlines
/obj/effect/turf_decal/trimline
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110
	icon_state = "trimline_box"

/// Automatically generates all trimlines for a decal with the given path.
#define TRIMLINE_SUBTYPE_HELPER(path)\
##path/line {\
	icon_state = "trimline";\
}\
##path/corner {\
	icon_state = "trimline_corner";\
}\
##path/end {\
	icon_state = "trimline_end";\
}\
##path/arrow_cw {\
	icon_state = "trimline_arrow_cw";\
}\
##path/arrow_ccw {\
	icon_state = "trimline_arrow_ccw";\
}\
##path/warning {\
	icon_state = "trimline_warn";\
}\
##path/mid_joiner {\
	icon_state = "trimline_mid";\
}\
##path/filled {\
	icon_state = "trimline_box_fill";\
}\
##path/filled/line {\
	icon_state = "trimline_fill";\
}\
##path/filled/corner {\
	icon_state = "trimline_corner_fill";\
}\
##path/filled/end {\
	icon_state = "trimline_end_fill";\
}\
##path/filled/arrow_cw {\
	icon_state = "trimline_arrow_cw_fill";\
}\
##path/filled/arrow_ccw {\
	icon_state = "trimline_arrow_ccw_fill";\
}\
##path/filled/warning {\
	icon_state = "trimline_warn_fill";\
}\
##path/filled/warning/corner {\
	icon_state = "trimline_corner_warn_fill";\
}\
##path/filled/mid_joiner {\
	icon_state = "trimline_mid_fill";\
}\
##path/filled/shrink_cw {\
	icon_state = "trimline_shrink_cw";\
}\
##path/filled/shrink_ccw {\
	icon_state = "trimline_shrink_ccw";\
}

/// White trimlines
/obj/effect/turf_decal/trimline/white
	color = "#FFFFFF"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/white)

/// Dark trimlines
/obj/effect/turf_decal/trimline/dark
	color = "#0e0f0f"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/dark)

/// Beige trimlines
/obj/effect/turf_decal/trimline/beige
	color = "#a37d4e"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/beige)

/// Red trimlines
/obj/effect/turf_decal/trimline/red
	color = "#DE3A3A"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/red)

/// Dark Red trimlines
/obj/effect/turf_decal/trimline/dark_red
	color = "#B11111"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/dark_red)

/// Green trimlines
/obj/effect/turf_decal/trimline/green
	color = "#9FED58"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/green)

/// Dark Green trimlines
/obj/effect/turf_decal/trimline/dark_green
	color = "#439C1E"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/dark_green)

/// Blue trimlines
/obj/effect/turf_decal/trimline/blue
	color = "#52B4E9"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/blue)

/// Dark Blue trimlines
/obj/effect/turf_decal/trimline/dark_blue
	color = "#486091"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/dark_blue)

/// Yellow trimlines
/obj/effect/turf_decal/trimline/yellow
	color = "#EFB341"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/yellow)

/// Purple trimlines
/obj/effect/turf_decal/trimline/purple
	color = "#D381C9"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/purple)

/// Brown trimlines
/obj/effect/turf_decal/trimline/brown
	color = "#A46106"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/brown)

/// Neutral trimlines
/obj/effect/turf_decal/trimline/neutral
	color = "#D4D4D4"
	alpha = 50

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/neutral)

/*
/// SCP-SPECIFIC TILE COLORS BEYOND THIS POINT.
*/

/// LCZ SCP trimlines
/obj/effect/turf_decal/trimline/lcz_tan
	color = "#E0C276"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/lcz_tan)

/// EZ SCP trimlines
/obj/effect/turf_decal/trimline/ez_orange
	color = "#ce8245"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/ez_orange)

/// CDCZ SCP trimlines
/obj/effect/turf_decal/trimline/cdcz_orange
	color = "#ce620a"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/cdcz_orange)

/// ScD SCP trimlines
/obj/effect/turf_decal/trimline/science_blue
	color = "#0545B5"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/science_blue)

/// Safe SCP trimlines
/obj/effect/turf_decal/trimline/safe
	color = "#365034"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/safe)

/// Euclid SCP trimlines
/obj/effect/turf_decal/trimline/euclid
	color = "#635424"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/euclid)

/// Keter SCP trimlines
/obj/effect/turf_decal/trimline/keter
	color = "#65261E"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/keter)

/// Thaumiel SCP trimlines
/obj/effect/turf_decal/trimline/thaumiel
	color = "#2A3856"

TRIMLINE_SUBTYPE_HELPER(/obj/effect/turf_decal/trimline/thaumiel)

#undef TRIMLINE_SUBTYPE_HELPER
