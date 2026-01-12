AllSpeciesUpgrades = _G.Mods["rtw6tLg"] or false
local title = "Insects Level up All Species"
local separator = " :: "
local debugMSG = { "New Game", "Game Started" }
local hour_duration = const.HourDuration
local day_duration = const.DayDuration
local resource_scale = const.ResourceScale

function Bkob_Log(hard_string,var)
	DebugPrint(hard_string)
	DebugPrint(var)
	DebugPrint("\n")
end

function SavegameFixups.ILU_fixes()
	DebugPrint("Fixing up a save game due to older EE version present!\n")
	MapForEach("map", "GujoT2", function(obj)
		obj:ComposeBodyParts()
		obj:InitEntity()
	end)
	for i, animal in ipairs(UIPlayer.labels.TamedAnimals) do
		if not UIPlayer.research_center:IsTechResearched(animal['FieldResearchTech']) then
			CompleteResearch(animal['FieldResearchTech'])
		end
		animal:InitEntity()
	end
	MapForEach("map", "TerritorialNest", function(nest)
		nest:Init() -- resets nests from 1st and bad implementation
	end)
	refresh_tame_counts()
end
--[[ To be depreciated
function set_expedition_tame(id, name)
	DebugPrint("Expedition tame being set!")
	name = name or 'N/A'
	if MapVarValues['nest_awaken_exp_tame'] or MapVarValues['nest_awaken_exp_tame'] == 'N/A' then
		MapVarValues['nest_awaken_exp_tame'] = id
	else
		MapVar('nest_awaken_exp_tame', id)
	end
	if MapVarValues['nest_awaken_tame_name'] or MapVarValues['nest_awaken_exp_tame'] == 'N/A' then
		MapVarValues['nest_awaken_tame_name'] = name
	else
		MapVar('nest_awaken_tame_name', id)
	end
end
--]]
local function add_perks_to_animals(type)
	if type == 'milk' then
		local output = ClassDescendantsList("Unit", function (name, classdef)
			return (classdef.SpeciesGroup == 'species_ulfen' or classdef.SpeciesGroup == 'species_camel' or classdef.SpeciesGroup == 'species_noth') --unit_ent.SpeciesGroup == 'birds'
		end)
		for _,animal in ipairs(output) do
			local def = _G[animal]
			table.insert_unique(def.AnimalPerks, "MilkProducer")
		end
	elseif type == 'eggs' then
		local output = ClassDescendantsList("Unit", function (name, classdef)
			return classdef.SpeciesGroup == 'species_gujo' --unit_ent.SpeciesGroup == 'birds'
		end)
		for _,animal in ipairs(output) do
			local def = _G[animal]
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
	},
}

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

DefineClass.UnitEvolution = {
	__parents = { "UnitComponent" },
	properties = {
		{ category = "EE Combat", id = "unit_tier", name = "Unit Tier", editor = "number", help = "What tier of unit (This is tracked to ensure players can limit the max individual difficulty of a save by limiting based on tier)", },
		{ category = "EE Combat", id = "evolution", name = "Evolved Form", editor = "choice", items = function (self) return combat_units_with_false() end, help = "What exact class this creature evolves into", },
		{ category = "EE Combat", id = "devolution", name = "Ancestor", editor = "choice", items = function (self) return combat_units_with_false() end, help = "What exact class this creature evolved from.", },
	},
	unit_tier = 1,
	evolution = false,
	devolution = false
}

