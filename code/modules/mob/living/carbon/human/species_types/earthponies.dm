/datum/species/human
	name = "Earthpony"
	id = "human"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	mutant_bodyparts = list("tail_human", "ears", "wings")
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human

/datum/species/human/qualifies_for_faction(faction_id)
	if(faction_id == "acolytes" || faction_id == "enclave")
		return 0
	return 1

/datum/species/human/qualifies_for_rank(rank, list/features)
	if((!features["tail_human"] || features["tail_human"] == "None") && (!features["ears"] || features["ears"] == "None"))
		return TRUE	//Pure humans are always allowed in all roles.
	return ..()

//Curiosity killed the cat's wagging tail.
/datum/species/human/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		H.endTailWag()

/datum/species/human/spec_life(mob/living/carbon/human/H)
	if (H.radiation>90 && prob(10))
		to_chat(H, "<span class='danger'>You feel strange!</span>")
		H.set_species(/datum/species/ghoul)
		H.Stun(40)
		H.radiation = 0

/datum/species/human/space_move(mob/living/carbon/human/H)
	var/obj/item/device/flightpack/F = H.get_flightpack()
	if(istype(F) && (F.flight) && F.allow_thrust(0.01, src))
		return TRUE