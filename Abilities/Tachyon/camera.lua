--[[ 
Tachyon Camera POV Script (Local)
Author: JaxOros
Description: Handles the player's camera effects while Tachyon mode is active,
including dynamic FOV adjustments based on the character's speed.
--]]

local Players = game:GetService("Players")       -- For accessing the local player
local RunService = game:GetService("RunService") -- For frame-based updates

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid") -- Reference to character's humanoid
local camera = workspace.CurrentCamera

local tool = script.Parent
local stateValue = tool:WaitForChild("State") :: BoolValue -- Tracks if Tachyon mode is active

--[[ Camera FOV settings ]]
local minFOV = 70          -- Base FOV
local maxFOV = 120         -- Maximum FOV at high speed
local k = 0.02             -- Exponential growth factor for speed -> FOV
local lerpSpeed = 0.1      -- Smooth interpolation speed for FOV

--[[ 
calculateFOV(speed)
Returns a Field of View value based on the humanoid's current speed.
Uses exponential curve for smooth scaling.
--]]
local function calculateFOV(speed)
	return minFOV + (maxFOV - minFOV) * (1 - math.exp(-k * speed))
end

--[[ 
Monitor Tachyon state changes to adjust camera FOV
--]]
stateValue:GetPropertyChangedSignal("Value"):Connect(function()
	local active = stateValue.Value
	if active then
		-- Store original FOV to restore later
		local originalFOV = camera.FieldOfView

		-- Connect a RenderStepped loop to update FOV every frame
		local connection
		connection = RunService.RenderStepped:Connect(function(dt)
			if not stateValue.Value then
				-- Disconnect when Tachyon mode ends and reset FOV
				connection:Disconnect()
				camera.FieldOfView = originalFOV
				return
			end

			-- Calculate target FOV based on humanoid speed
			local targetFOV = calculateFOV(humanoid.WalkSpeed)
			-- Smoothly interpolate current FOV toward target FOV
			camera.FieldOfView = camera.FieldOfView + (targetFOV - camera.FieldOfView) * lerpSpeed
		end)
	else
		-- Reset FOV if toggled off manually
		camera.FieldOfView = minFOV
	end
end)
