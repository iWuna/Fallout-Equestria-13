/* Toys!
 * Contains
 *		Balloons
 *		Fake singularity
 *		Toy gun
 *		Toy crossbow
 *		Toy swords
 *		Crayons
 *		Snap pops
 *		Mech prizes
 *		AI core prizes
 *		Toy codex gigas
 * 		Skeleton toys
 *		Cards
 *		Toy nuke
 *		Fake meteor
 *		Carp plushie
 *		Foam armblade
 *		Toy big red button
 *		Beach ball
 *		Toy xeno
 *      Kitty toys!
 *		Snowballs
 */


/obj/item/toy
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	force = 0


/*
 * Balloons
 */
/obj/item/toy/balloon
	name = "water balloon"
	desc = "A translucent balloon. There's nothing in it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "waterballoon-e"
	item_state = "balloon-empty"

/obj/item/toy/balloon/New()
	create_reagents(10)
	..()

/obj/item/toy/balloon/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/toy/balloon/afterattack(atom/A as mob|obj, mob/user, proximity)
	if(!proximity) return
	if (istype(A, /obj/structure/reagent_dispensers))
		var/obj/structure/reagent_dispensers/RD = A
		if(RD.reagents.total_volume <= 0)
			to_chat(user, "<span class='warning'>[RD] is empty.</span>")
		else if(reagents.total_volume >= 10)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
		else
			A.reagents.trans_to(src, 10)
			to_chat(user, "<span class='notice'>You fill the balloon with the contents of [A].</span>")
			desc = "A translucent balloon with some form of liquid sloshing around in it."
			update_icon()

/obj/item/toy/balloon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(I.reagents)
			if(I.reagents.total_volume <= 0)
				to_chat(user, "<span class='warning'>[I] is empty.</span>")
			else if(reagents.total_volume >= 10)
				to_chat(user, "<span class='warning'>[src] is full.</span>")
			else
				desc = "A translucent balloon with some form of liquid sloshing around in it."
				to_chat(user, "<span class='notice'>You fill the balloon with the contents of [I].</span>")
				I.reagents.trans_to(src, 10)
				update_icon()
	else if(I.is_sharp())
		balloon_burst()
	else
		return ..()

/obj/item/toy/balloon/throw_impact(atom/hit_atom)
	if(!..()) //was it caught by a mob?
		balloon_burst(hit_atom)

/obj/item/toy/balloon/proc/balloon_burst(atom/AT)
	if(reagents.total_volume >= 1)
		var/turf/T
		if(AT)
			T = get_turf(AT)
		else
			T = get_turf(src)
		T.visible_message("<span class='danger'>[src] bursts!</span>","<span class='italics'>You hear a pop and a splash.</span>")
		reagents.reaction(T)
		for(var/atom/A in T)
			reagents.reaction(A)
		icon_state = "burst"
		qdel(src)

/obj/item/toy/balloon/update_icon()
	if(src.reagents.total_volume >= 1)
		icon_state = "waterballoon"
		item_state = "balloon"
	else
		icon_state = "waterballoon-e"
		item_state = "balloon-empty"

/obj/item/toy/syndicateballoon
	name = "syndicate balloon"
	desc = "There is a tag on the back that reads \"FUK NT!11!\"."
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	force = 0
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	item_state = "syndballoon"
	w_class = WEIGHT_CLASS_BULKY

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "gravitational singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"

/*
 * Toy gun: Why isnt this an /obj/item/weapon/gun?
 */
/obj/item/toy/gun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up. Please recycle in an autolathe when you're out of caps."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "revolver"
	item_state = "gun"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	flags =  CONDUCT
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=10, MAT_GLASS=10)
	attack_verb = list("struck", "pistol whipped", "hit", "bashed")
	var/bullets = 7

/obj/item/toy/gun/examine(mob/user)
	..()
	to_chat(user, "There [bullets == 1 ? "is" : "are"] [bullets] cap\s left.")

/obj/item/toy/gun/attackby(obj/item/toy/ammo/gun/A, mob/user, params)

	if(istype(A, /obj/item/toy/ammo/gun))
		if (src.bullets >= 7)
			to_chat(user, "<span class='warning'>It's already fully loaded!</span>")
			return 1
		if (A.amount_left <= 0)
			to_chat(user, "<span class='warning'>There are no more caps!</span>")
			return 1
		if (A.amount_left < (7 - src.bullets))
			src.bullets += A.amount_left
			to_chat(user, text("<span class='notice'>You reload [] cap\s.</span>", A.amount_left))
			A.amount_left = 0
		else
			to_chat(user, text("<span class='notice'>You reload [] cap\s.</span>", 7 - src.bullets))
			A.amount_left -= 7 - src.bullets
			src.bullets = 7
		A.update_icon()
		return 1
	else
		return ..()

/obj/item/toy/gun/afterattack(atom/target as mob|obj|turf|area, mob/user, flag)
	if (flag)
		return
	if (!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	src.add_fingerprint(user)
	if (src.bullets < 1)
		user.show_message("<span class='warning'>*click*</span>", 2)
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
		return
	playsound(user, 'sound/weapons/Gunshot.ogg', 100, 1)
	src.bullets--
	user.visible_message("<span class='danger'>[user] fires [src] at [target]!</span>", \
						"<span class='danger'>You fire [src] at [target]!</span>", \
						 "<span class='italics'>You hear a gunshot!</span>")

/obj/item/toy/ammo/gun
	name = "capgun ammo"
	desc = "Make sure to recyle the box in an autolathe when it gets empty."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "357OLD-7"
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL=10, MAT_GLASS=10)
	var/amount_left = 7

/obj/item/toy/ammo/gun/update_icon()
	src.icon_state = text("357OLD-[]", src.amount_left)

/obj/item/toy/ammo/gun/examine(mob/user)
	..()
	to_chat(user, "There [amount_left == 1 ? "is" : "are"] [amount_left] cap\s left.")

/*
 * Toy swords
 */
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "sword0"
	item_state = "sword0"
	var/active = 0
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "struck", "hit")
	var/hacked = 0

/obj/item/toy/sword/attack_self(mob/user)
	active = !( active )
	if (active)
		to_chat(user, "<span class='notice'>You extend the plastic blade with a quick flick of your wrist.</span>")
		playsound(user, 'sound/weapons/saberon.ogg', 20, 1)
		if(hacked)
			icon_state = "swordrainbow"
			item_state = "swordrainbow"
		else
			icon_state = "swordblue"
			item_state = "swordblue"
		w_class = WEIGHT_CLASS_BULKY
	else
		to_chat(user, "<span class='notice'>You push the plastic blade back down into the handle.</span>")
		playsound(user, 'sound/weapons/saberoff.ogg', 20, 1)
		icon_state = "sword0"
		item_state = "sword0"
		w_class = WEIGHT_CLASS_SMALL
	add_fingerprint(user)

