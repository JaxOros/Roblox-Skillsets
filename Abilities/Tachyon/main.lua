--[[ 
Tachyon Skill Effect Script
Author: JaxOros
Description: Handles the activation of Tachyon mode, including spawning glyphs, 
speed boosts, and visual effects around the character.
--]]

local RunService = game:GetService("RunService")    -- For frame-based updates
local TweenService = game:GetService("TweenService") -- For fading in/out glyphs
local Debris = game:GetService("Debris")          -- For automatic cleanup of glyph parts

local tool = script.Parent
local stateValue = tool:WaitForChild("State") :: BoolValue -- Tracks if Tachyon mode is active

-- List of glyph textures
local TEXTURE_IDS = {
	"rbxassetid://139044966835385",
	"rbxassetid://86621276793056",
	"rbxassetid://119985107310602",
	"rbxassetid://127445800738386",
	"rbxassetid://94892303464853",
	"rbxassetid://77699957722613",
}

-- Tachyon speed and effect parameters
local SPEED_ON, SPEED_MAX, SPEED_SMOOTH = 2, 120, 8
local RAMP_IN, RAMP_OUT = 0.35, 0.25
local RATE_MIN, RATE_MAX = 1.5, 10.0
local FWD_MIN, FWD_MAX = 25.0, 35.0
local RAD_MIN, RAD_MAX = 1, 4.0
local V_JITTER = 1.2
local LIFE_MIN, LIFE_MAX = 1.4, 2.6
local SIZE_MIN, SIZE_MAX = 1.1, 2.6

-- Current Tachyon session
local session

--[[ 
ownerCharacter()
Returns the character associated with the tool.
If tool is in Backpack, returns the player’s character.
--]]
local function ownerCharacter()
	local p = tool.Parent
	if p and p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then return p end
	if p and p:IsA("Backpack") then
		local plr = p.Parent
		if typeof(plr) == "Instance" and plr:IsA("Player") then return plr.Character end
	end
	return nil
end

--[[ Utility functions for random and linear interpolation ]]
local function rand(a,b) return a + math.random()*(b-a) end
local function lerp(a,b,t) return a + (b-a)*t end

