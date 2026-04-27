UndefineClass('Shrieker')
DefineClass.Shrieker = {
	__parents = { "UnitNesting", "Shrieker_Manhunting" },
	__generated_by_class = "ModItemUnitAnimalCompositeDef",


	comment = "base unit, T1",
	object_class = "Shrieker_Manhunting",
	SpeciesGroup = "species_shrieker",
	RoamIntervalMax = 80000,
	composite_part_groups = {
		"Shrieker",
	},
	CombatGroup = "Shriekers",
	lead_priority = 3,
	DisplayName = T(642604017665, --[[ModItemUnitAnimalCompositeDef Shrieker DisplayName]] "Nesting shrieker"),
	DisplayNamePl = T(331973526630, --[[ModItemUnitAnimalCompositeDef Shrieker DisplayNamePl]] "Nesting shriekers"),
	Description = T(390008654202, --[[ModItemUnitAnimalCompositeDef Shrieker Description]] "Highly aggressive territorial insect. Will attack everything near the nest. The nest entrance covers an underground hive that grows overtime and spawns more guardians."),
	EatingDuration = 4000,
	pfclass_tamed_lead = 13,
	NewbornClass = "Shrieker_Manhunting_Mother",
	MinGrownScale = 100,
	UnitNesting = true,
	CanBurrowInNest = true,
}