// Copied from /obj/item/weapon/melee/energy/sword/attackby
/obj/item/toy/sword/attackby(obj/item/weapon/W, mob/living/user, params)
	if(istype(W, /obj/item/toy/sword))
		if((W.flags & NODROP) || (flags & NODROP))
			to_chat(user, "<span class='warning'>\the [flags & NODROP ? src : W] is stuck to your hand, you can't attach it to \the [flags & NODROP ? W : src]!</span>")
			return
		else
			to_chat(user, "<span class='notice'>You attach the ends of the two plastic swords, making a single double-bladed toy! You're fake-cool.</span>")
			var/obj/item/weapon/twohanded/dualsaber/toy/newSaber = new /obj/item/weapon/twohanded/dualsaber/toy(user.loc)
			if(hacked) // That's right, we'll only check the "original" "sword".
				newSaber.hacked = 1
				newSaber.item_color = "rainbow"
			user.unEquip(W)
			user.unEquip(src)
			qdel(W)
			qdel(src)
	else if(istype(W, /obj/item/device/multitool))
		if(hacked == 0)
			hacked = 1
			item_color = "rainbow"
			to_chat(user, "<span class='warning'>RNBW_ENGAGE</span>")

			if(active)
				icon_state = "swordrainbow"
				user.update_inv_hands()
		else
			to_chat(user, "<span class='warning'>It's already fabulous!</span>")
	else
		return ..()

/*
 * Foam armblade
 */
/obj/item/toy/foamblade
	name = "foam armblade"
	desc = "it says \"Sternside Changs #1 fan\" on it. "
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamblade"
	item_state = "arm_blade"
	attack_verb = list("pricked", "absorbed", "gored")
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE


/*
 * Subtype of Double-Bladed Energy Swords
 */
/obj/item/weapon/twohanded/dualsaber/toy
	name = "double-bladed toy sword"
	desc = "A cheap, plastic replica of TWO energy swords.  Double the fun!"
	force = 0
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	force_unwielded = 0
	force_wielded = 0
	origin_tech = null
	attack_verb = list("attacked", "struck", "hit")

/obj/item/weapon/twohanded/dualsaber/toy/hit_reaction()
	return 0

/obj/item/weapon/twohanded/dualsaber/toy/IsReflect()//Stops Toy Dualsabers from reflecting energy projectiles
	return 0

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'

/*
 * Snap pops
 */

/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = WEIGHT_CLASS_TINY
	var/ash_type = /obj/effect/decal/cleanable/ash

/obj/item/toy/snappop/proc/pop_burst(var/n=3, var/c=1)
	var/datum/effect_system/spark_spread/s = new()
	s.set_up(n, c, src)
	s.start()
	new ash_type(loc)
	visible_message("<span class='warning'>[src] explodes!</span>",
		"<span class='italics'>You hear a snap!</span>")
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	qdel(src)

/obj/item/toy/snappop/fire_act(exposed_temperature, exposed_volume)
	pop_burst()

/obj/item/toy/snappop/throw_impact(atom/hit_atom)
	if(!..())
		pop_burst()

/obj/item/toy/snappop/Crossed(H as mob|obj)
	if(ishuman(H) || issilicon(H)) //i guess carp and shit shouldn't set them off
		var/mob/living/carbon/M = H
		if(issilicon(H) || M.m_intent == MOVE_INTENT_RUN)
			to_chat(M, "<span class='danger'>You step on the snap pop!</span>")
			pop_burst(2, 0)

/obj/item/toy/snappop/phoenix
	name = "phoenix snap pop"
	desc = "Wow! And wow! And wow!"
	ash_type = /obj/effect/decal/cleanable/ash/snappop_phoenix

/obj/effect/decal/cleanable/ash/snappop_phoenix
	var/respawn_time = 300

/obj/effect/decal/cleanable/ash/snappop_phoenix/New()
	. = ..()
	addtimer(CALLBACK(src, .proc/respawn), respawn_time)

/obj/effect/decal/cleanable/ash/snappop_phoenix/proc/respawn()
	new /obj/item/toy/snappop/phoenix(get_turf(src))
	qdel(src)


/*
 * Mech prizes
 */
/obj/item/toy/prize
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"
	var/timer = 0
	var/cooldown = 30
	var/quiet = 0

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user)
	if(timer < world.time)
		to_chat(user, "<span class='notice'>You play with [src].</span>")
		timer = world.time + cooldown
		if(!quiet)
			playsound(user, 'sound/mecha/mechstep.ogg', 20, 1)
	else
		. = ..()

/obj/item/toy/prize/attack_hand(mob/user)
	if(loc == user)
		attack_self(user)
	else
		. = ..()

/obj/item/toy/prize/ripley
	name = "toy Ripley"
	desc = "Mini-Mecha action figure! Collect them all! 1/12."

/obj/item/toy/prize/fireripley
	name = "toy firefighting Ripley"
	desc = "Mini-Mecha action figure! Collect them all! 2/12."
	icon_state = "fireripleytoy"

/obj/item/toy/prize/deathripley
	name = "toy deathsquad Ripley"
	desc = "Mini-Mecha action figure! Collect them all! 3/12."
	icon_state = "deathripleytoy"

/obj/item/toy/prize/gygax
	name = "toy Gygax"
	desc = "Mini-Mecha action figure! Collect them all! 4/12."
	icon_state = "gygaxtoy"

/obj/item/toy/prize/durand
	name = "toy Durand"
	desc = "Mini-Mecha action figure! Collect them all! 5/12."
	icon_state = "durandprize"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mecha action figure! Collect them all! 6/12."
	icon_state = "honkprize"

/obj/item/toy/prize/marauder
	name = "toy Marauder"
	desc = "Mini-Mecha action figure! Collect them all! 7/12."
	icon_state = "marauderprize"

/obj/item/toy/prize/seraph
	name = "toy Seraph"
	desc = "Mini-Mecha action figure! Collect them all! 8/12."
	icon_state = "seraphprize"

/obj/item/toy/prize/mauler
	name = "toy Mauler"
	desc = "Mini-Mecha action figure! Collect them all! 9/12."
	icon_state = "maulerprize"

/obj/item/toy/prize/odysseus
	name = "toy Odysseus"
	desc = "Mini-Mecha action figure! Collect them all! 10/12."
	icon_state = "odysseusprize"

/obj/item/toy/prize/phazon
	name = "toy Phazon"
	desc = "Mini-Mecha action figure! Collect them all! 11/12."
	icon_state = "phazonprize"

/obj/item/toy/prize/reticence
	name = "toy Reticence"
	desc = "Mini-Mecha action figure! Collect them all! 12/12."
	icon_state = "reticenceprize"
	quiet = 1


