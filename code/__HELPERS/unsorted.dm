

/*
 * A large number of misc global procs.
 */

//Inverts the colour of an HTML string
/proc/invertHTML(HTMLstring)

	if (!( istext(HTMLstring) ))
		CRASH("Given non-text argument!")
		return
	else
		if (length(HTMLstring) != 7)
			CRASH("Given non-HTML argument!")
			return
	var/textr = copytext(HTMLstring, 2, 4)
	var/textg = copytext(HTMLstring, 4, 6)
	var/textb = copytext(HTMLstring, 6, 8)
	var/r = hex2num(textr)
	var/g = hex2num(textg)
	var/b = hex2num(textb)
	textr = num2hex(255 - r, 2)
	textg = num2hex(255 - g, 2)
	textb = num2hex(255 - b, 2)
	return text("#[][][]", textr, textg, textb)
	return

/proc/Get_Angle(atom/movable/start,atom/movable/end)//For beams.
	if(!start || !end)
		return 0
	var/dy
	var/dx
	dy=(32*end.y+end.pixel_y)-(32*start.y+start.pixel_y)
	dx=(32*end.x+end.pixel_x)-(32*start.x+start.pixel_x)
	if(!dy)
		return (dx>=0)?90:270
	.=arctan(dx/dy)
	if(dy<0)
		.+=180
	else if(dx<0)
		.+=360

//Returns location. Returns null if no location was found.
/proc/get_teleport_loc(turf/location,mob/target,distance = 1, density = 0, errorx = 0, errory = 0, eoffsetx = 0, eoffsety = 0)
/*
Location where the teleport begins, target that will teleport, distance to go, density checking 0/1(yes/no).
Random error in tile placement x, error in tile placement y, and block offset.
Block offset tells the proc how to place the box. Behind teleport location, relative to starting location, forward, etc.
Negative values for offset are accepted, think of it in relation to North, -x is west, -y is south. Error defaults to positive.
Turf and target are seperate in case you want to teleport some distance from a turf the target is not standing on or something.
*/

	var/dirx = 0//Generic location finding variable.
	var/diry = 0

	var/xoffset = 0//Generic counter for offset location.
	var/yoffset = 0

	var/b1xerror = 0//Generic placing for point A in box. The lower left.
	var/b1yerror = 0
	var/b2xerror = 0//Generic placing for point B in box. The upper right.
	var/b2yerror = 0

	errorx = abs(errorx)//Error should never be negative.
	errory = abs(errory)
	//var/errorxy = round((errorx+errory)/2)//Used for diagonal boxes.

	switch(target.dir)//This can be done through equations but switch is the simpler method. And works fast to boot.
	//Directs on what values need modifying.
		if(1)//North
			diry+=distance
			yoffset+=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(2)//South
			diry-=distance
			yoffset-=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(4)//East
			dirx+=distance
			yoffset+=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx
		if(8)//West
			dirx-=distance
			yoffset-=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx

	var/turf/destination=locate(location.x+dirx,location.y+diry,location.z)

	if(destination)//If there is a destination.
		if(errorx||errory)//If errorx or y were specified.
			var/destination_list[] = list()//To add turfs to list.
			//destination_list = new()
			/*This will draw a block around the target turf, given what the error is.
			Specifying the values above will basically draw a different sort of block.
			If the values are the same, it will be a square. If they are different, it will be a rectengle.
			In either case, it will center based on offset. Offset is position from center.
			Offset always calculates in relation to direction faced. In other words, depending on the direction of the teleport,
			the offset should remain positioned in relation to destination.*/

			var/turf/center = locate((destination.x+xoffset),(destination.y+yoffset),location.z)//So now, find the new center.

			//Now to find a box from center location and make that our destination.
			for(var/turf/T in block(locate(center.x+b1xerror,center.y+b1yerror,location.z), locate(center.x+b2xerror,center.y+b2yerror,location.z) ))
				if(density&&T.density)
					continue//If density was specified.
				if(T.x>world.maxx || T.x<1)
					continue//Don't want them to teleport off the map.
				if(T.y>world.maxy || T.y<1)
					continue
				destination_list += T
			if(destination_list.len)
				destination = pick(destination_list)
			else
				return

		else//Same deal here.
			if(density&&destination.density)
				return
			if(destination.x>world.maxx || destination.x<1)
				return
			if(destination.y>world.maxy || destination.y<1)
				return
	else	return

	return destination

/proc/getline(atom/M,atom/N)//Ultra-Fast Bresenham Line-Drawing Algorithm
	var/px=M.x		//starting x
	var/py=M.y
	var/line[] = list(locate(px,py,M.z))
	var/dx=N.x-px	//x distance
	var/dy=N.y-py
	var/dxabs=abs(dx)//Absolute value of x distance
	var/dyabs=abs(dy)
	var/sdx=sign(dx)	//Sign of x distance (+ or -)
	var/sdy=sign(dy)
	var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
	var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
	var/j			//Generic integer for counting
	if(dxabs>=dyabs)	//x distance is greater than y
		for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
			y+=dyabs
			if(y>=dxabs)	//Every dyabs steps, step once in y direction
				y-=dxabs
				py+=sdy
			px+=sdx		//Step on in x direction
			line+=locate(px,py,M.z)//Add the turf to the list
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
			py+=sdy
			line+=locate(px,py,M.z)
	return line

