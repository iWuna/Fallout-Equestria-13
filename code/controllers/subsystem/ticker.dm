var/round_start_time = 0

var/datum/subsystem/ticker/ticker

/datum/subsystem/ticker
	name = "Ticker"
	init_order = 0

	priority = 200
	flags = SS_FIRE_IN_LOBBY|SS_KEEP_TIMING

	var/current_state = GAME_STATE_STARTUP	//state of current round (used by process()) Use the defines GAME_STATE_* !
	var/force_ending = 0					//Round was ended by admin intervention
	// If true, there is no lobby phase, the game starts immediately.
	var/start_immediately = FALSE

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/login_music							//music played in pregame lobby
	var/round_end_sound						//music/jingle played when the world reboots

	var/list/datum/mind/minds = list()		//The characters in the game. Used for objective tracking.

	var/list/syndicate_coalition = list()	//list of traitor-compatible factions
	var/list/factions = list()				//list of all factions
	var/list/availablefactions = list()		//list of factions with openings
	var/list/scripture_states = list(SCRIPTURE_DRIVER = TRUE, \
	SCRIPTURE_SCRIPT = FALSE, \
	SCRIPTURE_APPLICATION = FALSE, \
	SCRIPTURE_REVENANT = FALSE, \
	SCRIPTURE_JUDGEMENT = FALSE) //list of clockcult scripture states for announcements

	var/delay_end = 0						//if set true, the round will not restart on it's own

	var/triai = 0							//Global holder for Triumvirate
	var/tipped = 0							//Did we broadcast the tip of the day yet?
	var/selected_tip						// What will be the tip of the day?

	var/timeLeft = 1200						//pregame timer

	var/totalPlayers = 0					//used for pregame stats on statpanel
	var/totalPlayersReady = 0				//used for pregame stats on statpanel

	var/queue_delay = 0
	var/list/queued_players = list()		//used for join queues when the server exceeds the hard population cap

	var/obj/screen/cinematic = null			//used for station explosion cinematic

	var/maprotatechecked = 0

	var/news_report

/datum/subsystem/ticker/New()
	NEW_SS_GLOBAL(ticker)

	/*
	login_music = pickweight(list('sound/f13music/fo2_brotherhood.ogg' = 45, 'sound/f13music/fo2_outpost.ogg' =45, 'sound/f13music/fo2_city.ogg' =45, 'sound/f13music/fo2_village.ogg' =5, 'sound/f13music/fo2_vats.ogg' =5)) // choose title music!
	if(SSevent.holidays && SSevent.holidays[APRIL_FOOLS])
		login_music = 'sound/f13music/mysterious_stranger.ogg'
	*/

	login_music = pickweight(list('sound/f13music/LPBOBD.ogg' = 45, 'sound/f13music/SBP.ogg' =45, 'sound/f13music/WWFLY.ogg' = 45, 'sound/f13music/WWMM.ogg' =45, 'sound/f13music/LMC.ogg' = 45, 'sound/f13music/LB.ogg' =45))

	//login_music = 'sound/f13music/Johnny Guitar.ogg'

/datum/subsystem/ticker/Initialize(timeofday)
	if(!syndicate_code_phrase)
		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)
		syndicate_code_response	= generate_code_phrase()
	..()

/datum/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			timeLeft = config.lobby_countdown * 10
			to_chat(world, "<span class='boldnotice'>Welcome to [station_name()]!</span>")
			to_chat(world, "Please set up your character and select \"Ready\". The game will start in [config.lobby_countdown] seconds.")
			current_state = GAME_STATE_PREGAME
			for(var/client/C in clients)
				window_flash(C) //let them know lobby has opened up.

		if(GAME_STATE_PREGAME)
				//lobby stats for statpanels
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/new_player/player in player_list)
				++totalPlayers
				if(player.ready)
					++totalPlayersReady

			if(start_immediately)
				timeLeft = 0

			//countdown
			if(timeLeft < 0)
				return
			timeLeft -= wait

			if(timeLeft <= 300 && !tipped)
				send_tip_of_the_round()
				tipped = TRUE

			if(timeLeft <= 0)
				current_state = GAME_STATE_SETTING_UP

		if(GAME_STATE_SETTING_UP)
			if(!setup())
				//setup failed
				current_state = GAME_STATE_STARTUP

		if(GAME_STATE_PLAYING)
			mode.process(wait * 0.1)
			check_queue()
			check_maprotate()
			scripture_states = scripture_unlock_alert(scripture_states)

			if(!mode.explosion_in_progress && mode.check_finished() || force_ending)
				current_state = GAME_STATE_FINISHED
				toggle_ooc(1) // Turn it on
				declare_completion(force_ending)
				spawn(50)
					world.Reboot("Round ended.", "end_proper", "proper completion")

