
/datum/stack_recipe/furniture
	one_per_turf = 1
	on_floor = 1
	difficulty = 2
	send_material_data = 1
	time = 5

/datum/stack_recipe/furniture/chair
	title = "chair"
	result_type = /obj/structure/bed/chair
	time = 10
	var/list/modifiers

/datum/stack_recipe/furniture/chair/display_name()
	return modifiers ? jointext(modifiers + ..(), " ") : ..()

/datum/stack_recipe/furniture/chair/padded
	req_amount = 2

#define PADDED_CHAIR(color) /datum/stack_recipe/furniture/chair/padded/##color{\
	result_type = /obj/structure/bed/chair/padded/##color;\
	modifiers = list("padded", #color);\
	}
PADDED_CHAIR(beige)
PADDED_CHAIR(black)
PADDED_CHAIR(brown)
PADDED_CHAIR(lime)
PADDED_CHAIR(teal)
PADDED_CHAIR(red)
PADDED_CHAIR(purple)
PADDED_CHAIR(green)
PADDED_CHAIR(yellow)
#undef PADDED_CHAIR

/datum/stack_recipe/furniture/chair/office
	title = "office chair"
	req_amount = 5

/datum/stack_recipe/furniture/chair/office/display_name()
	return modifiers ? jointext(modifiers + title, " ") : title // Bypass material

/datum/stack_recipe/furniture/chair/office/light
	result_type = /obj/structure/bed/chair/office/light
	modifiers = list("light")

/datum/stack_recipe/furniture/chair/office/dark
	result_type = /obj/structure/bed/chair/office/dark
	modifiers = list("dark")

/datum/stack_recipe/furniture/chair/office/comfy
	req_amount = 7

#define COMFY_OFFICE_CHAIR(color) /datum/stack_recipe/furniture/chair/office/comfy/##color{\
	result_type = /obj/structure/bed/chair/office/comfy/##color;\
	modifiers = list(#color, "comfy");\
	}
COMFY_OFFICE_CHAIR(beige)
COMFY_OFFICE_CHAIR(black)
COMFY_OFFICE_CHAIR(brown)
COMFY_OFFICE_CHAIR(lime)
COMFY_OFFICE_CHAIR(teal)
COMFY_OFFICE_CHAIR(red)
COMFY_OFFICE_CHAIR(purple)
COMFY_OFFICE_CHAIR(green)
COMFY_OFFICE_CHAIR(yellow)
#undef COMFY_OFFICE_CHAIR

/datum/stack_recipe/furniture/chair/comfy
	title = "comfy chair"
	req_amount = 3

#define COMFY_CHAIR(color) /datum/stack_recipe/furniture/chair/comfy/##color{\
	result_type = /obj/structure/bed/chair/comfy/##color;\
	modifiers = list(#color);\
	}
COMFY_CHAIR(beige)
COMFY_CHAIR(black)
COMFY_CHAIR(brown)
COMFY_CHAIR(lime)
COMFY_CHAIR(teal)
COMFY_CHAIR(red)
COMFY_CHAIR(purple)
COMFY_CHAIR(green)
COMFY_CHAIR(yellow)
#undef COMFY_CHAIR

/datum/stack_recipe/furniture/chair/arm
	title = "armchair"
	req_amount = 4

#define ARMCHAIR(color) /datum/stack_recipe/furniture/chair/arm/##color{\
	result_type = /obj/structure/bed/chair/armchair/##color;\
	modifiers = list(#color);\
	}
ARMCHAIR(beige)
ARMCHAIR(black)
ARMCHAIR(brown)
ARMCHAIR(lime)
ARMCHAIR(teal)
ARMCHAIR(red)
ARMCHAIR(purple)
ARMCHAIR(green)
ARMCHAIR(yellow)
#undef ARMCHAIR

/datum/stack_recipe/furniture/chair/wood
	req_amount = 3

/datum/stack_recipe/furniture/chair/wood/normal
	result_type = /obj/structure/bed/chair/wood

