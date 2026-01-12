UndefineClass('juno_t3')
DefineClass.juno_t3 = {
	__parents = { "Juno", "UnitPerkFrenzy" },
	__generated_by_class = "ModItemUnitAnimalCompositeDef",


	object_class = "Juno",
	EventProgressValue = 900,
	SpawnDefWeight = 30,
	CombatHostile = false,
	HitNegationChance = {
		blunt = 15,
		energy = 15,
		gas = 15,
		pacify = 20,
		piercing = 15,
	},
	HitNegationChance_blunt = 15,
	HitNegationChance_piercing = 15,
	HitNegationChance_energy = 15,
	HitNegationChance_gas = 15,
	HitNegationChance_pacify = 20,
	HumanThreat = true,
	RobotThreat = true,
	FieldResearchTech = "Field_Juno_T2",
	ForcedApproachPlanning = true,
	lead_priority = 6,
	DisplayName = T(--[[ModItemUnitAnimalCompositeDef juno_t3 DisplayName]] "Angry Juno"),
	DisplayNamePl = T(--[[ModItemUnitAnimalCompositeDef juno_t3 DisplayNamePl]] "Angry Juno"),
	DisplayNameUnknown = T(--[[ModItemUnitAnimalCompositeDef juno_t3 DisplayNameUnknown]] "Unknown Juno Evolution"),
	DisplayNameUnknownPL = T(--[[ModItemUnitAnimalCompositeDef juno_t3 DisplayNameUnknownPL]] "Unknown Juno Evolution"),
	Description = T(191163878118, --[[ModItemUnitAnimalCompositeDef juno_t3 Description]] "This Juno's species has focused it's biology on killing, and identifying what needs to be killed next. Low defenses, high damage. Deals <color TextButton>Blunt</color> damage."),
	BaseMaxHealth = 500000,
	DailyEatingAmount = 2000,
	ButcherResources = {
		PlaceObj('ButcherResAmount', {
			'resource', "RawMeatInsect",
			'min_amount', 75000,
		}),
	},
	ProduceResources = {
		PlaceObj('ResAmount', {
			'resource', "Stone",
			'amount', 75000,
		}),
	},
	ProduceResInterval = 2400000,
	AnimalPerks = {
		"StrongAnimal",
		"BloodFrenzy",
		"SmartPredator",
		"StoneDigger",
		"DraftableAnimal",
	},
	attack_weapon = "JunoMelee_Brute",
	DailyPregnancyChance = 90,
	PregnancyDuration = 3840000,
	GrowDuration = 3840000,
	NewbornClass = "juno_t4",
	UnitPerkFrenzy = true,
	FrenzyHealthPct = 99,
	FrenzyEffects = {
		"JunoFrenzy",
		"Frenzy_Conscious_2",
		"Frenzy_Fast",
	},
}