/datum/subsystem/ticker/proc/setup()
		//Create and announce mode
	var/list/datum/game_mode/runnable_modes
	if(master_mode == "random" || master_mode == "secret")
		runnable_modes = config.get_runnable_modes()

		if(master_mode == "secret")
			hide_mode = 1
			if(secret_force_mode != "secret")
				var/datum/game_mode/smode = config.pick_mode(secret_force_mode)
				if(!smode.can_start())
					message_admins("\blue Unable to force secret [secret_force_mode]. [smode.required_players] players and [smode.required_enemies] eligible antagonists needed.")
				else
					mode = smode

		if(!mode)
			if(!runnable_modes.len)
				to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
				return 0
			mode = pickweight(runnable_modes)

	else
		mode = config.pick_mode(master_mode)
		if(!mode.can_start())
			to_chat(world, "<B>Unable to start [mode.name].</B> Not enough players, [mode.required_players] players and [mode.required_enemies] eligible antagonists needed. Reverting to pre-game lobby.")
			qdel(mode)
			mode = null
			SSjob.ResetOccupations()
			return 0

	//Configure mode and assign player to special mode stuff
	var/can_continue = 0
	can_continue = src.mode.pre_setup()		//Choose antagonists
	SSjob.DivideOccupations() 				//Distribute jobs

	if(!Debug2)
		if(!can_continue)
			qdel(mode)
			mode = null
			to_chat(world, "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby.")
			SSjob.ResetOccupations()
			return 0
	else
		message_admins("<span class='notice'>DEBUG: Bypassing prestart checks...</span>")

	if(hide_mode)
		var/list/modes = new
		for (var/datum/game_mode/M in runnable_modes)
			modes += M.name
		modes = sortList(modes)
		to_chat(world, "<b>The gamemode is: secret!\
		Possibilities:</B> [english_list(modes)]")
	else
		mode.announce()

	current_state = GAME_STATE_PLAYING
	if(!config.ooc_during_round)
		toggle_ooc(0) // Turn it off
	round_start_time = world.time

	start_landmarks_list = shuffle(start_landmarks_list) //Shuffle the order of spawn points so they dont always predictably spawn bottom-up and right-to-left
	create_characters() //Create player characters and transfer them
	collect_minds()
	equip_characters()
	data_core.manifest()

	SSobjectives.setup_objectives()

	Master.RoundStart()

	to_chat(world, "<B><FONT color='#3c4438'>The following events shall be remembered under the code name of:<br><FONT color='#77ca00'>[station_name()]</FONT><br><FONT color='#3c4438'>Best of luck with your survival!</FONT></B>")
	to_chat(world, sound('sound/f13music/game_start.ogg'))

	if(SSevent.holidays)
		to_chat(world, "<font color='blue'>and...</font>")
		for(var/holidayname in SSevent.holidays)
			var/datum/holiday/holiday = SSevent.holidays[holidayname]
			to_chat(world, "<h4>[holiday.greet()]</h4>")


	spawn(0)//Forking here so we dont have to wait for this to finish
		mode.post_setup()
		//Cleanup some stuff
		/*
		for(var/obj/effect/landmark/start/S in landmarks_list)
			//Deleting Startpoints but we need the ai point to AI-ize people later
			if(S.name != "AI")
				qdel(S)
		*/
		var/list/adm = get_admin_counts()
		if(!adm["present"])
			send2irc("Server", "Round just started with no active admins online!")

	return 1

