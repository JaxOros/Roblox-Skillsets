--[[ 
Teleporter Script
Author: JaxOros
Description:
Handles player teleportation to a chosen zone when they touch the teleporter pad.
Displays a countdown timer and current teleporter capacity.
--]]

local Teleporter = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- References to RemoteEvents for GUI updates
local Remote_Folder = ReplicatedStorage:FindFirstChild("Remotes")
local gui_event = Remote_Folder:FindFirstChild("Zone_GUI")

-- GUI elements displaying timer and capacity
local Timer_Text = Teleporter:FindFirstChild("Timer_Holder")
                        :FindFirstChild("BillboardGui")
                        :FindFirstChild("TextLabel")
local Capacity_Text = Teleporter:FindFirstChild("Text_Holder")
                            :FindFirstChild("BillboardGui")
                            :FindFirstChild("TextLabel")

-- Extract numeric values from GUI text
local capacity_index = string.find(Capacity_Text.Text, "/") + 1
local timer_index = string.find(Timer_Text.Text, ":") + 2
local teleporter_capacity = tonumber(string.sub(Capacity_Text.Text, capacity_index, capacity_index + 1))
local teleporter_timer = tonumber(string.sub(Timer_Text.Text, timer_index, timer_index + 1))
local max_timer = teleporter_timer  -- store max timer for reset

local gui_debounce = false  -- ensures GUI event only fires once per cycle

-- Tables to track players inside the teleporter
local teleporter_holder = {} -- list of players queued for teleport
local touching_parts = {}    -- parts currently touching the teleporter

-- Function to teleport all queued players to the chosen boss
local function teleport(Chosen_Zone)
    for _, Player in ipairs(teleporter_holder) do
        local Character = Player.Character
        -- Only teleport players who are tagged as teleporting
        if not Character or not Character:HasTag("Teleporting " .. Teleporter.Name) then continue end

        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        Character:RemoveTag("Teleporting " .. Teleporter.Name)

        if HumanoidRootPart then
            -- Teleport player slightly above the boss position
            HumanoidRootPart.CFrame = Chosen_Zone.CFrame * CFrame.new(0, 5, 0)
        end
    end
end

-- Function to handle players touching or leaving the teleporter
local function touching(Character)
    local touching_count = 0

    -- Count how many parts are currently touching
    for _, is_touching in pairs(touching_parts) do
        if is_touching then
            touching_count += 1
        end
    end

    if touching_count > 0 then
        -- Player is entering the teleporter
        if #teleporter_holder >= teleporter_capacity then return end

        local Player = Players:GetPlayerFromCharacter(Character)

        -- Prevent duplicates
        for _, Added_Player in ipairs(teleporter_holder) do
            if Added_Player == Player then return end
        end
        
        -- Tag the character as teleporting
        Character:AddTag("Teleporting " .. Teleporter.Name)
        table.insert(teleporter_holder, Player)

        -- Fire GUI event for first player in queue
        if teleporter_holder[1] == Player and not gui_debounce then
            gui_event:FireClient(Player)
            gui_debounce = true
        end

        -- Update teleporter capacity display
        Capacity_Text.Text = #teleporter_holder .. " / " .. teleporter_capacity .. " Players"

    elseif touching_count == 0 then
        -- Player is leaving the teleporter
        local Player = Players:GetPlayerFromCharacter(Character)
        Character:RemoveTag("Teleporting " .. Teleporter.Name)

        -- Remove player from queue
        for index, Removed_Player in ipairs(teleporter_holder) do
            if Removed_Player == Player then
                table.remove(teleporter_holder, index)
                if index == 1 then
                    gui_debounce = false
                end
                break
            end
        end

        -- Update capacity display
        Capacity_Text.Text = #teleporter_holder .. " / " .. teleporter_capacity .. " Players"
    end
end

-- Event fired when a part touches the teleporter
Teleporter.Touched:Connect(function(Character_Part)
    local Character = Character_Part:FindFirstAncestorOfClass("Model")

    touching_parts[Character_Part] = true
    touching(Character)
end)

-- Event fired when a part leaves the teleporter
Teleporter.TouchEnded:Connect(function(Character_Part)
    local Character = Character_Part:FindFirstAncestorOfClass("Model")

    touching_parts[Character_Part] = nil
    touching(Character)
end)

-- Event fired by GUI when a zone is chosen
gui_event.OnServerEvent:Connect(function(Player, Chosen_Zone)
    local Character = Player.Character

    -- Countdown timer for teleport
    task.spawn(function()
        while teleporter_timer ~= 0 do
            task.wait(1)
            teleporter_timer -= 1
            Timer_Text.Text = "Time Left: " .. teleporter_timer
        end
    end)

    -- Teleport players when timer ends
    task.delay(teleporter_timer, function()
        teleport(Chosen_Zone)
        task.wait(1)
        teleporter_timer = max_timer
        Timer_Text.Text = "Time Left: " .. teleporter_timer
    end)
end)
