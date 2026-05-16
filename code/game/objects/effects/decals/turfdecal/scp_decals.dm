// SCP Foundation & Bay12 Decal Definitions
// These use /tg/'s element-based decal system (turf_decal -> datum/element/decal at runtime)
// All corner/border decals use decals-ported.dmi which has the Bay12-style border states
// Organized by category: SCP containment zones, Foundation colors, industrial, misc
//
// Icon state mapping (Bay12 name -> actual state in decals-ported.dmi):
//   corner_white          -> bordercolor
//   bordercolor           -> bordercolor (exists)
//   bordercolorcorner     -> bordercolorcorner (exists)
//   bordercolorcee        -> bordercolorcee (exists)
//   bordercolormonofull   -> bordercolorfull
//   corner_white_full     -> corner_white_full (exists)
//   corner_white_diagonal -> bordercolorcorner
//   corner_white_three_quarters -> bordercolorcee
//   bordercolorhalf       -> borderhalf
//   bordercolorfull       -> bordercolorfull (exists)

// ============================================================
// BASE CORNER DECAL - override icon to use decals-ported.dmi
// The parent /obj/effect/turf_decal uses decals.dmi which lacks border states
// ============================================================

/obj/effect/turf_decal/corner
	icon = 'icons/turf/decals-ported.dmi'
	icon_state = "bordercolor"
	alpha = 229

// ============================================================
// SCP CONTAINMENT ZONE CORNER DECALS
// Used throughout Site-53 to mark containment zones by classification
// ============================================================

/obj/effect/turf_decal/corner/euclid
	color = "#CCFF00"

/obj/effect/turf_decal/corner/euclid/border
	color = "#CCFF00"

/obj/effect/turf_decal/corner/euclid/bordercorner
	icon_state = "bordercolorcorner"
	color = "#CCFF00"

/obj/effect/turf_decal/corner/euclid/bordercee
	icon_state = "bordercolorcee"
	color = "#CCFF00"

/obj/effect/turf_decal/corner/euclid/full
	icon_state = "corner_white_full"
	color = "#CCFF00"

/obj/effect/turf_decal/corner/euclid/mono
	icon_state = "bordercolorfull"
	color = "#CCFF00"

/obj/effect/turf_decal/corner/keter
	color = "#FF0000"

/obj/effect/turf_decal/corner/keter/border
	color = "#FF0000"

/obj/effect/turf_decal/corner/keter/bordercorner
	icon_state = "bordercolorcorner"
	color = "#FF0000"

/obj/effect/turf_decal/corner/keter/bordercee
	icon_state = "bordercolorcee"
	color = "#FF0000"

/obj/effect/turf_decal/corner/keter/mono
	icon_state = "bordercolorfull"
	color = "#FF0000"

/obj/effect/turf_decal/corner/safe
	color = "#00CC00"

/obj/effect/turf_decal/corner/safe/border
	color = "#00CC00"

/obj/effect/turf_decal/corner/safe/bordercorner
	icon_state = "bordercolorcorner"
	color = "#00CC00"

/obj/effect/turf_decal/corner/safe/mono
	icon_state = "bordercolorfull"
	color = "#00CC00"

/obj/effect/turf_decal/corner/safe/half
	icon_state = "borderhalf"
	color = "#00CC00"

/obj/effect/turf_decal/corner/safe/three_quarters
	icon_state = "bordercolorcee"
	color = "#00CC00"

/obj/effect/turf_decal/corner/research
	color = "#9933FF"

/obj/effect/turf_decal/corner/research/border
	color = "#9933FF"

/obj/effect/turf_decal/corner/research/bordercorner
	icon_state = "bordercolorcorner"
	color = "#9933FF"

/obj/effect/turf_decal/corner/research/bordercee
	icon_state = "bordercolorcee"
	color = "#9933FF"

/obj/effect/turf_decal/corner/research/full
	icon_state = "corner_white_full"
	color = "#9933FF"

/obj/effect/turf_decal/corner/research/mono
	icon_state = "bordercolorfull"
	color = "#9933FF"