//Plus it provides an easy way to make cinematics for other events. Just use this as a template
/datum/subsystem/ticker/proc/station_explosion_cinematic(station_missed=0, override = null)
	if( cinematic )
		return	//already a cinematic in progress!

	for (var/datum/html_interface/hi in html_interfaces)
		hi.closeAll()
	//initialise our cinematic screen object
	cinematic = new /obj/screen{icon='icons/effects/station_explosion.dmi';icon_state="station_intact";layer=21;mouse_opacity=0;screen_loc="1,0";}(src)

	if(station_missed)
		for(var/mob/M in mob_list)
			M.notransform = TRUE //stop everything moving
			if(M.client)
				M.client.screen += cinematic	//show every client the cinematic
	else	//nuke kills everyone on z-level 1 to prevent "hurr-durr I survived"
		for(var/mob/M in mob_list)
			if(M.client)
				M.client.screen += cinematic
			if(M.stat != DEAD)
				var/turf/T = get_turf(M)
				if(T && T.z==1)
					M.death(0) //no mercy
				else
					M.notransform=TRUE //no moving for you

	//Now animate the cinematic
	switch(station_missed)
		if(NUKE_NEAR_MISS)	//nuke was nearby but (mostly) missed
			if( mode && !override )
				override = mode.name
			switch( override )
				if("nuclear emergency") //Nuke wasn't on station when it blew up
					flick("intro_nuke",cinematic)
					sleep(35)
					to_chat(world, sound('sound/effects/explosionfar.ogg'))
					flick("station_intact_fade_red",cinematic)
					cinematic.icon_state = "summary_nukefail"
				if("gang war") //Gang Domination (just show the override screen)
					cinematic.icon_state = "intro_malf_still"
					flick("intro_malf",cinematic)
					sleep(70)
				if("fake") //The round isn't over, we're just freaking people out for fun
					flick("intro_nuke",cinematic)
					sleep(35)
					to_chat(world, sound('sound/items/bikehorn.ogg'))
					flick("summary_selfdes",cinematic)
				else
					flick("intro_nuke",cinematic)
					sleep(35)
					to_chat(world, sound('sound/effects/explosionfar.ogg'))
					//flick("end",cinematic)


		if(NUKE_MISS_STATION || NUKE_SYNDICATE_BASE)	//nuke was nowhere nearby	//TODO: a really distant explosion animation
			sleep(50)
			to_chat(world, sound('sound/effects/explosionfar.ogg'))
		else	//station was destroyed
			if( mode && !override )
				override = mode.name
			switch( override )
				if("nuclear emergency") //Nuke Ops successfully bombed the station
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_explode_fade_red",cinematic)
					to_chat(world, sound('sound/effects/explosionfar.ogg'))
					cinematic.icon_state = "summary_nukewin"
				if("AI malfunction") //Malf (screen,explosion,summary)
					flick("intro_malf",cinematic)
					sleep(76)
					flick("station_explode_fade_red",cinematic)
					to_chat(world, sound('sound/effects/explosionfar.ogg'))
					cinematic.icon_state = "summary_malf"
				if("blob") //Station nuked (nuke,explosion,summary)
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_explode_fade_red",cinematic)
					to_chat(world, sound('sound/effects/explosionfar.ogg'))
					cinematic.icon_state = "summary_selfdes"
				if("no_core") //Nuke failed to detonate as it had no core
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_intact",cinematic)
					to_chat(world, sound('sound/ambience/signal.ogg'))
					sleep(100)
					if(cinematic)
						qdel(cinematic)
						cinematic = null
					for(var/mob/M in mob_list)
						M.notransform = FALSE
					return	//Faster exit, since nothing happened
				else //Station nuked (nuke,explosion,summary)
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_explode_fade_red", cinematic)
					to_chat(world, sound('sound/effects/explosionfar.ogg'))
					cinematic.icon_state = "summary_selfdes"
	//If its actually the end of the round, wait for it to end.
	//Otherwise if its a verb it will continue on afterwards.
	spawn(300)
		if(cinematic)
			qdel(cinematic)		//end the cinematic
		for(var/mob/M in mob_list)
			M.notransform = FALSE //gratz you survived
	return



/datum/subsystem/ticker/proc/create_characters()
	for(var/mob/new_player/player in player_list)
		if(player.ready && player.mind)
			joined_player_list += player.ckey
			if(player.mind.assigned_role=="AI")
				player.close_spawn_windows()
				player.AIize()
			else
				player.create_character()
				qdel(player)
		else
			player.new_player_panel()


