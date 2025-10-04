--[[ 
Lingering Snow Skill Script
Author: JaxOros
Description: Handles the activation of the Lingering Snow skill, including 
hitbox positioning, visual effects, damage detection, and camera control.
--]]

local tool = script.Parent
local hitbox = tool.Hitbox
local startEffects = hitbox.Start
local endEffects = hitbox.End

-- RemoteEvent to notify the client to start/stop camera manipulation
local event = game.ReplicatedStorage:FindFirstChild("LingeringSnow")
--[[
activate(folder, parentPart)
Enables all visual effects (Beams and ParticleEmitters) in a folder
and parents the folder to the given part.
--]]
local function activate(folder, parentPart)
	folder.Parent = parentPart
	for _, v in ipairs(folder:GetChildren()) do
		if v:IsA("Beam") then
			v.Enabled = true
			task.wait(0.1) -- stagger beam activation
		elseif v:IsA("ParticleEmitter") then
			v.Enabled = true
		end
	end
end

--[[
deactivate(folder)
Disables all Beams and ParticleEmitters in a folder.
--]]
local function deactivate(folder)
	for _, v in ipairs(folder:GetChildren()) do
		if v:IsA("Beam") or v:IsA("ParticleEmitter") then
			v.Enabled = false
		end
	end
end

--[[
playSound(sound, interval, count, parent)
Plays a sound multiple times safely, cloning it each time and destroying after playback.
--]]
local function playSound(sound, interval, count, parent)
	for i = 1, count do
		local sclone = sound:Clone()
		sclone.Parent = parent
		sclone:Play()
		sclone.Ended:Connect(function() sclone:Destroy() end)
		task.wait(interval)
	end
end

--[[
position(hitbox, part, offset)
Positions the hitbox relative to a reference part with the specified offset.
Hitbox is anchored and collisions are disabled.
--]]
local function position(hitbox, part, offset)
	hitbox.Anchored = true
	hitbox.CanCollide = false
	hitbox.CFrame = part.CFrame * offset
end

--[[
detect(hitbox, character, damage, duration, tickRate)
Detects all humanoids within the hitbox region repeatedly for the specified duration.
Applies damage to each humanoid once per tick.
--]]
local function detect(hitbox, character, damage, duration, tickRate)
	local ticks = math.floor(duration / tickRate)
	local regionSize = hitbox.Size
	local regionCFrame = hitbox.CFrame

	for _ = 1, ticks do
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.FilterDescendantsInstances = {character}

		local parts = workspace:GetPartBoundsInBox(regionCFrame, regionSize, params)
		local hitHumanoids = {}

		for _, part in ipairs(parts) do
			local enemy = part.Parent
			local enemyHum = enemy:FindFirstChildOfClass("Humanoid")
			if enemyHum and not hitHumanoids[enemyHum] then
				enemyHum:TakeDamage(damage)
				hitHumanoids[enemyHum] = true
			end
		end

		task.wait(tickRate)
	end
end

-- Main skill activation handler
tool.Activated:Connect(function()
	local character = tool.Parent
	character.Archivable = true -- ensure cloning is possible
	local player = game.Players:GetPlayerFromCharacter(character)
	local hrp = character.HumanoidRootPart

	-- Notify client to start camera control for cinematic effect
	event:FireClient(player, "Start", character, hitbox)

	-- Position hitbox and endEffects relative to character
	position(hitbox, hrp, CFrame.new(0, 9, -25))
	position(endEffects, hitbox, CFrame.new(0, 0, 0))

	-- Activate start effects asynchronously
	task.spawn(function()
		activate(startEffects, hitbox)
		task.wait(1)
		deactivate(startEffects)
	end)

	-- Begin damage detection in parallel
	task.spawn(function()
		detect(hitbox, character, 5, 12 * 0.2, 0.2)
	end)

	-- Perform phantom dashes along anchor points
	task.spawn(function()
		-- Hide the real character temporarily
		hrp.CFrame = hrp.CFrame - Vector3.new(0, 50, 0)
		hrp.Anchored = true

		for _, path in ipairs(slashPaths) do
			phantomDash(character, path, 0.3) -- moves clone along path
			task.wait(0.05)
		end
	end)

	-- Wait for first phase duration
	task.wait(12 * 0.2)

	-- Activate end effects and secondary damage detection
	task.spawn(function()
		activate(endEffects, hitbox)
		task.wait(15 * 0.2)
		deactivate(endEffects)
	end)

	task.spawn(function()
		detect(hitbox, character, 5, 15 * 0.2, 0.2)
	end)

	-- Restore character position and stop camera control
	task.spawn(function()
		task.wait(15 * 0.2)
		event:FireClient(player, "Stop")
		hrp.Anchored = false
		hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0)
	end)
end)
