
/mob/living/proc/get_bodypart(zone)
	return

/mob/living/carbon/get_bodypart(zone)
	if(!zone)
		zone = "chest"
	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		if(L.body_zone == zone)
			return L

/mob/living/carbon/has_hand_for_held_index(i)
	if(i)
		var/obj/item/bodypart/L = hand_bodyparts[i]
		if(L)
			return L
	return FALSE




/mob/proc/has_left_hand()
	return TRUE

/mob/living/carbon/has_left_hand()
	for(var/obj/item/bodypart/L in hand_bodyparts)
		if(L.held_index % 2)
			return TRUE
	return FALSE

/mob/living/carbon/alien/larva/has_left_hand()
	return 1


/mob/proc/has_right_hand()
	return TRUE

/mob/living/carbon/has_right_hand()
	for(var/obj/item/bodypart/L in hand_bodyparts)
		if(!(L.held_index % 2))
			return TRUE
	return FALSE

/mob/living/carbon/alien/larva/has_right_hand()
	return 1



//Limb numbers
/mob/proc/get_num_arms()
	return 2

/mob/living/carbon/get_num_arms()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/affecting = X
		if(affecting.body_part == ARM_RIGHT)
			.++
		if(affecting.body_part == ARM_LEFT)
			.++


//sometimes we want to ignore that we don't have the required amount of arms.
/mob/proc/get_arm_ignore()
	return 0

/mob/living/carbon/alien/larva/get_arm_ignore()
	return 1 //so we can still handcuff larvas.


/mob/proc/get_num_legs()
	return 2

/mob/living/carbon/get_num_legs()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/affecting = X
		if(affecting.body_part == LEG_RIGHT)
			.++
		if(affecting.body_part == LEG_LEFT)
			.++

//sometimes we want to ignore that we don't have the required amount of legs.
/mob/proc/get_leg_ignore()
	return 0

/mob/living/carbon/alien/larva/get_leg_ignore()
	return 1

/mob/living/carbon/human/get_leg_ignore()
	if(movement_type & FLYING)
		return 1

/mob/living/proc/get_missing_limbs()
	return list()

/mob/living/carbon/get_missing_limbs()
	var/list/full = list("head", "chest", "r_arm", "l_arm", "r_leg", "l_leg")
	for(var/zone in full)
		if(get_bodypart(zone))
			full -= zone
	return full

/mob/living/carbon/alien/larva/get_missing_limbs()
	var/list/full = list("head", "chest")
	for(var/zone in full)
		if(get_bodypart(zone))
			full -= zone
	return full

//Remove all embedded objects from all limbs on the carbon mob
/mob/living/carbon/proc/remove_all_embedded_objects()
	var/turf/T = get_turf(src)

	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		for(var/obj/item/I in L.embedded_objects)
			L.embedded_objects -= I
			I.forceMove(T)

	clear_alert("embeddedobject")

/mob/living/carbon/proc/has_embedded_objects()
	. = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/L = X
		for(var/obj/item/I in L.embedded_objects)
			return 1


//Helper for quickly creating a new limb - used by augment code in species.dm spec_attacked_by
/mob/living/carbon/proc/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/L
	switch(zone)
		if("l_arm")
			L = new /obj/item/bodypart/l_arm()
		if("r_arm")
			L = new /obj/item/bodypart/r_arm()
		if("head")
			L = new /obj/item/bodypart/head()
		if("l_leg")
			L = new /obj/item/bodypart/l_leg()
		if("r_leg")
			L = new /obj/item/bodypart/r_leg()
		if("chest")
			L = new /obj/item/bodypart/chest()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC)
	. = L

/mob/living/carbon/monkey/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/L
	switch(zone)
		if("l_arm")
			L = new /obj/item/bodypart/l_arm/monkey()
		if("r_arm")
			L = new /obj/item/bodypart/r_arm/monkey()
		if("head")
			L = new /obj/item/bodypart/head/monkey()
		if("l_leg")
			L = new /obj/item/bodypart/l_leg/monkey()
		if("r_leg")
			L = new /obj/item/bodypart/r_leg/monkey()
		if("chest")
			L = new /obj/item/bodypart/chest/monkey()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC)
	. = L

/mob/living/carbon/alien/larva/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/L
	switch(zone)
		if("head")
			L = new /obj/item/bodypart/head/larva()
		if("chest")
			L = new /obj/item/bodypart/chest/larva()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC)
	. = L

/mob/living/carbon/alien/humanoid/newBodyPart(zone, robotic, fixed_icon)
	var/obj/item/bodypart/L
	switch(zone)
		if("l_arm")
			L = new /obj/item/bodypart/l_arm/alien()
		if("r_arm")
			L = new /obj/item/bodypart/r_arm/alien()
		if("head")
			L = new /obj/item/bodypart/head/alien()
		if("l_leg")
			L = new /obj/item/bodypart/l_leg/alien()
		if("r_leg")
			L = new /obj/item/bodypart/r_leg/alien()
		if("chest")
			L = new /obj/item/bodypart/chest/alien()
	if(L)
		L.update_limb(fixed_icon, src)
		if(robotic)
			L.change_bodypart_status(BODYPART_ROBOTIC)
	. = L


/proc/skintone2hex(skin_tone)
	. = 0
	switch(skin_tone)
		if("green")
			. = "5ec491"
		if("cyan")
			. = "78bfcd"
		if("lavand")
			. = "e799f5"
		if("grey")
			. = "c6c3c6"
		if("neworange")
			. = "e1965a"
		if("darkred")
			. = "c33737"
		if("blue")
			. = "7997d9"
		if("lyra")
			. = "56d6ca"
		if("yellow")
			. = "dbd955"
		if("steelhooves")
			. = "82c52b"
		if("cyan")
			. = "5987a8"
		if("albino")
			. = "e8a0de"
		if("orange")
			. = "ffc905"

/mob/living/carbon/proc/Digitigrade_Leg_Swap(swap_back)
	var/body_plan_changed = FALSE
	for(var/X in bodyparts)
		var/obj/item/bodypart/O = X
		var/obj/item/bodypart/N
		if((!O.use_digitigrade && swap_back == FALSE) || (O.use_digitigrade && swap_back == TRUE))
			if(O.body_part == LEG_LEFT)
				if(swap_back == TRUE)
					N = new /obj/item/bodypart/l_leg
				else
					N = new /obj/item/bodypart/l_leg/digitigrade
			else if(O.body_part == LEG_RIGHT)
				if(swap_back == TRUE)
					N = new /obj/item/bodypart/r_leg
				else
					N = new /obj/item/bodypart/r_leg/digitigrade
		if(!N)
			continue
		body_plan_changed = TRUE
		O.drop_limb(1)
		qdel(O)
		N.attach_limb(src)
	if(body_plan_changed && ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.w_uniform)
			var/obj/item/clothing/under/U = H.w_uniform
			if(U.mutantrace_variation)
				if(swap_back)
					U.adjusted = NORMAL_STYLE
				else
					U.adjusted = DIGITIGRADE_STYLE
				H.update_inv_w_uniform()
		if(H.shoes && !swap_back)
			H.unEquip(H.shoes)
