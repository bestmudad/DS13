
SUBSYSTEM_DEF(vote)
	name = "Vote"
	wait = 10

	flags = SS_KEEP_TIMING|SS_NO_INIT

	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/list/choices = list()
	var/list/choice_by_ckey = list()
	var/list/generated_actions = list()
	var/initiator
	var/mode
	var/question
	var/started_time
	var/time_remaining
	var/list/voted = list()
	var/list/voting = list()

// Called by master_controller
/datum/controller/subsystem/vote/fire()
	if(!mode)
		return
	time_remaining = round((started_time + CONFIG_GET(number/vote_period) - world.time)/10)
	if(time_remaining < 0)
		result()
		SStgui.close_uis(src)
		reset()

/datum/controller/subsystem/vote/proc/reset()
	choices.Cut()
	choice_by_ckey.Cut()
	initiator = null
	mode = null
	question = null
	time_remaining = 0
	voted.Cut()
	voting.Cut()

	//remove_action_buttons()

/datum/controller/subsystem/vote/proc/get_result()
	//get the highest number of votes
	var/greatest_votes = 0
	var/total_votes = 0
	for(var/option in choices)
		var/votes = choices[option]
		total_votes += votes
		if(votes > greatest_votes)
			greatest_votes = votes
	//default-vote for everyone who didn't vote
	if(!CONFIG_GET(flag/default_no_vote) && choices.len)
		var/list/non_voters = GLOB.ckey_directory.Copy()
		non_voters -= voted
		for (var/non_voter_ckey in non_voters)
			var/client/C = non_voters[non_voter_ckey]
			if (!C || C.is_afk())
				non_voters -= non_voter_ckey
		if(non_voters.len > 0)
			if(mode == "restart")
				choices["Continue Playing"] += non_voters.len
				if(choices["Continue Playing"] >= greatest_votes)
					greatest_votes = choices["Continue Playing"]

	. = list()
	if(greatest_votes)
		for(var/option in choices)
			if(choices[option] == greatest_votes)
				. += option
	return .

/datum/controller/subsystem/vote/proc/announce_result()
	var/list/winners = get_result()
	var/text
	if(winners.len > 0)
		if(question)
			text += "<b>[question]</b>"
		else
			text += "<b>[capitalize(mode)] Vote</b>"
		for(var/i=1,i<=choices.len,i++)
			var/votes = choices[choices[i]]
			if(!votes)
				votes = 0
			text += "\n<b>[choices[i]]:</b> [votes]"
		if(mode != "custom")
			if(winners.len > 1)
				text = "\n<b>Vote Tied Between:</b>"
				for(var/option in winners)
					text += "\n\t[option]"
			. = pick(winners)
			text += "\n<b>Vote Result: [.]</b>"
		else
			text += "\n<b>Did not vote:</b> [GLOB.clients.len-voted.len]"
	else
		text += "<b>Vote Result: Inconclusive - No Votes!</b>"
	log_vote(text)
	//remove_action_buttons()
	to_chat(world, "\n<span class='infoplain'><font color='purple'>[text]</font></span>")
	return .

/datum/controller/subsystem/vote/proc/result()
	. = announce_result()
	var/restart = FALSE
	if(.)
		switch(mode)
			if("restart")
				if(. == "Restart Round")
					restart = TRUE
			if("gamemode")
				if(GLOB.master_mode != .)
					SSticker.save_mode(.)
					if(SSticker.HasRoundStarted())
						restart = TRUE
					else
						GLOB.master_mode = .
			if("next_map")
				var/datum/map_config/winning_map = config.maplist[.]
				if(!istype(winning_map))
					CRASH("[type] wasn't passed a valid winning map choice. (Got: [. || "null"] - [winning_map || "null"])")
				SSmapping.changemap(winning_map)
				SSmapping.map_voted = TRUE

	if(restart)
		var/active_admins = FALSE
		for(var/client/C in GLOB.admins)
			if(!C.is_afk() && check_rights(R_SERVER, FALSE, C))
				active_admins = TRUE
				break
		if(!active_admins)
			// No delay in case the restart is due to lag
			to_chat(world, "<span class='infoplain'>World restarting due to vote...</span>")

			feedback_set_details("end_error","restart vote")
			if(blackbox)
				blackbox.save_all_data_to_sql()
			sleep(50)
			log_game("Rebooting due to restart vote")
			world.Reboot(ping=TRUE)
		else
			to_chat(world, "<span style='boldannounce'>Notice:Restart vote will not restart the server automatically because there are active admins on.</span>")
			message_admins("A restart vote has passed, but there are active admins on with +server, so it has been canceled. If you wish, you may restart the server.")

	return .

/datum/controller/subsystem/vote/proc/submit_vote(vote)
	if(!mode)
		return FALSE
	if(CONFIG_GET(flag/no_dead_vote) && usr.stat == DEAD && !usr.client.holder)
		return FALSE
	if(!vote || vote < 1 || vote > choices.len)
		return FALSE
	// If user has already voted, remove their specific vote
	if(usr.ckey in voted)
		choices[choices[choice_by_ckey[usr.ckey]]]--
	else
		voted += usr.ckey
	choice_by_ckey[usr.ckey] = vote
	choices[choices[vote]]++
	return vote

