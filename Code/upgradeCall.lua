AllSpeciesUpgrades = _G.Mods["rtw6tLg"] or false
local title = "Insects Level up All Species"
local separator = " :: "
local debugMSG = { "New Game", "Game Started" }
local hour_duration = const.HourDuration
local day_duration = const.DayDuration
local resource_scale = const.ResourceScale

function Bkob_Log(hard_string,var)
	DebugPrint(hard_string)
	if var then
		DebugPrint(var)
	end
	DebugPrint("\n")
	if MapVarValues['EE_debug'] == 'all' then
		print(hard_string)
		print(var)
	end
end

function SavegameFixups.ILU_Gujo_fixes()
	Bkob_Log("Fixing up a save game due to older EE version present!\n")
	MapForEach("map", "GujoT3", function(obj,ids)
		if ids[obj.id] then
			obj.id = ids[obj.id]
			obj:ComposeBodyParts()
			obj:InitEntity()
		end
	end)
	for i, animal in ipairs(UIPlayer.labels.TamedAnimals) do
		if not UIPlayer.research_center:IsTechResearched(animal['FieldResearchTech']) then
			CompleteResearch(animal['FieldResearchTech'])
		end
		animal:InitEntity()
	end
end


function TrySpawnSurvivor(spawn_params, obj)
	local player = IsKindOf(obj, "PlayerObject") and obj.player or UIPlayer
	local survivor_def, survivor_id = PickCharacterToSpawn(player, spawn_params)
	if not survivor_def then return end
	
	local radius = obj and obj:GetRadius() or 0
	
	local pos
	local board_balloon = spawn_params.BoardBalloon
	local balloon = obj and obj.in_balloon
	if board_balloon then
		assert(IsValid(balloon))
		if not IsValid(balloon) then
			return
		end
	elseif spawn_params.SpawnNextToObject or spawn_params.SpawnNearPos then
		pos = spawn_params.SpawnNextToObject and obj or spawn_params.SpawnNearPos
		assert(IsValidPos(pos))
		if not IsValidPos(pos) then return end
		local max_radius = const.Gameplay.SurvivorSpawnNearObjMaxRadius
		pos = terrain.FindReachable(pos,
			const.tfrPassClass, Human.pfclass,
			const.tfrRandom, InteractionRand(nil, "LandHuman"),
			const.tfrCenterRadius, max_radius + radius, radius, false,
			const.tfrWeightRadius, 1, 1000, 3)
		assert(pos)
		if not pos then return end
	else
		-- find a flat place on the map far enough from shrieker nests
		local nests = MapGet("map", "TerritorialNest")
		local InvalidZ = const.InvalidZ
		local function filter_far_from_nest(x, y)
			-- check for distance to shrieker nests
			for _, nest in ipairs(nests or empty_table) do
				if nest:IsCloser2D(x, y, nest.territorial_range) then
					return false
				end
			end
			return true
		end
		local function filter(x, y)
			-- first make sure that the survivor will have a point to spawn on
			if not terrain.AreaPassable(x, y, InvalidZ, 1024, Human.pfclass) then
				return false
			end
			return filter_far_from_nest(x, y)
		end
		local x, y
		local seed = InteractionRand(nil, "LandHuman")
		if spawn_params.SpawnNearBase then
			local max_dist, min_dist = const.Gameplay.SurvivorSpawnNearBaseMaxRadius, const.Gameplay.SurvivorSpawnNearBaseMinRadius
			local origin = terrain.FindAreaPassable(GameStartPos, 4096, 64*guim, Human.pfclass)
			local retries = 4096
			local result = ConnectivityRandomTile(seed, origin, GameStartPos, max_dist, min_dist, Human.pfclass, retries, filter_far_from_nest)
			if result then
				x, y = result:xy()
			else
				x, y = GetRandomPlayablePos(GameStartPos, max_dist, min_dist, seed, Human.pfclass, Human.radius, filter)
			end
		else
			x, y = GetRandomPlayablePos(seed, Human.pfclass, Human.radius, filter)
		end
		assert(x)
		if not x then
			return
		end
		pos = point(x, y)
	end

	local survivor
	local from_rescued = spawn_params.FromRescued
	if from_rescued then
		for _, rescued_survior in ipairs(table.get(player.labels, "RescuedSurvivors")) do
			if rescued_survior.id == survivor_id then
				survivor = rescued_survior
				survivor:OnReturnFromRescued()
				break
			end
		end
	else
		survivor = SpawnHumanFromDef(survivor_def, player)
	end
	
	if not IsValid(survivor) then return end
	
	if board_balloon and IsValid(balloon) then
		balloon:Embark(survivor)
		pos = survivor:GetPos()
	elseif spawn_params.FollowLeader then
		survivor:TrySetLeader(obj)
	end
	
	survivor.adjust_clothes = spawn_params.AdjustClothes
	survivor:OnLanded(pos)
	if from_rescued then
		-- reinit rescued survivor
		survivor:OnHumanInited()
	end
	if spawn_params.DeadOnArrival then
		survivor:TrySetCommand("CmdDie", spawn_params.DieReason, "instant")
	elseif spawn_params.SpawnNearBase then
		local walk_to = terrain.FindPassableTile(GameStartPos) or GameStartPos
		survivor:TrySetCommand("Goto", walk_to, 16*guim, 0)
	end
	
	-- obj is the rescuer if such exists
	Msg("SurvivorSpawned", survivor, obj, player)
	return survivor
