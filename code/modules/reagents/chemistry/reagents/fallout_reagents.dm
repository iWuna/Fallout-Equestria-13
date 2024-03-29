/datum/reagent/stimpackium
	name = "Stimpackium"
	id = "stimpackium"
	color = "#FF0033"
	description = "Strange mixture for healing wounds."

datum/reagent/stimpackium/on_mob_life(mob/living/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if( STIMPACKIMMUNE in H.dna.species.species_traits)
			M.adjustFireLoss(-5.10*2.5*REM, 0)
			M.adjustBruteLoss(-5.10*2.5*REM, 0)
			return 1

	M.adjustFireLoss(-10.10*2.5*REM, 0)
	M.adjustBruteLoss(-10.10*2.5*REM, 0)
	. = 1

/datum/reagent/supstimpackium
	name = "SuperStimpackium"
	id = "supstimpackium"
	color = "#FF3300"
	description = "Strange mixture for healing wounds."

datum/reagent/supstimpackium/on_mob_life(mob/living/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if( STIMPACKIMMUNE in H.dna.species.species_traits)
			return .
	M.adjustFireLoss(-10.70*2.5*REM, 0)
	M.adjustBruteLoss(-10.70*2.5*REM, 0)
	. = 1

//Unrefined --for ELITE mechanics
/datum/reagent/stimpackium_oxy
	name = "Stimpackium"
	id = "stimpackium_oxy"
	color = "#FF0033"
	description = "Strange mixture for healing wounds."

datum/reagent/stimpackium_oxy/on_mob_life(mob/living/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if( STIMPACKIMMUNE in H.dna.species.species_traits)
			return .
	M.adjustFireLoss(-0.5*REM, 0)
	M.adjustBruteLoss(-0.5*REM, 0)
	M.adjustToxLoss(1.10*REM, 0)
	. = 1

/datum/reagent/supstimpackium_oxy
	name = "SuperStimpackium"
	id = "supstimpackium_oxy"
	color = "#FF3300"
	description = "Strange mixture for healing wounds."

datum/reagent/supstimpackium_oxy/on_mob_life(mob/living/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if( STIMPACKIMMUNE in H.dna.species.species_traits)
			return .
	M.adjustFireLoss(-0.80*REM, 0)
	M.adjustBruteLoss(-0.80*REM, 0)
	M.adjustToxLoss(1.6*REM, 0)
	. = 1
///unrefined


/datum/reagent/mentats
	name = "Mentats"
	id = "mentats"
	description = "Helps you, if you stupid. Possible..."
	color = "#2222FF"
	overdose_threshold = 60

/datum/reagent/mentats/on_mob_life(mob/living/M)
	M.adjustBrainLoss(-3*REM)
	..()
	. = 1

/datum/reagent/mentats/overdose_process(mob/living/M)
	M.adjustBrainLoss(7*REM)
	..()
	. = 1

/datum/reagent/broc_extract
	name = "Broc extract"
	id = "broc_extract"
	description = "Smashed flower. Can help with minor burns"
	color = "#2222FF"
	overdose_threshold = 10

/datum/reagent/broc_extract/on_mob_life(mob/living/M)
	M.adjustFireLoss(-0.20*REM, 0)
	..()
	. = 1

/datum/reagent/broc_extract/overdose_process(mob/living/M)
	M.set_drugginess(15)
	if(isturf(M.loc) && !isspaceturf(M.loc))
		if(M.canmove)
			if(prob(10)) step(M, pick(cardinal))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()
	if(M.hallucination < volume && prob(20))
		M.hallucination += 5
	..()
	. = 1

/datum/reagent/xander_extract
	name = "Xander extract"
	id = "xander_extract"
	description = "Grinded root. Helps you if you minor bruised"
	color = "#2222FF"
	overdose_threshold = 10

/datum/reagent/xander_extract/on_mob_life(mob/living/M)
	M.adjustBruteLoss(-0.20*REM, 0)
	..()
	. = 1

/datum/reagent/xander_extract/overdose_process(mob/living/M)
	M.set_drugginess(15)
	if(isturf(M.loc) && !isspaceturf(M.loc))
		if(M.canmove)
			if(prob(10)) step(M, pick(cardinal))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()
	if(M.hallucination < volume && prob(20))
		M.hallucination += 5
	..()
	. = 1

/datum/reagent/improve_reagent
	name = "Improver reagent"
	id = "improve_reagent"
	description = "Does nothing, but can improve other reagents"
	color = "#000011"

//foods and drinks

/datum/reagent/water/sunset
	name = "Sunset Sarsaparilla"
	id = "sunset"
	description = "A traditional radiation-free carbonated beverage of a root-beer-type.<br>Tastes like sunshine!"
	color = "#5555ffaa" // rgb: 170, 170, 170, 77 (alpha)
	//water_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/water/nuka
	name = "Sparkle-cola"
	id = "nuka"
	description = "The most popular flavored soft drink in the Equestria before the Great War.<br>It was preserved in a fairly pristine state."
	color = "#ff9955aa" // rgb: 170, 170, 170, 77 (alpha)
	//water_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/water/vim
	name = "VIM"
	id = "vim"
	description = "Vim! Pop Incorporated was founded in 1931, initially being sold as a health tonic. It wasn't as popular as Sparkle-Cola, however in Maine it was more widely consumed than its rival. Vim was even referred to as a state tradition and about to become the official state drink of Maine; however, during the process of making this official, legal situations forced the company to back off its marketing."
	color = "#ff9966aa" // rgb: 170, 170, 170, 77 (alpha)
	//water_factor = 5 * REAGENTS_METABOLISM

/datum/reagent/water/irradiated
	name = "Irradiated water"
	id = "radwater"
	description = "Don`t drink it, if you love your hairs"
	color = "#88ff8877"

/datum/reagent/water/irradiated/on_mob_life(mob/living/M)
	M.adjustToxLoss(1.2*REM, 0)  //fix it after RadRebalance
	..()
	. = 1

/datum/reagent/water/fev
	name = "IMP"
	id = "fev"
	description = "The Impelled Metamorphosis Potion (I.M.P.), which later on came to be known as Taint, was developed by Twilight Sparkle herself. The goal of the project was to create an army of artificial Alicorns loyal to Equestria. The Alicorns would be far more powerful than a typical unicorn and possess the flight and cloud walking/cloud controlling abilities of a Pegasus and the fortitude of an Earth Pony."
	color = "#88ff8877"

/datum/reagent/water/fev/on_mob_life(mob/living/M)
	M.adjustToxLoss(12*REM, 0)  //fix it after RadRebalance
	..()
	. = 1