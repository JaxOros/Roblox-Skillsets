--[[
Solemn Lament Skill Script
Author: JaxOros
Description: Handles weapon equipping, hitbox generation, sound effects, 
and critical hit effects for the "Solemn Lament" skill.
--]]

local tool = script.Parent
local debris = game:GetService("Debris")
local rs = game:GetService("ReplicatedStorage")

-- RemoteEvents
local eventFolder = rs:FindFirstChild("Events")
local clickedEvent = eventFolder:FindFirstChild("Clicked")
local critEvent = eventFolder:FindFirstChild("Crit")

-- Cooldown and debounce
local cd = 0.75
local debounce = false

-- Handles
local handleBlack = tool:FindFirstChild("Solemn Lament-Black")
local handleWhite = tool:FindFirstChild("Solemn Lament-White")

-- Motor6Ds for equipping weapons
local slb = Instance.new("Motor6D")
local slw = Instance.new("Motor6D")

-- Sound objects
local ping = Instance.new("Sound")
local pong = Instance.new("Sound")

--[[ 
Equipped()
Sets up Motor6Ds to attach the Black and White handles to the 
character's left and right arms respectively.
--]]
local function Equipped()
	local char = tool.Parent
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local leftArm = char:FindFirstChild("Left Arm")
	local rightArm = char:FindFirstChild("Right Arm")
	if not hrp or not leftArm or not rightArm then return end

	-- Attach Black handle to Left Arm
	slb.Name = "Solemn Lament Black"
	slb.C0 = CFrame.new(0, -0.75, 0) * CFrame.Angles(0, math.rad(90), math.rad(-100))
	slb.C1 = CFrame.new(0, 0, 0)
	slb.Part0 = leftArm
	slb.Part1 = handleBlack
	slb.Parent = leftArm

	-- Attach White handle to Right Arm
	slw.Name = "Solemn Lament White"
	slw.C0 = CFrame.new(0, -0.75, 0) * CFrame.Angles(0, math.rad(90), math.rad(-100))
	slw.C1 = CFrame.new(0, 0, 0)
	slw.Part0 = rightArm
	slw.Part1 = handleWhite
	slw.Parent = rightArm
end

--[[ 
hitbox()
Generates a standard attack hitbox with two sequential damage waves. 
Applies damage to enemy humanoids in range. Handles cooldown.
--]]
local function hitbox()
	if debounce then return end
	debounce = true

	local char = tool.Parent
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then debounce = false return end

	-- Notify client about click
	local plr = game.Players:GetPlayerFromCharacter(char)
	clickedEvent:FireClient(plr)
	task.wait(0.2)

	-- First hitbox
	local hitbox1 = Instance.new("Part")
	hitbox1.Name = "Hitbox"
	hitbox1.Anchored = true
	hitbox1.CanCollide = false
	hitbox1.Transparency = 1
	hitbox1.Size = Vector3.new(5, 5, 20)
	hitbox1.CFrame = hrp.CFrame * CFrame.new(0, 0, -10)
	hitbox1.Parent = workspace
	debris:AddItem(hitbox1, 0.6)

	local hitCharacters1 = {}
	for _, part in ipairs(workspace:GetPartsInPart(hitbox1)) do
		local eChar = part.Parent
		if eChar ~= char and not hitCharacters1[eChar] then
			local eHum = eChar:FindFirstChild("Humanoid")
			if eHum and eHum.Health > 0 then
				eHum:TakeDamage(10)
				hitCharacters1[eChar] = true
			end
		end
	end

	task.wait(0.46)

	-- Second hitbox
	local hitbox2 = Instance.new("Part")
	hitbox2.Name = "Hitbox2"
	hitbox2.Anchored = true
	hitbox2.CanCollide = false
	hitbox2.Transparency = 1
	hitbox2.Size = Vector3.new(5, 5, 20)
	hitbox2.CFrame = hrp.CFrame * CFrame.new(0, 0, -10)
	hitbox2.Parent = workspace
	debris:AddItem(hitbox2, 0.6)

	local hitCharacters2 = {}
	for _, part in ipairs(workspace:GetPartsInPart(hitbox2)) do
		local eChar = part.Parent
		if eChar ~= char and not hitCharacters2[eChar] then
			local eHum = eChar:FindFirstChild("Humanoid")
			if eHum and eHum.Health > 0 then
				eHum:TakeDamage(7.5)
				hitCharacters2[eChar] = true
			end
		end
	end

	task.wait(cd)
	debounce = false