/obj/item/toy/talking
	name = "talking action figure"
	desc = "A generic action figure modeled after nothing in particular."
	icon = 'icons/obj/toy.dmi'
	icon_state = "owlprize"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = FALSE
	var/messages = list("I'm super generic!", "Mathematics class is of variable difficulty!")
	var/span = "danger"
	var/recharge_time = 30

	var/chattering = FALSE
	var/phomeme

// Talking toys are language universal, and thus all species can use them
/obj/item/toy/talking/attack_alien(mob/user)
	. = attack_hand(user)

/obj/item/toy/talking/attack_self(mob/user)
	if(!cooldown)
		var/list/messages = generate_messages()
		activation_message(user)
		playsound(loc, 'sound/machines/click.ogg', 20, 1)

		spawn(0)
			for(var/message in messages)
				toy_talk(user, message)
				sleep(10)

		cooldown = TRUE
		spawn(recharge_time)
			cooldown = FALSE
		return
	..()

/obj/item/toy/talking/proc/activation_message(mob/user)
	user.visible_message(
		"<span class='notice'>[user] pulls the string on \the [src].</span>",
		"<span class='notice'>You pull the string on \the [src].</span>",
		"<span class='notice'>You hear a string being pulled.</span>")

/obj/item/toy/talking/proc/generate_messages()
	return list(pick(messages))

/obj/item/toy/talking/proc/toy_talk(mob/user, message)
	user.loc.visible_message("<span class='[span]'>[bicon(src)] [message]</span>")
	if(chattering)
		chatter(message, phomeme, user)

/*
 * AI core prizes
 */
/obj/item/toy/talking/AI
	name = "toy AI"
	desc = "A little toy model AI core with real law announcing action!"
	icon_state = "AI"

/obj/item/toy/talking/AI/generate_messages()
	return list(generate_ion_law())

/obj/item/toy/talking/strength
	name = "Applejack Statuette"
	desc = "Be Strong."
	icon = 'icons/fallout/objects/items.dmi'
	icon_state = "strength"
	w_class = WEIGHT_CLASS_SMALL
	recharge_time = 60

/obj/item/toy/talking/strength/activation_message(mob/user)
	user.visible_message(
		"<span class='notice'>[user] presses the button on \the [src].</span>",
		"<span class='notice'>You press the button on \the [src].</span>",
		"<span class='notice'>You hear a soft click.</span>")

/obj/item/toy/talking/strength/generate_messages()
	var/list/messages = list()
	messages = list(
	"����� � ������, �� ������ ��� ����. ����, �� �� ����� ��������� � ������� � �������� ��� ��������. Life is shit, but death is even worse. Sorry, we can not go back in time and cancel our birth.",
	"��� ��� ����� �������? ��� ����� �����. How do people kill? I need corpses.",
	"� ���� �� � ���� ���������, ��� � ���� ����� �� ������. Besides, I want to make sure that my corpses do not stand up.",
	"��� � ����? ���������� ������, �� ����. ������� ����� ������� � ��������� ��� ������ � ������ � ����� ����, ��� ������� ������ �� ������ ���, ��� ��� �����, ��� � ���� �� ������! What I want? Frankly, I do not know. Most of the time I ignore my mission and go into other people's houses, where I start to fumble around the shelves ... ooo, just the one behind your back!")
	return messages

/obj/item/toy/talking/perception
	name = "Pinkie Pie Statuette"
	desc = "Awareness! It was under 'E'!"
	icon = 'icons/fallout/objects/items.dmi'
	icon_state = "perception"
	w_class = WEIGHT_CLASS_SMALL
	recharge_time = 60

/obj/item/toy/talking/perception/activation_message(mob/user)
	user.visible_message(
		"<span class='notice'>[user] presses the button on \the [src].</span>",
		"<span class='notice'>You press the button on \the [src].</span>",
		"<span class='notice'>You hear a soft click.</span>")

/obj/item/toy/talking/perception/generate_messages()
	var/list/messages = list()
	messages = list(
	"I DON'T WANNA DIE IN FIRE!",
	"I hope Twilight forgive me. for everything.",
	"My Ministry was important for all Equestria.",
	"PINKIE IS WATCHING YOU!")
	return messages

/obj/item/toy/talking/endurance
	name = "Rarity Statuette"
	desc = "Be Unwavering."
	icon = 'icons/fallout/objects/items.dmi'
	icon_state = "endurance"
	w_class = WEIGHT_CLASS_SMALL
	recharge_time = 60

/obj/item/toy/talking/endurance/activation_message(mob/user)
	user.visible_message(
		"<span class='notice'>[user] presses the button on \the [src].</span>",
		"<span class='notice'>You press the button on \the [src].</span>",
		"<span class='notice'>You hear a soft click.</span>")

/obj/item/toy/talking/endurance/generate_messages()
	var/list/messages = list()
	messages = list(
	"Pfft!.",
	"We need to find this Dark-Magic book, pleeease?",
	"Sometime i miss for Sweetie Bell",
	"Oh, darling! This clothes are awful, find something less vulgar!")
	return messages

/obj/item/toy/talking/charisma
	name = "Fluttershy Statuette"
	desc = "Be Pleasant."
	icon = 'icons/fallout/objects/items.dmi'
	icon_state = "charisma"
	w_class = WEIGHT_CLASS_SMALL
	recharge_time = 60

/obj/item/toy/talking/charisma/activation_message(mob/user)
	user.visible_message(
		"<span class='notice'>[user] presses the button on \the [src].</span>",
		"<span class='notice'>You press the button on \the [src].</span>",
		"<span class='notice'>You hear a soft click.</span>")

/obj/item/toy/talking/charisma/generate_messages()
	var/list/messages = list()
	messages = list(
	"I wanna be a tree!",
	"Security saves pony? Right?",
	"I hope you don't kill them.",
	"You... should be kind! Please?.")
	return messages

/obj/item/toy/talking/intelligence
	name = "Twilight Sparkle Statuette"
	desc = "Be Smart."
	icon = 'icons/fallout/objects/items.dmi'
	icon_state = "intelligence"
	w_class = WEIGHT_CLASS_SMALL
	recharge_time = 60

/obj/item/toy/talking/intelligence/activation_message(mob/user)
	user.visible_message(
		"<span class='notice'>[user] presses the button on \the [src].</span>",
		"<span class='notice'>You press the button on \the [src].</span>",
		"<span class='notice'>You hear a soft click.</span>")

/obj/item/toy/talking/intelligence/generate_messages()
	var/list/messages = list()
	messages = list(
	"The Ministry of Peace seriously warns: do not feed Parasprites! Here, in fact, that's all.",
	"Once again, you will do so - and I'll shove your hoof into your ass, that you'll cough with laces!",
	"I once was in a crematorium, where the victims of burns were given discounts.",
	"Goldeblood was right... we loose this war.")
	return messages