//Returns whether or not a player is a guest using their ckey as an input
/proc/IsGuestKey(key)
	if (findtext(key, "Guest-", 1, 7) != 1) //was findtextEx
		return 0

	var/i, ch, len = length(key)

	for (i = 7, i <= len, ++i)
		ch = text2ascii(key, i)
		if (ch < 48 || ch > 57)
			return 0
	return 1

//Generalised helper proc for letting mobs rename themselves. Used to be clname() and ainame()
/mob/proc/rename_self(role)
	var/oldname = real_name
	var/newname
	var/loop = 1
	var/safety = 0

	while(loop && safety < 5)
		if(client && client.prefs.custom_names[role] && !safety)
			newname = client.prefs.custom_names[role]
		else
			switch(role)
				if("clown")
					newname = pick(clown_names)
				if("mime")
					newname = pick(mime_names)
				if("ai")
					newname = pick(ai_names)
				if("deity")
					newname = pick(clown_names|ai_names|mime_names) //pick any old name
				else
					return

		for(var/mob/living/M in player_list)
			if(M == src)
				continue
			if(!newname || M.real_name == newname)
				newname = null
				loop++ // name is already taken so we roll again
				break
		loop--
		safety++

	if(newname)
		fully_replace_character_name(oldname,newname)


//Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ionnum()
	return "[pick("!","@","#","$","%","^","&")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

//Returns a list of unslaved cyborgs
/proc/active_free_borgs()
	. = list()
	for(var/mob/living/silicon/robot/R in living_mob_list)
		if(R.connected_ai)
			continue
		if(R.stat == DEAD)
			continue
		if(R.emagged || R.scrambledcodes || R.syndicate)
			continue
		. += R

//Returns a list of AI's
/proc/active_ais(check_mind=0)
	. = list()
	for(var/mob/living/silicon/ai/A in living_mob_list)
		if(A.stat == DEAD)
			continue
		if(A.control_disabled == 1)
			continue
		if(check_mind)
			if(!A.mind)
				continue
		. += A
	return .

//Find an active ai with the least borgs. VERBOSE PROCNAME HUH!
/proc/select_active_ai_with_fewest_borgs()
	var/mob/living/silicon/ai/selected
	var/list/active = active_ais()
	for(var/mob/living/silicon/ai/A in active)
		if(!selected || (selected.connected_robots.len > A.connected_robots.len))
			selected = A

	return selected

/proc/select_active_free_borg(mob/user)
	var/list/borgs = active_free_borgs()
	if(borgs.len)
		if(user)
			. = input(user,"Unshackled cyborg signals detected:", "Cyborg Selection", borgs[1]) in borgs
		else
			. = pick(borgs)
	return .

/proc/select_active_ai(mob/user)
	var/list/ais = active_ais()
	if(ais.len)
		if(user)
			. = input(user,"AI signals detected:", "AI Selection", ais[1]) in ais
		else
			. = pick(ais)
	return .