end

function Building:EE_SpawnAround(class,who,name)
	print("Starting to spawn a unit around a building!")
    local spawn_def = SpawnDefs['spawn_nearby']
	local def = class and g_Classes[class]
	local instance = {}
	instance.SpawnClass = class
	instance.location = self
	instance.name = name or def.DisplayName
	if who and IsKindOf(def,'UnitAnimal') then
		instance.PostSpawn = function(self,obj,target,context)
				if not obj.Tameable then
					print("Animal can't be tamed")
					return
				end
				obj:CheatResearch()
				obj:Tame()
				Msg("AnimalTamed", nil, obj, true)
				if instance.name then
					obj.DisplayName = instance.name
				end
			end
	end
	spawn_def = spawn_def:CreateInstance(instance)
	local t = spawn_def:ResolveTarget()
	spawn_def:ActivateSpawn(t,{},100)
end

function SavegameFixups.EveryoneLives()
	Bkob_Log("Fixing up a save game due cheat killing a human on an expedition\n")
	for _,exp in ipairs(ExpeditionSites) do
		local survivors = GetValidSurvivorsOnMap()
		if exp.assigned_unit and not MapGetFirst(true, "Human", function(survivor, self) return (survivor.id == "Emily") end) then
			local center = AveragePoint2D(survivors)
			local pos = terrain.FindReachable(center,
				const.tfrPassClass, Human.pfclass,
				const.tfrRandom, InteractionRand(nil, "LandHuman"),
				const.tfrCenterRadius, const.Gameplay.SurvivorSpawnNearObjMaxRadius, 0, false,
				const.tfrWeightRadius, 1, 1000, 3)
			local survivor_def = CharacterDefs[exp.assigned_unit.id]
			local survivor_obj = SpawnHumanFromDef(survivor_def,UIPlayer,pos)
			exp.assigned_unit = false
		end
	end
end

function rebuild_animals()
	MapForEach("map",'UnitAnimal', function(obj)
		obj:ComposeBodyParts()
		obj:InitEntity()
	end)
end

function SavegameFixups.ILU_Decom_fixes()
	Bkob_Log("Fixing up a save game due to older EE version present!\n")
	rebuild_animals()
end

function SavegameFixups.mass_animal_clean()
	Bkob_Log("Cleaning the map of mass units, and units outside the map!")
	clean_outside_map()
	rebuild_animals()
end

function SavegameFixups.ILU_id_change_fix()
	local to_decom = {
		GujoT5="Gujo_T5",GujoT4="Gujo_T4",GujoT3="Gujo_T3",GujoT2="Gujo_T2",
		--dog_T5="Dog_T5",dog_T4="Dog_T4",dog_T3="Dog_T4",
		dog_T1="Dog_T2",
		Heavily_Mutated_PEx_Skarabei_Brute="Scarab_T5",Mutated_PEx_Skarabei_Brute="Scarab_T4",PEx_Skarabei="Scarab_T2",PEx_Skarabei_Brute="Scarab_T3",
		BadTrip_Bloated_Glutch_Stitcher="Glutch_T5",BadTrip_Bloated_Glutch="Glutch_T4",Bloated_Glutch="Glutch_T3",Glutch_Stitcher="Glutch_T2",
		Fast_Frenzied_Fortified_Bomber_Dragonfly="Dragongly_T5",Frenzied_Fortified_Bomber_Dragonfly="Dragongly_T4",Frenzied_Bomber_Dragonfly="Dragongly_T3",Frenzied_Dragonfly="Dragongly_T2",
		Spellsword_Tecatli="Tecatli_T5",Intelligent_Tecatli="Tecatli_T4",Heat_Reinforced_Tecatli="Tecatli_T3",Entombed_Tecatli="Tecatli_T2",VenomousRaptors="Tecatli_T1_venom",
		Rage_Focused_Scissorhands="Scissorhands_T5",Rage_Fueled_Scissorhand_Duelist="Scissorhands_T4",Brutal_Duelist_Scissorhands="Scissorhands_T3",
		Junoskar="Juno_T6",Too_Angry_Too_Die_Juno="Juno_T5",Hulk_Juno="Juno_T4",Angry_Juno="Juno_T3",
		Sniping_Entropy_Shielded_Shrieker="Shrieker_T5",Plague_Sniper_Shrieker="Shrieker_T4",Entropic_Shrieker="Shrieker_T3",
	}
	local animals = MapGet(true,'UnitAnimal')
	for _,creature in ipairs(animals) do
		local decom_check = to_decom[creature.class]
		if decom_check then
			creature:ChangeClass(decom_check)
		end
	end
end

function clean_outside_map()
	MapForEach(true, "UnitAnimal", function(unit, play_box)
		local check1, check2, check3
		 if play_box:Dist2(unit:GetPosXYZ()) == 0 or unit:CanBeOutsideMap() then return end
		-- inside helper functions def of map
		unit:CheatDelete()
	end, GetPlayBox())
	MapForEach(true, "Robot", function(unit, play_box)
		 if play_box:Dist2(unit:GetPosXYZ()) == 0 or unit:CanBeOutsideMap() then return end
		unit:CheatDelete()
	end, GetPlayBox())
end


