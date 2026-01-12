UndefineClass('Skarabei_Manhunting_Explosive')
DefineClass.Skarabei_Manhunting_Explosive = {
	__parents = { "GroundAnimal" },
	__generated_by_class = "ModItemUnitAnimalCompositeDef",


	object_class = "GroundAnimal",
	SpeciesGroup = "species_skarabei",
	pfclass = 5,
	composite_part_groups = {
		"Skarabei_Manhunting",
	},
	EventProgressValue = 40,
	SpawnDefWeight = 20,
	SpawnTags = set( "Boss" ),
	max_skinned_decals = 2,
	lead_priority = 1,
	Icon = "UI/Icons/Resources/res_skarabei",
	DisplayName = T(271167992950, --[[ModItemUnitAnimalCompositeDef Skarabei_Manhunting_Explosive DisplayName]] "Explosive skarabei"),
	DisplayNamePl = T(703916265435, --[[ModItemUnitAnimalCompositeDef Skarabei_Manhunting_Explosive DisplayNamePl]] "Explosive skarabei"),
	DisplayNameUnknown = T(476779391950, --[[ModItemUnitAnimalCompositeDef Skarabei_Manhunting_Explosive DisplayNameUnknown]] "Bloated overgrown insect"),
	DisplayNameUnknownPL = T(269860301943, --[[ModItemUnitAnimalCompositeDef Skarabei_Manhunting_Explosive DisplayNameUnknownPL]] "Bloated overgrown insects"),
	Description = T(749036829484, --[[ModItemUnitAnimalCompositeDef Skarabei_Manhunting_Explosive Description]] "Due to ill mutations, this skarabei is accumulating volatile liquids in its soft tissues, if its chitin shell breaks they will explode."),
	BaseMaxHealth = 40000,
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
			'min_amount', 25000,
		}),
	},
	BodySize = "medium",
	DeathWeapon = "SkarabeiDeathExplosion",
	AnimalPerks = {
		"ExplosiveGuts",
	},
	EatIdleAnim = {
		"eat",
	},
	anim_idle_nervous = {
		"idle_Nervous",
	},
}