//Returns a list of all items of interest with their name
/proc/getpois(mobs_only=0,skip_mindless=0)
	var/list/mobs = sortmobs()
	var/list/namecounts = list()
	var/list/pois = list()
	for(var/mob/M in mobs)
		if(skip_mindless && (!M.mind && !M.ckey))
			if(!isbot(M) && !istype(M, /mob/camera/))
				continue
		if(M.client && M.client.holder && M.client.holder.fakekey) //stealthmins
			continue
		var/name = avoid_assoc_duplicate_keys(M.name, namecounts)

		if(M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
		if(M.stat == DEAD)
			if(isobserver(M))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		pois[name] = M

	if(!mobs_only)
		for(var/atom/A in poi_list)
			if(!A || !A.loc)
				continue
			pois[avoid_assoc_duplicate_keys(A.name, namecounts)] = A

	return pois
//Orders mobs by type then by name
/proc/sortmobs()
	var/list/moblist = list()
	var/list/sortmob = sortNames(mob_list)
	for(var/mob/living/silicon/ai/M in sortmob)
		moblist.Add(M)
	for(var/mob/camera/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/pai/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/robot/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/human/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/brain/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/alien/M in sortmob)
		moblist.Add(M)
	for(var/mob/dead/observer/M in sortmob)
		moblist.Add(M)
	for(var/mob/new_player/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/monkey/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/simple_animal/slime/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/simple_animal/M in sortmob)
		moblist.Add(M)
//	for(var/mob/living/silicon/hivebot/M in world)
//		mob_list.Add(M)
//	for(var/mob/living/silicon/hive_mainframe/M in world)
//		mob_list.Add(M)
	for(var/mob/living/carbon/true_devil/M in sortmob)
		moblist.Add(M)
	return moblist

//E = MC^2
/proc/convert2energy(M)
	var/E = M*(SPEED_OF_LIGHT_SQ)
	return E

//M = E/C^2
/proc/convert2mass(E)
	var/M = E/(SPEED_OF_LIGHT_SQ)
	return M

/proc/key_name(whom, include_link = null, include_name = 1)
	var/mob/M
	var/client/C
	var/key
	var/ckey

	if(!whom)
		return "*null*"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
		ckey = C.ckey
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
		ckey = M.ckey
	else if(istext(whom))
		key = whom
		ckey = ckey(whom)
		C = directory[ckey]
		if(C)
			M = C.mob
	else
		return "*invalid*"

	. = ""

	if(!ckey)
		include_link = 0

	if(key)
		if(C && C.holder && C.holder.fakekey && !include_name)
			if(include_link)
				. += "<a href='?priv_msg=[C.findStealthKey()]'>"
			. += "Administrator"
		else
			if(include_link)
				. += "<a href='?priv_msg=[ckey]'>"
			. += key
		if(!C)
			. += "\[DC\]"

		if(include_link)
			. += "</a>"
	else
		. += "*no key*"

	if(include_name && M)
		if(M.real_name)
			. += "/([M.real_name])"
		else if(M.name)
			. += "/([M.name])"

	return .

/proc/key_name_admin(whom, include_name = 1)
	return key_name(whom, 1, include_name)

/proc/get_mob_by_ckey(key)
	if(!key)
		return
	var/list/mobs = sortmobs()
	for(var/mob/M in mobs)
		if(M.ckey == key)
			return M

//Returns the atom sitting on the turf.
//For example, using this on a disk, which is in a bag, on a mob, will return the mob because it's on the turf.
//Optional arg 'type' to stop once it reaches a specific type instead of a turf.
/proc/get_atom_on_turf(atom/movable/M, stop_type)
	var/atom/loc = M
	while(loc && loc.loc && !isturf(loc.loc))
		loc = loc.loc
		if(stop_type && istype(loc, stop_type))
			break
	return loc

// returns the turf located at the map edge in the specified direction relative to A
// used for mass driver
/proc/get_edge_target_turf(atom/A, direction)
	var/turf/target = locate(A.x, A.y, A.z)
	if(!A || !target)
		return 0
		//since NORTHEAST == NORTH & EAST, etc, doing it this way allows for diagonal mass drivers in the future
		//and isn't really any more complicated

		// Note diagonal directions won't usually be accurate
	if(direction & NORTH)
		target = locate(target.x, world.maxy, target.z)
	if(direction & SOUTH)
		target = locate(target.x, 1, target.z)
	if(direction & EAST)
		target = locate(world.maxx, target.y, target.z)
	if(direction & WEST)
		target = locate(1, target.y, target.z)
	return target

// returns turf relative to A in given direction at set range
// result is bounded to map size
// note range is non-pythagorean
// used for disposal system
/proc/get_ranged_target_turf(atom/A, direction, range)

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	if(direction & WEST)
		x = max(1, x - range)

	return locate(x,y,A.z)


// returns turf relative to A offset in dx and dy tiles
// bound to map limits
/proc/get_offset_target_turf(atom/A, dx, dy)
	var/x = min(world.maxx, max(1, A.x + dx))
	var/y = min(world.maxy, max(1, A.y + dy))
	return locate(x,y,A.z)

/atom/proc/GetAllContents()
	var/list/processing_list = list(src)
	var/list/assembled = list()

	while(processing_list.len)
		var/atom/A = processing_list[1]
		processing_list -= A

		for(var/atom/a in A)
			if(!(a in assembled))
				processing_list |= a

		assembled |= A

	return assembled

//Step-towards method of determining whether one atom can see another. Similar to viewers()
/proc/can_see(atom/source, atom/target, length=5) // I couldnt be arsed to do actual raycasting :I This is horribly inaccurate.
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	var/steps = 1
	if(current != target_turf)
		current = get_step_towards(current, target_turf)
		while(current != target_turf)
			if(steps > length)
				return 0
			if(current.opacity)
				return 0
			for(var/thing in current)
				var/atom/A = thing
				if(A.opacity)
					return 0
			current = get_step_towards(current, target_turf)
			steps++

	return 1

/proc/is_blocked_turf(turf/T, exclude_mobs)
	if(T.density)
		return 1
	for(var/i in T)
		var/atom/A = i
		if(A.density && (!exclude_mobs || !ismob(A)))
			return 1
	return 0

/proc/is_anchored_dense_turf(turf/T) //like the older version of the above, fails only if also anchored
	if(T.density)
		return 1
	for(var/i in T)
		var/atom/movable/A = i
		if(A.density && A.anchored)
			return 1
	return 0

/proc/get_step_towards2(atom/ref , atom/trg)
	var/base_dir = get_dir(ref, get_step_towards(ref,trg))
	var/turf/temp = get_step_towards(ref,trg)

	if(is_blocked_turf(temp))
		var/dir_alt1 = turn(base_dir, 90)
		var/dir_alt2 = turn(base_dir, -90)
		var/turf/turf_last1 = temp
		var/turf/turf_last2 = temp
		var/free_tile = null
		var/breakpoint = 0

		while(!free_tile && breakpoint < 10)
			if(!is_blocked_turf(turf_last1))
				free_tile = turf_last1
				break
			if(!is_blocked_turf(turf_last2))
				free_tile = turf_last2
				break
			turf_last1 = get_step(turf_last1,dir_alt1)
			turf_last2 = get_step(turf_last2,dir_alt2)
			breakpoint++

		if(!free_tile)
			return get_step(ref, base_dir)
		else
			return get_step_towards(ref,free_tile)

	else
		return get_step(ref, base_dir)

//Takes: Anything that could possibly have variables and a varname to check.
//Returns: 1 if found, 0 if not.
/proc/hasvar(datum/A, varname)
	if(A.vars.Find(lowertext(varname)))
		return 1
	else
		return 0

//Repopulates sortedAreas list
/proc/SortAreas()
	sortedAreas = list()

	for(var/area/A in world)
		sortedAreas.Add(A)

	sortTim(sortedAreas, /proc/cmp_name_asc)

/area/proc/addSorted()
	sortedAreas.Add(src)
	sortTim(sortedAreas, /proc/cmp_name_asc)

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all areas of that type in the world.
/proc/get_areas(areatype, subtypes=TRUE)
	if(istext(areatype))
		areatype = text2path(areatype)
	else if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type
	else if(!ispath(areatype))
		return null

	var/list/areas = list()
	if(subtypes)
		var/list/cache = typecacheof(areatype)
		for(var/V in sortedAreas)
			var/area/A = V
			if(cache[A.type])
				areas += V
	else
		for(var/V in sortedAreas)
			var/area/A = V
			if(A.type == areatype)
				areas += V
	return areas

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all turfs in areas of that type of that type in the world.
/proc/get_area_turfs(areatype, target_z = 0, subtypes=FALSE)
	if(istext(areatype))
		areatype = text2path(areatype)
	else if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type
	else if(!ispath(areatype))
		return null

	var/list/turfs = list()
	if(subtypes)
		var/list/cache = typecacheof(areatype)
		for(var/V in sortedAreas)
			var/area/A = V
			if(!cache[A.type])
				continue
			for(var/turf/T in A)
				if(target_z == 0 || target_z == T.z)
					turfs += T
	else
		for(var/V in sortedAreas)
			var/area/A = V
			if(A.type != areatype)
				continue
			for(var/turf/T in A)
				if(target_z == 0 || target_z == T.z)
					turfs += T
	return turfs

/proc/get_cardinal_dir(atom/A, atom/B)
	var/dx = abs(B.x - A.x)
	var/dy = abs(B.y - A.y)
	return get_dir(A, B) & (rand() * (dx+dy) < dy ? 3 : 12)

//chances are 1:value. anyprob(1) will always return true
/proc/anyprob(value)
	return (rand(1,value)==value)

/proc/view_or_range(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = view(distance,center)
		if("range")
			. = range(distance,center)
	return

/proc/oview_or_orange(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = oview(distance,center)
		if("range")
			. = orange(distance,center)
	return

/proc/parse_zone(zone)
	if(zone == "r_hand")
		return "right hand"
	else if (zone == "l_hand")
		return "left hand"
	else if (zone == "l_arm")
		return "left arm"
	else if (zone == "r_arm")
		return "right arm"
	else if (zone == "l_leg")
		return "left leg"
	else if (zone == "r_leg")
		return "right leg"
	else if (zone == "l_foot")
		return "left foot"
	else if (zone == "r_foot")
		return "right foot"
	else
		return zone

/*

 Gets the turf this atom's *ICON* appears to inhabit
 It takes into account:
 * Pixel_x/y
 * Matrix x/y

 NOTE: if your atom has non-standard bounds then this proc
 will handle it, but:
 * if the bounds are even, then there are an even amount of "middle" turfs, the one to the EAST, NORTH, or BOTH is picked
 (this may seem bad, but you're atleast as close to the center of the atom as possible, better than byond's default loc being all the way off)
 * if the bounds are odd, the true middle turf of the atom is returned

*/

/proc/get_turf_pixel(atom/movable/AM)
	if(!istype(AM))
		return

	//Find AM's matrix so we can use it's X/Y pixel shifts
	var/matrix/M = matrix(AM.transform)

	var/pixel_x_offset = AM.pixel_x + M.get_x_shift()
	var/pixel_y_offset = AM.pixel_y + M.get_y_shift()

	//Irregular objects
	if(AM.bound_height != world.icon_size || AM.bound_width != world.icon_size)
		var/icon/AMicon = icon(AM.icon, AM.icon_state)
		pixel_x_offset += ((AMicon.Width()/world.icon_size)-1)*(world.icon_size*0.5)
		pixel_y_offset += ((AMicon.Height()/world.icon_size)-1)*(world.icon_size*0.5)
		qdel(AMicon)

	//DY and DX
	var/rough_x = round(round(pixel_x_offset,world.icon_size)/world.icon_size)
	var/rough_y = round(round(pixel_y_offset,world.icon_size)/world.icon_size)

	//Find coordinates
	var/turf/T = get_turf(AM) //use AM's turfs, as it's coords are the same as AM's AND AM's coords are lost if it is inside another atom
	var/final_x = T.x + rough_x
	var/final_y = T.y + rough_y

	if(final_x || final_y)
		return locate(final_x, final_y, T.z)

//Finds the distance between two atoms, in pixels
//centered = 0 counts from turf edge to edge
//centered = 1 counts from turf center to turf center
//of course mathematically this is just adding world.icon_size on again
/proc/getPixelDistance(atom/A, atom/B, centered = 1)
	if(!istype(A)||!istype(B))
		return 0
	. = bounds_dist(A, B) + sqrt((((A.pixel_x+B.pixel_x)**2) + ((A.pixel_y+B.pixel_y)**2)))
	if(centered)
		. += world.icon_size

/proc/get(atom/loc, type)
	while(loc)
		if(istype(loc, type))
			return loc
		loc = loc.loc
	return null


//For objects that should embed, but make no sense being is_sharp or is_pointed()
//e.g: rods
var/list/can_embed_types = typecacheof(list(
	/obj/item/stack/rods,
	/obj/item/pipe))

/proc/can_embed(obj/item/W)
	if(W.is_sharp())
		return 1
	if(is_pointed(W))
		return 1

	if(is_type_in_typecache(W, can_embed_types))
		return 1


/*
Checks if that loc and dir has a item on the wall
*/
var/list/WALLITEMS = typecacheof(list(
	/obj/machinery/power/apc, /obj/machinery/airalarm, /obj/item/device/radio/intercom,
	/obj/structure/extinguisher_cabinet, /obj/structure/reagent_dispensers/peppertank,
	/obj/machinery/status_display, /obj/machinery/requests_console, /obj/machinery/light_switch, /obj/structure/sign,
	/obj/machinery/newscaster, /obj/machinery/firealarm, /obj/structure/noticeboard, /obj/machinery/button,
	/obj/machinery/computer/security/telescreen, /obj/machinery/embedded_controller/radio/simple_vent_controller,
	/obj/item/weapon/storage/secure/safe, /obj/machinery/door_timer, /obj/machinery/flasher, /obj/machinery/keycard_auth,
	/obj/structure/mirror, /obj/structure/fireaxecabinet, /obj/machinery/computer/security/telescreen/entertainment
	))

var/list/WALLITEMS_EXTERNAL = typecacheof(list(
	/obj/machinery/camera, /obj/structure/camera_assembly,
	/obj/structure/light_construct, /obj/machinery/light))

var/list/WALLITEMS_INVERSE = typecacheof(list(
	/obj/structure/light_construct, /obj/machinery/light))


/proc/gotwallitem(loc, dir, var/check_external = 0)
	var/locdir = get_step(loc, dir)
	for(var/obj/O in loc)
		if(is_type_in_typecache(O, WALLITEMS) && check_external != 2)
			//Direction works sometimes
			if(is_type_in_typecache(O, WALLITEMS_INVERSE))
				if(O.dir == turn(dir, 180))
					return 1
			else if(O.dir == dir)
				return 1

			//Some stuff doesn't use dir properly, so we need to check pixel instead
			//That's exactly what get_turf_pixel() does
			if(get_turf_pixel(O) == locdir)
				return 1

		if(is_type_in_typecache(O, WALLITEMS_EXTERNAL) && check_external)
			if(is_type_in_typecache(O, WALLITEMS_INVERSE))
				if(O.dir == turn(dir, 180))
					return 1
			else if(O.dir == dir)
				return 1

	//Some stuff is placed directly on the wallturf (signs)
	for(var/obj/O in locdir)
		if(is_type_in_typecache(O, WALLITEMS) && check_external != 2)
			if(O.pixel_x == 0 && O.pixel_y == 0)
				return 1
	return 0

/proc/format_text(text)
	return replacetext(replacetext(text,"\proper ",""),"\improper ","")

/obj/proc/atmosanalyzer_scan(datum/gas_mixture/air_contents, mob/user, obj/target = src)
	var/obj/icon = target
	user.visible_message("[user] has used the analyzer on [bicon(icon)] [target].", "<span class='notice'>You use the analyzer on [bicon(icon)] [target].</span>")
	var/pressure = air_contents.return_pressure()
	var/total_moles = air_contents.total_moles()

	to_chat(user, "<span class='notice'>Results of analysis of [bicon(icon)] [target].</span>")
	if(total_moles>0)
		to_chat(user, "<span class='notice'>Pressure: [round(pressure,0.1)] kPa</span>")

		var/list/cached_gases = air_contents.gases

		for(var/id in cached_gases)
			var/gas_concentration = cached_gases[id][MOLES]/total_moles
			if(id in hardcoded_gases || gas_concentration > 0.001) //ensures the four primary gases are always shown.
				to_chat(user, "<span class='notice'>[cached_gases[id][GAS_META][META_GAS_NAME]]: [round(gas_concentration*100, 0.01)] %</span>")

		to_chat(user, "<span class='notice'>Temperature: [round(air_contents.temperature-T0C)] &deg;C</span>")
	else
		to_chat(user, "<span class='notice'>[target] is empty!</span>")
	return

/proc/check_target_facings(mob/living/initator, mob/living/target)
	/*This can be used to add additional effects on interactions between mobs depending on how the mobs are facing each other, such as adding a crit damage to blows to the back of a guy's head.
	Given how click code currently works (Nov '13), the initiating mob will be facing the target mob most of the time
	That said, this proc should not be used if the change facing proc of the click code is overriden at the same time*/
	if(!ismob(target) || target.lying)
	//Make sure we are not doing this for things that can't have a logical direction to the players given that the target would be on their side
		return FACING_FAILED
	if(initator.dir == target.dir) //mobs are facing the same direction
		return FACING_SAME_DIR
	if(is_A_facing_B(initator,target) && is_A_facing_B(target,initator)) //mobs are facing each other
		return FACING_EACHOTHER
	if(initator.dir + 2 == target.dir || initator.dir - 2 == target.dir || initator.dir + 6 == target.dir || initator.dir - 6 == target.dir) //Initating mob is looking at the target, while the target mob is looking in a direction perpendicular to the 1st
		return FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR

/proc/random_step(atom/movable/AM, steps, chance)
	var/initial_chance = chance
	while(steps > 0)
		if(prob(chance))
			step(AM, pick(alldirs))
		chance = max(chance - (initial_chance / steps), 0)
		steps--

/proc/living_player_count()
	var/living_player_count = 0
	for(var/mob in player_list)
		if(mob in living_mob_list)
			living_player_count += 1
	return living_player_count

/proc/randomColor(mode = 0)	//if 1 it doesn't pick white, black or gray
	switch(mode)
		if(0)
			return pick("white","black","gray","red","green","blue","brown","yellow","orange","darkred",
						"crimson","lime","darkgreen","cyan","navy","teal","purple","indigo")
		if(1)
			return pick("red","green","blue","brown","yellow","orange","darkred","crimson",
						"lime","darkgreen","cyan","navy","teal","purple","indigo")
		else
			return "white"

/proc/params2turf(scr_loc, turf/origin)
	if(!scr_loc)
		return null
	var/tX = splittext(scr_loc, ",")
	var/tY = splittext(tX[2], ":")
	var/tZ = origin.z
	tY = tY[1]
	tX = splittext(tX[1], ":")
	tX = tX[1]
	tX = Clamp(origin.x + text2num(tX) - world.view - 1, 1, world.maxx)
	tY = Clamp(origin.y + text2num(tY) - world.view - 1, 1, world.maxy)
	return locate(tX, tY, tZ)

/proc/screen_loc2turf(text, turf/origin)
	if(!text)
		return null
	var/tZ = splittext(text, ",")
	var/tX = splittext(tZ[1], "-")
	var/tY = text2num(tX[2])
	tX = splittext(tZ[2], "-")
	tX = text2num(tX[2])
	tZ = origin.z
	tX = Clamp(origin.x + 7 - tX, 1, world.maxx)
	tY = Clamp(origin.y + 7 - tY, 1, world.maxy)
	return locate(tX, tY, tZ)

/proc/IsValidSrc(datum/D)
	if(istype(D))
		return !qdeleted(D)
	return 0



//Get the dir to the RIGHT of dir if they were on a clock
//NORTH --> NORTHEAST
/proc/get_clockwise_dir(dir)
	. = angle2dir(dir2angle(dir)+45)

//Get the dir to the LEFT of dir if they were on a clock
//NORTH --> NORTHWEST
/proc/get_anticlockwise_dir(dir)
	. = angle2dir(dir2angle(dir)-45)


//Compare A's dir, the clockwise dir of A and the anticlockwise dir of A
//To the opposite dir of the dir returned by get_dir(B,A)
//If one of them is a match, then A is facing B
/proc/is_A_facing_B(atom/A,atom/B)
	if(!istype(A) || !istype(B))
		return 0
	if(isliving(A))
		var/mob/living/LA = A
		if(LA.lying)
			return 0
	var/goal_dir = angle2dir(dir2angle(get_dir(B,A)+180))
	var/clockwise_A_dir = get_clockwise_dir(A.dir)
	var/anticlockwise_A_dir = get_anticlockwise_dir(B.dir)

	if(A.dir == goal_dir || clockwise_A_dir == goal_dir || anticlockwise_A_dir == goal_dir)
		return 1
	return 0


/*
rough example of the "cone" made by the 3 dirs checked

 B
  \
   \
    >
      <
       \
        \
B --><-- A
        /
       /
      <
     >
    /
   /
 B

*/


//Center's an image.
//Requires:
//The Image
//The x dimension of the icon file used in the image
//The y dimension of the icon file used in the image
// eg: center_image(I, 32,32)
// eg2: center_image(I, 96,96)

/proc/center_image(var/image/I, x_dimension = 0, y_dimension = 0)
	if(!I)
		return

	if(!x_dimension || !y_dimension)
		return

	if((x_dimension == world.icon_size) && (y_dimension == world.icon_size))
		return I

	//Offset the image so that it's bottom left corner is shifted this many pixels
	//This makes it infinitely easier to draw larger inhands/images larger than world.iconsize
	//but still use them in game
	var/x_offset = -((x_dimension/world.icon_size)-1)*(world.icon_size*0.5)
	var/y_offset = -((y_dimension/world.icon_size)-1)*(world.icon_size*0.5)

	//Correct values under world.icon_size
	if(x_dimension < world.icon_size)
		x_offset *= -1
	if(y_dimension < world.icon_size)
		y_offset *= -1

	I.pixel_x = x_offset
	I.pixel_y = y_offset

	return I

//ultra range (no limitations on distance, faster than range for distances > 8); including areas drastically decreases performance
/proc/urange(dist=0, atom/center=usr, orange=0, areas=0)
	if(!dist)
		if(!orange)
			return list(center)
		else
			return list()

	var/list/turfs = RANGE_TURFS(dist, center)
	if(orange)
		turfs -= get_turf(center)
	. = list()
	for(var/V in turfs)
		var/turf/T = V
		. += T
		. += T.contents
		if(areas)
			. |= T.loc

//similar function to range(), but with no limitations on the distance; will search spiralling outwards from the center
/proc/spiral_range(dist=0, center=usr, orange=0)
	if(!dist)
		if(!orange)
			return list(center)
		else
			return list()

	var/turf/t_center = get_turf(center)
	if(!t_center)
		return list()

	var/list/L = list()
	var/turf/T
	var/y
	var/x
	var/c_dist = 1

	if(!orange)
		L += t_center
		L += t_center.contents

	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y-c_dist to y)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x-c_dist to x)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents
		c_dist++

	return L

//similar function to RANGE_TURFS(), but will search spiralling outwards from the center (like the above, but only turfs)
/proc/spiral_range_turfs(dist=0, center=usr, orange=0)
	if(!dist)
		if(!orange)
			return list(center)
		else
			return list()

	var/turf/t_center = get_turf(center)
	if(!t_center)
		return list()

	var/list/L = list()
	var/turf/T
	var/y
	var/x
	var/c_dist = 1

	if(!orange)
		L += t_center

	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y-c_dist to y)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x-c_dist to x)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
		c_dist++

	return L