/obj/effect/turf_decal/corner/research/three_quarters
	icon_state = "bordercolorcee"
	color = "#9933FF"

// ============================================================
// FOUNDATION COLOR CORNER DECALS
// Standard color variants used throughout Site-53
// ============================================================

/obj/effect/turf_decal/corner/paleblue
	color = "#66B2FF"

/obj/effect/turf_decal/corner/paleblue/border
	color = "#66B2FF"

/obj/effect/turf_decal/corner/paleblue/bordercorner
	icon_state = "bordercolorcorner"
	color = "#66B2FF"

/obj/effect/turf_decal/corner/paleblue/bordercee
	icon_state = "bordercolorcee"
	color = "#66B2FF"

/obj/effect/turf_decal/corner/paleblue/diagonal
	icon_state = "bordercolorcorner"
	color = "#66B2FF"

/obj/effect/turf_decal/corner/paleblue/mono
	icon_state = "bordercolorfull"
	color = "#66B2FF"

/obj/effect/turf_decal/corner/paleblue/half
	icon_state = "borderhalf"
	color = "#66B2FF"

/obj/effect/turf_decal/corner/paleblue/three_quarters
	icon_state = "bordercolorcee"
	color = "#66B2FF"

/obj/effect/turf_decal/corner/beige
	color = "#C8A882"

/obj/effect/turf_decal/corner/beige/border
	color = "#C8A882"

/obj/effect/turf_decal/corner/beige/bordercorner
	icon_state = "bordercolorcorner"
	color = "#C8A882"

/obj/effect/turf_decal/corner/beige/bordercee
	icon_state = "bordercolorcee"
	color = "#C8A882"

/obj/effect/turf_decal/corner/beige/mono
	icon_state = "bordercolorfull"
	color = "#C8A882"

/obj/effect/turf_decal/corner/b_green
	color = "#00FF00"

/obj/effect/turf_decal/corner/b_green/border
	color = "#00FF00"

/obj/effect/turf_decal/corner/b_green/bordercorner
	icon_state = "bordercolorcorner"
	color = "#00FF00"

/obj/effect/turf_decal/corner/lime
	color = "#99FF00"

/obj/effect/turf_decal/corner/lime/border
	color = "#99FF00"

/obj/effect/turf_decal/corner/lime/bordercorner
	icon_state = "bordercolorcorner"
	color = "#99FF00"

/obj/effect/turf_decal/corner/lime/mono
	icon_state = "bordercolorfull"
	color = "#99FF00"

/obj/effect/turf_decal/corner/purple
	color = "#CC00FF"

/obj/effect/turf_decal/corner/purple/border
	color = "#CC00FF"

/obj/effect/turf_decal/corner/purple/bordercorner
	icon_state = "bordercolorcorner"
	color = "#CC00FF"

/obj/effect/turf_decal/corner/purple/bordercee
	icon_state = "bordercolorcee"
	color = "#CC00FF"

/obj/effect/turf_decal/corner/purple/full
	icon_state = "corner_white_full"
	color = "#CC00FF"

/obj/effect/turf_decal/corner/purple/mono
	icon_state = "bordercolorfull"
	color = "#CC00FF"

/obj/effect/turf_decal/corner/brown
	color = "#865C2A"

/obj/effect/turf_decal/corner/brown/border
	color = "#865C2A"

/obj/effect/turf_decal/corner/brown/bordercorner
	icon_state = "bordercolorcorner"
	color = "#865C2A"

/obj/effect/turf_decal/corner/brown/bordercee
	icon_state = "bordercolorcee"
	color = "#865C2A"

/obj/effect/turf_decal/corner/brown/mono
	icon_state = "bordercolorfull"
	color = "#865C2A"

/obj/effect/turf_decal/corner/orange
	color = "#FF9900"

/obj/effect/turf_decal/corner/orange/border
	color = "#FF9900"

/obj/effect/turf_decal/corner/orange/bordercorner
	icon_state = "bordercolorcorner"
	color = "#FF9900"

/obj/effect/turf_decal/corner/orange/bordercee
	icon_state = "bordercolorcee"
	color = "#FF9900"