/obj/item/toy/talking/agility
	name = "Rainbow Dash Statuette"
	desc = "Be Awesome!"
	icon = 'icons/fallout/objects/items.dmi'
	icon_state = "agility"
	w_class = WEIGHT_CLASS_SMALL
	recharge_time = 60

/obj/item/toy/talking/agility/activation_message(mob/user)
	user.visible_message(
		"<span class='notice'>[user] presses the button on \the [src].</span>",
		"<span class='notice'>You press the button on \the [src].</span>",
		"<span class='notice'>You hear a soft click.</span>")

/obj/item/toy/talking/agility/generate_messages()
	var/list/messages = list()
	messages = list(
	"You know, I once had thousands of employees. Few people lived up to my expectations, and fewer than those who surpassed them.",
	"Ministry of Awesome are SO FUCKING AWESOME!",
	"Thoose Zebras can suck my wing!",
	"TEN SECONDS FLAT!.")
	return messages

/obj/item/toy/talking/luck
	name = "Spike Statuette"
	desc = "Be lucky."
	icon = 'icons/fallout/objects/items.dmi'
	icon_state = "luck"
	w_class = WEIGHT_CLASS_SMALL
	recharge_time = 60

/obj/item/toy/talking/luck/activation_message(mob/user)
	user.visible_message(
		"<span class='notice'>[user] presses the button on \the [src].</span>",
		"<span class='notice'>You press the button on \the [src].</span>",
		"<span class='notice'>You hear a soft click.</span>")

/obj/item/toy/talking/luck/generate_messages()
	var/list/messages = list()
	messages = list(
	"��� ��� ���������� �������� ��� �����? ����� ��� ������ ��� ����!",
	"��� ����� ����� ��� ��������!",
	"������, ����� ������ ������ ���� � ���� ������, ����������� ����� ������ ����� ���.",
	"�� �� �������������, ������� ����� �������� ���, ����� � ������ ��, ��� � ����� ������� ����.")
	return messages

/obj/item/toy/talking/codex_gigas
	name = "Toy Codex Gigas"
	desc = "A tool to help you write fictional devils!"
	icon = 'icons/obj/library.dmi'
	icon_state = "demonomicon"
	w_class = WEIGHT_CLASS_SMALL
	recharge_time = 60

/obj/item/toy/talking/codex_gigas/activation_message(mob/user)
	user.visible_message(
		"<span class='notice'>[user] presses the button on \the [src].</span>",
		"<span class='notice'>You press the button on \the [src].</span>",
		"<span class='notice'>You hear a soft click.</span>")

/obj/item/toy/talking/codex_gigas/generate_messages()
	var/datum/devilinfo/devil = randomDevilInfo()
	var/list/messages = list()
	messages += "Some fun facts about: [devil.truename]"
	messages += "[lawlorify[LORE][devil.bane]]"
	messages += "[lawlorify[LORE][devil.obligation]]"
	messages += "[lawlorify[LORE][devil.ban]]"
	messages += "[lawlorify[LORE][devil.banish]]"
	return messages

/obj/item/toy/talking/owl
	name = "owl action figure"
	desc = "An action figure modeled after 'The Owl', defender of justice."
	icon_state = "owlprize"
	messages = list("You won't get away this time, Griffin!", "Stop right there, criminal!", "Hoot! Hoot!", "I am the night!")
	chattering = TRUE
	phomeme = "owl"

/obj/item/toy/talking/griffin
	name = "griffin action figure"
	desc = "An action figure modeled after 'The Griffin', criminal mastermind."
	icon_state = "griffinprize"
	messages = list("You can't stop me, Owl!", "My plan is flawless! The vault is mine!", "Caaaawwww!", "You will never catch me!")
	chattering = TRUE
	phomeme = "griffin"

/obj/item/toy/talking/skeleton
	name = "skeleton action figure"
	desc = "An action figure modeled after 'Oh-cee', the original content \
		skeleton.\nNot suitable for infants or assistants under 36 months \
		of age."
	icon_state = "skeletonprize"
	attack_verb = list("boned", "dunked on", "worked down to the bone")
	chattering = TRUE

	var/list/regular_messages = list(
		"Why was the skeleton such a bad liar? \
			Because you can see right through him!",
		"When does a skeleton laugh? When something tickles his funny bone!",
		"Why couldn't the skeleton win the beauty contest? \
			 Because he had no body!",
		"What do you call a skeleton in the winter? A numbskull!",
		"What did the skeleton say before eating? Bone appetit!",
		"What type of art do skeletons like? Skulltures!",
		"What instrument do skeletons play? The trom-bone!",
		"Why are skeletons always so calm? \
			Because nothing gets under their skin!",
		"How did the skeleton know it was going to rain? \
			He could feel it in his bones.",
		"Why did the skeleton go to the hospital? \
			To get his ghoul stones removed.",
		"Why can't skeletons play music in churches? \
			Because they have no organs.",
		"There's a skeleton inside everyone! Except slime people I guess...",
		"The birds are too busy to notice me acting in the shadows!",
		"Giraffes have the same number of bones in their necks as humans. \
			You should never trust a giraffe.",
		"When I meet a dog in the street, I always offer it a bone!",
		"In corsetry, a bone is one of the rigid parts of a corset that \
			forms its frame and gives it rigidity.",
		"A person who plays the trombone is called a trombonist or \
			trombone player.",
		"Remember, compromise is for those without backbones!",
		"If you go up to the captain and say the word 'bone' repeatedly, \
			eventually he'll brig you.",
		"Yo ho ho, shiver me bones!",
		"So what you're saying is, you only love me for my legs?",
		"You will never again find socks that match!",
		"BONES! BONES! BONES!",
		"Bones absorb x-rays, which is why radiation gives you superpowers.",
		"Oh-cee! The ORIGINAL CONTENT SKELETON. Suitable for ages 36 months \
			and up.",
		"I just don't have the heart to judge you.",
		"I don't have the stomach for this.",
		"I'm a fighter, not a liver.",
		"How can I see without eyeballs?",
		"Ask your parents about 'boning', before you get pregnant.",
		"Remember, a dog is for life, not just for christmas.")

/obj/item/toy/talking/skeleton/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is trying to commit suicide with [src].</span>")

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.set_species(/datum/species/skeleton)

	toy_talk(user, "RATTLE ME BONES")

	user.Stun(5)
	sleep(20)
	return OXYLOSS

/obj/item/toy/talking/skeleton/generate_messages()
	return list(pick(regular_messages))

