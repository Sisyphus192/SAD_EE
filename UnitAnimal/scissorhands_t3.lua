UndefineClass('scissorhands_t3')
DefineClass.scissorhands_t3 = {
	__parents = { "Scissorhands", "UnitPerkFrenzy" },
	__generated_by_class = "ModItemUnitAnimalCompositeDef",


	object_class = "Scissorhands",
	EventProgressValue = 350,
	SpawnDefWeight = 30,
	CombatHostile = false,
	HitNegationChance = {
		blunt = 30,
		energy = 30,
		gas = 15,
		pacify = 40,
		piercing = 15,
	},
	HitNegationChance_blunt = 30,
	HitNegationChance_piercing = 15,
	HitNegationChance_energy = 30,
	HitNegationChance_gas = 15,
	HitNegationChance_pacify = 40,
	HumanThreat = true,
	RobotThreat = true,
	FieldResearchTech = "Field_Scissorhands_T2",
	lead_priority = 12,
	DisplayName = T(--[[ModItemUnitAnimalCompositeDef scissorhands_t3 DisplayName]] "Brutal Scissorhand Duelist"),
	DisplayNamePl = T(--[[ModItemUnitAnimalCompositeDef scissorhands_t3 DisplayNamePl]] "Brutal Scissorhand Duelist"),
	DisplayNameUnknown = T(568883049640, --[[ModItemUnitAnimalCompositeDef scissorhands_t3 DisplayNameUnknown]] "Unknown Scissorhands Evolution"),
	DisplayNameUnknownPL = T(183266165907, --[[ModItemUnitAnimalCompositeDef scissorhands_t3 DisplayNameUnknownPL]] "Unknown Scissorhands Evolution"),
	Description = T(810154241954, --[[ModItemUnitAnimalCompositeDef scissorhands_t3 Description]] "Blades that are honed by attacking or defending from other Scissorhands. If this blade touches us, it will be more likely to deal critical wounds. Able to deftly dodge blunt force, and dissapates any energy attacks with ease. Deals <color TextSubtitleBlue>Piercing</color> damage."),
	BaseMaxHealth = 400000,
	DailyEatingAmount = 3000,
	ButcherResources = {
		PlaceObj('ButcherResAmount', {
			'resource', "RawMeatInsect",
			'min_amount', 40000,
		}),
	},
	ProduceResources = {
		PlaceObj('ResAmount', {
			'resource', "Stone",
			'amount', 45000,
		}),
	},
	ProduceResInterval = 2400000,
	AnimalPerks = {
		"StrongAnimal",
		"StoneDigger",
		"DraftableAnimal",
	},
	attack_weapon = "ScissorhandsMelee_Brute",
	TamingChance = 60,
	DailyPregnancyChance = 70,
	PregnancyDuration = 3840000,
	GrowDuration = 3840000,
	NewbornClass = "scissorhands_t4",
	MinNewbornScale = 60,
	MaxNewbornScale = 60,
	MinGrownScale = 115,
	MaxGrownScale = 120,
	UnitPerkFrenzy = true,
	FrenzyHealthPct = 99,
	FrenzyEffects = {
		"Frenzy_Conscious_2",
	},
}