end

--[[ 
sound(soundObj)
Clones and plays a sound, automatically cleaning it up after playing.
--]]
local function sound(soundObj)
	local clone = soundObj:Clone()
	clone.Parent = soundObj.Parent
	clone:Play()
	debris:AddItem(clone, soundObj.TimeLength + 0.2)
end

--[[ 
critbox()
Generates multiple small hitboxes in sequence for a critical attack.
Plays alternating ping/pong sounds and applies damage.
--]]
local function critbox()
	local char = tool.Parent
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local plr = game.Players:GetPlayerFromCharacter(char)
	critEvent:FireClient(plr)

	for i = 1, 28 do
		local hitbox = Instance.new("Part")
		hitbox.Name = "Hitbox" .. i
		hitbox.Anchored = true
		hitbox.CanCollide = false
		hitbox.Transparency = 1
		hitbox.Size = Vector3.new(5, 5, 20)
		hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -10)
		hitbox.Parent = workspace
		debris:AddItem(hitbox, 0.6)

		-- Assign sounds
		ping.SoundId = "rbxassetid://17699455319"
		pong.SoundId = "rbxassetid://17699458609"
		if i % 2 == 0 then
			sound(ping)
		else
			sound(pong)
		end

		-- Damage handling in parallel
		local hitChars = {}
		task.spawn(function()
			local lifetime = 0.6
			local interval = 0.1
			local elapsed = 0
			while elapsed < lifetime do
				for _, part in ipairs(workspace:GetPartsInPart(hitbox)) do
					local eChar = part.Parent
					local eHum = eChar and eChar:FindFirstChild("Humanoid")
					if eHum and eHum.Health > 0 and eChar ~= char and not hitChars[eChar] then
						if i == 27 then
							eHum:TakeDamage(10)
						else
							eHum:TakeDamage(1)
						end
						hitChars[eChar] = true
					end
				end
				task.wait(interval)
				elapsed += interval
			end
		end)

		task.wait(0.13)
	end
end

--[[ 
createStaticHitbox(position, effectTemplate, emitCount, interval)
Creates a temporary hitbox with a particle effect that emits a specified
number of particles at the given interval.
--]]
local effectsFolder = rs:FindFirstChild("Effects")
local black = effectsFolder:FindFirstChild("Black")
local white = effectsFolder:FindFirstChild("White")
local blackEffect = black:FindFirstChild("1")
local whiteEffect = white:FindFirstChild("1")

local function createStaticHitbox(position, effectTemplate, emitCount, interval)
	local hitbox = Instance.new("Part")
	hitbox.Size = Vector3.new(3, 3, 1)
	hitbox.Anchored = true
	hitbox.CanCollide = false
	hitbox.Transparency = 1
	hitbox.CFrame = position
	hitbox.Parent = tool.Parent

	local effectInstance = effectTemplate:Clone()
	effectInstance.Parent = hitbox

	for i = 1, emitCount do
		effectInstance:Emit(emitCount)
		task.wait(interval)
	end

	debris:AddItem(hitbox, 0.6)
end

--[[ 
Client-triggered static hitboxes for click and crit events
--]]
clickedEvent.OnServerEvent:Connect(function()
	local char = tool.Parent
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Emit white then black effects
	createStaticHitbox(hrp.CFrame * CFrame.new(0, 0, -3), whiteEffect, 10, 0.025)
	task.wait(0.2)
	createStaticHitbox(hrp.CFrame * CFrame.new(0, 0, -3), blackEffect, 10, 0.025)
end)

critEvent.OnServerEvent:Connect(function()
	local char = tool.Parent
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	for i = 1, 13 do
		createStaticHitbox(hrp.CFrame * CFrame.new(0, 0, -3), whiteEffect, 10, 0)
		createStaticHitbox(hrp.CFrame * CFrame.new(0, 0, -3), blackEffect, 10, 0)
	end
end)

-- Connect tool events
tool.Activated:Connect(hitbox)
tool.Equipped:Connect(Equipped)
critEvent.OnServerEvent:Connect(critbox)
