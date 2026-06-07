// === STATUE PIECES ===================================================
/obj/item/chezz
	name = "chezz statue"
	desc = ""
	icon = 'modular/icons/obj/chezz.dmi'
	icon_state = "white_pawn"
	w_class = WEIGHT_CLASS_HUGE	// life-size statue: won't fit in pockets/packs, only the enchanted box
	dropshrink = 1
	throw_range = 1
	throwforce = 0

/obj/item/chezz/Initialize()
	. = ..()
	// Must be carried with both hands.
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

// --- White ---
/obj/item/chezz/white
	icon_state = "white_pawn"

/obj/item/chezz/white/pawn
	name = "white serf"
	icon_state = "white_pawn"
	desc = "Advances one square forward, or two from its start (=). Captures one square diagonally forward (x).\n+-----------+\n| . . . . . |\n| . . = . . |\n| . x ^ x . |\n| . . P . . |\n| . . . . . |\n+-----------+\n. empty   ^ move   x capture   = first move"

/obj/item/chezz/white/rook
	name = "white man-at-arms"
	icon_state = "white_rook"
	desc = "Slides any number of empty squares horizontally or vertically.\n+-----------+\n| . . * . . |\n| . . * . . |\n| * * R * * |\n| . . * . . |\n| . . * . . |\n+-----------+\n. empty   * reachable"

/obj/item/chezz/white/knight
	name = "white saiga"
	icon_state = "white_knight"
	desc = "Leaps in an L: two squares one way, then one at a right angle. Jumps over anything between.\n+-----------+\n| . * . * . |\n| * . . . * |\n| . . N . . |\n| * . . . * |\n| . * . * . |\n+-----------+\n. empty   * reachable"

/obj/item/chezz/white/bishop
	name = "white magos"
	icon_state = "white_bishop"
	desc = "Slides any number of empty squares diagonally, always on one color.\n+-----------+\n| * . . . * |\n| . * . * . |\n| . . B . . |\n| . * . * . |\n| * . . . * |\n+-----------+\n. empty   * reachable"

/obj/item/chezz/white/queen
	name = "white banneret"
	icon_state = "white_queen"
	desc = "Slides any number of empty squares in any straight line: horizontal, vertical, or diagonal.\n+-----------+\n| * . * . * |\n| . * * * . |\n| * * Q * * |\n| . * * * . |\n| * . * . * |\n+-----------+\n. empty   * reachable"

/obj/item/chezz/white/king
	name = "white duke"
	icon_state = "white_king"
	desc = "Moves one square in any direction. It may never step into check, and losing it loses the game.\n+-----------+\n| . . . . . |\n| . * * * . |\n| . * K * . |\n| . * * * . |\n| . . . . . |\n+-----------+\n. empty   * reachable"

// --- Black ---
/obj/item/chezz/black
	icon_state = "black_pawn"

/obj/item/chezz/black/pawn
	name = "black serf"
	icon_state = "black_pawn"
	desc = "Advances one square forward, or two from its start (=). Captures one square diagonally forward (x).\n+-----------+\n| . . . . . |\n| . . = . . |\n| . x ^ x . |\n| . . P . . |\n| . . . . . |\n+-----------+\n. empty   ^ move   x capture   = first move"

/obj/item/chezz/black/rook
	name = "black man-at-arms"
	icon_state = "black_rook"
	desc = "Slides any number of empty squares horizontally or vertically.\n+-----------+\n| . . * . . |\n| . . * . . |\n| * * R * * |\n| . . * . . |\n| . . * . . |\n+-----------+\n. empty   * reachable"

/obj/item/chezz/black/knight
	name = "black saiga"
	icon_state = "black_knight"
	desc = "Leaps in an L: two squares one way, then one at a right angle. Jumps over anything between.\n+-----------+\n| . * . * . |\n| * . . . * |\n| . . N . . |\n| * . . . * |\n| . * . * . |\n+-----------+\n. empty   * reachable"

/obj/item/chezz/black/bishop
	name = "black magos"
	icon_state = "black_bishop"
	desc = "Slides any number of empty squares diagonally, always on one color.\n+-----------+\n| * . . . * |\n| . * . * . |\n| . . B . . |\n| . * . * . |\n| * . . . * |\n+-----------+\n. empty   * reachable"

/obj/item/chezz/black/queen
	name = "black banneret"
	icon_state = "black_queen"
	desc = "Slides any number of empty squares in any straight line: horizontal, vertical, or diagonal.\n+-----------+\n| * . * . * |\n| . * * * . |\n| * * Q * * |\n| . * * * . |\n| * . * . * |\n+-----------+\n. empty   * reachable"

/obj/item/chezz/black/king
	name = "black duke"
	icon_state = "black_king"
	desc = "Moves one square in any direction. It may never step into check, and losing it loses the game.\n+-----------+\n| . . . . . |\n| . * * * . |\n| . * K * . |\n| . * * * . |\n| . . . . . |\n+-----------+\n. empty   * reachable"


// === BOARD SQUARE TURFS ==============================================
//  Modeled on the existing /turf/open/floor/rogue/tile checkered floor.
/turf/open/floor/rogue/tile/chezz_light
	name = "light chezz square"
	desc = ""
	icon = 'modular/icons/obj/chezz.dmi'
	icon_state = "square_light"
	smooth = SMOOTH_FALSE
	canSmoothWith = null

/turf/open/floor/rogue/tile/chezz_dark
	name = "dark chezz square"
	desc = ""
	icon = 'modular/icons/obj/chezz.dmi'
	icon_state = "square_dark"
	smooth = SMOOTH_FALSE
	canSmoothWith = null