/obj/item/toy/talking/skeleton/toy_talk(user, message)
	phomeme = pick("sans", "papyrus")

	span = "danger [phomeme]"
	..()

/*
|| A Deck of Cards for playing various games of chance ||
*/



/obj/item/toy/cards
	resistance_flags = FLAMMABLE
	obj_integrity = 50
	max_integrity = 50
	var/parentdeck = null
	var/deckstyle = "nanotrasen"
	var/card_hitsound = null
	var/card_force = 0
	var/card_throwforce = 0
	var/card_throw_speed = 3
	var/card_throw_range = 7
	var/list/card_attack_verb = list("attacked")

/obj/item/toy/cards/proc/apply_card_vars(obj/item/toy/cards/newobj, obj/item/toy/cards/sourceobj) // Applies variables for supporting multiple types of card deck
	if(!istype(sourceobj))
		return

/obj/item/toy/cards/deck
	name = "deck of cards"
	desc = "A deck of space-grade playing cards."
	icon = 'icons/obj/toy.dmi'
	deckstyle = "nanotrasen"
	icon_state = "deck_nanotrasen_full"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
	var/obj/machinery/computer/holodeck/holo = null // Holodeck cards should not be infinite
	var/list/cards = list()

/obj/item/toy/cards/deck/New()
	..()
	icon_state = "deck_[deckstyle]_full"
	for(var/i = 2; i <= 10; i++)
		cards += "[i] of Hearts"
		cards += "[i] of Spades"
		cards += "[i] of Clubs"
		cards += "[i] of Diamonds"
	cards += "King of Hearts"
	cards += "King of Spades"
	cards += "King of Clubs"
	cards += "King of Diamonds"
	cards += "Queen of Hearts"
	cards += "Queen of Spades"
	cards += "Queen of Clubs"
	cards += "Queen of Diamonds"
	cards += "Jack of Hearts"
	cards += "Jack of Spades"
	cards += "Jack of Clubs"
	cards += "Jack of Diamonds"
	cards += "Ace of Hearts"
	cards += "Ace of Spades"
	cards += "Ace of Clubs"
	cards += "Ace of Diamonds"


/obj/item/toy/cards/deck/attack_hand(mob/user)
	if(user.lying)
		return
	var/choice = null
	if(cards.len == 0)
		to_chat(user, "<span class='warning'>There are no more cards to draw!</span>")
		return
	var/obj/item/toy/cards/singlecard/H = new/obj/item/toy/cards/singlecard(user.loc)
	if(holo)
		holo.spawned += H // track them leaving the holodeck
	choice = cards[1]
	H.cardname = choice
	H.parentdeck = src
	var/O = src
	H.apply_card_vars(H,O)
	src.cards -= choice
	H.pickup(user)
	user.put_in_hands(H)
	user.visible_message("[user] draws a card from the deck.", "<span class='notice'>You draw a card from the deck.</span>")
	update_icon()

/obj/item/toy/cards/deck/update_icon()
	if(cards.len > 26)
		icon_state = "deck_[deckstyle]_full"
	else if(cards.len > 10)
		icon_state = "deck_[deckstyle]_half"
	else if(cards.len > 0)
		icon_state = "deck_[deckstyle]_low"
	else if(cards.len == 0)
		icon_state = "deck_[deckstyle]_empty"

/obj/item/toy/cards/deck/attack_self(mob/user)
	if(cooldown < world.time - 50)
		cards = shuffle(cards)
		playsound(user, 'sound/items/cardshuffle.ogg', 50, 1)
		user.visible_message("[user] shuffles the deck.", "<span class='notice'>You shuffle the deck.</span>")
		cooldown = world.time

/obj/item/toy/cards/deck/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/cards/singlecard))
		var/obj/item/toy/cards/singlecard/SC = I
		if(SC.parentdeck == src)
			if(!user.unEquip(SC))
				to_chat(user, "<span class='warning'>The card is stuck to your hand, you can't add it to the deck!</span>")
				return
			cards += SC.cardname
			user.visible_message("[user] adds a card to the bottom of the deck.","<span class='notice'>You add the card to the bottom of the deck.</span>")
			qdel(SC)
		else
			to_chat(user, "<span class='warning'>You can't mix cards from other decks!</span>")
		update_icon()
	else if(istype(I, /obj/item/toy/cards/cardhand))
		var/obj/item/toy/cards/cardhand/CH = I
		if(CH.parentdeck == src)
			if(!user.unEquip(CH))
				to_chat(user, "<span class='warning'>The hand of cards is stuck to your hand, you can't add it to the deck!</span>")
				return
			cards += CH.currenthand
			user.visible_message("[user] puts their hand of cards in the deck.", "<span class='notice'>You put the hand of cards in the deck.</span>")
			qdel(CH)
		else
			to_chat(user, "<span class='warning'>You can't mix cards from other decks!</span>")
		update_icon()
	else
		return ..()

/obj/item/toy/cards/deck/MouseDrop(atom/over_object)
	var/mob/living/M = usr
	if(!istype(M) || usr.incapacitated() || usr.lying)
		return
	if(Adjacent(usr))
		if(over_object == M && loc != M)
			M.put_in_hands(src)
			to_chat(usr, "<span class='notice'>You pick up the deck.</span>")

		else if(istype(over_object, /obj/screen/inventory/hand))
			var/obj/screen/inventory/hand/H = over_object
			if(!remove_item_from_storage(M))
				M.unEquip(src)
			M.put_in_hand(src, H.held_index)
			to_chat(usr, "<span class='notice'>You pick up the deck.</span>")

	else
		to_chat(usr, "<span class='warning'>You can't reach it from here!</span>")



/obj/item/toy/cards/cardhand
	name = "hand of cards"
	desc = "A number of cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nanotrasen_hand2"
	w_class = WEIGHT_CLASS_TINY
	var/list/currenthand = list()
	var/choice = null


/obj/item/toy/cards/cardhand/attack_self(mob/user)
	user.set_machine(src)
	interact(user)

/obj/item/toy/cards/cardhand/interact(mob/user)
	var/dat = "You have:<BR>"
	for(var/t in currenthand)
		dat += "<A href='?src=\ref[src];pick=[t]'>A [t].</A><BR>"
	dat += "Which card will you remove next?"
	var/datum/browser/popup = new(user, "cardhand", "Hand of Cards", 400, 240)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(dat)
	popup.open()


