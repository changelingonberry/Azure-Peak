// A Knight may take a Squire as their protégé for the round.
//
// Mechanics:
//   - While the squire stays within view of the knight, on town turf, and both are alive, the
//     squire gains the /datum/status_effect/buff/protege_vigilance buff (+1 CON, +1 WIL, +1 SPD —
//     the same stat profile that town guards get from /datum/status_effect/buff/guardbuffone,
//     scoped to "in the knight's company while on patrol" rather than just "in town").
//   - The knight gets NO direct stat buff for taking a squire. But they do get the Empath trait purely for their chosen protégé.
//   - When the squire dies, the knight takes a 10-mood hit via /datum/stressevent/protege_dead.
//     A 5-minute grace period prevents revive-die-revive-die loops from instantly stacking;
//     stacks up to 5 deep otherwise, so a knight who repeatedly loses their squire feels it.
/datum/action/cooldown/spell/takeprotege
	name = "Take Protégé"
	desc = "Designate a nearby Squire as your protégé. You will know how they feel. So long as you patrol the town together \
	within view of each other, your squire gains the vigilance of a town guardsman (+1 \
	Constitution, +1 Willpower, +1 Speed). Should they fall, your spirit will mourn them. You \
	may only have one squire at a time; should they leave the round you may take another."
	button_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "eminence_rally"
	cast_range = 1
	primary_resource_cost = 0
	primary_resource_type = SPELL_COST_NONE
	cooldown_time = 30 SECONDS
	charge_required = TRUE
	charge_time = 3 SECONDS
	associated_skill = /datum/skill/misc/reading
	self_cast_possible = FALSE
	spell_requirements = SPELL_REQUIRES_SAME_Z
	antimagic_flags = NONE
	invocation_type = INVOCATION_EMOTE
	invocations = list("%CASTER takes on a protégé. May their bond be unbreakable.")
	invocation_self_message = "I take on a protégé. May our bond be unbreakable."


/datum/action/cooldown/spell/takeprotege/is_valid_target(atom/cast_on)
	if(!isliving(cast_on) || !ishuman(cast_on))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/takeprotege/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/L = cast_on
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		reset_spell_cooldown()
		return FALSE
	if(H == L)
		to_chat(H, span_warning("I cannot take myself as a squire."))
		reset_spell_cooldown()
		return FALSE
	if(H.job != "Knight")
		to_chat(H, span_warning("Only a knight may take a squire."))
		reset_spell_cooldown()
		return FALSE
	if(L.job != "Squire")
		to_chat(H, span_warning("I can only take a squire as my protégé."))
		reset_spell_cooldown()
		return FALSE

	// A despawned/dead/ghosted prior bond yields to a fresh cast.
	var/mob/living/carbon/human/existing_squire = H.get_squire()
	if(existing_squire)
		if(squire_bond_partner_despawned(existing_squire))
			squire_bond_break(H, existing_squire)
		else
			to_chat(H, span_warning("I already have a protégé."))
			reset_spell_cooldown()
			return FALSE

	var/mob/living/carbon/human/existing_lord = L.get_knight_lord()
	if(existing_lord)
		if(squire_bond_partner_despawned(existing_lord))
			squire_bond_break(existing_lord, L)
		else
			to_chat(H, span_warning("[L.name] already serves another knight."))
			reset_spell_cooldown()
			return FALSE

	if(alert(L, "[H.name] offers to take you as their protégé. While by their side on the town's streets, you stand with a guardsman's vigilance, but they will have the read on you. Do you accept?", "Take Protégé", "I ACCEPT", "I REFUSE") == "I REFUSE")
		to_chat(H, span_warning("[L.name] has declined the bond."))
		reset_spell_cooldown()
		return FALSE

	H.set_squire(L)
	L.set_knight_lord(H)
	H.RegisterSignal(H, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/mob/living/carbon/human, squire_bond_on_move), TRUE)
	L.RegisterSignal(L, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/mob/living/carbon/human, squire_bond_on_move), TRUE)
	H.RegisterSignal(L, COMSIG_LIVING_DEATH, TYPE_PROC_REF(/mob/living/carbon/human, on_protege_death), TRUE)
	to_chat(H, span_nicegreen("[L.name] is now your protégé."))
	to_chat(L, span_nicegreen("[H.name] has taken you as their protégé."))
	if(squire_bond_buff_eligible(H, L))
		L.apply_status_effect(/datum/status_effect/buff/protege_vigilance)
	return TRUE


