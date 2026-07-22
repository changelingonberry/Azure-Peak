/obj/effect/proc_holder/spell/self/howl
	name = "Howl"
	desc = "Howl to the moon to communicate with my fellow volves. Do beware, those versed in beasttongue may be listening."
	overlay_state = "howl"
	antimagic_allowed = TRUE
	recharge_time = 600 //1 minute
	ignore_cockblock = TRUE
	var/use_language = FALSE
	var/list/howl_sounds = list('sound/vo/mobs/wwolf/howl (1).ogg','sound/vo/mobs/wwolf/howl (2).ogg')
	var/list/howl_sounds_far = list('sound/vo/mobs/wwolf/howldist (1).ogg','sound/vo/mobs/wwolf/howldist (2).ogg')
	var/wolf_antag_type = /datum/antagonist/werewolf
	var/howl_spies_allowed = TRUE
	var/howl_distance_limit = 500

/obj/effect/proc_holder/spell/self/howl/cast(mob/user = usr)
	..()
	var/message = input("Howl at the hidden moon...", "MOONCURSED") as text|null
	if(!message) return

	var/datum/antagonist/antag_data = user.mind.has_antag_datum(wolf_antag_type)

	// sound played for owner
	playsound(user, pick(howl_sounds_far), 75, TRUE)

	for(var/mob/player in GLOB.player_list)

		if(!player.mind) continue
		if(player.stat == DEAD) continue
		if(isbrain(player)) continue

		// Announcement to other werewolves (and anyone else who has beast language somehow)
		if(player.mind.has_antag_datum(wolf_antag_type) || (player.has_language(/datum/language/beast)) && howl_spies_allowed)
			var/speaker_name = (antag_data && hasvar(antag_data, "wolfname")) ? antag_data:wolfname : user.real_name
			to_chat(player, span_boldannounce("[speaker_name] howls to the hidden moon: [message]"))

		//sound played for other players
		if(player == src) continue
		var/player_distance = get_dist(player,src)
		if(player_distance > 7 && player_distance <= howl_distance_limit)
			player.playsound_local(get_turf(player), pick(howl_sounds_far), 50, FALSE, pressure_affected = FALSE)

	user.log_message("howls: [message] ([wolf_antag_type])", LOG_GAME)

/obj/effect/proc_holder/spell/self/claws
	name = "Lupine Claws"
	desc = "Unsheathe your claws."
	overlay_state = "claws"
	antimagic_allowed = TRUE
	recharge_time = 20 //2 seconds
	ignore_cockblock = TRUE
	var/list/extended_claw_record = list(FALSE, FALSE)
	var/claw_type = /obj/item/rogueweapon/werewolf_claw
	range = -1

