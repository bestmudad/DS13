#define ASSIGNMENT_ANY "Any"
#define ASSIGNMENT_AI "AI"
#define ASSIGNMENT_CYBORG "Robot"
#define ASSIGNMENT_ENGINEER "Engineer"
#define ASSIGNMENT_GARDENER "Gardener"
#define ASSIGNMENT_JANITOR "Janitor"
#define ASSIGNMENT_MEDICAL "Medical"
#define ASSIGNMENT_SCIENTIST "Scientist"
#define ASSIGNMENT_SECURITY "Security"

var/global/list/severity_to_string = list(EVENT_LEVEL_MUNDANE = "Mundane", EVENT_LEVEL_MODERATE = "Moderate", EVENT_LEVEL_MAJOR = "Major")

/datum/event_container
	var/severity = -1
	var/delayed = 0
	var/delay_modifier = 1
	var/next_event_time = 0
	var/list/available_events
	var/list/last_event_time = list()
	var/datum/event_meta/next_event = null

	var/last_world_time = 0

/datum/event_container/proc/process()
	if(!next_event_time)
		set_event_delay()

	if(delayed || !CONFIG_GET(flag/allow_random_events))
		next_event_time += (world.time - last_world_time)
	else if(world.time > next_event_time)
		start_event()

	last_world_time = world.time

/datum/event_container/proc/start_event()
	if(!next_event)	// If non-one has explicitly set an event, randomly pick one
		next_event = acquire_event()

	// Has an event been acquired?
	if(next_event)
		// Set when the event of this type was last fired, and prepare the next event start
		last_event_time[next_event] = world.time
		set_event_delay()
		next_event.enabled = !next_event.one_shot	// This event will no longer be available in the random rotation if one shot

		new next_event.event_type(next_event)	// Events are added and removed from the processing queue in their New/kill procs

		log_debug("Starting event '[next_event.name]' of severity [severity_to_string[severity]].")
		next_event = null						// When set to null, a random event will be selected next time
	else
		// If not, wait for one minute, instead of one tick, before checking again.
		next_event_time += (60 * 10)


/datum/event_container/proc/acquire_event()
	if(available_events.len == 0)
		return
	var/active_with_role = number_active_with_role()

	var/list/possible_events = list()
	for(var/datum/event_meta/EM in available_events)
		var/event_weight = get_weight(EM, active_with_role)
		if(event_weight)
			possible_events[EM] = event_weight

	if(possible_events.len == 0)
		return null

	// Select an event and remove it from the pool of available events
	var/picked_event = pickweight(possible_events)
	available_events -= picked_event
	return picked_event

/datum/event_container/proc/get_weight(var/datum/event_meta/EM, var/list/active_with_role)
	if(!EM.enabled)
		return 0

	var/weight = EM.get_weight(active_with_role)
	var/last_time = last_event_time[EM]
	if(last_time)
		var/time_passed = world.time - last_time
		var/weight_modifier = max(0, round((CONFIG_GET(number/expected_round_length) - time_passed) / 300))
		weight = weight - weight_modifier

	return weight

/datum/event_container/proc/set_event_delay()
	// If the next event time has not yet been set and we have a custom first time start
	if(next_event_time == 0 && EVENT_FIRST_RUN[severity])
		var/lower = EVENT_FIRST_RUN[severity]["lower"]
		var/upper = EVENT_FIRST_RUN[severity]["upper"]
		var/event_delay = rand(lower, upper)
		next_event_time = world.time + event_delay
	// Otherwise, follow the standard setup process
	else
		var/playercount_modifier = 1
		switch(GLOB.player_list.len)
			if(0 to 10)
				playercount_modifier = 1.2
			if(11 to 15)
				playercount_modifier = 1.1
			if(16 to 25)
				playercount_modifier = 1
			if(26 to 35)
				playercount_modifier = 0.9
			if(36 to 100000)
				playercount_modifier = 0.8
		playercount_modifier = playercount_modifier * delay_modifier

		var/event_delay = rand(EVENT_DELAY_LOWER[severity], EVENT_DELAY_UPPER[severity]) * playercount_modifier
		next_event_time = world.time + event_delay

	log_debug("Next event of severity [severity_to_string[severity]] in [(next_event_time - world.time)/600] minutes.")