/atom/proc/contains(var/atom/A)
	if(!A)
		return 0
	for(var/atom/location = A.loc, location, location = location.loc)
		if(location == src)
			return 1

/proc/add_to_proximity_list(atom/A, range)
	var/turf/T = get_turf(A)
	if(!T || !A.loc)
		throw EXCEPTION("Someone adding a prox sensor in nullspace")
	var/list/L = block(locate(T.x - range, T.y - range, T.z), locate(T.x + range, T.y + range, T.z))
	for(var/B in L)
		var/turf/C = B
		LAZYINITLIST(C.proximity_checkers)
		C.proximity_checkers[A] = TRUE
	return L

/proc/remove_from_proximity_list(atom/A, range, oldloc = null)
	var/turf/T = get_turf(oldloc ? oldloc : A)
	var/list/L = block(locate(T.x - range, T.y - range, T.z), locate(T.x + range, T.y + range, T.z))
	for(var/B in L)
		var/turf/C = B
		if (!C.proximity_checkers)
			continue
		C.proximity_checkers.Remove(A)

/proc/shift_proximity(atom/checker, atom/A, range, atom/B, newrange)
	var/turf/T = get_turf(A)
	var/turf/Q = get_turf(B)
	if(T == Q && range == newrange)
		return 0
	var/list/L = block(locate(T.x - range, T.y - range, T.z), locate(T.x + range, T.y + range, T.z))
	var/list/M = block(locate(Q.x - newrange, Q.y - newrange, Q.z), locate(Q.x + newrange, Q.y + newrange, Q.z))
	var/list/N = L - M
	var/list/O = M - L
	for(var/C in N)
		var/turf/D = C
		if (!D.proximity_checkers)
			continue
		D.proximity_checkers.Remove(checker)
	for(var/E in O)
		var/turf/F = E
		LAZYINITLIST(F.proximity_checkers)
		F.proximity_checkers[checker] = TRUE
	return 1