// Strict invalidity used by cast() — a knight whose squire has fully left the round (gibbed, dead,
// or ghosted/SSD) can take a new one. The move/death paths only QDELETED-check inline.
/proc/squire_bond_partner_despawned(mob/living/M)
	return QDELETED(M) || M.stat == DEAD || !M.client

// All conditions that must be true for the squire to receive the vigilance buff:
// both alive, squire in view of knight, and squire currently on town turf.
/proc/squire_bond_buff_eligible(mob/living/carbon/human/knight, mob/living/carbon/human/squire)
	if(QDELETED(knight) || QDELETED(squire))
		return FALSE
	if(knight.stat == DEAD || squire.stat == DEAD)
		return FALSE
	if(!(knight in view(7, get_turf(squire))))
		return FALSE
	var/area/rogue/squire_area = get_area(squire)
	if(!istype(squire_area) || !squire_area.town_area)
		return FALSE
	return TRUE

/proc/squire_bond_break(mob/living/knight, mob/living/squire)
	if(knight && !QDELETED(knight))
		if(squire && !QDELETED(squire))
			knight.UnregisterSignal(squire, COMSIG_LIVING_DEATH)
		knight.UnregisterSignal(knight, COMSIG_MOVABLE_MOVED)
		knight.set_squire(null)
	if(squire && !QDELETED(squire))
		squire.UnregisterSignal(squire, COMSIG_MOVABLE_MOVED)
		squire.set_knight_lord(null)
		squire.remove_status_effect(/datum/status_effect/buff/protege_vigilance)

/mob/living/carbon/human/proc/squire_bond_on_move(atom/movable/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/partner
	var/mob/living/carbon/human/squire_mob
	var/mob/living/carbon/human/knight_mob
	if(get_squire())
		partner = get_squire()
		knight_mob = src
		squire_mob = partner
	else if(get_knight_lord())
		partner = get_knight_lord()
		knight_mob = partner
		squire_mob = src
	if(!partner)
		UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
		return
	if(QDELETED(partner))
		squire_bond_break(knight_mob, squire_mob)
		return
	if(!squire_bond_buff_eligible(knight_mob, squire_mob))
		return
	squire_mob.apply_status_effect(/datum/status_effect/buff/protege_vigilance)

/mob/living/carbon/human/proc/on_protege_death(mob/living/source, gibbed)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	// 5-minute grace period: a revive-die-revive-die loop within 5 min of the last death
	// counts as continuing trauma, not fresh trauma, so we skip the stack.
	var/datum/stressevent/existing = get_stress_event(/datum/stressevent/protege_dead)
	if(existing && (world.time - existing.time_added) < 5 MINUTES)
		return
	to_chat(src, span_userdanger("My protégé [source.name] has fallen!"))
	add_stress(/datum/stressevent/protege_dead)


/datum/stressevent/protege_dead
	stressadd = 10
	stressadd_per_extra_stack = 10
	max_stacks = 5
	timer = 30 MINUTES
	desc = span_boldred("My protégé has fallen. I have failed in my duty.")


// The squire's proximity buff. Mirrors /datum/status_effect/buff/guardbuffone (CON/WIL/SPD)
// but is gated on line-of-sight to the bonded knight (and squire being on town turf) instead of
// merely standing on town turf.
/datum/status_effect/buff/protege_vigilance
	id = "protege_vigilance"
	alert_type = /atom/movable/screen/alert/status_effect/buff/protege_vigilance
	duration = 1 MINUTES
	tick_interval = 30 SECONDS
	effectedstats = list(STATKEY_CON = 1, STATKEY_WIL = 1, STATKEY_SPD = 1)

/datum/status_effect/buff/protege_vigilance/tick()
	var/mob/living/carbon/human/knight = owner?.get_knight_lord()
	if(!knight || QDELETED(knight))
		qdel(src)
		return
	// Refresh from the tick so the buff doesn't time out while standing still in town with the
	// knight in view. Movement signals also refresh; either path is enough on its own.
	if(squire_bond_buff_eligible(knight, owner))
		refresh()

/datum/status_effect/buff/protege_vigilance/on_apply()
	. = ..()
	to_chat(owner, span_blue("My knight stands with me. I shall stand vigilant."))

/datum/status_effect/buff/protege_vigilance/on_remove()
	if(owner && !QDELETED(owner))
		to_chat(owner, span_warning("Without my knight near, my vigilance fades."))
	. = ..()

/atom/movable/screen/alert/status_effect/buff/protege_vigilance
	name = "Vigilant Protégé"
	desc = "My knight stands with me on the streets we patrol. Faster, better stronger."
	icon_state = "buff"
