UndefineClass('Shrieker_T2')
DefineClass.Shrieker_T2 = {
	__parents = { "UnitNesting", "Shrieker_Manhunting", "UnitAreaEffect", "UnitPerkFrenzy" },
	__generated_by_class = "ModItemUnitAnimalCompositeDef",


	object_class = "Shrieker_Manhunting",
	SpeciesGroup = "species_shrieker",
	EventProgressValue = 750,
	SpawnDefWeight = 30,
	SpawnTags = set(),
	CombatHostile = false,
	CombatUseCover = true,
	HitNegationChance = {
		blunt = 10,
		energy = 10,
		gas = 10,
		pacify = 40,
		piercing = 50,
	},
	HitNegationChance_blunt = 10,
	HitNegationChance_piercing = 50,
	HitNegationChance_energy = 10,
	HitNegationChance_gas = 10,
	HitNegationChance_pacify = 40,
	HumanThreat = true,
	RobotThreat = true,
	FieldResearchTech = "Field_Shrieker_T2",
	lead_priority = 6,
	DisplayName = T(210096238503, --[[ModItemUnitAnimalCompositeDef Shrieker_T2 DisplayName]] "Entropic Shrieker"),
	DisplayNamePl = T(383358412796, --[[ModItemUnitAnimalCompositeDef Shrieker_T2 DisplayNamePl]] "Entropic Shrieker"),
	DisplayNameUnknown = T(982950825877, --[[ModItemUnitAnimalCompositeDef Shrieker_T2 DisplayNameUnknown]] "Unknown Shrieker Evolution"),
	DisplayNameUnknownPL = T(561769342615, --[[ModItemUnitAnimalCompositeDef Shrieker_T2 DisplayNameUnknownPL]] "Unknown Shrieker Evolution"),
	Description = T(957198603241, --[[ModItemUnitAnimalCompositeDef Shrieker_T2 Description]] "Shrieker's who have evolved long barbed spikes. Resistant to piercing attacks, the barbs fully pierce and lodge in nearby terrain, lowering movement speed. Deals <color TextButton>Blunt</color> and <color TextSubtitleBlue>Piercing</color> damage."),
	BaseMaxHealth = 400000,
	DailyEatingAmount = 2000,
	ButcherResources = {
		PlaceObj('ButcherResAmount', {
			'resource', "RawMeatInsect",
			'min_amount', 75000,
		}),
	},
	ChanceToBeMale = 50,
	ProduceResources = {
		PlaceObj('ResAmount', {
			'resource', "CarbonNanotubes",
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
	attack_weapon = "shriker_range_move",
	TamingChance = 60,
	DailyPregnancyChance = 70,
	PregnancyDuration = 3840000,
	GrowDuration = 3840000,
	NewbornClass = "Shrieker_T4",
	UnitAreaEffect = true,
	UnitNesting = true,
	UnitPerkFrenzy = true,
	AffectRadius = 25000,
	AffectClass = "UnitAnimal",
	Effects = {
		PlaceObj('AreaEffectHealthCondition', {
			BodyPartGroup = "WholeBody",
			HealthCond = "BroodMotherNearby",
			HealthCondType = "Buff",
		}),
	},
	Disabled = function (self)
		return self:IsDead() or self:IsUnconscious()
	end,
	AffectFilter = function (self, target)
		return target.CombatGroup == self.CombatGroup
			and target:HasUnitTag("AgitatedByPheromones")
			and not target:IsDead()
			and not target:IsUnconscious()
	end,
	FrenzyHealthPct = 99,
	FrenzyEffects = {
		"Frenzy_Conscious_2",
	},
}