/proc/flick_overlay_static(image/I, atom/A, duration)
	set waitfor = 0
	if(!A || !I)
		return
	A.add_overlay(I)
	sleep(duration)
	A.overlays -= I

/proc/get_areas_in_z(zlevel)
	. = list()
	var/validarea = FALSE
	for(var/V in sortedAreas)
		var/area/A = V
		validarea = TRUE
		for(var/turf/T in A)
			if(T.z != zlevel)
				validarea = FALSE
				break
		if(validarea)
			. += A

/proc/get_closest_atom(type, list, source)
	var/closest_atom
	var/closest_distance
	for(var/A in list)
		if(!istype(A, type))
			continue
		var/distance = get_dist(source, A)
		if(!closest_atom)
			closest_distance = distance
			closest_atom = A
		else
			if(closest_distance > distance)
				closest_distance = distance
				closest_atom = A
	return closest_atom


proc/pick_closest_path(value, list/matches = get_fancy_list_of_atom_types())
	if (value == FALSE) //nothing should be calling us with a number, so this is safe
		value = input("Enter type to find (blank for all, cancel to cancel)", "Search for type") as null|text
		if (isnull(value))
			return
	value = trim(value)
	if(!isnull(value) && value != "")
		matches = filter_fancy_list(matches, value)

	if(matches.len==0)
		return

	var/chosen
	if(matches.len==1)
		chosen = matches[1]
	else
		chosen = input("Select a type", "Pick Type", matches[1]) as null|anything in matches
		if(!chosen)
			return
	chosen = matches[chosen]
	return chosen