/datum/subsystem/ticker/proc/collect_minds()
	for(var/mob/living/player in player_list)
		if(player.mind)
			ticker.minds += player.mind


/datum/subsystem/ticker/proc/equip_characters()
	for(var/mob/living/carbon/human/player in player_list)
		if(player && player.mind && player.mind.assigned_role)
			if(player.mind.assigned_role != player.mind.special_role)
				SSjob.EquipRank(player, player.mind.assigned_role, 0)

/datum/subsystem/ticker/proc/declare_completion()

	to_chat(world, "<BR><BR><BR><FONT size=3><B>The round has ended.</B></FONT>")

	SSobjectives.on_roundend()

	//Adds the del() log to world.log in a format condensable by the runtime condenser found in tools
	if(SSgarbage.didntgc.len)
		var/dellog = ""
		for(var/path in SSgarbage.didntgc)
			dellog += "Path : [path] \n"
			dellog += "Failures : [SSgarbage.didntgc[path]] \n"
		world.log << dellog

	//Collects persistence features
	SSpersistence.CollectData()
	return 1

/datum/subsystem/ticker/proc/send_tip_of_the_round()
/*
	var/m
	if(selected_tip)
		m = selected_tip
	else
		var/list/randomtips = file2list("config/tips.txt")
		var/list/memetips = file2list("config/sillytips.txt")
		if(randomtips.len && prob(95))
			m = pick(randomtips)
		else if(memetips.len)
			m = pick(memetips)

	if(m)
		to_chat(world, "<font color='purple'><b>Tip of the round: \
			</b>[html_encode_ru(m)]</font>")
*/

/datum/subsystem/ticker/proc/check_queue()
	if(!queued_players.len || !config.hard_popcap)
		return

	queue_delay++
	var/mob/new_player/next_in_line = queued_players[1]

	switch(queue_delay)
		if(5) //every 5 ticks check if there is a slot available
			if(living_player_count() < config.hard_popcap)
				if(next_in_line && next_in_line.client)
					to_chat(next_in_line, "<span class='userdanger'>A slot has opened! You have approximately 20 seconds to join. <a href='?src=\ref[next_in_line];late_join=override'>\>\>Join Game\<\<</a></span>")
					to_chat(next_in_line, sound('sound/misc/notice1.ogg'))
					next_in_line.LateChoices()
					return
				queued_players -= next_in_line //Client disconnected, remove he
			queue_delay = 0 //No vacancy: restart timer
		if(25 to INFINITY)  //No response from the next in line when a vacancy exists, remove he
			to_chat(next_in_line, "<span class='danger'>No response recieved. You have been removed from the line.</span>")
			queued_players -= next_in_line
			queue_delay = 0

/datum/subsystem/ticker/proc/check_maprotate()
	if (!config.maprotation || !SERVERTOOLS)
		return
	if (SSshuttle.emergency.mode != SHUTTLE_ESCAPE || SSshuttle.canRecall())
		return
	if (maprotatechecked)
		return

	maprotatechecked = 1

	//map rotate chance defaults to 75% of the length of the round (in minutes)
	if (!prob((world.time/600)*config.maprotatechancedelta))
		return
	spawn(0) //compiling a map can lock up the mc for 30 to 60 seconds if we don't spawn
		maprotate()


/world/proc/has_round_started()
	if (ticker && ticker.current_state >= GAME_STATE_PLAYING)
		return TRUE
	return FALSE

/datum/subsystem/ticker/Recover()
	current_state = ticker.current_state
	force_ending = ticker.force_ending
	hide_mode = ticker.hide_mode
	mode = ticker.mode
	event_time = ticker.event_time
	event = ticker.event

	login_music = ticker.login_music
	round_end_sound = ticker.round_end_sound

	minds = ticker.minds

	syndicate_coalition = ticker.syndicate_coalition
	factions = ticker.factions
	availablefactions = ticker.availablefactions

	delay_end = ticker.delay_end

	triai = ticker.triai
	tipped = ticker.tipped
	selected_tip = ticker.selected_tip

	timeLeft = ticker.timeLeft

	totalPlayers = ticker.totalPlayers
	totalPlayersReady = ticker.totalPlayersReady

	queue_delay = ticker.queue_delay
	queued_players = ticker.queued_players
	cinematic = ticker.cinematic
	maprotatechecked = ticker.maprotatechecked


