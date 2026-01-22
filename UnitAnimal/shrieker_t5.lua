UndefineClass('Shrieker_T5')
DefineClass.Shrieker_T5 = {
	__parents = { "UnitNesting", "Shrieker_Manhunting", "UnitAreaEffect", "UnitPerkFrenzy" },
	__generated_by_class = "ModItemUnitAnimalCompositeDef",


	object_class = "Shrieker_Manhunting",
	SpeciesGroup = "species_shrieker",
	EventProgressValue = 2000,
	SpawnDefWeight = 30,
	CombatHostile = false,
	CombatUseCover = true,
	HitNegationChance = {
		blunt = 75,
		energy = 25,
		gas = 50,
		pacify = 80,
		piercing = 90,
	},
	HitNegationChance_blunt = 75,
	HitNegationChance_piercing = 90,
	HitNegationChance_energy = 25,
	HitNegationChance_gas = 50,
	HitNegationChance_pacify = 80,
	HumanThreat = true,
	RobotThreat = true,
	FieldResearchTech = "Field_Shrieker_T4",
	lead_priority = 6,
	DisplayName = T(219852402884, --[[ModItemUnitAnimalCompositeDef Shrieker_T5 DisplayName]] "Sniping Entropic Shielded Shrieker"),
	DisplayNamePl = T(394183373238, --[[ModItemUnitAnimalCompositeDef Shrieker_T5 DisplayNamePl]] "Sniping Entropic Shielded Shrieker"),
	DisplayNameUnknown = T(358521198402, --[[ModItemUnitAnimalCompositeDef Shrieker_T5 DisplayNameUnknown]] "Unknown Shrieker Evolution"),
	DisplayNameUnknownPL = T(224838244446, --[[ModItemUnitAnimalCompositeDef Shrieker_T5 DisplayNameUnknownPL]] "Unknown Shrieker Evolution"),
	Description = T(919946988433, --[[ModItemUnitAnimalCompositeDef Shrieker_T5 Description]] "A regenerating, long range, durable Shrieker. The only thing that can reliably hit them are energy weapons, filling their sealed exoskeleton with energy. Deals <color TextButton>Blunt</color> and <color TextSubtitleBlue>Piercing</color> damage."),
	BaseMaxHealth = 1000000,
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
		"SmartPredator",
		"StoneDigger",
		"DraftableAnimal",
		"AP_Fortified",
		"AP_Regen",
	},
	attack_weapon = "shriker_range_long",
	TamingMinimumSkill = 8,
	TamingChance = 25,
	DailyPregnancyChance = 65,
	PregnancyDuration = 1920000,
	GrowDuration = 1920000,
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
		"Frenzy_Regen",
		"Frenzy_Conscious_4",
	},
}