/datum/event_container/proc/SelectEvent()
	var/datum/event_meta/EM = input("Select an event to queue up.", "Event Selection", null) as null|anything in available_events
	if(!EM)
		return
	if(next_event)
		available_events += next_event
	available_events -= EM
	next_event = EM
	return EM

/datum/event_container/mundane
	severity = EVENT_LEVEL_MUNDANE
	available_events = list(
		// Severity level, event name, even type, base weight, role weights, one shot, min weight, max weight. Last two only used if set and non-zero
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Nothing",			/datum/event/nothing,			100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "APC Damage",		/datum/event/apc_damage,		20, 	list(ASSIGNMENT_ENGINEER = 10)),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Computer Damage",		/datum/event/computer_damage,		20, 	list(ASSIGNMENT_ENGINEER = 10)),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Camera Damage",		/datum/event/camera_damage,		20, 	list(ASSIGNMENT_ENGINEER = 10)),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Money Hacker",		/datum/event/money_hacker, 		0, 		list(ASSIGNMENT_ANY = 4), 1, 10, 25),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Money Lotto",		/datum/event/money_lotto, 		0, 		list(ASSIGNMENT_ANY = 1), 1, 5, 15),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Shipping Error",	/datum/event/shipping_error	, 	30, 	list(ASSIGNMENT_ANY = 2), 0),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Electrical Storm",	/datum/event/electrical_storm, 	20,		list(ASSIGNMENT_ENGINEER = 20, ASSIGNMENT_JANITOR = 100)),
	)

/datum/event_container/mundane/New()
	..()
	if(istype(GLOB.using_map, /datum/map/ishimura))
		available_events += new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Space Dust", /datum/event/dust, 30, list(ASSIGNMENT_ENGINEER = 10))
		available_events += new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Meteor Shower", /datum/event/meteor_wave/ishimura, 150, list(ASSIGNMENT_ENGINEER = 20))

/datum/event_container/moderate
	severity = EVENT_LEVEL_MODERATE
	available_events = list(
		// 						Severity level, 		event name, 				event type, 							base weight, role weights, one shot, min weight, max weight. Last two only used if set and non-zero
		new /datum/event_meta(	EVENT_LEVEL_MODERATE, 	"Nothing",					/datum/event/nothing,					1030),
		new /datum/event_meta(	EVENT_LEVEL_MODERATE, 	"Communication Blackout",	/datum/event/communications_blackout,	100,	list(ASSIGNMENT_AI = 100, ASSIGNMENT_ENGINEER = 20)),
		new /datum/event_meta(	EVENT_LEVEL_MODERATE, 	"Electrical Storm",			/datum/event/electrical_storm, 			10,		list(ASSIGNMENT_ENGINEER = 15, ASSIGNMENT_JANITOR = 10)),

		new /datum/event_meta(	EVENT_LEVEL_MODERATE, 	"Grid Check",				/datum/event/grid_check, 				200,	list(ASSIGNMENT_ENGINEER = 10)),
		new /datum/event_meta(	EVENT_LEVEL_MODERATE, 	"Ion Storm",				/datum/event/ionstorm, 					0,		list(ASSIGNMENT_AI = 50, ASSIGNMENT_CYBORG = 50, ASSIGNMENT_ENGINEER = 15, ASSIGNMENT_SCIENTIST = 5)),
		)

/datum/event_container/mundane/New()
	..()
	if(istype(GLOB.using_map, /datum/map/ishimura))
		available_events += new /datum/event_meta(	EVENT_LEVEL_MODERATE, 	"Gravity Failure",			/datum/event/gravity,	 				75,		list(ASSIGNMENT_ENGINEER = 25))
		available_events += new /datum/event_meta(	EVENT_LEVEL_MODERATE, 	"Meteor Shower",			/datum/event/meteor_wave/ishimura,		400,		list(ASSIGNMENT_ENGINEER = 20))

/*
	Major events are reserved for crew objectives.
*/
/datum/event_container/major
	severity = EVENT_LEVEL_MAJOR
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Nothing",				/datum/event/nothing,			5),
		)


#undef ASSIGNMENT_ANY
#undef ASSIGNMENT_AI
#undef ASSIGNMENT_CYBORG
#undef ASSIGNMENT_ENGINEER
#undef ASSIGNMENT_GARDENER
#undef ASSIGNMENT_JANITOR
#undef ASSIGNMENT_MEDICAL
#undef ASSIGNMENT_SCIENTIST
#undef ASSIGNMENT_SECURITY
