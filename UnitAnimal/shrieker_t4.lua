UndefineClass('shrieker_t4')
DefineClass.shrieker_t4 = {
	__parents = { "UnitNesting", "Shrieker_Manhunting", "UnitAreaEffect", "UnitPerkFrenzy" },
	__generated_by_class = "ModItemUnitAnimalCompositeDef",


	object_class = "Shrieker_Manhunting",
	SpeciesGroup = "species_shrieker",
	EventProgressValue = 1100,
	SpawnDefWeight = 30,
	CombatHostile = false,
	CombatUseCover = true,
	HitNegationChance = {
		blunt = 25,
		energy = 15,
		gas = 15,
		pacify = 60,
		piercing = 55,
	},
	HitNegationChance_blunt = 25,
	HitNegationChance_piercing = 55,
	HitNegationChance_energy = 15,
	HitNegationChance_gas = 15,
	HitNegationChance_pacify = 60,
	HumanThreat = true,
	RobotThreat = true,
	FieldResearchTech = "Field_Shrieker_T2",
	lead_priority = 6,
	DisplayName = T(--[[ModItemUnitAnimalCompositeDef shrieker_t4 DisplayName]] "Plague Sniper Shrieker"),
	DisplayNamePl = T(--[[ModItemUnitAnimalCompositeDef shrieker_t4 DisplayNamePl]] "Plague Sniper Shrieker"),
	DisplayNameUnknown = T(632905210618, --[[ModItemUnitAnimalCompositeDef shrieker_t4 DisplayNameUnknown]] "Unknown Shrieker Evolution"),
	DisplayNameUnknownPL = T(256115533630, --[[ModItemUnitAnimalCompositeDef shrieker_t4 DisplayNameUnknownPL]] "Unknown Shrieker Evolution"),
	Description = T(197605412242, --[[ModItemUnitAnimalCompositeDef shrieker_t4 Description]] "Attacks that slow, and longer range than even our upgraded railguns. All while their durability has increased.... Thankfully still weak to energy and gas weapons. Deals <color TextButton>Blunt</color> and <color TextSubtitleBlue>Piercing</color> damage."),
	BaseMaxHealth = 600000,
	DailyEatingAmount = 3000,
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
	CmdProduceResources = function (animal)
		if not animal:IsTamed() then return animal:UpdateProductionTime() end
		return animal:DoProduceResourcesDiminishingReturns()
	end,
	AnimalPerks = {
		"StrongAnimal",
		"SmartPredator",
		"StoneDigger",
		"DraftableAnimal",
	},
	attack_weapon = "shriker_range_long",
	DailyPregnancyChance = 80,
	PregnancyDuration = 2880000,
	GrowDuration = 2880000,
	NewbornClass = "shrieker_t5",
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
		"Frenzy_Conscious_3",
	},
}

