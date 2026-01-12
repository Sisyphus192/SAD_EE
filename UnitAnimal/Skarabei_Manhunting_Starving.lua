UndefineClass('Skarabei_Manhunting_Starving')
DefineClass.Skarabei_Manhunting_Starving = {
	__parents = { "GroundAnimal" },
	__generated_by_class = "ModItemUnitAnimalCompositeDef",


	object_class = "GroundAnimal",
	SpeciesGroup = "species_skarabei",
	composite_part_groups = {
		"Skarabei_Manhunting",
	},
	CombatGroup = "StarvingInsects",
	HumanThreat = true,
	Icon = "UI/Icons/Resources/res_skarabei",
	DisplayName = T(922768912350, --[[ModItemUnitAnimalCompositeDef Skarabei_Manhunting_Starving DisplayName]] "Starving skarabei"),
	DisplayNamePl = T(509071208264, --[[ModItemUnitAnimalCompositeDef Skarabei_Manhunting_Starving DisplayNamePl]] "Starving skarabei"),
	DisplayNameUnknown = T(777301905161, --[[ModItemUnitAnimalCompositeDef Skarabei_Manhunting_Starving DisplayNameUnknown]] "Starving overgrown insect"),
	DisplayNameUnknownPL = T(767325899547, --[[ModItemUnitAnimalCompositeDef Skarabei_Manhunting_Starving DisplayNameUnknownPL]] "Starving overgrown insects"),
	Description = T(517010502374, --[[ModItemUnitAnimalCompositeDef Skarabei_Manhunting_Starving Description]] "A small starving Skarabei. It's not aggressive but will eat unprotected food, carcasses and plant harvest."),
	FoodResources = {
		"FoodAnimalHerbivore",
		"FoodAnimalCarnivore",
		"Slop",
	},
	FoodSourceClasses = {
		"UnitCorpse",
		"ResourcePile",
		"Plant",
		"AnimalFeeder",
	},
	ButcherResources = {
		PlaceObj('ButcherResAmount', {
			'resource', "RawMeatInsect",
			'min_amount', 2000,
		}),
	},
	EatIdleAnim = {
		"eat",
	},
	anim_idle_nervous = {
		"idle_Nervous",
	},
}