/obj/item/toy/cards/cardhand/Topic(href, href_list)
	if(..())
		return
	if(usr.stat || !ishuman(usr) || !usr.canmove)
		return
	var/mob/living/carbon/human/cardUser = usr
	var/O = src
	if(href_list["pick"])
		if (cardUser.is_holding(src))
			var/choice = href_list["pick"]
			var/obj/item/toy/cards/singlecard/C = new/obj/item/toy/cards/singlecard(cardUser.loc)
			src.currenthand -= choice
			C.parentdeck = src.parentdeck
			C.cardname = choice
			C.apply_card_vars(C,O)
			C.pickup(cardUser)
			cardUser.put_in_hands(C)
			cardUser.visible_message("<span class='notice'>[cardUser] draws a card from [cardUser.p_their()] hand.</span>", "<span class='notice'>You take the [C.cardname] from your hand.</span>")

			interact(cardUser)
			if(src.currenthand.len < 3)
				src.icon_state = "[deckstyle]_hand2"
			else if(src.currenthand.len < 4)
				src.icon_state = "[deckstyle]_hand3"
			else if(src.currenthand.len < 5)
				src.icon_state = "[deckstyle]_hand4"
			if(src.currenthand.len == 1)
				var/obj/item/toy/cards/singlecard/N = new/obj/item/toy/cards/singlecard(src.loc)
				N.parentdeck = src.parentdeck
				N.cardname = src.currenthand[1]
				N.apply_card_vars(N,O)
				cardUser.unEquip(src)
				N.pickup(cardUser)
				cardUser.put_in_hands(N)
				to_chat(cardUser, "<span class='notice'>You also take [currenthand[1]] and hold it.</span>")
				cardUser << browse(null, "window=cardhand")
				qdel(src)
		return

/obj/item/toy/cards/cardhand/attackby(obj/item/toy/cards/singlecard/C, mob/living/user, params)
	if(istype(C))
		if(C.parentdeck == src.parentdeck)
			src.currenthand += C.cardname
			user.unEquip(C)
			user.visible_message("[user] adds a card to [user.p_their()] hand.", "<span class='notice'>You add the [C.cardname] to your hand.</span>")
			interact(user)
			if(currenthand.len > 4)
				src.icon_state = "[deckstyle]_hand5"
			else if(currenthand.len > 3)
				src.icon_state = "[deckstyle]_hand4"
			else if(currenthand.len > 2)
				src.icon_state = "[deckstyle]_hand3"
			qdel(C)
		else
			to_chat(user, "<span class='warning'>You can't mix cards from other decks!</span>")
	else
		return ..()

/obj/item/toy/cards/cardhand/apply_card_vars(obj/item/toy/cards/newobj,obj/item/toy/cards/sourceobj)
	..()
	newobj.deckstyle = sourceobj.deckstyle
	newobj.icon_state = "[deckstyle]_hand2" // Another dumb hack, without this the hand is invisible (or has the default deckstyle) until another card is added.
	newobj.card_hitsound = sourceobj.card_hitsound
	newobj.card_force = sourceobj.card_force
	newobj.card_throwforce = sourceobj.card_throwforce
	newobj.card_throw_speed = sourceobj.card_throw_speed
	newobj.card_throw_range = sourceobj.card_throw_range
	newobj.card_attack_verb = sourceobj.card_attack_verb
	newobj.resistance_flags = sourceobj.resistance_flags

/obj/item/toy/cards/singlecard
	name = "card"
	desc = "a card"
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_nanotrasen_down"
	w_class = WEIGHT_CLASS_TINY
	var/cardname = null
	var/flipped = 0
	pixel_x = -5


/obj/item/toy/cards/singlecard/examine(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/cardUser = user
		if(cardUser.is_holding(src))
			cardUser.visible_message("[cardUser] checks [cardUser.p_their()] card.", "<span class='notice'>The card reads: [cardname]</span>")
		else
			to_chat(cardUser, "<span class='warning'>You need to have the card in your hand to check it!</span>")


/obj/item/toy/cards/singlecard/verb/Flip()
	set name = "Flip Card"
	set category = "Object"
	set src in range(1)
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(!flipped)
		src.flipped = 1
		if (cardname)
			src.icon_state = "sc_[cardname]_[deckstyle]"
			src.name = src.cardname
		else
			src.icon_state = "sc_Ace of Spades_[deckstyle]"
			src.name = "What Card"
		src.pixel_x = 5
	else if(flipped)
		src.flipped = 0
		src.icon_state = "singlecard_down_[deckstyle]"
		src.name = "card"
		src.pixel_x = -5

/obj/item/toy/cards/singlecard/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/cards/singlecard/))
		var/obj/item/toy/cards/singlecard/C = I
		if(C.parentdeck == src.parentdeck)
			var/obj/item/toy/cards/cardhand/H = new/obj/item/toy/cards/cardhand(user.loc)
			H.currenthand += C.cardname
			H.currenthand += src.cardname
			H.parentdeck = C.parentdeck
			H.apply_card_vars(H,C)
			user.unEquip(C)
			H.pickup(user)
			user.put_in_active_hand(H)
			to_chat(user, "<span class='notice'>You combine the [C.cardname] and the [src.cardname] into a hand.</span>")
			qdel(C)
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You can't mix cards from other decks!</span>")

	if(istype(I, /obj/item/toy/cards/cardhand/))
		var/obj/item/toy/cards/cardhand/H = I
		if(H.parentdeck == parentdeck)
			H.currenthand += cardname
			user.unEquip(src)
			user.visible_message("[user] adds a card to [user.p_their()] hand.", "<span class='notice'>You add the [cardname] to your hand.</span>")
			H.interact(user)
			if(H.currenthand.len > 4)
				H.icon_state = "[deckstyle]_hand5"
			else if(H.currenthand.len > 3)
				H.icon_state = "[deckstyle]_hand4"
			else if(H.currenthand.len > 2)
				H.icon_state = "[deckstyle]_hand3"
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You can't mix cards from other decks!</span>")
	else
		return ..()

/obj/item/toy/cards/singlecard/attack_self(mob/user)
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	Flip()

/obj/item/toy/cards/singlecard/apply_card_vars(obj/item/toy/cards/singlecard/newobj,obj/item/toy/cards/sourceobj)
	..()
	newobj.deckstyle = sourceobj.deckstyle
	newobj.icon_state = "singlecard_down_[deckstyle]" // Without this the card is invisible until flipped. It's an ugly hack, but it works.
	newobj.card_hitsound = sourceobj.card_hitsound
	newobj.hitsound = newobj.card_hitsound
	newobj.card_force = sourceobj.card_force
	newobj.force = newobj.card_force
	newobj.card_throwforce = sourceobj.card_throwforce
	newobj.throwforce = newobj.card_throwforce
	newobj.card_throw_speed = sourceobj.card_throw_speed
	newobj.throw_speed = newobj.card_throw_speed
	newobj.card_throw_range = sourceobj.card_throw_range
	newobj.throw_range = newobj.card_throw_range
	newobj.card_attack_verb = sourceobj.card_attack_verb
	newobj.attack_verb = newobj.card_attack_verb


