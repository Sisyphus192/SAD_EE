UndefineClass('Skarabei_Manhunting_Poisonous')
DefineClass.Skarabei_Manhunting_Poisonous = {
	__parents = { "GroundAnimal" },
	__generated_by_class = "ModItemUnitAnimalCompositeDef",


	object_class = "GroundAnimal",
	SpeciesGroup = "species_skarabei",
	composite_part_groups = {
		"Skarabei_Manhunting",
	},
	EventProgressValue = 12,
	Icon = "UI/Icons/Resources/res_skarabei",
	DisplayName = T(968213114915, --[[ModItemUnitAnimalCompositeDef Skarabei_Manhunting_Poisonous DisplayName]] "Poisonous skarabei"),
	DisplayNamePl = T(538393700924, --[[ModItemUnitAnimalCompositeDef Skarabei_Manhunting_Poisonous DisplayNamePl]] "Poisonous skarabei"),
	DisplayNameUnknown = T(533255825612, --[[ModItemUnitAnimalCompositeDef Skarabei_Manhunting_Poisonous DisplayNameUnknown]] "Venomous overgrown insect"),
	DisplayNameUnknownPL = T(524442236448, --[[ModItemUnitAnimalCompositeDef Skarabei_Manhunting_Poisonous DisplayNameUnknownPL]] "Venomous overgrown insects"),
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
			'min_amount', 5000,
		}),
	},
	AnimalPerks = {
		"Poisonous",
	},
	attack_weapon = "PoisonousSkarabeiWeapon",
	EatIdleAnim = {
		"eat",
	},
	anim_idle_nervous = {
		"idle_Nervous",
	},
}