/datum/stack_recipe/furniture/chair/wood/fancy
	result_type = /obj/structure/bed/chair/wood/wings
	modifiers = list("fancy")

/datum/stack_recipe/furniture/door
	title = "door"
	result_type = /obj/machinery/door/unpowered/simple
	req_amount = 10
	time = 50
	send_material_data = 0

/datum/stack_recipe/furniture/barricade
	title = "barricade"
	result_type = /obj/structure/barricade
	req_amount = 5
	time = 50

/datum/stack_recipe/furniture/stool
	title = "stool"
	result_type = /obj/item/stool

/datum/stack_recipe/furniture/bar_stool
	title = "bar_stool"
	result_type = /obj/item/stool/bar

/datum/stack_recipe/furniture/bed
	title = "bed"
	result_type = /obj/structure/bed
	req_amount = 2

/datum/stack_recipe/furniture/table_frame
	title = "table frame"
	result_type = /obj/structure/table
	time = 10

/datum/stack_recipe/furniture/rack
	title = "rack"
	result_type = /obj/structure/table/rack

/datum/stack_recipe/furniture/closet
	title = "closet"
	result_type = /obj/structure/closet
	req_amount = 2
	time = 15

/datum/stack_recipe/furniture/canister
	title = "canister"
	result_type = /obj/machinery/portable_atmospherics/canister
	req_amount = 10
	time = 10
	send_material_data = 0

/datum/stack_recipe/furniture/computerframe
	title = "computer frame"
	result_type = /obj/structure/computerframe
	req_amount = 5
	time = 25

/datum/stack_recipe/furniture/girder
	title = "wall girders"
	result_type = /obj/structure/girder
	req_amount = 10
	time = 50

/datum/stack_recipe/furniture/wall
	title = "low wall frame"
	result_type = /obj/structure/wall_frame
	req_amount = 2
	time = 50

/datum/stack_recipe/furniture/machine
	title = "machine frame"
	result_type = /obj/machinery/constructable_frame/machine_frame
	req_amount = 5
	time = 25
	send_material_data = 0



/datum/stack_recipe/furniture/door_assembly
	req_amount = 4
	time = 50

/datum/stack_recipe/furniture/door_assembly/standard
	title = "standard airlock assembly"
	result_type = /obj/structure/door_assembly

/datum/stack_recipe/furniture/door_assembly/airtight
	title = "airtight hatch assembly"
	result_type = /obj/structure/door_assembly/door_assembly_hatch

/datum/stack_recipe/furniture/door_assembly/highsec
	title = "high security airlock assembly"
	result_type = /obj/structure/door_assembly/door_assembly_highsecurity

/datum/stack_recipe/furniture/door_assembly/firedoor
	title = "emergency shutter"
	result_type = /obj/structure/firedoor_assembly

/datum/stack_recipe/furniture/door_assembly/multi_tile
	title = "multi-tile airlock assembly"
	result_type = /obj/structure/door_assembly/multi_tile

/datum/stack_recipe/furniture/crate
	title = "crate"
	result_type = /obj/structure/closet/crate
	req_amount = 10
	time = 50

/datum/stack_recipe/furniture/crate/plastic
	result_type = /obj/structure/closet/crate/plastic

/datum/stack_recipe/furniture/flaps
	title = "flaps"
	result_type = /obj/structure/plasticflaps
	req_amount = 30
	time = 50

/datum/stack_recipe/furniture/coffin
	title = "coffin"
	result_type = /obj/structure/closet/coffin
	req_amount = 5
	time = 15

/datum/stack_recipe/furniture/bookcase
	title = "book shelf"
	result_type = /obj/structure/bookcase
	req_amount = 5
	time = 15

/datum/stack_recipe/furniture/planting_bed
	title = "planting bed"
	result_type = /obj/machinery/portable_atmospherics/hydroponics/soil
	req_amount = 3
	time = 10
	send_material_data = 0