/*
|| Syndicate playing cards, for pretending you're Gambit and playing poker for the nuke disk. ||
*/

/obj/item/toy/cards/deck/syndicate
	name = "suspicious looking deck of cards"
	desc = "A deck of space-grade playing cards. They seem unusually rigid."
	deckstyle = "syndicate"
	card_hitsound = 'sound/weapons/bladeslice.ogg'
	card_force = 5
	card_throwforce = 10
	card_throw_speed = 3
	card_throw_range = 7
	card_attack_verb = list("attacked", "sliced", "diced", "slashed", "cut")
	resistance_flags = 0

/*
 * Fake nuke
 */

/obj/item/toy/nuke
	name = "\improper Nuclear Fission Explosive toy"
	desc = "A plastic model of a Nuclear Fission Explosive."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoyidle"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/nuke/attack_self(mob/user)
	if (cooldown < world.time)
		cooldown = world.time + 1800 //3 minutes
		user.visible_message("<span class='warning'>[user] presses a button on [src].</span>", "<span class='notice'>You activate [src], it plays a loud noise!</span>", "<span class='italics'>You hear the click of a button.</span>")
		sleep(5)
		icon_state = "nuketoy"
		playsound(src, 'sound/machines/Alarm.ogg', 100, 0, surround = 0)
		sleep(135)
		icon_state = "nuketoycool"
		sleep(cooldown - world.time)
		icon_state = "nuketoyidle"
	else
		var/timeleft = (cooldown - world.time)
		to_chat(user, "<span class='alert'>Nothing happens, and '</span>[round(timeleft/10)]<span class='alert'>' appears on a small display.</span>")

/*
 * Fake meteor
 */

/obj/item/toy/minimeteor
	name = "\improper Mini-Meteor"
	desc = "Relive the excitement of a meteor shower! SweetMeat-eor. Co is not responsible for any injuries, headaches or hearing loss caused by Mini-Meteor."
	icon = 'icons/obj/toy.dmi'
	icon_state = "minimeteor"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/minimeteor/throw_impact(atom/hit_atom)
	if(!..())
		playsound(src, 'sound/effects/meteorimpact.ogg', 40, 1)
		for(var/mob/M in urange(10, src))
			if(!M.stat && !isAI(M))
				shake_camera(M, 3, 1)
		qdel(src)

/*
 * Carp plushie
 */

/obj/item/toy/carpplushie
	name = "space carp plushie"
	desc = "An adorable stuffed toy that resembles a space carp."
	icon = 'icons/obj/toy.dmi'
	icon_state = "carpplushie"
	item_state = "carp_plushie"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bitten", "eaten", "fin slapped")
	resistance_flags = FLAMMABLE
	var/bitesound = 'sound/weapons/bite.ogg'

//Attack mob
/obj/item/toy/carpplushie/attack(mob/M, mob/user)
	playsound(loc, bitesound, 20, 1)	//Play bite sound in local area
	return ..()

//Attack self
/obj/item/toy/carpplushie/attack_self(mob/user)
	playsound(src.loc, bitesound, 20, 1)
	to_chat(user, "<span class='notice'>You pet [src]. D'awww.</span>")
	return ..()

/*
 * Toy big red button
 */
/obj/item/toy/redbutton
	name = "big red button"
	desc = "A big, plastic red button. Reads 'From HonkCo Pranks?' on the back."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/redbutton/attack_self(mob/user)
	if (cooldown < world.time)
		cooldown = (world.time + 300) // Sets cooldown at 30 seconds
		user.visible_message("<span class='warning'>[user] presses the big red button.</span>", "<span class='notice'>You press the button, it plays a loud noise!</span>", "<span class='italics'>The button clicks loudly.</span>")
		playsound(src, 'sound/effects/explosionfar.ogg', 50, 0, surround = 0)
		for(var/mob/M in urange(10, src)) // Checks range
			if(!M.stat && !isAI(M)) // Checks to make sure whoever's getting shaken is alive/not the AI
				sleep(8) // Short delay to match up with the explosion sound
				shake_camera(M, 2, 1) // Shakes player camera 2 squares for 1 second.

	else
		to_chat(user, "<span class='alert'>Nothing happens.</span>")

/*
 * Snowballs
 */

/obj/item/toy/snowball
	name = "snowball"
	desc = "A compact ball of snow. Good for throwing at people."
	icon = 'icons/obj/toy.dmi'
	icon_state = "snowball"
	throwforce = 12 //pelt your enemies to death with lumps of snow

/obj/item/toy/snowball/afterattack(atom/target as mob|obj|turf|area, mob/user)
	user.drop_item()
	src.throw_at(target, throw_range, throw_speed)

/obj/item/toy/snowball/throw_impact(atom/hit_atom)
	if(!..())
		playsound(src, 'sound/effects/pop.ogg', 20, 1)
		qdel(src)

/*
 * Beach ball
 */
/obj/item/toy/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "beachball"
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets

/obj/item/toy/beach_ball/afterattack(atom/target as mob|obj|turf|area, mob/user)
	user.drop_item()
	src.throw_at(target, throw_range, throw_speed)

/*
 * Xenomorph action figure
 */

/obj/item/toy/toy_xeno
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_xeno"
	name = "xenomorph action figure"
	desc = "MEGA presents the new Xenos Isolated action figure! Comes complete with realistic sounds! Pull back string to use."
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/toy_xeno/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = (world.time + 50) //5 second cooldown
		user.visible_message("<span class='notice'>[user] pulls back the string on [src].</span>")
		icon_state = "[initial(icon_state)]_used"
		sleep(5)
		audible_message("<span class='danger'>[bicon(src)] Hiss!</span>")
		var/list/possible_sounds = list('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg')
		var/chosen_sound = pick(possible_sounds)
		playsound(get_turf(src), chosen_sound, 50, 1)
		spawn(45)
			if(src)
				icon_state = "[initial(icon_state)]"
	else
		to_chat(user, "<span class='warning'>The string on [src] hasn't rewound all the way!</span>")
		return

// TOY MOUSEYS :3 :3 :3

/obj/item/toy/cattoy
	name = "toy mouse"
	desc = "A colorful toy mouse!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_mouse"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
	resistance_flags = FLAMMABLE


/*
 * Action Figures
 */

/obj/item/toy/figure
	name = "Non-Specific Action Figure action figure"
	desc = null
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoy"
	var/cooldown = 0
	var/toysay = "What the fuck did you do?"
	var/toysound = 'sound/machines/click.ogg'

/obj/item/toy/figure/New()
    desc = "A \"Space Life\" brand [src]."
    ..()

/obj/item/toy/figure/attack_self(mob/user as mob)
	if(cooldown <= world.time)
		cooldown = world.time + 50
		to_chat(user, "<span class='notice'>The [src] says \"[toysay]\"</span>")
		playsound(user, toysound, 20, 1)

