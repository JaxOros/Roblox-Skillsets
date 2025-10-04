--[[
Lingering Snow Camera Control (LocalScript)
Author: JaxOros
Description: Handles client-side camera behavior for the Lingering Snow skill.
Smoothly follows the character during skill activation and returns to normal after.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- RemoteEvent from server to start/stop camera control
local SkillCameraEvent = game.ReplicatedStorage:WaitForChild("LingeringSnow")

-- Camera control state variables
local controlling = false       -- Whether the skill camera is active
local cameraConnection          -- Connection to RenderStepped for smooth updates
local character = nil           -- Reference to the character being followed
local hitbox = nil              -- Reference to the hitbox part

-- Camera settings
local camAngle = Vector3.new(-35, 90, 0)  -- pitch (X), yaw (Y), roll (Z)
local camDistance = 20                     -- distance behind character
local camHeight = 70                       -- height above character
local camLerpSpeed = 0.2                   -- smooth movement speed

--[[
startCameraControl(char, hb)
Begins controlling the camera to follow the character during skill activation.
Sets camera to Scriptable and smoothly follows the character and hitbox.
--]]
local function startCameraControl(char, hb)
	if controlling then return end
	controlling = true
	character = char
	hitbox = hb
	camera.CameraType = Enum.CameraType.Scriptable

	-- Connect to RenderStepped for smooth camera updates
	cameraConnection = RunService.RenderStepped:Connect(function(dt)
		if not (controlling and character and hitbox) then return end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		-- Calculate camera target position using height, distance, and rotation offsets
		local upOffset = Vector3.new(0, camHeight, 0)
		local forwardOffset = Vector3.new(0, 0, -camDistance)
		local rotation = CFrame.Angles(math.rad(camAngle.X), math.rad(camAngle.Y), math.rad(camAngle.Z))
		local targetPos = hrp.Position + upOffset + (rotation:VectorToWorldSpace(forwardOffset))

		-- Smoothly interpolate camera position towards target
		camera.CFrame = camera.CFrame:Lerp(CFrame.new(targetPos, hitbox.Position), camLerpSpeed)
	end)
end

--[[
stopCameraControl()
Stops the skill camera and smoothly returns it to default behind-character view.
--]]
local function stopCameraControl()
	if not controlling then return end
	controlling = false

	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		-- Fallback: reset to default camera
		camera.CameraType = Enum.CameraType.Custom
		if cameraConnection then
			cameraConnection:Disconnect()
			cameraConnection = nil
		end
		return
	end

	local finalCFrame = CFrame.new(hrp.Position + Vector3.new(0, 5, 10), hrp.Position) -- default behind-character
	local lerpSpeed = 0.1

	-- Disconnect main RenderStepped connection
	if cameraConnection then
		cameraConnection:Disconnect()
		cameraConnection = nil
	end

	-- Smoothly return camera to default using new RenderStepped connection
	local returnConnection
	returnConnection = RunService.RenderStepped:Connect(function(dt)
		camera.CFrame = camera.CFrame:Lerp(finalCFrame, lerpSpeed)
		-- Stop once camera is close enough
		if (camera.CFrame.Position - finalCFrame.Position).Magnitude < 0.1 then
			camera.CFrame = finalCFrame
			camera.CameraType = Enum.CameraType.Custom
			returnConnection:Disconnect()
		end
	end)
end

--[[
Listen to RemoteEvent from server
Starts or stops camera control based on action ("Start" or "Stop")
--]]
SkillCameraEvent.OnClientEvent:Connect(function(action, char, hb)
	if action == "Start" then
		startCameraControl(char, hb)
	elseif action == "Stop" then
		stopCameraControl()
	end
end)
