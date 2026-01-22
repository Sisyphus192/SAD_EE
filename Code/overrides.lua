
local def_group = const.Combat.DefaultGroup or "Default"
function CombatGroupsSetItems()
	local groups = {}
	ClassDescendants("AttackableObject", function(name, def, groups)
		groups[def.CombatGroup or def_group] = true
	end, groups)
	groups['Robots']=true
	return table.keys(groups, true)
end

-- Gujo (and Tecatli) override so they are more aggressive after 2 years of game time
function GujoBase:IsAttackTarget(target)
	local human_group = Human.CombatGroup
	if target.CombatGroup == human_group and GameTime() > (const.YearDuration * 2) then
		--Gujo never attack Humans, unless enraged (by Human) or forced by storybit
		if self:IsForcedAttackTarget(target) then
			return true
		end
		if self:IsAggressive() then
			local history = self.attacked_history
			for _, attacker in ipairs(history) do
				if attacker.CombatGroup == human_group and GameTime() - history[attacker] > self.AttackMemory then
					return true
				end
			end
		end
		return
	end
	return UnitAnimal.IsAttackTarget(self, target)
end

-- Raise assert time from 100ms to 500ms
function SpawnDef:ActivateSpawn(target, context, progress)
	if not self.Enabled or (GameState.Tutorial and not self.EnabledInTutorial) then return end
	if not self.EnabledWithoutSurvivors and not CheckValidSurvivorsOnMap() then return end
	if not CheckRegionSet(self.Regions) then return end
	local rand = InteractionRandCreate("SpawnActivate")
	local chance = self.Chance
	if chance < 100 and rand(100) > chance then return end
	if self.Cond and not self:Cond(target, context, progress) then return end
	local spawn_class = self:ResolveSpawnClass()
	local map_class = self.MapCountClass or spawn_class
	if self.MapCountLimit then
		local map_count = MapCount("map", map_class, self.MapCountFilter or nil)
		if map_count >= self.MapCountLimit then return end
	end
	local count = self.Count + rand(self.RandomCount + 1)
	local mod = self:CountMod(target, progress) or 100
	count = self:ModifyCount(count, mod, rand)
	if count <= 0 then
		return
	end
	NetUpdateHash("SpawnDef:Activate", self.id, count)
	dbg(self:DbgInit())
	
	local class_list = self:GetSpawnList()
	
	SpawnCounter = SpawnCounter + 1
	local occupied = {}
	local group_id = string.format("%s%d", self.id, SpawnCounter)
	local function TrySpawn(self, target, common_target, delay, occupied)
		if delay > 0 then
			Sleep(delay)
		end
		dbg(self:DbgBreak())
		local st = GetPreciseTicks()
		local class = spawn_class
		if #class_list > 1 then
			class = table.weighted_rand(class_list, 2, rand())[1]
		end
		local spawn_loc = self.SpawnAsGroup
			and self:FindGroupSpawnLoc(class, common_target, occupied)
			or self:FindSpawnLoc(class, target, context)
		if not spawn_loc then
			spawn_print("Failed to find location for", self.id)
		else
			NetUpdateHash("SpawnDef:Spawn", self.id, spawn_loc)
			dbg(self:DbgMarkSpawnPos(spawn_loc))
			local obj = self:Spawn(spawn_loc, class)
			if IsValid(obj) then
				self:PostSpawn(obj, spawn_loc, context)
				obj:AddToGroup(group_id)
				obj.SpawnGroupId = group_id
			end
		end
		if self.SpawnTimeLimit then
			local spawn_step_time = GetPreciseTicks() - st
			assert(spawn_step_time < 500)
		end
		return true
	end
	
	local spawn_as_group = self.SpawnAsGroup
	local spawned, count0 = 0, count
	local fixed_delay, throttle_delay, random_delay = self.Delay, self.ThrottleDelay, self.RandomDelay
	while count > 0 do
		--when groups are turned off - treat it as groups of size 1
		local group_count = spawn_as_group and rand(self.GroupSizeMin, self.GroupSizeMax) or 1
		group_count = Min(count, group_count)
		if group_count == 0 then group_count = count end
		count = count - group_count
		local common_target = spawn_as_group and self:FindSpawnLoc(spawn_class, target)
		for i = 1, group_count do
			local rand_delay
			local delay = fixed_delay
			if random_delay > 0 then
				delay = delay + rand(random_delay + 1)
			end
			if throttle_delay > 0 then
				delay = delay + MulDivRound(throttle_delay, spawned, count0)
			end
			delay = delay * 100 / self:DelayMod(target, progress)
			if delay > 0 then
				CreateGameTimeThread(TrySpawn, self, target, common_target, delay, occupied)
			else
				TrySpawn(self, target, common_target, 0, occupied)
			end
			spawned = spawned + 1
		end
	end
end

-- Making Robots use combat groups so factions can be enabled in more complex mods
AppendClass.Robot = {
	properties = {
		{ category = "Combat", id = "CombatGroup", name = "Combat Group", editor = "combo", default = false, items = CombatGroupsComboItems, template = true, help = "Members of the same combat group do not attack each other", },	},
}

-- Adding code that doesn't try and set a skill level above 10
function ModifySkill:OnStart(obj, context)
	local skill = self.Skill
	if skill == "" then return end
	if self.Inclination then
		obj:SetSkillInclination(skill, self.Inclination)
	end
	local level_change = self.Level
	if level_change ~= 0 then
		local old_level = obj:GetSkillLevel(skill) or 0
		local level = old_level + level_change
		obj:SetSkillLevel(skill, level)
		-- Override to not set levels higher than max allowed
		if level > 10 then
			level = 10
		end
	end
end