/obj/item/toy/figure/cmo
	name = "Chief Medical Officer action figure"
	icon_state = "cmo"
	toysay = "Suit sensors!"

/obj/item/toy/figure/assistant
	name = "Assistant action figure"
	icon_state = "assistant"
	toysay = "Grey tide world wide!"

/obj/item/toy/figure/atmos
	name = "Atmospheric Technician action figure"
	icon_state = "atmos"
	toysay = "Glory to Atmosia!"

/obj/item/toy/figure/bartender
	name = "Bartender action figure"
	icon_state = "bartender"
	toysay = "Where is Pun Pun?"

/obj/item/toy/figure/borg
	name = "Cyborg action figure"
	icon_state = "borg"
	toysay = "I. LIVE. AGAIN."
	toysound = 'sound/voice/liveagain.ogg'

/obj/item/toy/figure/botanist
	name = "Botanist action figure"
	icon_state = "botanist"
	toysay = "Blaze it!"

/obj/item/toy/figure/captain
	name = "Captain action figure"
	icon_state = "captain"
	toysay = "Any heads of staff?"

/obj/item/toy/figure/cargotech
	name = "Cargo Technician action figure"
	icon_state = "cargotech"
	toysay = "For Cargonia!"

/obj/item/toy/figure/ce
	name = "Chief Engineer action figure"
	icon_state = "ce"
	toysay = "Wire the solars!"

/obj/item/toy/figure/chaplain
	name = "Chaplain action figure"
	icon_state = "chaplain"
	toysay = "Praise Space Jesus!"

/obj/item/toy/figure/chef
	name = "Chef action figure"
	icon_state = "chef"
	toysay = " I'll make you into a burger!"

/obj/item/toy/figure/chemist
	name = "Chemist action figure"
	icon_state = "chemist"
	toysay = "Get your pills!"

/obj/item/toy/figure/clown
	name = "Clown action figure"
	icon_state = "clown"
	toysay = "Honk!"
	toysound = 'sound/items/bikehorn.ogg'

/obj/item/toy/figure/ian
	name = "Ian action figure"
	icon_state = "ian"
	toysay = "Arf!"

/obj/item/toy/figure/detective
	name = "Detective action figure"
	icon_state = "detective"
	toysay = "This airlock has grey jumpsuit and insulated glove fibers on it."

/obj/item/toy/figure/dsquad
	name = "Death Squad Officer action figure"
	icon_state = "dsquad"
	toysay = "Kill em all!"

/obj/item/toy/figure/engineer
	name = "Engineer action figure"
	icon_state = "engineer"
	toysay = "Oh god, the singularity is loose!"

/obj/item/toy/figure/geneticist
	name = "Geneticist action figure"
	icon_state = "geneticist"
	toysay = "Smash!"

/obj/item/toy/figure/hop
	name = "Head of Personnel action figure"
	icon_state = "hop"
	toysay = "Giving out all access!"

/obj/item/toy/figure/hos
	name = "Head of Security action figure"
	icon_state = "hos"
	toysay = "Go ahead, make my day."

/obj/item/toy/figure/qm
	name = "Quartermaster action figure"
	icon_state = "qm"
	toysay = "Please sign this form in triplicate and we will see about geting you a welding mask within 3 business days."

/obj/item/toy/figure/janitor
	name = "Janitor action figure"
	icon_state = "janitor"
	toysay = "Look at the signs, you idiot."

/obj/item/toy/figure/lawyer
	name = "Lawyer action figure"
	icon_state = "lawyer"
	toysay = "My client is a dirty traitor!"

/obj/item/toy/figure/librarian
	name = "Librarian action figure"
	icon_state = "librarian"
	toysay = "One day while..."

/obj/item/toy/figure/md
	name = "Medical Doctor action figure"
	icon_state = "md"
	toysay = "The patient is already dead!"

/obj/item/toy/figure/mime
	name = "Mime action figure"
	icon_state = "mime"
	toysay = "..."
	toysound = null

/obj/item/toy/figure/miner
	name = "Shaft Miner action figure"
	icon_state = "miner"
	toysay = "COLOSSUS RIGHT OUTSIDE THE BASE!"

/obj/item/toy/figure/ninja
	name = "Ninja action figure"
	icon_state = "ninja"
	toysay = "Oh god! Stop shooting, I'm friendly!"

/obj/item/toy/figure/wizard
	name = "Wizard action figure"
	icon_state = "wizard"
	toysay = "Ei Nath!"
	toysound = 'sound/magic/Disintegrate.ogg'

/obj/item/toy/figure/rd
	name = "Research Director action figure"
	icon_state = "rd"
	toysay = "Blowing all of the borgs!"

/obj/item/toy/figure/roboticist
	name = "Roboticist action figure"
	icon_state = "roboticist"
	toysay = "Big stompy mechs!"
	toysound = 'sound/mecha/mechstep.ogg'

/obj/item/toy/figure/scientist
	name = "Scientist action figure"
	icon_state = "scientist"
	toysay = "I call toxins."
	toysound = 'sound/effects/explosionfar.ogg'

/obj/item/toy/figure/syndie
	name = "Nuclear Operative action figure"
	icon_state = "syndie"
	toysay = "Get that fucking disk!"

/obj/item/toy/figure/secofficer
	name = "Security Officer action figure"
	icon_state = "secofficer"
	toysay = "I am the law!"
	toysound = 'sound/misc/warneverchanges.ogg'

/obj/item/toy/figure/virologist
	name = "Virologist action figure"
	icon_state = "virologist"
	toysay = "The cure is potassium!"

/obj/item/toy/figure/warden
	name = "Warden action figure"
	icon_state = "warden"
	toysay = "Seventeen minutes for coughing at an officer!"


/obj/item/toy/dummy
	name = "ventriloquist dummy"
	desc = "It's a dummy, dummy."
	icon = 'icons/obj/toy.dmi'
	icon_state = "assistant"
	item_state = "doll"
	var/doll_name = "Dummy"

//Add changing looks when i feel suicidal about making 20 inhands for these.
/obj/item/toy/dummy/attack_self(mob/user)
	var/new_name = stripped_input(usr,"What would you like to name the dummy?","Input a name",doll_name,MAX_NAME_LEN)
	if(!new_name)
		return
	doll_name = new_name
	to_chat(user, "You name the dummy as \"[doll_name]\"")
	name = "[initial(name)] - [doll_name]"

/obj/item/toy/dummy/talk_into(atom/movable/M, message, channel, list/spans)
	log_say("[key_name(M)] : through dummy : [message]")
	say(message)
	return NOPASS

/obj/item/toy/dummy/GetVoice()
	return doll_name
