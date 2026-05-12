// A Knight may take a squire as their protégé for the round. While the two stay within view of
// each other, both gain stat buffs. The buff has a 2 minute duration: it refreshes while they are
// together, recedes a minute after they part, and re-applies on movement if they meet again later.
/datum/action/cooldown/spell/takeprotege
	name = "Take Protégé"
	desc = "Designate a nearby squire as your protégé. So long as the two of you stay within \
	view of each other, you gain +1 Willpower and your squire gains +1 Willpower and +1 Fortune. \
	You may only have one squire at a time; should they leave the round you may take another."
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

	if(alert(L, "[H.name] offers to take you as their protégé. You get +1 Willpower and +1 Fortune in their presence. Do you accept?", "Take Protégé", "I ACCEPT", "I REFUSE") == "I REFUSE")
		to_chat(H, span_warning("[L.name] has declined the bond."))
		reset_spell_cooldown()
		return FALSE

	H.set_squire(L)
	L.set_knight_lord(H)
	H.RegisterSignal(H, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/mob/living/carbon/human, squire_bond_on_move), TRUE)
	L.RegisterSignal(L, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/mob/living/carbon/human, squire_bond_on_move), TRUE)
	to_chat(H, span_nicegreen("[L.name] is now your protégé."))
	to_chat(L, span_nicegreen("[H.name] has taken you as their protégé."))
	H.apply_status_effect(/datum/status_effect/buff/squire_bond/knight)
	L.apply_status_effect(/datum/status_effect/buff/squire_bond/squire)
	return TRUE


// Used by the move/tick path: only true if the partner is fully gone (gibbed or dead).
// A briefly client-less mob (e.g. admin-spawned dummy, SSD player) does NOT shatter the bond,
// otherwise the very first movement would tear the buff down.
/proc/squire_bond_partner_invalid(mob/living/M)
	return QDELETED(M) || M.stat == DEAD

// Used by cast(): treats a permanently absent player as eligible-for-replacement so the
// knight can take a new squire if their original one ghosted out of the round.
/proc/squire_bond_partner_despawned(mob/living/M)
	return QDELETED(M) || M.stat == DEAD || !M.client

/proc/squire_bond_break(mob/living/knight, mob/living/squire)
	if(knight && !QDELETED(knight))
		knight.set_squire(null)
		knight.UnregisterSignal(knight, COMSIG_MOVABLE_MOVED)
		knight.remove_status_effect(/datum/status_effect/buff/squire_bond/knight)
	if(squire && !QDELETED(squire))
		squire.set_knight_lord(null)
		squire.UnregisterSignal(squire, COMSIG_MOVABLE_MOVED)
		squire.remove_status_effect(/datum/status_effect/buff/squire_bond/squire)

/mob/living/carbon/human/proc/squire_bond_on_move(atom/movable/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/partner
	var/is_knight_side = FALSE
	if(get_squire())
		partner = get_squire()
		is_knight_side = TRUE
	else if(get_knight_lord())
		partner = get_knight_lord()
	if(!partner)
		UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
		return
	if(squire_bond_partner_invalid(partner))
		if(is_knight_side)
			squire_bond_break(src, partner)
		else
			squire_bond_break(partner, src)
		return
	if(!(partner in view(7, get_turf(src))))
		return
	if(is_knight_side)
		src.apply_status_effect(/datum/status_effect/buff/squire_bond/knight)
		partner.apply_status_effect(/datum/status_effect/buff/squire_bond/squire)
	else
		src.apply_status_effect(/datum/status_effect/buff/squire_bond/squire)
		partner.apply_status_effect(/datum/status_effect/buff/squire_bond/knight)


// The proximity buff. Inherits STATUS_EFFECT_REFRESH from /datum/status_effect/buff, so re-applying
// just refreshes the timer rather than stacking.
/datum/status_effect/buff/squire_bond
	duration = 2 MINUTES
	tick_interval = 30 SECONDS
	var/datum/status_effect/buff/squire_bond/partner_buff_type

/datum/status_effect/buff/squire_bond/proc/get_partner()
	return null // overridden per side

/datum/status_effect/buff/squire_bond/tick()
	var/mob/living/carbon/human/partner = get_partner()
	if(!partner || squire_bond_partner_invalid(partner))
		// surviving side cleans up the bond
		var/mob/living/carbon/human/H = owner
		if(istype(H))
			if(H.get_squire() == partner)
				squire_bond_break(H, partner)
			else if(H.get_knight_lord() == partner)
				squire_bond_break(partner, H)
			else
				H.set_squire(null)
				H.set_knight_lord(null)
				H.UnregisterSignal(H, COMSIG_MOVABLE_MOVED)
		qdel(src)
		return
	if(partner in view(7, get_turf(owner)))
		refresh()
		if(partner_buff_type)
			partner.apply_status_effect(partner_buff_type)


/datum/status_effect/buff/squire_bond/knight
	id = "squire_bond_knight"
	alert_type = /atom/movable/screen/alert/status_effect/buff/squire_bond/knight
	effectedstats = list(STATKEY_WIL = 1)
	partner_buff_type = /datum/status_effect/buff/squire_bond/squire

/datum/status_effect/buff/squire_bond/knight/get_partner()
	return owner?.get_squire()

/datum/status_effect/buff/squire_bond/knight/on_apply()
	. = ..()
	to_chat(owner, span_blue("My protegé is at my side."))

/datum/status_effect/buff/squire_bond/knight/on_remove()
	if(owner && !QDELETED(owner))
		to_chat(owner, span_warning("Without my protégé near, my resolve dims."))
	. = ..()


/datum/status_effect/buff/squire_bond/squire
	id = "squire_bond_squire"
	alert_type = /atom/movable/screen/alert/status_effect/buff/squire_bond/squire
	effectedstats = list(STATKEY_WIL = 1, STATKEY_LCK = 1)
	partner_buff_type = /datum/status_effect/buff/squire_bond/knight

/datum/status_effect/buff/squire_bond/squire/get_partner()
	return owner?.get_knight_lord()

/datum/status_effect/buff/squire_bond/squire/on_apply()
	. = ..()
	to_chat(owner, span_blue("My knight is at my side."))

/datum/status_effect/buff/squire_bond/squire/on_remove()
	if(owner && !QDELETED(owner))
		to_chat(owner, span_warning("Without my knight near, my courage wavers."))
	. = ..()


/atom/movable/screen/alert/status_effect/buff/squire_bond/knight
	name = "Pledge to my protégé"
	desc = "My protégé is near. I shall be a role model to them."
	icon_state = "buff"

/atom/movable/screen/alert/status_effect/buff/squire_bond/squire
	name = "Commitment to my knight"
	desc = "My knight is near. I shall not dissapoint them."
	icon_state = "buff"