function clean_mass_animals()
	local chains = #Presets.UnitClassChain.Default
	for i=1, chains do
		local units_check = {}
		local chain = Presets.UnitClassChain.Default[i]
		if chain and chain.units then
			for _,unit in ipairs(chain.units) do
				units_check[unit.Unit] = true
			end
			local count = MapCount(true,'UnitAnimal',function(unit,ids)
				if ids[unit.class] then
					return true
				else
					return false
				end
			end,units_check)
			if count > 500 then
				Bkob_Log("Need to delete units in this chain because there are over 500 on the map!",chain.id)
				MapForEach(true,'UnitAnimal',function(unit,ids)
					if ids[unit.class] and not unit.is_tamed then
						unit:CheatDelete()
					end
				end,units_check)
			end
		end
	end
end

-- lag avoider......
function OnMsg.NewDayStarted(year, day)
	clean_outside_map()
	clean_mass_animals()
end

local function add_perks_to_animals(type)
	if type == 'milk' then
		local output = ClassDescendantsList("Unit", function (name, classdef)
			return (classdef.SpeciesGroup == 'species_ulfen' or classdef.SpeciesGroup == 'species_camel' or classdef.SpeciesGroup == 'species_noth') --unit_ent.SpeciesGroup == 'birds'
		end)
		for _,animal in ipairs(output) do
			local def = g_Classes[animal]
			table.insert_unique(def.AnimalPerks, "MilkProducer")
		end
	elseif type == 'eggs' then
		local output = ClassDescendantsList("Unit", function (name, classdef)
			return classdef.SpeciesGroup == 'species_gujo' --unit_ent.SpeciesGroup == 'birds'
		end)
		for _,animal in ipairs(output) do
			local def = g_Classes[animal]
			table.insert_unique(def.AnimalPerks, "EggsProducer")
		end
	end
end

function OnMsg.ModsReloaded()
	if _G.Mods["LH_Milk"] then
		CreateRealTimeThread(function()
			local milk_given = false
			local retry = 3
			while not milk_given and retry > 0 do
				retry = retry - 1
				Sleep(200)
				if Presets.AnimalPerk.Default["MilkProducer"] then
					add_perks_to_animals('milk')
					milk_given = true
				end
			end
		end)
	end
	if _G.Mods["LH_Eggs"] then
		CreateRealTimeThread(function()
			local eggs_given = false
			local retry = 3
			while not eggs_given and retry > 0 do
				retry = retry - 1
				Sleep(200)
				if Presets.AnimalPerk.Default["EggsProducer"] then
					add_perks_to_animals('eggs')
					eggs_given = true
				end
			end
		end)
	end
end

local EE_tier_pivot = {}
local EE_evo_pivot = {}

--Input: evo_pivot[unit_id] output: evo unit list
function build_evo_pivot()
	Bkob_Log("Building Evo Pivot")
	EE_evo_pivot = {}
	local chains = #Presets.UnitClassChain.Default
	for i=1, chains do
		local chain = Presets.UnitClassChain.Default[i]
		if chain and chain.units then
			local evo_chain_list = chain.units
			local max_t = chain:get_max_tier()
			for _,v in ipairs(evo_chain_list) do
				local unit_class = v.Unit
				local evo_tier = v.Tier or 1
				if evo_tier + 1 <= max_t then
					local evos = chain:get_units_by_tier(evo_tier + 1)
					EE_evo_pivot[unit_class] = evos
				else
					EE_evo_pivot[unit_class] = {}
				end
			end
		end
	end
	Bkob_Log("Done building evo pivot table")
end

--Input: tier_pivot[unit_id] output: tier number
function build_tier_pivot()
	Bkob_Log("Building tier tier pivot table ")
	EE_tier_pivot = {}
	local chains = #Presets.UnitClassChain.Default
	for i=1, chains do
		local chain = Presets.UnitClassChain.Default[i]
		if chain and chain.units then
			--Bkob_Log("Reviewing: ",chain.units)
			for _,unit in ipairs(chain.units) do
				local unit_class = unit.Unit
				local tier = unit.Tier or 1
				--Bkob_Log("Adding this unit to tier pivot table ",unit_class)
				EE_tier_pivot[unit_class] = tier
			end
		end
	end
	Bkob_Log("Done building tier pivot table")
end

function print_pivots()
	print("EVO PIVOT")
	print(EE_evo_pivot)
	print("TIER PIVOT")
	print(EE_tier_pivot)
end

function build_pivot_tables()
	build_evo_pivot()
	build_tier_pivot()
end

function get_tier_Table()
	return EE_tier_pivot
end

function get_evo_Table()
	return EE_evo_pivot
end

function OnMsg.ModsReloaded()
	build_pivot_tables()
end

