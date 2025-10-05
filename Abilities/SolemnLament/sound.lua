--[[
Solemn Lament Local Animation & Input Script
Author: JaxOros
Description: Handles animations, sound effects, and input detection for 
the "Solemn Lament" skill locally for the player.
--]]

local tool = script.Parent
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

local rs = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")

-- RemoteEvents
local eventFolder = rs:WaitForChild("Events")
local clickEvent = eventFolder:WaitForChild("Clicked")
local critEvent = eventFolder:WaitForChild("Crit")

-- Animations
local animFolder = tool:WaitForChild("Animations")
local idleAnim = animFolder:WaitForChild("idle")
local walkAnim = animFolder:WaitForChild("walk")
local celebrationAnim = animFolder:WaitForChild("celebration")
local critAnim = animFolder:WaitForChild("crit")

-- Animator
local animator = hum:FindFirstChildOfClass("Animator")
if not animator then
	animator = Instance.new("Animator")
	animator.Parent = hum
end

-- Load animation tracks
local idleTrack = animator:LoadAnimation(idleAnim)
local walkTrack = animator:LoadAnimation(walkAnim)
local clickTrack = animator:LoadAnimation(celebrationAnim)
local critTrack = animator:LoadAnimation(critAnim)

-- Animation priorities
idleTrack.Priority = Enum.AnimationPriority.Idle
walkTrack.Priority = Enum.AnimationPriority.Movement

-- Sounds
local ping = Instance.new("Sound", char)
local pong = Instance.new("Sound", char)
ping.SoundId = "rbxassetid://17699455319"
pong.SoundId = "rbxassetid://17699458609"

-- Debounce and cooldown
local debounce = false
local cd = 5

--[[ 
Click Event Handler
Plays the celebration animation and ping/pong sounds when the server fires the "Clicked" event.
--]]
clickEvent.OnClientEvent:Connect(function()
	clickEvent:FireServer()
	clickTrack:Play()
	task.wait(0.2)
	ping:Play()
	task.wait(0.46)
	pong:Play()
	task.wait(clickTrack.Length - 0.86)
	clickTrack:Stop()
end)

--[[ 
Critical Input Handler
Listens for the R key. Fires the "Crit" event and plays the critical animation.
Includes debounce to prevent rapid firing.
--]]
uis.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.R then
		if debounce then return end
		debounce = true

		if tool.Equipped then
			critEvent:FireServer()
			critTrack:Play()
			task.wait(critTrack.Length)
			critTrack:Stop()
			print("R key pressed, firing crit event!")
		end

		task.wait(cd)
		debounce = false
	end
end)

--[[ 
Tool Equipped Handler
Continuously switches between idle and walking animations based on humanoid movement.
--]]
tool.Equipped:Connect(function()
	print("Equipped")
	while char == plr.Character and hum and hum.Parent do
		if hum.MoveDirection.Magnitude > 0 then
			if not walkTrack.IsPlaying then walkTrack:Play() end
			if idleTrack.IsPlaying then idleTrack:Stop() end
		else
			if not idleTrack.IsPlaying then idleTrack:Play() end
			if walkTrack.IsPlaying then walkTrack:Stop() end
		end
		task.wait(0.1)
	end
end)

--[[ 
Tool Unequipped Handler
Stops all animations when the tool is unequipped.
--]]
tool.Unequipped:Connect(function()
	print("Unequipped")
	if idleTrack then idleTrack:Stop() end
	if walkTrack then walkTrack:Stop() end
end)