/datum/subsystem/ticker/proc/send_news_report()
	var/news_message
	var/news_source = "Nanotrasen News Network"
	switch(news_report)
		if(NUKE_SYNDICATE_BASE)
			news_message = "In a daring raid, the heroic crew of [station_name()] detonated a nuclear device in the heart of a terrorist base."
		if(STATION_DESTROYED_NUKE)
			news_message = "We would like to reassure all employees that the reports of a Syndicate backed nuclear attack on [station_name()] are, in fact, a hoax. Have a secure day!"
		if(STATION_EVACUATED)
			news_message = "The crew of [station_name()] has been evacuated amid unconfirmed reports of enemy activity."
		if(GANG_LOSS)
			news_message = "Organized crime aboard [station_name()] has been stamped out by members of our ever vigilant security team. Remember to thank your assigned officers today!"
		if(GANG_TAKEOVER)
			news_message = "Contact with [station_name()] has been lost after a sophisticated hacking attack by organized criminal elements. Stay vigilant!"
		if(BLOB_WIN)
			news_message = "[station_name()] was overcome by an unknown biological outbreak, killing all crew on board. Don't let it happen to you! Remember, a clean work station is a safe work station."
		if(BLOB_NUKE)
			news_message = "[station_name()] is currently undergoing decontanimation after a controlled burst of radiation was used to remove a biological ooze. All employees were safely evacuated prior, and are enjoying a relaxing vacation."
		if(BLOB_DESTROYED)
			news_message = "[station_name()] is currently undergoing decontamination procedures after the destruction of a biological hazard. As a reminder, any crew members experiencing cramps or bloating should report immediately to security for incineration."
		if(CULT_ESCAPE)
			news_message = "Security Alert: A group of religious fanatics have escaped from [station_name()]."
		if(CULT_FAILURE)
			news_message = "Following the dismantling of a restricted cult aboard [station_name()], we would like to remind all employees that worship outside of the Chapel is strictly prohibited, and cause for termination."
		if(CULT_SUMMON)
			news_message = "Company officials would like to clarify that [station_name()] was scheduled to be decommissioned following meteor damage earlier this year. Earlier reports of an unknowable eldritch horror were made in error."
		if(NUKE_MISS)
			news_message = "The Syndicate have bungled a terrorist attack [station_name()], detonating a nuclear weapon in empty space near by."
		if(OPERATIVES_KILLED)
			news_message = "Repairs to [station_name()] are underway after an elite Syndicate death squad was wiped out by the crew."
		if(OPERATIVE_SKIRMISH)
			news_message = "A skirmish between security forces and Syndicate agents aboard [station_name()] ended with both sides bloodied but intact."
		if(REVS_WIN)
			news_message = "Company officials have reassured investors that despite a union led revolt aboard [station_name()] that there will be no wage increases for workers."
		if(REVS_LOSE)
			news_message = "[station_name()] quickly put down a misguided attempt at mutiny. Remember, unionizing is illegal!"
		if(WIZARD_KILLED)
			news_message = "Tensions have flared with the Wizard's Federation following the death of one of their members aboard [station_name()]."
		if(STATION_NUKED)
			news_message = "[station_name()] activated its self destruct device for unknown reasons. Attempts to clone the Captain so he can be arrested and executed are under way."
		if(CLOCK_SUMMON)
			news_message = "The garbled messages about hailing a mouse and strange energy readings from [station_name()] have been discovered to be an ill-advised, if thorough, prank by a clown."
		if(CLOCK_SILICONS)
			news_message = "The project started by [station_name()] to upgrade their silicon units with advanced equipment have been largely successful, though they have thus far refused to release schematics in a violation of company policy."
		if(CLOCK_PROSELYTIZATION)
			news_message = "The burst of energy released near [station_name()] has been confirmed as merely a test of a new weapon. However, due to an unexpected mechanical error, their communications system has been knocked offline."
		if(SHUTTLE_HIJACK)
			news_message = "During routine evacuation procedures, the emergency shuttle of [station_name()] had its navigation protocols corrupted and went off course, but was recovered shortly after."

	if(news_message)
		send2otherserver(news_source, news_message,"News_Report")