--[[ 
spawnGlyph(pos, parentFolder)
Spawns a single glyph at the given world position.
Glyph fades in, lingers, then fades out.
--]]
local function spawnGlyph(pos, parentFolder)
	local part = Instance.new("Part")
	part.Name = "TachyonGlyph"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.new(0.2,0.2,0.2)
	part.CFrame = CFrame.new(pos)
	part.Parent = parentFolder

	local bb = Instance.new("BillboardGui")
	bb.Name = "GlyphGui"
	bb.AlwaysOnTop = false
	bb.MaxDistance = 120
	bb.LightInfluence = 0
	local s = math.random()*(SIZE_MAX-SIZE_MIN) + SIZE_MIN
	bb.Size = UDim2.fromOffset(s*80, s*80)
	bb.StudsOffset = Vector3.new(0,0,0)
	bb.Parent = part

	local img = Instance.new("ImageLabel")
	img.BackgroundTransparency = 1
	img.AnchorPoint = Vector2.new(0.5,0.5)
	img.Position = UDim2.fromScale(0.5,0.5)
	img.Size = UDim2.fromScale(1,1)
	img.Image = TEXTURE_IDS[math.random(1,#TEXTURE_IDS)]
	img.ImageColor3 = Color3.fromRGB(255, 215 + math.random(-15,10), 90 + math.random(0,30))
	img.ImageTransparency = 1
	img.Rotation = math.random(0,359)
	img.Parent = bb

	local life = math.random()*(LIFE_MAX-LIFE_MIN)+LIFE_MIN

	-- Fade in quickly
	TweenService:Create(img, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0.08}):Play()
	-- Fade out near end of life
	task.delay(life*0.85, function()
		if img.Parent then
			TweenService:Create(img, TweenInfo.new(life*0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
		end
	end)

	-- Cleanup after life duration
	Debris:AddItem(part, life)
end

--[[ 
cleanupSession()
Disconnects all connections and removes glyph folder for the current session.
--]]
local function cleanupSession()
	if not session then return end
	if session.hb then session.hb:Disconnect() end
	if session.died then session.died:Disconnect() end
	if session.folder and session.folder.Parent then session.folder:Destroy() end
	session = nil
end

--[[ 
startSession(character)
Begins Tachyon mode for the given character.
Spawns glyphs around the character dynamically based on speed and movement.
--]]
local function startSession(character)
	if session and session.character == character then return end
	if session then cleanupSession() end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local hum = character:FindFirstChildOfClass("Humanoid")
	if not (hrp and hum) then return end

	local folder = Instance.new("Folder")
	folder.Name = "TachyonField_"..character.Name
	folder.Parent = workspace

	local smoothedSpeed, ramp, acc = 0, 0, 0

	-- Heartbeat loop: spawn glyphs continuously
	local hb = RunService.Heartbeat:Connect(function(dt)
		if not character.Parent or hum.Health <= 0 then cleanupSession() return end

		-- Smooth planar speed for spawn rate calculation
		local planar = Vector3.new(hrp.AssemblyLinearVelocity.X,0,hrp.AssemblyLinearVelocity.Z).Magnitude
		smoothedSpeed += (planar - smoothedSpeed) * math.clamp(SPEED_SMOOTH*dt, 0, 1)

		-- Compute alpha for glyph spawn intensity
		local alpha = math.clamp((smoothedSpeed - SPEED_ON)/math.max(1,(SPEED_MAX - SPEED_ON)), 0, 1)^1.15
		local active = stateValue.Value and (smoothedSpeed > SPEED_ON or hum.MoveDirection.Magnitude > 0.05)
		ramp = math.clamp(ramp + (active and (dt/RAMP_IN) or -(dt/RAMP_OUT)), 0, 1)

		local spawnRate = (RATE_MIN + (RATE_MAX - RATE_MIN)*alpha) * ramp
		acc += spawnRate * dt

		while acc >= 1 do
			acc -= 1
			-- Determine glyph position around character
			local fwd = hrp.CFrame.LookVector
			local right = hrp.CFrame.RightVector
			local up = hrp.CFrame.UpVector
			local fwdOff = lerp(FWD_MIN, FWD_MAX, alpha)
			local rad = rand(RAD_MIN, RAD_MAX)
			local ang = math.random()*math.pi*2
			local yj = rand(-V_JITTER, V_JITTER)
			local pos = hrp.Position + fwd*fwdOff + right*math.cos(ang)*rad + up*(math.sin(ang)*rad + yj)
			spawnGlyph(pos, folder)
		end
	end)

	-- Cleanup if humanoid dies
	local died = hum.Died:Connect(function() cleanupSession() end)

	session = {character=character, folder=folder, hb=hb, died=died}
end

--[[ 
speedControl()
Applies a gradual speed boost while Tachyon mode is active.
Resets walk speed when mode is deactivated.
--]]
local function speedControl()
	local c = ownerCharacter()
	local hum = c:FindFirstChild("Humanoid")
	while stateValue.Value do
		hum.WalkSpeed += 1
		task.wait(2)
	end
	if not stateValue.Value then
		hum.WalkSpeed = 16
	end
end

--[[ Tool activation: toggles Tachyon mode ]]
tool.Activated:Connect(function()
	task.wait(1)
	stateValue.Value = not stateValue.Value
	if stateValue.Value == false then
		cleanupSession()
		speedControl()
	else
		local c = ownerCharacter()
		if c then startSession(c) end
		speedControl()
	end
end)

--[[ Monitor state changes to start session if needed ]]
stateValue:GetPropertyChangedSignal("Value"):Connect(function()
	if stateValue.Value then
		local c = ownerCharacter()
		if (not session) and c then startSession(c) end
		speedControl()
	end
end)