//  The convertible ballroom dance floor. A mapper paints this, then the
//  lever-driven converter toggles it to/from chezz squares.
/turf/open/floor/rogue/tile/ballroom
	name = "ballroom floor"
	desc = ""
	icon = 'modular/icons/obj/chezz.dmi'
	icon_state = "ballroom"
	smooth = SMOOTH_FALSE
	canSmoothWith = null


// === CRAFTING — craft chezz squares onto a floor ===============
/datum/crafting_recipe/roguetown/turfs/stone/chezz_light
	name = "light chezz tile"
	result = /turf/open/floor/rogue/tile/chezz_light
	craftdiff = 1
	category = "Floors"

/datum/crafting_recipe/roguetown/turfs/stone/chezz_dark
	name = "dark chezz tile"
	result = /turf/open/floor/rogue/tile/chezz_dark
	craftdiff = 1
	category = "Floors"


// === LEVER RECEIVER — ballroom <-> chezzboard ========================
/obj/structure/chezz_converter
	name = "chezzboard mechanism"
	desc = ""
	icon = 'modular/icons/obj/chezz.dmi'
	icon_state = "set_box"		// usually hidden under the floor; reuse a sprite
	density = FALSE
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER
	max_integrity = 0
	redstone_structure = TRUE
	var/converted = FALSE

/obj/structure/chezz_converter/redstone_triggered(mob/user)
	var/area/A = get_area(src)
	if(!A)
		return
	converted = !converted
	for(var/turf/open/floor/rogue/tile/T in A)
		if(converted)
			// Only transform ballroom floor into the checkerboard.
			if(istype(T, /turf/open/floor/rogue/tile/ballroom))
				if((T.x + T.y) % 2)
					T.ChangeTurf(/turf/open/floor/rogue/tile/chezz_light, flags = CHANGETURF_INHERIT_AIR)
				else
					T.ChangeTurf(/turf/open/floor/rogue/tile/chezz_dark, flags = CHANGETURF_INHERIT_AIR)
		else
			// Revert any chezz square back to ballroom floor.
			if(istype(T, /turf/open/floor/rogue/tile/chezz_light) || istype(T, /turf/open/floor/rogue/tile/chezz_dark))
				T.ChangeTurf(/turf/open/floor/rogue/tile/ballroom, flags = CHANGETURF_INHERIT_AIR)
	playsound(src, 'sound/foley/lever.ogg', 100, extrarange = 3)


// === ENCHANTED CHEZZ SET BOX =========================================
/datum/component/storage/concrete/roguetown/chezz
	screen_max_rows = 8
	screen_max_columns = 4
	max_w_class = WEIGHT_CLASS_HUGE		// magically holds the life-size statues
	not_while_equipped = FALSE

/datum/component/storage/concrete/roguetown/chezz/New(datum/P, ...)
	. = ..()
	can_hold = typecacheof(list(/obj/item/chezz))

/obj/item/storage/chezz_set
	name = "chezz set of holding"
	desc = {"An enchanted coffer that swallows a full set of life-size chezz statues.
+---------------------------------------------+
|                CHEZZ  RULES                 |
+---------------------------------------------+
White moves first, then players alternate turns,
moving one piece per turn. Capture by landing on
an enemy piece; it is removed from the board.
The goal is CHECKMATE: attacking the enemy king
so it cannot escape capture. If a king is merely
attacked it is in CHECK and must be made safe at
once. A position with no legal move and no check
is STALEMATE - a draw.

-- SPECIAL MOVES --
CASTLING: once per game, if neither the king nor
the chosen rook has moved, the squares between
them are empty, and the king is not in or moving
through check - move the king two squares toward
the rook, then place that rook on the far side of
the king.
  +-------------------+      +-------------------+
  | . . . . R . . K . |  ->  | . . . . . R K . . |
  +-------------------+      +-------------------+

EN PASSANT: if an enemy pawn advances two squares
and lands beside your pawn, on your very next turn
only you may capture it as if it had moved one
square, taking it diagonally.

PROMOTION: a pawn reaching the far rank is swapped
for a queen, rook, bishop, or knight of its color
(usually a queen).

Examine any statue to see how that piece moves."}
	icon = 'modular/icons/obj/chezz.dmi'
	icon_state = "set_box"
	w_class = WEIGHT_CLASS_NORMAL
	component_type = /datum/component/storage/concrete/roguetown/chezz

/obj/item/storage/chezz_set/PopulateContents()
	// White
	for(var/i in 1 to 8)
		new /obj/item/chezz/white/pawn(src)
	new /obj/item/chezz/white/rook(src)
	new /obj/item/chezz/white/rook(src)
	new /obj/item/chezz/white/knight(src)
	new /obj/item/chezz/white/knight(src)
	new /obj/item/chezz/white/bishop(src)
	new /obj/item/chezz/white/bishop(src)
	new /obj/item/chezz/white/queen(src)
	new /obj/item/chezz/white/queen(src)
	new /obj/item/chezz/white/king(src)
	// Black
	for(var/i in 1 to 8)
		new /obj/item/chezz/black/pawn(src)
	new /obj/item/chezz/black/rook(src)
	new /obj/item/chezz/black/rook(src)
	new /obj/item/chezz/black/knight(src)
	new /obj/item/chezz/black/knight(src)
	new /obj/item/chezz/black/bishop(src)
	new /obj/item/chezz/black/bishop(src)
	new /obj/item/chezz/black/queen(src)
	new /obj/item/chezz/black/queen(src)
	new /obj/item/chezz/black/king(src)
