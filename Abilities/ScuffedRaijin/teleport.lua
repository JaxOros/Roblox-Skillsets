--[[
Teleport Client Script (Local Script)
Author: JaxOros
Description: Allows players to place teleportation tags in the world
and teleport to them using mouse input.
--]]

local tool = script.Parent
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local teleport_event = tool:WaitForChild("RemoteEvent") -- RemoteEvent to notify server
local markTemplate = tool:WaitForChild("Mark") -- Template for tag object

local uis = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

-- Table to keep track of all placed tags
local tags = {}
local mouse
local button1Conn, button2Conn

--[[ 
getTagNearPosition(pos, radius)
Returns the first tag within a certain radius from the position.
Used to detect and remove nearby tags.
--]]
local function getTagNearPosition(pos, radius)
	for i, tag in ipairs(tags) do
		if (tag.Position - pos).Magnitude <= radius then
			return tag, i
		end
	end
	return nil
end

--[[ 
onButton1Down()
Handles left-click: places a tag on a valid target or removes nearby tags.
--]]
local function onButton1Down()
	if not mouse then return end
	local target = mouse.Target
	if not target then return end

	local hitPos = mouse.Hit.Position
	local root = character:FindFirstChild("HumanoidRootPart")
	-- Only allow placement if within 10 studs of the player
	if not root or (hitPos - root.Position).Magnitude > 10 then return end

	-- Check for nearby tag to remove
	local nearTag, index = getTagNearPosition(hitPos, 5)
	if nearTag then
		nearTag:Destroy()
		table.remove(tags, index)
		print("Removed nearby tag.")
		return
	end

	-- Create new tag
	local tag = markTemplate:Clone()
	tag.Mark.Enabled = true
	tag.CFrame = CFrame.new(hitPos)
	tag.Anchored = false
	tag.Parent = workspace

	-- Weld tag to the target object
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = tag
	weld.Part1 = target
	weld.Parent = tag

	-- Add to tags list
	table.insert(tags, tag)
	print("Placed tag on:", target:GetFullName())
end

--[[ 
onButton2Down()
Handles right-click: teleports player to the nearest tag in the direction of the camera.
--]]
local function onButton2Down()
	if #tags == 0 then
		warn("No tags exist.")
		return
	end

	-- Cast a ray from the camera to detect which tag the player is aiming at
	local mousePos = uis:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
	local rayOrigin = ray.Origin
	local rayDirection = ray.Direction.Unit * 500

	local closestTag = nil
	local closestDist = math.huge

	for _, tag in ipairs(tags) do
		local toTag = tag.Position - rayOrigin
		local projection = toTag:Dot(rayDirection.Unit)
		if projection < 0 then continue end -- skip tags behind the camera

		local closestPointOnRay = rayOrigin + rayDirection.Unit * projection
		local dist = (tag.Position - closestPointOnRay).Magnitude

		if dist <= 5 and projection < closestDist then
			closestTag = tag
			closestDist = projection
		end
	end

	if closestTag then
		-- Teleport player slightly above the tag
		local tpPos = closestTag.Position + Vector3.new(0, 3, 0)
		character:PivotTo(CFrame.new(tpPos))
		teleport_event:FireServer(tpPos)
		print("Teleported to tag:", closestTag:GetFullName())
	else
		warn("Not aiming at any tag.")
	end
end

--[[ 
tool.Equipped
Connects mouse button events when the tool is equipped
--]]
tool.Equipped:Connect(function(mouseObj)
	mouse = mouseObj
	button1Conn = mouse.Button1Down:Connect(onButton1Down)
	button2Conn = mouse.Button2Down:Connect(onButton2Down)
end)

--[[ 
tool.Unequipped
Disconnects events and clears references when tool is unequipped
--]]
tool.Unequipped:Connect(function()
	if button1Conn then button1Conn:Disconnect() end
	if button2Conn then button2Conn:Disconnect() end
	mouse = nil
end)
