--[[ 
Teleport Server Script
Author: JaxOros
Description: Handles teleporting the player to a target CFrame sent from the client.
--]]

local tool = script.Parent
local teleport_event = tool:WaitForChild("RemoteEvent") -- RemoteEvent to listen for teleport requests

-- Event handler for when a player requests teleportation
teleport_event.OnServerEvent:Connect(function(player, targetCFrame)
	-- Ensure the player has a character
	local character = player.Character
	if not character then return end

	-- Get the HumanoidRootPart of the character
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		warn("[Server] Could not find HumanoidRootPart for", player.Name)
		return
	end

	-- Teleport the player's root part to the target CFrame
	root.CFrame = CFrame.new(targetCFrame.CFrame)
	print("[Server] Teleported", player.Name, "to", targetCFrame.CFrame)
end)