/obj/effect/proc_holder/spell/self/claws/cast(list/targets, mob/user)
	. = ..()
	var/list/current_hands = list(FALSE, FALSE)
	current_hands[LEFT_HANDS] = user.get_item_for_held_index(LEFT_HANDS)
	current_hands[RIGHT_HANDS] = user.get_item_for_held_index(RIGHT_HANDS)
	var/extending_claws = FALSE
	// note the potential (and intentional) double negative for having a hand for that index; if you're missing
	// that arm, we need to return a truthy value to flip into a falsy value, so you don't try to extend claws
	// if you're missing one arm and trying to free up the other hand from your current claws
	if(!(current_hands[LEFT_HANDS] || !user.has_hand_for_held_index(LEFT_HANDS)) || !(current_hands[RIGHT_HANDS] || !user.has_hand_for_held_index(RIGHT_HANDS)))
		extending_claws = TRUE
	//LEFT_HANDS = 1, RIGHT_HANDS = 2, see code/__DEFINES/inventory.dm
	for(var/hand_index = 1, hand_index < 3, hand_index++)
		var/current_item = current_hands[hand_index]
		if(extending_claws)
			// don't try to force a claw into a hand holding something, like a succulent limb inconveniently
			// attached to a victim
			if(current_hands[hand_index])
				continue
			// don't try to force a claw into a hand that was detached from you, non-succulently
			if(!user.has_hand_for_held_index(hand_index))
				continue
			var/new_claw
			if(hand_index == LEFT_HANDS)
				var/left_claw_path = text2path("[claw_type]/left")
				new_claw = new left_claw_path(user)
				user.put_in_l_hand(new_claw)
				extended_claw_record[LEFT_HANDS] = new_claw
			else
				var/right_claw_path = text2path("[claw_type]/right")
				new_claw = new right_claw_path(user)
				user.put_in_r_hand(new_claw)
				extended_claw_record[RIGHT_HANDS] = new_claw
			RegisterSignal(new_claw, COMSIG_QDELETING, PROC_REF(clear_claw_entry))
			continue
		var/claw_entry = extended_claw_record[hand_index]
		if(claw_entry && current_item != claw_entry)
			var/msg = "[user] held item wasn't extended_claw_entry as expected; Expected: [claw_entry], Got: [current_item]"
			log_admin(msg)
			log_runtime(msg)
		if(istype(current_item, claw_type))
			if(!claw_entry)
				var/msg = "[user] had a werewolf claw that wasn't being tracked by the claw entries: [current_item]"
				log_admin(msg)
				log_runtime(msg)
			user.temporarilyRemoveItemFromInventory(I = current_item, force = TRUE)
			qdel(current_item)
		extended_claw_record[hand_index] = FALSE		
	return TRUE

/obj/effect/proc_holder/spell/self/claws/proc/clear_claw_entry(datum/source)
	SIGNAL_HANDLER
	var/claw_index = extended_claw_record.Find(source)
	if(claw_index)
		extended_claw_record[claw_index] = FALSE


/datum/action/cooldown/spell/repulse/werewolf
	name = "Terrifying Howl"
	desc = "Let loose a howl of dread, repelling anyone around you."
	button_icon_state = "howl"
	cooldown_time = 6 MINUTES
	charge_required = FALSE
	showsparkles = FALSE
	invocations = null
	sound = 'sound/vo/mobs/wwolf/roar.ogg'
	spell_flags = SPELL_IGNORE_SPELLBLOCK

/datum/action/cooldown/spell/ravage
	name = "Ravage"
	desc = "Requires an aggressive grab on a prone and living target. Savage your victim's throat with your jaws, forcing Dendor's Madness directly into their veins and converting them into a verevolf."
	fluff_desc = "A curse spread not by moonlight alone, but by will. Where infection is a slow rot, Ravage is a dam burst — a torrent of Dendor's Madness poured directly into the blood of one already made helpless. Even the foulest of beasts reserve this act for the worthy, or the foolish. It is not mercy. It is recruitment."
	button_icon_state = "bite"
	charge_required = FALSE
	click_to_activate = FALSE
	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_SKILL
	cooldown_time = 5 MINUTES
	spell_requirements = SPELL_REQUIRES_SAME_Z
	spell_flags = SPELL_IGNORE_SPELLBLOCK
	has_visual_effects = FALSE

/datum/action/cooldown/spell/ravage/cast(atom/cast_on)
	. = ..()
	if(!ishuman(owner))
		return FALSE

	if(owner.pulling && ishuman(owner.pulling) && owner.grab_state >= GRAB_AGGRESSIVE)
		throat_bite(owner.pulling, owner)
		return TRUE

	to_chat(owner, span_warning("I need an aggressive grab on a floored victim to Ravage them!"))
	reset_spell_cooldown()
	return FALSE