//gives us the stack trace from CRASH() without ending the current proc.
/proc/stack_trace(msg)
	CRASH(msg)

//Key thing that stops lag. Cornerstone of performance in ss13, Just sitting here, in unsorted.dm.

//Increases delay as the server gets more overloaded,
//as sleeps aren't cheap and sleeping only to wake up and sleep again is wasteful
#define DELTA_CALC max(((max(world.tick_usage, world.cpu) / 100) * max(Master.sleep_delta,1)), 1)

/proc/stoplag()
	. = 0
	var/i = 1
	do
		. += round(i*DELTA_CALC)
		sleep(i*world.tick_lag*DELTA_CALC)
		i *= 2
	while (world.tick_usage > min(TICK_LIMIT_TO_RUN, CURRENT_TICKLIMIT))

#undef DELTA_CALC

/proc/flash_color(mob_or_client, flash_color="#960000", flash_time=20)
	var/client/C
	if(istype(mob_or_client, /mob))
		var/mob/M = mob_or_client
		if(M.client)
			C = M.client
		else
			return
	else if(istype(mob_or_client, /client))
		C = mob_or_client

	if(!istype(C))
		return

	C.color = flash_color
	spawn(0)
		animate(C, color = initial(C.color), time = flash_time)

#define RANDOM_COLOUR (rgb(rand(0,255),rand(0,255),rand(0,255)))