/obj/effect/turf_decal/corner/orange/mono
	icon_state = "bordercolorfull"
	color = "#FF9900"

/obj/effect/turf_decal/corner/orange/half
	icon_state = "borderhalf"
	color = "#FF9900"

/obj/effect/turf_decal/corner/orange/diagonal
	icon_state = "bordercolorcorner"
	color = "#FF9900"

/obj/effect/turf_decal/corner/orange/three_quarters
	icon_state = "bordercolorcee"
	color = "#FF9900"

/obj/effect/turf_decal/corner/green
	color = "#00CC00"

/obj/effect/turf_decal/corner/green/border
	color = "#00CC00"

/obj/effect/turf_decal/corner/green/bordercorner
	icon_state = "bordercolorcorner"
	color = "#00CC00"

/obj/effect/turf_decal/corner/green/mono
	icon_state = "bordercolorfull"
	color = "#00CC00"

/obj/effect/turf_decal/corner/grey
	color = "#8D8C8C"

/obj/effect/turf_decal/corner/grey/border
	color = "#8D8C8C"

/obj/effect/turf_decal/corner/grey/bordercorner
	icon_state = "bordercolorcorner"
	color = "#8D8C8C"

/obj/effect/turf_decal/corner/grey/mono
	icon_state = "bordercolorfull"
	color = "#8D8C8C"

/obj/effect/turf_decal/corner/grey/diagonal
	icon_state = "bordercolorcorner"
	color = "#8D8C8C"

/obj/effect/turf_decal/corner/black
	color = "#333333"

/obj/effect/turf_decal/corner/black/border
	color = "#333333"

/obj/effect/turf_decal/corner/black/bordercorner
	icon_state = "bordercolorcorner"
	color = "#333333"

/obj/effect/turf_decal/corner/black/bordercee
	icon_state = "bordercolorcee"
	color = "#333333"

/obj/effect/turf_decal/corner/black/diagonal
	icon_state = "bordercolorcorner"
	color = "#333333"

/obj/effect/turf_decal/corner/black/full
	icon_state = "corner_white_full"
	color = "#333333"

/obj/effect/turf_decal/corner/black/mono
	icon_state = "bordercolorfull"
	color = "#333333"

/obj/effect/turf_decal/corner/blue
	color = "#0066FF"

/obj/effect/turf_decal/corner/blue/border
	color = "#0066FF"

/obj/effect/turf_decal/corner/blue/bordercorner
	icon_state = "bordercolorcorner"
	color = "#0066FF"

/obj/effect/turf_decal/corner/blue/bordercee
	icon_state = "bordercolorcee"
	color = "#0066FF"

/obj/effect/turf_decal/corner/blue/full
	icon_state = "corner_white_full"
	color = "#0066FF"

/obj/effect/turf_decal/corner/blue/three_quarters
	icon_state = "bordercolorcee"
	color = "#0066FF"

/obj/effect/turf_decal/corner/blue/mono
	icon_state = "bordercolorfull"
	color = "#0066FF"

/obj/effect/turf_decal/corner/yellow
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/border
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/bordercorner
	icon_state = "bordercolorcorner"
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/bordercee
	icon_state = "bordercolorcee"
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/borderfull
	icon_state = "bordercolorfull"
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/mono
	icon_state = "bordercolorfull"
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/diagonal
	icon_state = "bordercolorcorner"
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/half
	icon_state = "borderhalf"
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/full
	icon_state = "corner_white_full"
	color = "#FFCC00"

/obj/effect/turf_decal/corner/yellow/three_quarters
	icon_state = "bordercolorcee"
	color = "#FFCC00"

/obj/effect/turf_decal/corner/red
	color = "#CC0000"

/obj/effect/turf_decal/corner/red/border
	color = "#CC0000"

/obj/effect/turf_decal/corner/red/bordercorner
	icon_state = "bordercolorcorner"
	color = "#CC0000"

/obj/effect/turf_decal/corner/red/bordercee
	icon_state = "bordercolorcee"
	color = "#CC0000"