/datum/action/cooldown/spell/ravage/proc/throat_bite(mob/living/carbon/human/target, mob/living/carbon/human/user)
	var/tear_time = 10 SECONDS
	var/inject_time = 10 SECONDS

	if(target == user)
		reset_spell_cooldown()
		return
	if(!iscarbon(target))
		to_chat(user, span_info("This creature cannot bear Dendor's Madness."))
		reset_spell_cooldown()
		return
	if(target.stat == DEAD)
		to_chat(user, span_notice("They're dead."))
		reset_spell_cooldown()
		return
	if(!target.Adjacent(user))
		to_chat(user, span_info("I need to be next to [target] to Ravage them."))
		reset_spell_cooldown()
		return
	if((target.mobility_flags & MOBILITY_STAND))
		to_chat(user, span_info("My victim must be lying down."))
		reset_spell_cooldown()
		return
	if(!target.can_werewolf())
		to_chat(user, span_notice("Dendor's Madness finds no purchase in this one."))
		reset_spell_cooldown()
		return
	if(HAS_TRAIT(target, TRAIT_BLACKBLOOD))
		to_chat(user, span_notice("Dendor's Madness recoils from [target.p_their()] corrupted blood!"))
		reset_spell_cooldown()
		return

	user.visible_message(span_alert("[user] pins [target] down and lunges for [target.p_their()] throat..."))

	var/obj/item/bodypart/head = target.get_bodypart(BODY_ZONE_HEAD)
	var/do_stage1 = head && !head.has_wound(/datum/wound/bite/large)

	target.balloon_alert_to_viewers("<font color='#cc4400'>Ravaging..!</font>")
	if(!HAS_TRAIT(target, TRAIT_NOPAIN))
		target.emote("scream")

	if(do_stage1)
		jitter_channel(target, tear_time, 100, 300)
		if(!do_after(user, tear_time, target = target))
			return
		if(head)
			head.add_wound(/datum/wound/bite/large)
		target.apply_damage(30, BRUTE, BODY_ZONE_HEAD)
		playsound(user, 'sound/combat/wound_tear.ogg', 60, FALSE, 3)
		user.visible_message(span_alert("[user] wrenches [user.p_their()] jaws into [target.p_their()] throat, tearing through the flesh!"))

	jitter_channel(target, inject_time, do_stage1 ? 300 : 100, 500)
	target.set_light(2, 2, 2, l_color = GLOW_COLOR_DENDOR)
	user.visible_message(span_alert("[user] presses [user.p_their()] maw against [target.p_their()] wound, forcing Dendor's Madness into the blood..."))
	if(!do_after(user, inject_time, target = target) && head && head.has_wound(/datum/wound/bite/large))
		target.set_light(0)
		return
	target.set_light(0)

	if(!target.Adjacent(user) || (target.mobility_flags & MOBILITY_STAND))
		to_chat(user, span_warning("My victim got away before I could finish!"))
		return

	if(target.stat == DEAD || !iscarbon(target))
		return

	var/datum/antagonist/werewolf/wolfy = target.werewolf_check()
	if(!wolfy)
		to_chat(user, span_warning("The curse was rejected — [target] resists Dendor's Madness!"))
		return

	if(!HAS_TRAIT(target, TRAIT_NOPAIN))
		target.emote("agony")
	user.visible_message(span_alert("[user] tears free of [target.p_their()] throat, Dendor's Madness now burning through [target.p_their()] veins!"))
	target.balloon_alert_to_viewers("<font color='#558d20'>Infected!</font>")
	target.apply_damage(20, BRUTE, BODY_ZONE_HEAD)
	target.flash_fullscreen("redflash3")
	to_chat(target, span_danger("Something tears through my veins — burning, CHANGING ME FROM WITHIN!"))

/datum/action/cooldown/spell/ravage/proc/jitter_channel(mob/living/target, duration, start_jitter, end_jitter)
	var/interval = 14
	var/steps = round(duration / interval)
	for(var/i = 0; i < steps; i++)
		var/jitteriness = start_jitter + (end_jitter - start_jitter) * i * 1.0 / max(steps - 1, 1)
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, do_jitter_animation), jitteriness), i * interval)
