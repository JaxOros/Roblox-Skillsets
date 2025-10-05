--[[
Stat Manager System
Author: JaxOros
Description:
Server-authoritative system for managing player stats, abilities, progression, equipment,
passive regeneration, and data persistence.
--]]

--[[
Services
--]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

--[[
Module Table
--]]
local StatManager = {}
StatManager.__index = StatManager

--[[
Default Stats
Editable
--]]
local DEFAULT_STATS = {
	Health = {Base=100, Max=100, Regen=1},
	Mana = {Base=50, Max=50, Regen=1},
	Stamina = {Base=75, Max=75, Regen=2},
	Strength = {Base=10, Max=100},
	Agility = {Base=10, Max=100},
	Intelligence = {Base=10, Max=100},
	Experience = {Base=0, Max=1000},
	Level = {Base=1, Max=100},
}

--[[
Internal State
--]]
local playersStats = {}  -- player -> stats
local playersAbilities = {} -- player -> abilities
local statChangeCallbacks = {} -- player -> {callback functions}
local abilityUseCallbacks = {} -- player -> {callback functions}
local playersEquipment = {} -- player -> {equipmentName -> equipmentData}
local passiveRegenRates = {Health=1, Mana=1, Stamina=2} -- editable

-- DataStore for saving/loading
local playerDataStore = DataStoreService:GetDataStore("PlayerStatManager")

--[[
Utility Functions
--]]
local function clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

local function createStatTable(player)
	local tbl = {}
	for statName, statData in pairs(DEFAULT_STATS) do
		tbl[statName] = {
			Value = statData.Base,
			Base = statData.Base,
			Max = statData.Max,
			Modifiers = {},
			Regen = statData.Regen or 0,
		}
	end
	return tbl
end

local function calculateStat(player, statName)
	local stat = playersStats[player][statName]
	if not stat then return end

	local value = stat.Base
	for _, mod in pairs(stat.Modifiers) do
		if mod.Type == "Add" then
			value += mod.Amount
		elseif mod.Type == "Multiply" then
			value *= mod.Amount
		end
	end
	stat.Value = clamp(value, 0, stat.Max)
	return stat.Value
end

--[[
Modifier Functions
--]]
function StatManager.applyModifier(player, statName, modName, modType, amount, duration)
	local stat = playersStats[player] and playersStats[player][statName]
	if not stat then return end
	local mod = {Name=modName, Type=modType, Amount=amount}
	stat.Modifiers[modName] = mod
	calculateStat(player, statName)
	if duration then
		task.delay(duration, function()
			if stat.Modifiers[modName] then
				stat.Modifiers[modName] = nil
				calculateStat(player, statName)
			end
		end)
	end
end

function StatManager.removeModifier(player, statName, modName)
	local stat = playersStats[player] and playersStats[player][statName]
	if stat and stat.Modifiers[modName] then
		stat.Modifiers[modName] = nil
		calculateStat(player, statName)
	end
end

function StatManager.getStat(player, statName)
	local stat = playersStats[player] and playersStats[player][statName]
	if not stat then return nil end
	return stat.Value
end

function StatManager.setStat(player, statName, value)
	local stat = playersStats[player] and playersStats[player][statName]
	if not stat then return end
	stat.Value = clamp(value, 0, stat.Max)
	if statChangeCallbacks[player] then
		for _, cb in ipairs(statChangeCallbacks[player]) do
			pcall(cb, player, statName, stat.Value)
		end
	end
end

function StatManager.addStatChangeListener(player, callback)
	if not statChangeCallbacks[player] then statChangeCallbacks[player] = {} end
	table.insert(statChangeCallbacks[player], callback)
end

--[[
Leveling & Experience
--]]
local function addExperience(player, amount)
	local stats = playersStats[player]
	if not stats then return end
	stats.Experience.Value += amount
	while stats.Experience.Value >= stats.Experience.Max do
		stats.Experience.Value -= stats.Experience.Max
		stats.Level.Value += 1
		stats.Experience.Max = math.floor(stats.Experience.Max*1.2)
		if statChangeCallbacks[player] then
			for _, cb in ipairs(statChangeCallbacks[player]) do
				pcall(cb, player, "LevelUp", stats.Level.Value)
			end
		end
	end
end

function StatManager.addExperience(player, amount)
	if playersStats[player] then addExperience(player, amount) end
end

--[[
Abilities System
--]]
function StatManager.registerAbility(player, abilityName, cooldown, requirementFunc, onUseFunc)
	if not playersAbilities[player] then playersAbilities[player] = {} end
	playersAbilities[player][abilityName] = {
		Cooldown = cooldown or 5,
		LastUsed = 0,
		Requirement = requirementFunc or function() return true end,
		OnUse = onUseFunc or function() end,
		Interactions = {}, -- general table for AoE, buffs, etc.
	}
end

function StatManager.useAbility(player, abilityName)
	local abilities = playersAbilities[player]
	if not abilities then return false end
	local ability = abilities[abilityName]
	if not ability then return false end
	local now = tick()
	if now - ability.LastUsed < ability.Cooldown then return false end
	if not ability.Requirement(player) then return false end
	ability.LastUsed = now
	ability.OnUse(player)
	-- process interactions
	for _, interaction in pairs(ability.Interactions) do
		pcall(interaction, player)
	end
	if abilityUseCallbacks[player] then
		for _, cb in ipairs(abilityUseCallbacks[player]) do
			pcall(cb, player, abilityName)
		end
	end
	return true
end

function StatManager.addAbilityUseListener(player, callback)
	if not abilityUseCallbacks[player] then abilityUseCallbacks[player] = {} end
	table.insert(abilityUseCallbacks[player], callback)
end

--[[
Equipment System
- Each equipment can apply modifiers and may have a level requirement
- equipmentData = {Name, LevelReq, Modifiers = {{Stat, Type, Amount}}, OnEquip, OnUnequip}
--]]
function StatManager.equipItem(player, equipmentData)
	if not playersStats[player] or not equipmentData then return false end
	if equipmentData.LevelReq and playersStats[player].Level.Value < equipmentData.LevelReq then return false end
	if not playersEquipment[player] then playersEquipment[player] = {} end
	if playersEquipment[player][equipmentData.Name] then return false end -- already equipped

	-- apply modifiers
	for _, mod in ipairs(equipmentData.Modifiers or {}) do
		StatManager.applyModifier(player, mod.Stat, equipmentData.Name, mod.Type, mod.Amount)
	end
	if equipmentData.OnEquip then pcall(equipmentData.OnEquip, player) end
	playersEquipment[player][equipmentData.Name] = equipmentData
	return true
end

function StatManager.unequipItem(player, equipmentName)
	local equipment = playersEquipment[player] and playersEquipment[player][equipmentName]
	if not equipment then return false end
	for _, mod in ipairs(equipment.Modifiers or {}) do
		StatManager.removeModifier(player, mod.Stat, equipmentName)
	end
	if equipment.OnUnequip then pcall(equipment.OnUnequip, player) end
	playersEquipment[player][equipmentName] = nil
	return true
end

function StatManager.getEquipment(player)
	return playersEquipment[player] or {}
end

--[[
Passive Regeneration
- Runs every interval, regenerates Health, Mana, Stamina
--]]
local REGEN_INTERVAL = 1
RunService.Heartbeat:Connect(function(dt)
	for player, stats in pairs(playersStats) do
		if player and player.Parent then
			for _, statName in pairs({"Health","Mana","Stamina"}) do
				local stat = stats[statName]
				if stat then
					local regenAmount = stat.Regen * REGEN_INTERVAL
					StatManager.setStat(player, statName, stat.Value + regenAmount)
				end
			end
		end
	end
end)

--[[
Data Persistence
--]]
local function savePlayerData(player)
	local stats = playersStats[player]
	local abilities = playersAbilities[player]
	local equipment = playersEquipment[player]
	if not stats then return end
	local success, err = pcall(function()
		local dataToSave = {
			Stats = {},
			Abilities = {},
			Equipment = {},
		}
		for k,v in pairs(stats) do
			dataToSave.Stats[k] = {Value=v.Value, Base=v.Base, Max=v.Max}
		end
		for k,v in pairs(abilities or {}) do
			dataToSave.Abilities[k] = {Cooldown=v.Cooldown, LastUsed=v.LastUsed}
		end
		for k,v in pairs(equipment or {}) do
			dataToSave.Equipment[k] = v -- raw table
		end
		playerDataStore:SetAsync(player.UserId, dataToSave)
	end)
	if not success then
		warn("Failed to save data for", player.Name, err)
	end
end

local function loadPlayerData(player)
	local success, data = pcall(function()
		return playerDataStore:GetAsync(player.UserId)
	end)
	if success and data then
		local stats = createStatTable(player)
		for k,v in pairs(data.Stats or {}) do
			if stats[k] then
				stats[k].Value = v.Value
				stats[k].Base = v.Base
				stats[k].Max = v.Max
			end
		end
		playersStats[player] = stats
		-- Abilities
		playersAbilities[player] = data.Abilities or {}
		-- Equipment
		playersEquipment[player] = data.Equipment or {}
	else
		playersStats[player] = createStatTable(player)
		playersAbilities[player] = {}
		playersEquipment[player] = {}
	end
end

Players.PlayerAdded:Connect(function(player)
	loadPlayerData(player)
end)

Players.PlayerRemoving:Connect(function(player)
	savePlayerData(player)
end)

--[[
Main Functions
- Stat management
- Modifiers
- Experience & Leveling
- Abilities
- Equipment
- Passive Regen is automatic
- Data saving/loading automatic
--]]
return StatManager