/obj/effect/turf_decal/corner/red/borderfull
	icon_state = "bordercolorfull"
	color = "#CC0000"

/obj/effect/turf_decal/corner/red/diagonal
	icon_state = "bordercolorcorner"
	color = "#CC0000"

/obj/effect/turf_decal/corner/red/full
	icon_state = "corner_white_full"
	color = "#CC0000"

/obj/effect/turf_decal/corner/red/mono
	icon_state = "bordercolorfull"
	color = "#CC0000"

/obj/effect/turf_decal/corner/white
	color = "#FFFFFF"

/obj/effect/turf_decal/corner/white/border
	color = "#FFFFFF"

/obj/effect/turf_decal/corner/white/bordercorner
	icon_state = "bordercolorcorner"
	color = "#FFFFFF"

/obj/effect/turf_decal/corner/white/bordercee
	icon_state = "bordercolorcee"
	color = "#FFFFFF"

/obj/effect/turf_decal/corner/white/mono
	icon_state = "bordercolorfull"
	color = "#FFFFFF"

/obj/effect/turf_decal/corner/lightgrey
	color = "#D4D4D4"

/obj/effect/turf_decal/corner/lightgrey/border
	color = "#D4D4D4"

/obj/effect/turf_decal/corner/lightgrey/bordercorner
	icon_state = "bordercolorcorner"
	color = "#D4D4D4"

// ============================================================
// INDUSTRIAL DECALS (Foundation variant)
// Used for hazard markings, loading zones, etc.
// All use decals-ported.dmi which has danger/delivery/outline states
// ============================================================

/obj/effect/turf_decal/industrial
	icon = 'icons/turf/decals-ported.dmi'

/obj/effect/turf_decal/industrial/warning
	icon_state = "danger"

/obj/effect/turf_decal/industrial/warning/corner
	icon_state = "dangercorner"

/obj/effect/turf_decal/industrial/warning/cee
	icon_state = "dangercee"

/obj/effect/turf_decal/industrial/warning/full
	icon_state = "dangerfull"

/obj/effect/turf_decal/industrial/warning/fulltile
	icon_state = "dangerfull"

/obj/effect/turf_decal/industrial/outline
	icon_state = "outline"

/obj/effect/turf_decal/industrial/outline/yellow
	color = "#cfcf55"

/obj/effect/turf_decal/industrial/outline/red
	color = COLOR_RED_GRAY

/obj/effect/turf_decal/industrial/outline/orange
	color = COLOR_DARK_ORANGE

/obj/effect/turf_decal/industrial/outline/blue
	color = COLOR_BLUE_GRAY

/obj/effect/turf_decal/industrial/outline/grey
	color = "#808080"

/obj/effect/turf_decal/industrial/hatch
	icon_state = "delivery"

/obj/effect/turf_decal/industrial/hatch/red
	color = COLOR_RED_GRAY

/obj/effect/turf_decal/industrial/hatch/yellow
	color = "#cfcf55"

/obj/effect/turf_decal/industrial/hatch/orange
	color = COLOR_DARK_ORANGE

/obj/effect/turf_decal/industrial/hatch/blue
	color = COLOR_BLUE_GRAY

/obj/effect/turf_decal/industrial/fire
	icon_state = "danger"
	color = "#FF0000"

/obj/effect/turf_decal/industrial/firstaid
	icon_state = "outline"
	color = "#FFFFFF"

/obj/effect/turf_decal/industrial/loading
	icon = 'icons/turf/decals.dmi'
	icon_state = "loadingarea"

/obj/effect/turf_decal/industrial/radiation
	icon_state = "danger"
	color = "#00FF00"

/obj/effect/turf_decal/industrial/radiation/corner
	icon_state = "dangercorner"
	color = "#00FF00"

/obj/effect/turf_decal/industrial/shutoff
	icon_state = "shutoff"

// ============================================================
// STRIPE DECALS (Foundation color variants)
// Warning stripe markings in various colors
// These use the base decals.dmi which has warningline states
// ============================================================

/obj/effect/turf_decal/stripes/red
	icon_state = "warningline"
	color = "#DE3A3A"