function Find_evolution(classdef)
	Bkob_Log("Finding evolution for: ",classdef.id)
	local possible
	if classdef.is_tameable and classdef.NewbornClass then
		possible = classdef.NewbornClass or classdef.id
	else
		possible = classdef.evolution or classdef.id
	end
	if g_Classes[possible].unit_tier > MapVarValues["ILU_Tier_Max"] then
		Bkob_Log("evolution not allowed to spawn. Reverting evolution to what we where given!",'')
		possible = classdef.id
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
	DebugPrint("Building final spawn table\n")
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
	local stop = get_stop(species)
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
	DebugPrint("Preg rate for ")
	DebugPrint(species)
	DebugPrint("\n")
	--local tame_check = MapVarValues['tame_last_refresh'] or 0
	--if tame_check + (2 * day_duration) < GameTime() then -- refresh every other day
	--		refresh_tame_counts()
	--end
	local base_rate = rate or specific_species.DailyPregnancyChance or 60 -- default to 60 instead of 0
	--local stop = get_stop(species_class)
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
	DebugPrint("Updating the armor HCs")
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
	DebugPrint("non-robot attack incoming\n")
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
	local this_defs_avg = DivRound(progress_and_weight, sum_weight)
	if this_defs_avg > min_average_cost then return build_output(temp_class_list) end
	local max_loops = 40
	local up_count_cap = 1
	local max_tier = GameVarValues['ILU_Tier_Max'] or 6
	local i = 0
	local capped = 0
	local evolution = false
	while i < max_loops and this_defs_avg < min_average_cost and capped < #temp_class_list do
		i = i + 1
		evolution = false
		for _, v in ipairs(temp_class_list) do
			local v_def = g_Classes[v['now']]
			local next = Find_evolution(v['now'])
			local maybe_evo = g_Classes[next]
			local not_this_unit = v['up_count'] ~= up_count_cap
			local same_creature = maybe_evo.id ~= v_def.id
			local now_capped = maybe_evo.tier == max_tier
			local too_high = maybe_evo.unit_tier > max_tier
			if not (not_this_unit or same_creature or too_high or evolution) then
				if now_capped then
					capped = capped + 1
				end
				evolution = maybe_evo
				v['now'] = evolution.id
				v['up_count'] = v['up_count'] + 1
				v['ep'] = evolution.EventProgressValue
				local weighted_ep_old = DivRound(v['weight'] * v_def.EventProgressValue, sum_weight)
				local weighted_ep_new = DivRound(v['weight'] * evolution.EventProgressValue, sum_weight)
				this_defs_avg = this_defs_avg - weighted_ep_old + weighted_ep_new
			end
		end
		if not evolution then
			up_count_cap = up_count_cap + 1
		end
	end
	return build_output(temp_class_list)
end

-- robot attack upgrader
function ILU_ActivateAttackDropshipSpawnDefs(robot_spawndef, main_unit, added_units, progress_mul)
	DebugPrint("Robot attack incoming\n")
	local robot_spawn_def = SpawnDefs[robot_spawndef]
	if not robot_spawn_def then return end
	local dropship_spawn_def = SpawnDefs["Attack_Dropship"]
	if not dropship_spawn_def then return end
	progress_mul = progress_mul or 100
	local addedClassList = {}
	local instance = {}
	instance.spawnClass, addedClassList = check_count_and_upgrade(main_unit, added_units)
	instance.AdditionalClassList = {}
	--print("First assault chosen", instance.spawnClass)
	--print(addedClassList)
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
	DebugPrint("EE animal trying to generate limited resources")
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
	DebugPrint("EE animal done generating resources (maybe)")
end

function EE_Instantiate()
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
end

function EE_init_and_set_options(id)
	EE_Instantiate()
	EE_set_mod_options(id)
end

function EE_set_mod_options(id)
	id = id or CurrentModId
	if is_preg_loaded() then
		DebugPrint("Pregnancy Mod detected!\n")
		AddGameNotification('Preg_mod_conflict')
	end
	local options = CurrentModOptions
	if CurrentModId ~= id or not CurrentModOptions then
		return
	end
	DebugPrint("EE Mod Options applied!\n")
	DebugPrint('Override tame cap found? ')
	DebugPrint(options.O_Man_Cap)
	DebugPrint("\n")
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
	if options.O_simple_combat == true then
		MapVarValues["ILU_combat_type"] = 'simple'
	elseif options.O_simple_combat == false then
		MapVarValues["ILU_combat_type"] = 'complex'
	else
		MapVarValues["ILU_combat_type"] = 'complex'
	end
	ILU_update_armor_hcs()
end

OnMsg.ApplyModOptions = EE_init_and_set_options
--OnMsg.LoadGame = EE_check
OnMsg.GameStarted = EE_Instantiate