/datum/controller/subsystem/vote/proc/initiate_vote(vote_type, initiator_key)
	//Server is still intializing.
	if(!Master.current_runlevel)
		to_chat(usr, SPAN_WARNING("Cannot start vote, server is not done initializing."))
		return FALSE
	var/lower_admin = FALSE
	var/ckey = ckey(initiator_key)
	if(GLOB.admin_datums[ckey])
		lower_admin = TRUE

	if(!mode)
		if(started_time)
			var/next_allowed_time = (started_time + CONFIG_GET(number/vote_delay))
			if(mode)
				to_chat(usr, SPAN_WARNING("There is already a vote in progress! please wait for it to finish."))
				return FALSE
			if(next_allowed_time > world.time && !lower_admin)
				to_chat(usr, SPAN_WARNING("A vote was initiated recently, you must wait [DisplayTimeText(next_allowed_time-world.time)] before a new vote can be started!"))
				return FALSE

		reset()
		switch(vote_type)
			if("restart")
				choices.Add("Restart Round","Continue Playing")
			if("gamemode")
				for(var/datum/game_mode/mode as anything in config.votable_modes)
					var/players = length(GLOB.clients)
					if(players < mode.required_players)
						continue
					choices.Add(mode.config_tag)
			if("next_map")
				for(var/map in shuffle(config.maplist))
					var/datum/map_config/possible_config = config.maplist[map]
					if(!possible_config.votable)
						continue
					if(possible_config.config_min_users > 0 && GLOB.clients.len < possible_config.config_min_users)
						continue
					if(possible_config.config_max_users > 0 && GLOB.clients.len > possible_config.config_max_users)
						continue
					choices += possible_config.map_name
			if("custom")
				question = stripped_input(usr,"What is the vote for?")
				if(!question)
					return FALSE
				for(var/i=1,i<=10,i++)
					var/option = capitalize(stripped_input(usr,"Please enter an option or hit cancel to finish"))
					if(!option || mode || !usr.client)
						break
					choices.Add(option)
			else
				return FALSE
		mode = vote_type
		initiator = initiator_key
		started_time = world.time
		var/text = "[capitalize(mode)] vote started by [initiator || "CentCom"]."
		if(mode == "custom")
			text += "\n[question]"
		log_vote(text)
		var/vp = CONFIG_GET(number/vote_period)
		to_chat(world, "\n<span class='infoplain'><font color='purple'><b>[text]</b>\nType <b>vote</b> or click <a href='?_src_=client;open_vote_menu=1'>here</a> to place your votes.\nYou have [DisplayTimeText(vp)] to vote.</font></span>")
		time_remaining = round(vp/10)
		for(var/c in GLOB.clients)
			var/client/C = c
			//var/datum/action/vote/V = new
			//if(question)
			//	V.name = "Vote: [question]"
			//C.player_details.player_actions += V
			//V.Grant(C.mob)
			//generated_actions += V
			SEND_SOUND(C, sound('sound/misc/bloop.ogg'))
		return TRUE
	return FALSE

/mob/verb/vote()
	set category = "OOC"
	set name = "Vote"
	SSvote.tgui_interact(usr)

/datum/controller/subsystem/vote/proc/automatic_vote()
	initiate_vote("gamemode", null, TRUE)

/datum/controller/subsystem/vote/ui_state()
	return GLOB.tgui_always_state

/datum/controller/subsystem/vote/tgui_interact(mob/user, datum/tgui/ui)
	// Tracks who is voting
	if(!(user.client?.ckey in voting))
		voting += user.client?.ckey
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Vote")
		ui.open()

/datum/controller/subsystem/vote/ui_data(mob/user)
	var/list/data = list(
		"allow_vote_mode" = CONFIG_GET(flag/allow_vote_mode),
		"allow_vote_restart" = CONFIG_GET(flag/allow_vote_restart),
		"allow_map_voting" = CONFIG_GET(flag/allow_map_voting),
		"choices" = list(),
		"lower_admin" = !!user.client?.holder,
		"mode" = mode,
		"question" = question,
		"selected_choice" = choice_by_ckey[user.client?.ckey],
		"time_remaining" = time_remaining,
		"upper_admin" = check_rights(R_ADMIN, FALSE, user.client),
		"voting" = list(),
	)

	if(!!user.client?.holder)
		data["voting"] = voting

	for(var/key in choices)
		data["choices"] += list(list(
			"name" = key,
			"votes" = choices[key] || 0
		))

	return data

/datum/controller/subsystem/vote/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/upper_admin = check_rights(R_ADMIN, FALSE, usr.client)

	switch(action)
		if("cancel")
			if(usr.client.holder)
				usr.log_message("[key_name_admin(usr)] cancelled a vote.", LOG_ADMIN)
				message_admins("[key_name_admin(usr)] has cancelled the current vote.")
				reset()
		if("toggle_restart")
			if(upper_admin)
				CONFIG_SET(flag/allow_vote_restart, !CONFIG_GET(flag/allow_vote_restart))
		if("restart")
			if(CONFIG_GET(flag/allow_vote_restart) || usr.client.holder)
				initiate_vote("restart", usr.key)
		if("toggle_gamemode")
			if(upper_admin)
				CONFIG_SET(flag/allow_vote_mode, !CONFIG_GET(flag/allow_vote_mode))
		if("toggle_next_map")
			if(upper_admin)
				CONFIG_SET(flag/allow_map_voting, !CONFIG_GET(flag/allow_map_voting))
		if("gamemode")
			if(CONFIG_GET(flag/allow_vote_mode) || usr.client.holder)
				initiate_vote("gamemode", usr.key)
		if("next_map")
			if(CONFIG_GET(flag/allow_map_voting) || usr.client.holder)
				initiate_vote("next_map", usr.key)
		if("custom")
			if(usr.client.holder)
				initiate_vote("custom", usr.key)
		if("vote")
			submit_vote(round(text2num(params["index"])))
	return TRUE

/datum/controller/subsystem/vote/ui_close(mob/user)
	voting -= user.client?.ckey