/obj/effect/turf_decal/stripes/yellow
	icon_state = "warningline"
	color = "#EFB341"

/obj/effect/turf_decal/stripes/orange
	icon_state = "warningline"
	color = "#FF9900"

/obj/effect/turf_decal/stripes/brown
	icon_state = "warningline"
	color = "#A46106"

/obj/effect/turf_decal/stripes/blue
	icon_state = "warningline"
	color = "#52B4E9"

/obj/effect/turf_decal/stripes/gray
	icon_state = "warningline"
	color = "#8D8C8C"

/obj/effect/turf_decal/stripes/green
	icon_state = "warningline"
	color = "#9FED58"

/obj/effect/turf_decal/stripes/mauve
	icon_state = "warningline"
	color = "#D381C9"

/obj/effect/turf_decal/stripes/paleblue
	icon_state = "warningline"
	color = "#66B2FF"

/obj/effect/turf_decal/stripes/gunmetal
	icon_state = "warningline"
	color = "#474747"

/obj/effect/turf_decal/stripes/white
	icon_state = "warningline_white"

// ============================================================
// CARPET DECALS
// carpet_* states don't exist in any DMI - use spline_plain as fallback
// ============================================================

/obj/effect/turf_decal/carpet
	icon = 'icons/turf/decals-ported.dmi'
	icon_state = "spline_plain"

/obj/effect/turf_decal/carpet/green
	icon_state = "spline_plain"
	color = "#00CC00"

/obj/effect/turf_decal/carpet/orange
	icon_state = "spline_plain"
	color = "#FF9900"

/obj/effect/turf_decal/carpet/purple
	icon_state = "spline_plain"
	color = "#9933FF"

/obj/effect/turf_decal/carpet/red
	icon_state = "spline_plain"
	color = "#CC0000"

// ============================================================
// SPLINE DECALS (Foundation color variants)
// spline_fancy doesn't exist in any DMI - use spline_plain as fallback
// ============================================================

/obj/effect/turf_decal/spline
	icon = 'icons/turf/decals-ported.dmi'

/obj/effect/turf_decal/spline/fancy
	icon_state = "spline_plain"

/obj/effect/turf_decal/spline/fancy/black
	color = COLOR_GRAY

/obj/effect/turf_decal/spline/fancy/black/corner
	icon_state = "spline_plain_cee"

/obj/effect/turf_decal/spline/fancy/wood
	color = "#cb9e04"

/obj/effect/turf_decal/spline/fancy/wood/corner
	icon_state = "spline_plain_cee"

/obj/effect/turf_decal/spline/plain
	icon_state = "spline_plain"
	alpha = 229

/obj/effect/turf_decal/spline/plain/blue
	color = COLOR_BLUE_GRAY

/obj/effect/turf_decal/spline/plain/white
	color = COLOR_WHITE

/obj/effect/turf_decal/spline/plain/yellow
	color = COLOR_BROWN

// ============================================================
// MISCELLANEOUS DECALS
// ============================================================

/obj/effect/turf_decal/chapel
	icon = 'icons/turf/floors.dmi'
	icon_state = "chapel"

/obj/effect/turf_decal/snow
	icon = 'icons/turf/overlays.dmi'
	icon_state = "snowfloor"

/obj/effect/turf_decal/stoneborder
	icon = 'icons/turf/decals-ported.dmi'
	icon_state = "stoneborder"

/obj/effect/turf_decal/stoneborder/corner
	icon_state = "stoneborder_c"

/obj/effect/turf_decal/borderfloorblack
	icon = 'icons/turf/decals-ported.dmi'
	icon_state = "borderfloor_black"

/obj/effect/turf_decal/floordetail
	icon = 'icons/turf/decals-ported.dmi'
	icon_state = "manydot"

/obj/effect/turf_decal/floordetail/edgedrain
	icon_state = "edge"

/obj/effect/turf_decal/scp
	icon = 'icons/turf/decals-ported.dmi'

/obj/effect/turf_decal/scp/arrow
	icon_state = "shutoff"
