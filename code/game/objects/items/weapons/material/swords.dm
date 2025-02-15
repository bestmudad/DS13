/obj/item/material/sword
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "claymore"
	item_state = "claymore"
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_LARGE
	tool_qualities = list(QUALITY_CUTTING = 40, QUALITY_WIRE_CUTTING = 10)
	force_divisor = 0.5 // 20 when wielded with hardnes 60 (steel)
	thrown_force_divisor = 0.5 // 10 when thrown with weight 20 (steel)
	sharp = 1
	edge = 1
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	attack_noun = list("attack", "slash", "stab", "slice", "tear", "rip", "dice", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	base_parry_chance = 50
	melee_accuracy_bonus = 10

/obj/item/material/sword/replica
	tool_qualities = list()
	edge = 0
	sharp = 0
	force_divisor = 0.2
	thrown_force_divisor = 0.2

/obj/item/material/sword/katana
	name = "katana"
	desc = "Woefully underpowered in D20. This one looks pretty sharp."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	slot_flags = SLOT_BELT | SLOT_BACK
	tool_qualities = list(QUALITY_CUTTING = 40, QUALITY_WIRE_CUTTING = 10)

/obj/item/material/sword/katana/replica
	tool_qualities = list()
	edge = 0
	sharp = 0
	force_divisor = 0.2
	thrown_force_divisor = 0.2