#define QDEL_IN(item, time) addtimer(CALLBACK(GLOBAL_PROC, /proc/qdel, item), time, TIMER_STOPPABLE)

/proc/check_for_cleanbot_bug()
	var/static/admins_warned //bet you didn't know you could do this!
	var/icon/Icon_test = icon('icons/BadAss.dmi')
	if(!istype(Icon_test))
		var/msg = "Cleanbot bug detected in icons! Icons are mapping to [Icon_test]"
		if (!admins_warned)
			admins_warned = 1
			spawn(25)
				message_admins(msg)
		stack_trace(msg)
	var/sound/Sound_test = sound('sound/misc/null.ogg')
	if(!istype(Sound_test))
		var/msg = "Cleanbot bug detected in sounds! Sounds are mapping to [Sound_test]"
		if (!admins_warned)
			admins_warned = 1
			spawn(25)
				message_admins(msg)
		stack_trace(msg)

/proc/random_nukecode()
	var/val = rand(0, 99999)
	var/str = "[val]"
	while(length(str) < 5)
		str = "0" + str
	. = str

/atom/proc/Shake(pixelshiftx = 15, pixelshifty = 15, duration = 250)
	var/initialpixelx = pixel_x
	var/initialpixely = pixel_y
	var/shiftx = rand(-pixelshiftx,pixelshiftx)
	var/shifty = rand(-pixelshifty,pixelshifty)
	animate(src, pixel_x = pixel_x + shiftx, pixel_y = pixel_y + shifty, time = 0.2, loop = duration)
	pixel_x = initialpixelx
	pixel_y = initialpixely