function Get_unit_classes()
	local to_return = {}
	local chains = Presets.UnitClassChain.Default
	for i=1,#chains do
		if chains[i] then
			to_return[#to_return+1] = chains[i].id
		end
	end
	return to_return
end

-- Need this here instead of nest mod because we are defining the robots here
AppendClass.UnitNesting = {
	properties = {
		{ category = "Nest", id = "NestEffectRobo", name = "Nest Proximity Effect", editor = "preset_id", default = "FamiliarGroundRobo", preset_class = "RobotCondition", template = true },
	}
}

AppendClass.UnitSpeciesGroup = {
	properties = {
		{category = "Species", id = "species_name", name = "Species Name", editor = "text", translate = true, default = T(1234567894, "Unknown Species"), help = "What species of creature.",},
		{category = "Species", id = "herd_size_modifier", name = "Tame cap modifier (%)", editor = "number", scale = 'percent', default = 100, help = "How solitary this unit is. < 100 will cause unit to hit tame cap faster. > 100 will let them go above cap",},
		{category = "Species", id = "primary_combat_group", name = "Primary combat group", editor = "choice", default = false, items = function() return CombatGroupsSetItems() end, help = "What combat group should this unit below too initially.",},
		{category = "Species", id = "allied_combat_groups", name = "Allied Combat Groups", editor = "string_list", default = {}, help = "Combat groups that should not be attacked",},
		{category = "Species", id = "nest_class", name = "Species Nest", editor = "choice", default = false, items = function() return ClassDescendantsList('TerritorialNest') end , help = "What nest is related to this species.",},
		{category = "Species", id = "intelligence", name = "Intelligence", editor = "choice", default = 'primal', items = {"primal","sub-sentient",'sentient','coordinated'} , help = "How complicated this species can behave.",},
		{category = "Species", id = "evo_chains", name = "Evolution Chains", editor = "string_list", default = false, modifiable = true, items = function() return Get_unit_classes() end, },
	},
}

function Get_unit_species_preset()
	local to_return = {}
	local entries = #Presets.UnitSpeciesGroup.Default+1
	for i = 1, entries do
		local species = Presets.UnitSpeciesGroup.Default[i]
		if species.primary_combat_group then
			table.insert_unique(to_return, species.id)
		end
	end
	return to_return
end

DefineClass.UnitEvoInstance = {
	__parents = { "PropertyObject" },
	properties = {
		{ category = "Unit", id = "Unit", name = "Unit", editor = "choice", default = false, items = function (self) return GetSpawnClasses() end,},
		{ category = "Unit", id = "Tier", name = "Unit Tier", default = 1, editor = "number", help = "What tier of unit (This is tracked to ensure players can limit the max individual difficulty of a save by limiting based on tier)", },
	},
}

-- Specific 
DefineClass.UnitClassChain = {
	__parents = {"ListPreset"},
	properties = {
		{ category = "Evolution",	id = "units", name = "Units in Chain", editor = "nested_list", default = false, modifiable = true, base_class = "UnitEvoInstance", inclusive = true, auto_expand = true },	
	},
}

function UnitClassChain:get_units_by_tier(tier)
	local to_return = {}
	for _,unit in ipairs(self.units) do
		if unit.Tier == tier then
			to_return[#to_return+1] = unit.Unit
		end
	end
	return to_return
end

function UnitClassChain:get_correct_evo(ep)
	local to_return = {}
	local max_count = MapVarValues['ILU_max']
	local min_tier = self:get_min_tier()
	local max_tier = self:get_max_tier()
	local found = false
	local retry = 20
	local cur_tier = min_tier
	while not found and retry > 0 do
		retry = retry -1
		local this_tier_units = self:get_units_by_tier(cur_tier)
		for _,animal in ipairs(this_tier_units) do
			if g_Classes[animal].EventProgressValue * max_count > ep then
				to_return[#to_return+1] = animal
				found = true
			end
		end
		cur_tier = cur_tier + 1
		-- if the EP given is more than the highest tier units cap value
		if cur_tier == max_tier and not found then
			to_return[#to_return+1] = table.rand(self:get_units_by_tier(cur_tier))
			found = true
		end
	end
	return to_return
end

function UnitClassChain:get_min_tier()
	local to_return = 0
	for _,unit in ipairs(self.units) do
		if unit.Tier < to_return then
			to_return = unit.Tier
		end
	end
	return to_return
end

function UnitClassChain:get_max_tier()
	local to_return = 0
	for _,unit in ipairs(self.units) do
		if unit.Tier > to_return then
			to_return = unit.Tier
		end
	end
	return to_return
end

DefineModItemPreset("UnitClassChain", { EditorName = "Evolution Chain", EditorSubmenu = "Animals" })

function UnitSpeciesGroup:ally_with(combat_group)
	local found = false
	for _, group in ipairs(self.allied_combat_groups) do
		if group == combat_group then
			found = true
		end
	end
	if not found then 
		self.allied_combat_groups[#self.allied_combat_groups+1]= combat_group
	end
end

function UnitSpeciesGroup:betrayed_by(combat_group)
	local found = false
	for _, group in ipairs(self.allied_combat_groups) do
		if group == combat_group then
			found = true
		end
	end
	if found then 
		self.allied_combat_groups[#self.allied_combat_groups+1]= combat_group
	end
end

function UnitSpeciesGroup:change_primary_combat_group(combat_group)
	if self.primary_combat_group ~= combat_group then
		self.primary_combat_group = combat_group
	end
	-- todo map through each non-player controlled unit, check if they have the old primary comabt group. if so, change it to the new one.
	MapForEach(true,'Unit',function(unit)
		if IsKindOf(unit,'UnitAnimal') and unit.is_tamed then return end

		if unit.CombatGroup == self.primary_combat_group and unit.command_center then
			unit.CombatGroup = combat_group
		end
	end)
end

function combat_units_with_false()
	local test_array = {false}
	local combat_units = table.keys(ClassDescendants("UnitCombat"), true)
	return table.append(test_array, combat_units)
end

function Find_evolution(classdef)
	Bkob_Log("Finding evolution for: ",classdef.class)
	local possible
	local cur_tier = EE_tier_pivot[classdef.class] or 1
	if cur_tier >= MapVarValues["ILU_Tier_Max"] then
		Bkob_Log("evolution not allowed to spawn. Reverting evolution to what we where given!",'')
		return classdef.class
	end
	if classdef.Tameable and classdef.NewbornClass then
		Bkob_Log("Unit is tameable and has a newborn class!")
		possible = classdef.NewbornClass or classdef.class
	else
		local possible_ups = EE_evo_pivot[classdef.class]
		Bkob_Log("Doing it the pivot table way!")
		if #possible_ups > 0 then
			possible = table.rand(possible_ups)
		else
			possible = classdef.class
		end
	end
	if EE_tier_pivot[possible] > MapVarValues["ILU_Tier_Max"] then
		Bkob_Log("evolution not allowed to spawn. Reverting evolution to what we where given!",'')
		possible = classdef.class
	else
		Bkob_Log("Giving back this evolution: ",possible)
	end
	return possible
end

-------------------------- Mini FUNCTIONS ----------------------------------

local function is_preg_loaded()
	for _, mod in ipairs(ModsLoaded) do
		if mod.id == 'hy8RluH' then
			return true
		end
	end
	return false
end

local function build_output(final_full_table)
	Bkob_Log("Building final spawn table\n")
	local additional_class_list = {}
	local final_main_name = ''
	for i = 1, #final_full_table do
		if i == 1 then
			final_main_name = final_full_table[i]['now']
		else
			additional_class_list[i - 1] = { id = final_full_table[i]['now'], weight = final_full_table[i]['weight'] }
		end
	end
	return final_main_name, additional_class_list
end

-- This is already getting the id of the UnitSpeciesGroup
function carrying_capacity(species)
	Bkob_Log("Getting carrying capacity of a species: ",species)
	local herd_mod = Presets.UnitSpeciesGroup.Default[species].herd_size_modifier or 100
	local max
	if MapVarValues["EE_hard_cap"] then
		max = MapVarValues[species] --get_preg_quota(species)
	end
	if not max then
		max = DivRound(DivRound(MapVarValues['ILU_max'] or 150, 6) * herd_mod, 100)
	end
	Bkob_Log("The maxx for this species is: ", max)
	return max or 30 -- just in case we **** a brick
end

---------------------- MAJOR FUNCTIONS -----------------------------

function new_preg_rate(specific_species, rate)
	local species = specific_species.SpeciesGroup
	if not Presets.UnitSpeciesGroup.Default[species] then return rate end
	Bkob_Log("Preg rate for ",specific_species)
	-- default to 60
	local base_rate = rate or specific_species.DailyPregnancyChance or 60
	local count = 0
	for _,v in ipairs(UIPlayer.labels.TamedAnimals) do
		if v.SpeciesGroup == species then
			count = count + 1
		end
	end
	if count < 2 then return rate or 60 end
	local no = MapVarValues[stop] or 0
	local cc = carrying_capacity(species)
	local fin_mod = 100 * (cc - no) / cc
	local to_return = fin_mod * base_rate / 100
	local override = false
	if override then
		to_return = 0
	end
	return to_return
end

function ILU_update_armor_hcs()
	Bkob_Log("Updating the armor HCs")
	local combat_type = MapVarValues['ILU_combat_type']
	local flip_table = {}
	if not combat_type then
		return
	elseif combat_type == 'simple' then
		flip_table = {
			{ id = 'armor_leather_complex',   flip = 'armor_leather_simple' },
			{ id = 'armor_vleather_complex',  flip = 'armor_vleather_simple' },
			{ id = 'armor_synth_complex',     flip = 'armor_synth_simple' },
			{ id = 'armor_badCarbon_complex', flip = 'armor_badCarbon_simple' },
			{ id = 'armor_carbon_complex',    flip = 'armor_carbon_simple' },
		}
	elseif combat_type == 'complex' then
		flip_table = {
			{ flip = 'armor_leather_complex',   id = 'armor_leather_simple' },
			{ flip = 'armor_vleather_complex',  id = 'armor_vleather_simple' },
			{ flip = 'armor_synth_complex',     id = 'armor_synth_simple' },
			{ flip = 'armor_badCarbon_complex', id = 'armor_badCarbon_simple' },
			{ flip = 'armor_carbon_complex',    id = 'armor_carbon_simple' },
		}
	end
	local found_flip = true
	while found_flip do
		found_flip = false
		MapForEach(true, "Human", function(unit, was_flipped)
			for _, v in ipairs(flip_table) do
				for _, effect in ipairs(unit.status_effects or empty_table) do
					if IsKindOf(effect, "ModItemHealthCondition") and effect.id == v['id'] then
						unit:RemoveHealthCondition(v['id'])
						unit:AddHealthCondition(v['flip'], 'combatflip')
						found_flip = true
					end
				end
			end
		end)
	end
end

-- classdef UnitEvolution Unit Component + EP based upgrading
function check_count_and_upgrade(start_animal, additionalClassList, progress_percent)
	Bkob_Log("non-robot attack incoming\n")
	progress_percent = progress_percent or 100
	local actual_EP_Bank = DivRound((progress_percent * EventProgress), 100)
	local max_count = MapVarValues['ILU_max']
	if not max_count then ILU_set_mod_options("rtw6tLg") end
	local max_count = MapVarValues['ILU_max']
	local min_average_cost = DivRound(actual_EP_Bank, max_count)
	local start_ep = g_Classes[start_animal].EventProgressValue --lookupEP(start_animal)
	local temp_class_list = {
		{ start = start_animal, weight = 100, now = start_animal, up_count = 0},
	}
	local sum_weight = 100
	local progress_and_weight = start_ep * 100
	for i = 1, #additionalClassList do
		local this_ep = g_Classes[additionalClassList[i][1]].EventProgressValue --lookupEP(additionalClassList[i][1])
		local expansion = {}
		expansion['now'] = additionalClassList[i][1]
		expansion['start'] = additionalClassList[i][1]
		expansion['weight'] = additionalClassList[i][2]
		expansion['up_count'] = 0
		--expansion['ep'] = this_ep
		sum_weight = sum_weight + additionalClassList[i][2]
		progress_and_weight = progress_and_weight + this_ep * additionalClassList[i][2]
		temp_class_list[i + 1] = expansion
	end
	Bkob_Log('attack wave initial spawning',temp_class_list)
	local this_defs_avg = DivRound(progress_and_weight, sum_weight)
	if this_defs_avg > min_average_cost then return build_output(temp_class_list) end
	local max_loops = 40
	local up_count_cap = 1
	local max_tier = GameVarValues['ILU_Tier_Max'] or 6
	local i = 0
	local capped = 0
	local evolution = false
	Bkob_Log('Length of spawn list: ',#temp_class_list)
	while i < max_loops and this_defs_avg < min_average_cost and capped < #temp_class_list do
		i = i + 1
		Bkob_Log('Loop: ',i)
		Bkob_Log('Capped evolutions: ',capped)
		evolution = false
		for _, v in ipairs(temp_class_list) do
			Bkob_Log('Checking this entry: ',v)
			local v_def = g_Classes[v['now']]
			-- Find_evolution already detects classes above player option tier cap.
			-- So if next == v['now'], we should consider this entry maxxed out 
			local next = Find_evolution(v_def)
			local maybe_evo = g_Classes[next]
			local already_loop_capped = v['up_count'] >= up_count_cap
			if already_loop_capped then
				Bkob_Log("Entry loop evo capped:")
				goto continue
			end
			local same_creature = v['now'] == next
			if same_creature then
				Bkob_Log("Got same creature back from evo code!")
				capped = capped + 1
				goto continue
			end
			evolution = maybe_evo
			v['now'] = evolution.class
			v['up_count'] = v['up_count'] + 1
			v['ep'] = evolution.EventProgressValue
			local weighted_ep_old = DivRound(v['weight'] * v_def.EventProgressValue, sum_weight)
			local weighted_ep_new = DivRound(v['weight'] * evolution.EventProgressValue, sum_weight)
			this_defs_avg = this_defs_avg - weighted_ep_old + weighted_ep_new
			Bkob_Log('Entry is now: ',v)
			-- this checks if the current tier of evo unit is the max option; or we have run out of evos
			local tier_capped = (EE_tier_pivot[evolution.class] == max_tier) or (Find_evolution(evolution) == evolution.class)
			if tier_capped then
				Bkob_Log("This evolution is now capped!")
				capped = capped + 1
			end
			::continue::
		end
		if not evolution then
			up_count_cap = up_count_cap + 1
			Bkob_Log('Did not find an evolution this loop. Can now evolve each instance this many times: ',up_count_cap)
		end
	end
	return build_output(temp_class_list)
end

-- robot attack upgrader
function ILU_ActivateAttackDropshipSpawnDefs(robot_spawndef, main_unit, added_units, progress_mul)
	Bkob_Log("Robot attack incoming\n")
	local robot_spawn_def = SpawnDefs[robot_spawndef]
	if not robot_spawn_def then return end
	local dropship_spawn_def = SpawnDefs["Attack_Dropship"]
	if not dropship_spawn_def then return end
	progress_mul = progress_mul or 100
	local addedClassList = {}
	local instance = {}
	instance.spawnClass, addedClassList = check_count_and_upgrade(main_unit, added_units)
	instance.AdditionalClassList = {}
	for i = 1, #addedClassList do
		instance.AdditionalClassList[#instance.AdditionalClassList + 1] = { addedClassList[i]['id'], addedClassList[i]
			['weight'] }
	end
	robot_spawn_def = robot_spawn_def:CreateInstance(instance)
	local seed = InteractionRand(nil, "AttackWave")
	local rand = BraidRandomCreate(seed)
	local count = robot_spawn_def.Count + rand(robot_spawn_def.RandomCount + 1)
	local mod = robot_spawn_def:CalculateInvadersCountMod(robot_spawn_def, progress_mul) or 100
	count = robot_spawn_def:ModifyCount(count, mod, rand)
	if count <= 0 then
		return
	end
	local MaxInvadersPerDropship = const.Gameplay.MaxInvadersPerDropship
	local MaxDropshipsPossible = const.Gameplay.MaxAttackDropshipsCount
	local dropships = Min(DivCeil(count, MaxInvadersPerDropship), MaxDropshipsPossible)
	robot_spawn_def.Count = count / dropships
	instance = {}
	instance.RobotSpawnDef = robot_spawn_def
	instance.Count = dropships
	dropship_spawn_def = dropship_spawn_def:CreateInstance(instance)
	local context = { robot_spawn_def = robot_spawn_def }
	dropship_spawn_def:ActivateSpawn(nil, context)
end

--UIPlayer:GetStoredResAmount('ScrapMetal')
local ProduceResource = ProduceResource
local PlaceResourcePile = PlaceResourcePile
local params = { disable_requests = true }
function UnitAnimal:DoProduceResourcesDiminishingReturns()
	Bkob_Log("EE animal trying to generate limited resources")
	if self:IsTamed() then
		local happiness_pct = Min(self.Happiness / 1000, 100)
		for _, res_amount in ipairs(self.ProduceResources) do
			local amount = res_amount.amount
			local happiness_mod = MulDivRound(amount, happiness_pct, 100)
			if happiness_mod > resource_scale then
				amount = amount + RoundResourceAmount(happiness_mod)
			end
			if UIPlayer:GetStoredResAmount(res_amount.resource) >= const.ResourceScale * 300 then
				self:AddHealthCondition('tamed_constipated', 'too_many_resources')
			elseif self:HasHealthCondition('tamed_constipated') then
				self:RemoveHealthCondition('tamed_constipated', 'resources_normalized')
				ProduceResource(nil, self, res_amount.resource, amount)
			else
				ProduceResource(nil, self, res_amount.resource, amount)
			end
		end
	else
		for _, res_amount in ipairs(self.ProduceResources) do
			PlaceResourcePile(self, res_amount.resource, res_amount.amount, false, params)
		end
	end
	self:UpdateProductionTime()
	Bkob_Log("EE animal done generating resources (maybe)")
end

function EE_Instantiate()
	build_pivot_tables()
	if MapVarValues['ILU_max'] == nil then MapVar('ILU_max', 150) end
	if MapVarValues['ILU_Tier_Max'] == nil then MapVar('ILU_Tier_Max', 6) end
	if MapVarValues['ILU_combat_type'] == nil then MapVar('ILU_combat_type',"complex") end
	if MapVarValues['species_shrieker_cap'] == nil then MapVar("species_shrieker_cap",20) end
	if MapVarValues['species_scissorhands_cap'] == nil then MapVar("species_scissorhands_cap",10) end
	if MapVarValues['species_draka_cap'] == nil then MapVar("species_draka_cap",20) end
	if MapVarValues['species_ulfen_cap'] == nil then MapVar("species_ulfen_cap",20) end
	if MapVarValues['species_noth_cap'] == nil then MapVar("species_noth_cap",20) end
	if MapVarValues['species_shogu_cap'] == nil then MapVar("species_shogu_cap",10) end
	if MapVarValues['species_camel_cap'] == nil then MapVar("species_camel_cap",20) end
	if MapVarValues['species_gujo_cap'] == nil then MapVar("species_gujo_cap",10) end
	if MapVarValues['species_dogs_cap'] == nil then MapVar("species_dogs_cap",20) end
	if MapVarValues['species_tecatli_cap'] == nil then MapVar("species_tecatli_cap",10) end
	if MapVarValues['species_juno_cap'] == nil then MapVar("species_juno_cap",10) end
	if MapVarValues['EE_hard_cap'] == nil then MapVar("EE_hard_cap",false) end
	if MapVarValues['nest_awaken_exp_tame'] == nil then MapVar('nest_awaken_exp_tame', false) end
	if MapVarValues['nest_awaken_tame_name'] == nil then MapVar('nest_awaken_tame_name', false) end
	if MapVarValues['EE_debug'] == nil then MapVar('EE_debug', false) end
	if MapVarValues['preg_evo_chance'] == nil then MapVar('preg_evo_chance', 20) end
end

function EE_init_and_set_options(id)
	EE_Instantiate()
	EE_set_mod_options(id)
end

function EE_set_mod_options(id)
	id = id or CurrentModId
	if is_preg_loaded() then
		Bkob_Log("Pregnancy Mod detected!\n")
		AddGameNotification('Preg_mod_conflict')
	end
	local options = CurrentModOptions
	if CurrentModId ~= id or not CurrentModOptions then
		return
	end
	Bkob_Log("EE Mod Options applied!\n")
	Bkob_Log('Override tame cap found? ')
	Bkob_Log(options.O_Man_Cap)
	Bkob_Log("\n")
	--if not table.find(MapVars, 'O_Man_Cap') then MapVar("O_Man_Cap", options.O_Man_Cap) end
	if options.O_Man_Cap then
		MapVarValues['EE_hard_cap'] = true
		MapVarValues["species_shrieker_cap"]=options.ShriekersQuota or 20
		MapVarValues["species_scissorhands_cap"]=options.ScissorQuota or 10
		MapVarValues["species_draka_cap"]=options.DrakaQuota or 20
		MapVarValues["species_ulfen_cap"]=options.UlfenQuota or 20
		MapVarValues["species_noth_cap"]=options.NothQuota or 20
		MapVarValues["species_shogu_cap"]=options.ShoguQuota or 10
		MapVarValues["species_camel_cap"]=options.CamelQuota or 20
		MapVarValues["species_gujo_cap"]=options.GujoQuota or 10
		MapVarValues["species_dogs_cap"]=options.DogQuota or 20
		MapVarValues["species_tecatli_cap"]=options.TecatliQuota or 10
		MapVarValues["species_juno_cap"]=options.JunoQuota or 10
	else
		MapVarValues['EE_hard_cap'] = false
	end
	MapVarValues["ILU_max"] = options.O_ILU_max or 150
	MapVarValues["ILU_Tier_Max"] = options.O_ILU_max_tier or 6
	MapVarValues["preg_evo_chance"] = options.preg_evo_chance or 20
	if options.O_simple_combat == true then
		MapVarValues["ILU_combat_type"] = 'simple'
	elseif options.O_simple_combat == false then
		MapVarValues["ILU_combat_type"] = 'complex'
	else
		MapVarValues["ILU_combat_type"] = 'complex'
	end
	ILU_update_armor_hcs()
end

local function check_evo_counts(init,fin)
	local found = false
	local retry = 10
	while not found or retry > 0 do
		retry = retry - 1
		local init_tier = EE_tier_pivot[init] or 1
		local fin_tier = EE_tier_pivot[fin] or 1
		return fin_tier - init_tier
	end
end

function Find_evo_chain(unit_id)
	local chains = #Presets.UnitClassChain.Default
	for i=1, chains do
		local chain = Presets.UnitClassChain.Default[i]
		if chain and chain.units then
			for _,unit in ipairs(chain.units) do
				if unit.Unit == unit_id then return chain end
			end
		end
	end
	return false
end

function find_newborn_class(unit)
	local evo = unit.NewbornClass
	local chance = MapVarValues['preg_evo_chance'] or 100
	if evo and AsyncRand(100) < chance then
		return evo
	else
		return unit.class
	end
end

-- Tests the externally (external from this code file) called functions
-- loop through all species defined in evo chains
-- Make sure they can all evolve properly
-- Then loop through all base game attack species and test their evolutions at various EP levels
function EE_QA(full_debug)
	full_debug = full_debug or false
	EE_Instantiate()
	-- so logs print to screen
	MapVarValues['EE_debug'] = full_debug
	build_pivot_tables()
	local species = table.keys(EE_evo_pivot)
	for _,v in ipairs(species) do
		Find_evolution(g_Classes[v])
	end
	--CheatPlaceAllUnitAnimals(MapGetFirst('map','LandingCapsuleMarker'))
	local species = {
		-- UnitAnimals
		'Skarabei_Manhunting','Dragonfly','Shrieker_Manhunting','Scissorhands','Juno','Glutch_Manhunting',
		-- robot units
		'LightHostileRobot_LVL1','HostileRobot_Scout_LVL1','HeavyHostileRobot_LVL1','Demo_1','HostileCombatQuadcopter_LVL1','HostileCrawler_LaserGun','HostileCrawler_MachineGun'
	}
	local EP_nums = {100, 800, 1200, 5000, 15000, 30000, 75000, 140000,300000}
	local old_EP = EventProgress
	for _,s in ipairs(species) do
		local evo_chain = Find_evo_chain(s)
		for _,no in ipairs(EP_nums) do
			EventProgress = no
			Bkob_Log('unit: ',s)
			Bkob_Log('At this EP: ',no)
			local main, addl = check_count_and_upgrade(s, {}, 100)
			local correct_evo = evo_chain:get_correct_evo(no)
			if correct_evo ~= main then
				Bkob_Log("Evolved as expected, evolving x time: "..check_evo_counts(s,main))
			else
				print(s..' at '..no..' ep ')
				print("Something went wrong! SpawnDef unit: "..main..' Chain Evo unit: '..correct_evo)
			end
		end
	end
	EventProgress = old_EP
	print("Testing animal attack storybits!")
	MapVarValues['EE_debug'] = true
	CreateRealTimeThread(function()
		EP_nums = {800,5000,12000,60000,140000}
		local sleep_count = 5000
		for _,no in ipairs(EP_nums) do
			local spawned = false
			local deleted = false
			EventProgress = NA_tutorial
			local events = {'AnimalAttack_Initial_Scissorhands','AnimalAttack_Initial_Dragonflies','AnimalAttack_Initial_Shriekers',
				'AnimalAttack_Initial_Junos','AnimalAttack_Initial_ManhuntingGlutch','OrbitalRadio_CamelAttack','OrbitalRadio_GujoAttack',
				'OrbitalRadio_NothAttack','OrbitalRadio_ScarabAttack','OrbitalRadio_ShoguAttack','OrbitalRadio_TecatliAttack',
				'OrbitalRadio_UlfenAttack','RobotAttack_Single_EarlyGame','RobotAttack_Single_MidGame','RobotAttack_Single_LateGame'
			}
			for _,sb in ipairs(events) do
				Sleep(sleep_count * 2)
				EventProgress = no
				local evo_chain = Find_evo_chain('Glutch_Manhunting')
				local correct_evo = evo_chain:get_correct_evo(no)
				local main, addl = check_count_and_upgrade('Glutch_Manhunting', {}, 100)
				while not spawned and not deleted do
					Sleep(sleep_count)
					if not spawned then
						EventProgress = no
						ForceActivateStoryBit(sb)
						spawned = true
						Sleep(sleep_count)
					elseif spawned then
						print("Already spawned this sb")
					end
					if spawned and not deleted then
						local invaders = MapCount("map", "UnitInvader")
						if invaders > 0 then
							print("There are invaders! Killing em")
							MapForEach("map","UnitInvader",function(unit) unit:CheatDelete() end)
							deleted = true
						end
					end
				end
				print("Onto the next SB")
				spawned = false
				deleted = false
			end
		end
	end)
end

OnMsg.ApplyModOptions = EE_init_and_set_options
--OnMsg.LoadGame = EE_check
OnMsg.GameStarted = EE_Instantiate