/proc/weightclass2text(var/w_class)
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			. = "tiny"
		if(WEIGHT_CLASS_SMALL)
			. = "small"
		if(WEIGHT_CLASS_NORMAL)
			. = "normal-sized"
		if(WEIGHT_CLASS_BULKY)
			. = "bulky"
		if(WEIGHT_CLASS_HUGE)
			. = "huge"
		if(WEIGHT_CLASS_GIGANTIC)
			. = "gigantic"
		else
			. = ""

/var/mob/dview/dview_mob = new

//Version of view() which ignores darkness, because BYOND doesn't have it (I actually suggested it but it was tagged redundant, BUT HEARERS IS A T- /rant).
/proc/dview(var/range = world.view, var/center, var/invis_flags = 0)
	if(!center)
		return

	dview_mob.forceMove(center)

	dview_mob.see_invisible = invis_flags

	. = view(range, dview_mob)
	dview_mob.forceMove(null)

/mob/dview
	invisibility = 101
	density = 0
	see_in_dark = 1e6
	anchored = 1

/mob/dview/Destroy(force=0)
	stack_trace("ALRIGHT WHICH FUCKER TRIED TO DELETE *MY* DVIEW?")

	if (!force)
		return QDEL_HINT_LETMELIVE

	world.log << "EVACUATE THE SHITCODE IS TRYING TO STEAL MUH JOBS"
	global.dview_mob = new
	return QDEL_HINT_QUEUE


#define FOR_DVIEW(type, range, center, invis_flags) \
	dview_mob.forceMove(center);           \
	dview_mob.see_invisible = invis_flags; \
for(type in view(range, dview_mob))

//can a window be here, or is there a window blocking it?
/proc/valid_window_location(turf/T, dir_to_check)
	if(!T)
		return FALSE
	for(var/obj/O in T)
		if(istype(O, /obj/machinery/door/window) && (O.dir == dir_to_check || dir_to_check == FULLTILE_WINDOW_DIR))
			return FALSE
		if(istype(O, /obj/structure/windoor_assembly))
			var/obj/structure/windoor_assembly/W = O
			if(W.ini_dir == dir_to_check || dir_to_check == FULLTILE_WINDOW_DIR)
				return FALSE
		if(istype(O, /obj/structure/window))
			var/obj/structure/window/W = O
			if(W.ini_dir == dir_to_check || W.ini_dir == FULLTILE_WINDOW_DIR || dir_to_check == FULLTILE_WINDOW_DIR)
				return FALSE
	return TRUE

/proc/get_var_from_type(type, variable)
	if(!type || !variable)
		return null
	var/obj = PoolOrNew(type)
	var/var_data = obj:vars[variable]
	PlaceInPool(obj,FALSE)
	return var_data
//Using in loadout system
/proc/slot_name_by_type(type)
	if(ispath(type, /obj/item/clothing/head))
		return "head"
	if(ispath(type, /obj/item/clothing/suit))
		return "armor"
	if(ispath(type, /obj/item/clothing/gloves))
		return "gloves"
	if(ispath(type, /obj/item/clothing/shoes))
		return "shoes"
	if(ispath(type, /obj/item/clothing/under))
		return "uniform"
	if(ispath(type, /obj/item/weapon) && !ispath(type, /obj/item/weapon/reagent_containers))
		return "weapon"
	return "misc"