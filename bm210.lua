if not game:IsLoaded() then game.Loaded:Wait() end
if game.GameId ~= 1720936166 then return end
local benchmark_time = os.clock()

-- Helper Functions
local function Split(s, delimiter)
    local result = {}
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

local function StringToCFrame(input)
    return CFrame.new(unpack(game:GetService("HttpService"):JSONDecode("[" ..
                                                                           input ..
                                                                           "]")))
end

local function ShallowCopy(original)
    local copy = {}
    for key, value in pairs(original) do copy[key] = value end
    return copy
end

local function DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then v = DeepCopy(v) end
        copy[k] = v
    end
    return copy
end

local function TableLength(t)
    local n = 0

    for _ in pairs(t) do n = n + 1 end

    return n
end

local function TableConcat(t1, t2)
    for i = 1, #t2 do t1[#t1 + 1] = t2[i] end
    return t1
end

local function get_keys(t)
    local keys = {}
    for key, _ in pairs(t) do table.insert(keys, key) end
    return keys
end

local postfixes = {
    ["n"] = 10 ^ (-6),
    ["m"] = 10 ^ (-3),
    ["k"] = 10 ^ 3,
    ["M"] = 10 ^ 6,
    ["G"] = 10 ^ 9
}

local function convert(n)
    local postfix = n:sub(-1)
    if postfixes[postfix] then
        return tonumber(n:sub(1, -2)) * postfixes[postfix]
    elseif tonumber(n) then
        return tonumber(n)
    else
        error("invalid postfix")
    end
end

-- https://devforum.roblox.com/t/comparing-color-values/1017439/2
local function CompareColor3(base, toCompare)
    local base_colors = {base.R, base.G, base.B} -- table to hold the original color3s
    local comp_colors = {toCompare.R, toCompare.G, toCompare.B} -- table to 

    local verdict = {} -- table to hold whether other not each of them were the same

    for index, col in ipairs(comp_colors) do -- uses an "ipairs" loop instead of "pairs" loop because this is numerical
        if base_colors[index] == col then -- checks if the index of the base_colors table is the same
            table.insert(verdict, true) -- add 1 true value to the verdict table
        else
            table.insert(verdict, false) -- add 1 false value to the verdict table
        end
    end

    if table.find(verdict, false) then -- if one of them is false then it isn't the same
        return false -- returns false
    else
        return true -- returns true
    end
end

local version = "4.0 BETA"
local Settings
local Macros = {}

benchmark_time = os.clock()

--[[local Rayfield = loadstring(game:HttpGet(
                                'https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
local Rayfield = loadstring(game:HttpGet(
                                'https://raw.githubusercontent.com/UI-Interface/CustomFIeld/main/RayField.lua'))()
local Rayfield = loadstring(game:HttpGet(
                                'https://karmapanda-script.herokuapp.com/rayfield'))()
()]] --

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "KarmaPanda's ASTD Script (Version 1.0)",
    LoadingTitle = "KarmaPanda's ASTD Script",
    LoadingSubtitle = "fork by blob",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = true, Invite = "BrnQQGKbvE", RememberJoins = true},
    KeySystem = false,
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    Theme = {
        TextColor = Color3.fromRGB(220, 220, 220),

        Background = Color3.fromRGB(18, 18, 18),
        Topbar     = Color3.fromRGB(26, 26, 26),
        Shadow     = Color3.fromRGB(12, 12, 12),

        NotificationBackground        = Color3.fromRGB(22, 22, 22),
        NotificationActionsBackground = Color3.fromRGB(200, 200, 200),

        TabBackground         = Color3.fromRGB(38, 38, 38),
        TabStroke             = Color3.fromRGB(50, 50, 50),
        TabBackgroundSelected = Color3.fromRGB(160, 28, 28),
        TabTextColor          = Color3.fromRGB(180, 180, 180),
        SelectedTabTextColor  = Color3.fromRGB(255, 255, 255),

        ElementBackground          = Color3.fromRGB(28, 28, 28),
        ElementBackgroundHover     = Color3.fromRGB(36, 36, 36),
        SecondaryElementBackground = Color3.fromRGB(20, 20, 20),
        ElementStroke              = Color3.fromRGB(48, 48, 48),
        SecondaryElementStroke     = Color3.fromRGB(38, 38, 38),

        SliderBackground = Color3.fromRGB(140, 24, 24),
        SliderProgress   = Color3.fromRGB(180, 32, 32),
        SliderStroke     = Color3.fromRGB(200, 40, 40),

        ToggleBackground          = Color3.fromRGB(28, 28, 28),
        ToggleEnabled             = Color3.fromRGB(180, 30, 30),
        ToggleDisabled            = Color3.fromRGB(80, 80, 80),
        ToggleEnabledStroke       = Color3.fromRGB(210, 45, 45),
        ToggleDisabledStroke      = Color3.fromRGB(100, 100, 100),
        ToggleEnabledOuterStroke  = Color3.fromRGB(120, 20, 20),
        ToggleDisabledOuterStroke = Color3.fromRGB(55, 55, 55),

        DropdownSelected   = Color3.fromRGB(38, 38, 38),
        DropdownUnselected = Color3.fromRGB(28, 28, 28),

        InputBackground  = Color3.fromRGB(24, 24, 24),
        InputStroke      = Color3.fromRGB(55, 55, 55),
        PlaceholderColor = Color3.fromRGB(140, 140, 140),
    }
})

-- Early close: if close_on_injection is enabled in the saved settings, hide UI immediately
-- This runs before full settings load so we read the file directly
pcall(function()
    local earlySettingsPath = "KarmaPanda\\ASTD\\Settings\\" .. game.Players.LocalPlayer.UserId .. ".json"
    if isfile(earlySettingsPath) then
        local earlySettings = game:GetService("HttpService"):JSONDecode(readfile(earlySettingsPath))
        if earlySettings and earlySettings.close_on_injection then
            task.spawn(function()
                task.wait(0.5)
                -- Simulate K press to toggle Rayfield closed ASAP
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, Enum.KeyCode.K, false, game)
                task.wait(0.1)
                vim:SendKeyEvent(false, Enum.KeyCode.K, false, game)
            end)
        end
    end
end)

print("[KarmaPanda] Rayfield Loaded: " .. os.clock() - benchmark_time)
benchmark_time = os.clock()

if not isfolder("KarmaPanda") then makefolder("KarmaPanda") end

if not isfolder("KarmaPanda\\ASTD") then makefolder("KarmaPanda\\ASTD") end

if not isfolder("KarmaPanda\\ASTD\\Settings") then
    makefolder("KarmaPanda\\ASTD\\Settings")
end

local SettingsFile = "KarmaPanda\\ASTD\\Settings\\" ..
                         game.Players.LocalPlayer.UserId .. ".json"

local InfiniteMapTable = {
    ["-1"] = "Regular [1]",
    ["-1.7"] = "Regular [2]",
    ["-1.1"] = "Category",
    ["-1.3"] = "Air",
    ["-1.8"] = "Solo",
    ["-1.9"] = "Random Unit",
    ["-1.5"] = "Double Path",
    ["-97"] = "Gauntlet",
    ["-98"] = "Training",
    ["-99"] = "Farm"
}

local AdventureMapTable = {
    ["-13"] = "String Raid",
    ["-1003"] = "Sijin Raid",
    ["-1004"] = "Spirit Raid",
    ["-1111"] = "Marine HQ",
    ["-1112"] = "Kai Planet",
    ["-1113"] = "Hell",
    ["-1114"] = "Machi Planet",
    ["-1117"] = "Candy Raid",
    ["-1118"] = "Demon Mark Raid",
    ["-1121"] = "Soul Raid",
    ["-1122"] = "Sun Raid",
    ["-1125"] = "Meteor Raid",
    ["-1127"] = "Berserker Raid",
    ["-1128"] = "Venom Raid",
    ["-1129"] = "Dueled Raid",
    ["-1132"] = "Hunt On Blacksmith",
    ["-1133"] = "Mythical Freedom",
    ["-1134"] = "Bizare Prison",
    ["-1136"] = "Six Eyes Raid",
    ["-1142"] = "TOP1",
    ["-1143"] = "TOP2",
    ["-1144"] = "TOP3",
    ["-1145"] = "TOP4",
    ["-1146"] = "TOP5",
    ["-1147"] = "TOP6",
    ["-1155"] = "Demon Raid M2",
    ["-1156"] = "Divine Raid",
    ["-1450"] = "Random Boss Rush",
    ["-1451"] = "Random Boss Rush 2",
    ["-1506"] = "Path Raid",
    ["-1550"] = "Enuma Raid",
    ["-1168"] = "Demon Memory Raid",
    ["-1167"] = "Ocean Memory Raid",
    ["-1166"] = "Earth Tournament Memory Raid",
    ["-1165"] = "Purple Planet Raid",
    ["-1164"] = "Darkness Raid",
    ["-1163"] = "Malevolent Raid",
    ["-1162"] = "Crystal Cavern Raid"
}

local function GetMapsFromTable(T)
    local maps = {}
    for _, v in pairs(T) do table.insert(maps, v) end
    return maps
end

local DefaultSettings = {
    version = version,
    auto_buff = true,
    auto_buff_units = {
        ["Erwin"] = {
            ["Mode"] = "Box",
            ["Checks"] = {"attack"},
            ["Ability Type"] = "Normal",
            ["Time"] = 13
        },
        ["Merlin"] = {
            ["Mode"] = "Pair",
            ["Checks"] = {"range"},
            ["Ability Type"] = "Normal",
            ["Time"] = 30
        },
        ["Brook6"] = {
            ["Mode"] = "Box",
            ["Checks"] = {"attack", "range"},
            ["Ability Type"] = "Normal",
            ["Time"] = 13
        },
        ["Kisuke6"] = {
            ["Mode"] = "Pair",
            ["Checks"] = {"attack", "range"},
            ["Ability Type"] = "Multiple",
            ["Ability Name"] = "Buff Ability",
            ["Time"] = 13
        },
        ["Rayleigh"] = {
            ["Mode"] = "Box",
            ["Checks"] = {"attack"},
            ["Ability Type"] = "Normal",
            ["Time"] = 13
        },
        ["Six Eyes Gojo"] = {
            ["Mode"] = "Cycle",
            ["Checks"] = {},
            ["Ability Type"] = "Normal",
            ["Cycle Units"] = 7,
            ["Time"] = 10,
            ["Delay"] = 1
        },
        ["Merlin6"] = {
            ["Time"] = 13,
            ["Checks"] = {"attack", "range"},
            ["Mode"] = "Box",
            ["Ability Type"] = "Normal"
        },
        ["Gojo7"] = {
            ["Time"] = 9.5,
            ["Checks"] = {""},
            ["Mode"] = "Box",
            ["Delay"] = 0,
            ["Ability Type"] = "Normal"
        },
        ["Hoshino"] = {
            ["Time"] = 15,
            ["Checks"] = {""},
            ["Mode"] = "Spam",
            ["Delay"] = 0,
            ["Ability Type"] = "Normal"
        },
        ["Metal Cooler"] = {
            ["Time"] = 21,
            ["Checks"] = {""},
            ["Mode"] = "Spam",
            ["Delay"] = 0.5,
            ["Ability Type"] = "Normal"
        },
        ["Satorou Gojou"] = {
            ["Time"] = 10,
            ["Checks"] = {""},
            ["Mode"] = "Box",
            ["Delay"] = 0,
            ["Ability Type"] = "Normal"
        }
    },
    auto_vote_extreme = false,
    auto_2x = false,
    auto_3x = false,
    macro_profile = "Default Profile",
    macro_record = false,
    macro_playback = false,
    macro_record_time_offset = 0,
    macro_money_tracking = false,
    macro_playback_time_offset = 0,
    macro_magnitude = 1,
    macro_playback_search_attempts = 60,
    macro_playback_search_delay = 1,
    macro_summon = true,
    macro_sell = true,
    macro_upgrade = true,
    macro_ability = true,
    macro_auto_ability = true,
    macro_priority = true,
    macro_skipwave = true,
    macro_autoskipwave = true,
    macro_speedchange = true,
    macro_ability_blacklist = {
        "Erwin", "Merlin", "Brook6", "Kisuke6", "Rayleigh", "Merlin6", "Gojo7",
        "Hoshino", "Metal Cooler"
    },
    macro_timer_version = "Version 2",
    action_queue_remote_fire_delay = 0.25,
    action_queue_remote_on_fail = true,
    action_queue_remote_on_fail_delay = 1,
    action_queue_remote_on_fail_delay_loop = 0.5,
    auto_join_game = false,
    auto_join_tower = false,
    auto_join_delay = 5,
    auto_join_mode = "Infinite",
    auto_join_story_level = 1,
    auto_join_infinite_level = "-1.7",
    auto_join_trial_level = 1,
    auto_join_raid_level = 1,
    auto_join_challenge_level = 1,
    auto_join_bout_level = 1,
    auto_join_adventure_level = "-1133",
    auto_join_w3_level = 1,
    auto_evolve_exp = true,
    auto_skip_gui = true,
    webhook_url = "",
    webhook_discord_id = "",
    webhook_user_name = true,
    webhook_color = "B41E1E",
    webhook_ping_user = false,
    webhook_end_game = false,
    webhook_exp_evolve = false,
    anti_afk = true,
    disable_3d_rendering = false,
    auto_execute = false,
    auto_battle = false,
    auto_battle_gems = 2700,
    fps_boost = false,
    auto_upgrade = false,
    auto_upgrade_money = 100,
    auto_upgrade_wave_stop = 100,
    auto_upgrade_sell = false,
    auto_upgrade_wave = 0,
    auto_upgrade_wave_sell = 100,
    anonymous_mode = true,
    anonymous_mode_name = "Anonymous",
    close_on_injection = false,
    auto_upgrade_targets = {}  -- empty = upgrade all; otherwise only these unit names
}

if not pcall(function() readfile(SettingsFile) end) then
    writefile(SettingsFile,
              game:GetService("HttpService"):JSONEncode(DefaultSettings))
end

if not pcall(function()
    Settings = game:GetService("HttpService"):JSONDecode(readfile(SettingsFile))
end) then
    writefile(SettingsFile,
              game:GetService("HttpService"):JSONEncode(DefaultSettings))
    Settings = DefaultSettings
end

local IndividualMacroDefaultSettings = {
    ["Macro"] = {},
    ["Units"] = {},
    ["Map"] = {},
    ["Settings"] = {}
}

local MacroDefaultSettings = {
    ["Default Profile"] = DeepCopy(IndividualMacroDefaultSettings)
}

local folder_name = "KarmaPanda\\ASTD\\" .. game.Players.LocalPlayer.UserId

if not isfolder(folder_name) then makefolder(folder_name) end

if #listfiles(folder_name) == 0 then
    writefile(folder_name .. "\\" .. "Default Profile.json",
              game:GetService("HttpService"):JSONEncode(MacroDefaultSettings))
end

for _, file in pairs(listfiles(folder_name)) do
    if not pcall(function()
        local json_content = game:GetService("HttpService"):JSONDecode(readfile(
                                                                           file))

        for k, v in pairs(json_content) do
            if Macros[k] ~= nil then
                delfile(file)
            else
                Macros[k] = v
            end
        end
    end) then print("Error reading file: " .. file) end
end

if TableLength(Macros) == 0 then
    writefile(folder_name .. "\\" .. "Default Profile.json",
              game:GetService("HttpService"):JSONEncode(MacroDefaultSettings))
    Macros["Default Profile"] = DeepCopy(IndividualMacroDefaultSettings)
end

local MacroProfileList = {}

for i, _ in pairs(Macros) do table.insert(MacroProfileList, i) end

if Macros[Settings.macro_profile] == nil then
    Settings.macro_profile = MacroProfileList[#MacroProfileList]
end

function Save()
    writefile(SettingsFile, game:GetService("HttpService"):JSONEncode(Settings))

    for profile_name, macro_table in pairs(Macros) do
        local save_data = {}
        save_data[profile_name] = macro_table
        writefile(folder_name .. "\\" .. profile_name .. ".json",
                  game:GetService("HttpService"):JSONEncode(save_data))
    end
end

for k, v in pairs(DefaultSettings) do
    if Settings[k] == nil then Settings[k] = v end
end

-- Migrate old orange webhook color to crimson red
if Settings.webhook_color == "FF8700" then
    Settings.webhook_color = "B41E1E"
end

Settings.version = version
Save()
print("[KarmaPanda] Filesystem Loaded: " .. os.clock() - benchmark_time)
benchmark_time = os.clock()

-- Game Helper Variables
local Player = game.Players.LocalPlayer
local GUI = Player.PlayerGui

-- Game Helper Functions
local function get_world()
    local worlds = {
        ["14657361824"] = -2, -- team event
        ["5552815761"] = -1, -- time chamber
        ["11574204578"] = 0,
        ["4996049426"] = 1,
        ["7785334488"] = 2
        -- ["11886211138"] = 3
    }
    return worlds[tostring(game.PlaceId)]
end

local function get_game_speed()
    return game:GetService("ReplicatedStorage").SpeedUP.Value
end

local function Delay(time, condition)
    local timeElapsed = 0
    local updates = 0.1 -- 100 ms checks

    while timeElapsed < time do
        if not condition then break end
        timeElapsed = timeElapsed + (updates * get_game_speed())
        task.wait(updates)
    end
end

local function get_units()
    local units = {}
    local T = game:GetService("Workspace").Unit:GetChildren()

    for k, v in pairs(T) do
        if v:FindFirstChild("Owner") ~= nil and tostring(v.Owner.Value) ==
            Player.Name then table.insert(units, v) end
    end

    return units
end

local CachedStats, OrbsV2Client, DataFolderClient

if get_world() ~= -1 and get_world() ~= -2 then
    CachedStats = require(Player.Backpack:WaitForChild("Framework")
                              :WaitForChild("CachedStats"))
    OrbsV2Client = require(game:GetService("ReplicatedStorage"):WaitForChild(
                               "Framework"):WaitForChild("OrbsV2Client"))
    DataFolderClient =
        require(game.ReplicatedStorage.Framework.DataFolderClient)
end

local function get_all_storage_items()
    local items = {}

    if get_world() ~= -1 and get_world() ~= -2 then
        local storageItems = game:GetService("ReplicatedStorage").StorageItems

        for _, item in pairs(storageItems:GetChildren()) do
            if item.Name ~= "Disc" then -- no package link smh
                table.insert(items, item.Name)
            end
        end
    end
    return items
end

local function get_all_units()
    local units = {}

    if get_world() ~= -1 and get_world() ~= -2 then
        for k, v in pairs(
                        game:GetService("ReplicatedStorage").Unit:GetChildren()) do
            if v.Name ~= "PackageLink" then
                table.insert(units, v.Name)
            end
        end
    end

    return units
end

local function get_stat(unit_name) return CachedStats.getstat(unit_name) end

local function get_unit_from_gui(unit_name)
    local UnitGUI = GUI:FindFirstChild("HUD"):FindFirstChild("BottomFrame")
                        :FindFirstChild("Unit")

    for _, v in pairs(UnitGUI:GetChildren()) do
        if v.ClassName == "Frame" then
            local u = v:FindFirstChild("Unit")
            if u.Value == unit_name then return v end
        end
    end

    return nil
end

local function get_loadout_units()
    local names = {}
    local seen = {}
    pcall(function()
        local UnitGUI = GUI:FindFirstChild("HUD"):FindFirstChild("BottomFrame")
                            :FindFirstChild("Unit")
        if UnitGUI then
            for _, v in pairs(UnitGUI:GetChildren()) do
                if v.ClassName == "Frame" then
                    local u = v:FindFirstChild("Unit")
                    if u and u.Value and u.Value ~= "" and not seen[u.Value] then
                        table.insert(names, u.Value)
                        seen[u.Value] = true
                    end
                end
            end
        end
    end)
    return names
end

local function get_summon_cost(unit_name)
    local cost = get_stat(unit_name)["Cost"]
    local discount = 0
    local unit = get_unit_from_gui(unit_name)

    if unit == nil then
        local orb = OrbsV2Client.GetAssignedOrbForUnit(unit_name)

        if orb ~= nil then
            local orb_stats = CachedStats.getOrbStat(orb)

            if orb_stats ~= nil then
                if orb_stats["InitialCost"] ~= nil then
                    discount = orb_stats["InitialCost"]
                end
                if orb_stats["InitialPercentageCost"] ~= nil then
                    cost = cost * orb_stats["InitialPercentageCost"]
                end
            end
        end

        return cost - discount
    else
        local image_label = unit:FindFirstChild("ImageLabel")

        if image_label ~= nil then
            local text_label = image_label:FindFirstChild("TextLabel")

            if text_label ~= nil then cost = convert(text_label.Text) end
        end

        return cost
    end
end

local function get_upgrade_cost(unit_name, level)
    local unit = get_stat(unit_name)

    if unit ~= nil then
        local upgrades = unit["Upgrade"]

        if upgrades[level] == nil then
            return 0
        else
            local cost = upgrades[level]["Cost"]
            local unit = get_unit_from_gui(unit_name)

            if unit ~= nil then
                local id = unit:FindFirstChild("ID")

                if id ~= nil then
                    local orb = OrbsV2Client.GetAssignedOrbForUnit(id.Value)
                    if orb ~= nil then
                        local orb_stats = CachedStats.getOrbStat(orb)

                        if orb_stats ~= nil then
                            if orb_stats["InitialPercentageCost"] ~= nil then
                                cost = cost * orb_stats["InitialPercentageCost"]
                            end
                        end
                    end
                end
            end

            return cost
        end
    else
        return 0 -- cannot find unit with get_stat
    end
end

local function get_max_upgrade_level(unit_name)
    return #get_stat(unit_name)["Upgrade"]
end

local function get_money() return Player:FindFirstChild("Money").Value end

local function get_wave()
    local WaveValue = game:GetService("ReplicatedStorage"):FindFirstChild(
                          "WaveValue")
    local wave = 0
    if WaveValue ~= nil then wave = WaveValue.Value end
    return wave
end

local function get_gems()
    if DataFolderClient ~= nil then
        return DataFolderClient.Get("Gems")
    else
        return nil
    end
end

local function get_gold()
    if DataFolderClient ~= nil then
        return DataFolderClient.Get("Gold")
    else
        return nil
    end
end

local function get_stardust()
    if DataFolderClient ~= nil then
        return DataFolderClient.Get("StardustStone")
    else
        return nil
    end
end

local function get_level()
    if DataFolderClient ~= nil then
        return DataFolderClient.Get("Level")
    else
        return nil
    end
end

local function get_battle_pass_tier()
    local bp_tier = "nil"

    pcall(function()
        bp_tier = GUI.TowerPassRewards.Main.Page.Main.Top.CurrentTierBox.Tier
                      .Text
    end)

    return bp_tier
end

local function is_lobby()
    if get_world() ~= -1 and get_world() ~= -2 then
        return game.ReplicatedStorage:FindFirstChild("Lobby").Value
    else
        return nil
    end
end

local function get_number_missions()
    if get_world() ~= -1 and get_world() ~= -2 then
        return #game.ReplicatedStorage.Remotes.Server:InvokeServer("Mission")
    else
        return 204
    end
end

local function GetInventory()
    return game.ReplicatedStorage.Remotes.Server:InvokeServer("Data", "Units")
end

local function UnequipUnit(unitName)
    game:GetService("ReplicatedStorage").Remotes.Input:FireServer("Unequip", {Stats = unitName})
    task.wait(0.3)
end

local function EquipUnit(unitID, unitLevel, unitName)
    local statsJson = game:GetService("HttpService"):JSONEncode({
        ID = unitID,
        Level = unitLevel,
        Name = unitName
    })
    game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("Equip", {Stats = statsJson})
    task.wait(0.2)
    game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("Data", "CurrentEquipSlot")
    task.wait(0.1)
    game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("Data", "Unit_Equip")
    task.wait(0.2)
end

local function GetCurrentEquippedUnits()
    local equipped = {}
    pcall(function()
        local equipData = game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("Data", "Unit_Equip")
        if equipData then
            for _, v in pairs(equipData) do
                if v.Name then
                    table.insert(equipped, v.Name)
                end
            end
        end
    end)
    return equipped
end

local function EquipMacroUnits()
    if not Macros[Settings.macro_profile] or not Macros[Settings.macro_profile]["Units"] then
        Rayfield:Notify({Title = "Auto Equip", Content = "No units found in the selected macro profile.", Duration = 5})
        return
    end

    local macroUnits = get_keys(Macros[Settings.macro_profile]["Units"])
    if #macroUnits == 0 then
        Rayfield:Notify({Title = "Auto Equip", Content = "No units found in the selected macro profile.", Duration = 5})
        return
    end

    -- Get player inventory
    local inventory = GetInventory()
    if not inventory then
        Rayfield:Notify({Title = "Auto Equip", Content = "Could not read inventory.", Duration = 5})
        return
    end

    -- Build lookup: find the best (highest level) version of each needed unit
    local bestUnits = {}  -- unitName -> {ID, Level, Name}
    for _, item in pairs(inventory) do
        if table.find(macroUnits, item.Name) then
            if not bestUnits[item.Name] or (item.Level or 0) > (bestUnits[item.Name].Level or 0) then
                bestUnits[item.Name] = {ID = item.ID, Level = item.Level or 1, Name = item.Name}
            end
        end
    end

    -- Check for missing units
    local missing = {}
    for _, name in pairs(macroUnits) do
        if not bestUnits[name] then
            table.insert(missing, name)
        end
    end

    if #missing > 0 then
        Rayfield:Notify({
            Title = "Missing Units",
            Content = "You do not have: " .. table.concat(missing, ", "),
            Duration = 8
        })
        -- Still equip the ones we do have
    end

    -- Unequip all current units first
    local currentEquipped = GetCurrentEquippedUnits()
    for _, name in pairs(currentEquipped) do
        UnequipUnit(name)
    end
    task.wait(0.5)

    -- Equip macro units
    local equipped = {}
    for _, name in pairs(macroUnits) do
        if bestUnits[name] then
            local unit = bestUnits[name]
            EquipUnit(unit.ID, unit.Level, unit.Name)
            table.insert(equipped, name)
        end
    end

    if #equipped > 0 then
        Rayfield:Notify({
            Title = "Auto Equip",
            Content = "Equipped " .. #equipped .. " unit(s): " .. table.concat(equipped, ", "),
            Duration = 6
        })
    end
end

local function get_game_status()
    local status = GUI.HUD:WaitForChild("MissionEnd"):WaitForChild("BG")
                       :WaitForChild("Status"):WaitForChild("Status")

    return status.Text
end

local function get_stage()
    local stage = "N/A"
    pcall(function()
        local smv = game:GetService("ReplicatedStorage"):FindFirstChild("STORYMODE_VALUE")
        if smv then
            local val = tonumber(smv.Value) or 0

            -- Tower floors: -100001 = floor 1, -100050 = floor 50, -100100 = floor 100
            if val <= -100001 then
                local floor = math.abs(val) - 100000
                stage = "Tower Floor " .. tostring(floor)

            -- Story mode: positive numbers are story levels
            elseif val > 0 then
                stage = tostring(val) .. " - Story"

            -- Infinite mode maps
            elseif InfiniteMapTable[tostring(val)] then
                stage = InfiniteMapTable[tostring(val)] .. " - Infinite"

            -- Adventure / Raid maps
            elseif AdventureMapTable[tostring(val)] then
                stage = AdventureMapTable[tostring(val)] .. " - Adventure"

            -- Check with decimal keys (e.g. "-1.7")
            else
                -- Try matching against infinite map keys with decimals
                local found = false
                for k, v in pairs(InfiniteMapTable) do
                    if tonumber(k) == val then
                        stage = v .. " - Infinite"
                        found = true
                        break
                    end
                end
                if not found then
                    for k, v in pairs(AdventureMapTable) do
                        if tonumber(k) == val then
                            stage = v .. " - Adventure"
                            found = true
                            break
                        end
                    end
                end
                if not found then
                    stage = tostring(val)
                end
            end
        end
    end)
    return stage
end

local function get_world_teleporter()
    if 1 == get_world() then
        return game:GetService("Workspace").Queue["W2 PERM"].World2.Script115
    elseif 2 == get_world() then
        return game:GetService("Workspace").Script115
    end
end

local function CheckAttackBuff(Units)
    pcall(function()
        for _, v in pairs(Units) do
            local buffs = v:FindFirstChild("Head"):FindFirstChild("EffectBBGUI")
            if buffs ~= nil then
                local attack_buff = buffs:FindFirstChild("Frame")
                                        :FindFirstChild("AttackImage")

                if not attack_buff.Visible then return false end
            else
                return false
            end
        end

        return true
    end)
end

local function CheckRangeBuff(Units)
    for _, v in pairs(Units) do
        local buffs = v:FindFirstChild("Head"):FindFirstChild("EffectBBGUI")
        if buffs ~= nil then
            local range_buff = buffs:FindFirstChild("Frame"):FindFirstChild(
                                   "RangeImage")

            if not range_buff.Visible then return false end
        else
            return false
        end
    end

    return true
end

local function CheckStun(unit)
    local buffs = unit:FindFirstChild("Head"):FindFirstChild("EffectBBGUI")
    if buffs ~= nil then
        local stun = buffs:FindFirstChild("Frame"):FindFirstChild("StunImage")

        if not stun.Visible then return false end
    else
        return false
    end

    return true
end

local function HideSummonGUI()
    while GUI:WaitForChild("HUD"):FindFirstChild("SUMMONGUI") ~= nil do
        local vim = game:GetService('VirtualInputManager')
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait()
        vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(0.25)
    end
end

local StartTime = 30
local TimeOffset = 0

local function ElapsedTime()
    local wave = get_wave()

    if wave > 0 then
        if Settings.macro_timer_version == "Version 1" then
            return getrenv()["time"]() + TimeOffset
        elseif Settings.macro_timer_version == "Version 2" then
            return (getrenv()["time"]() - StartTime) + TimeOffset
        end
    end

    return 0
end

local function CalculateTimeOffset()
    task.spawn(function()
        repeat task.wait() until get_game_speed() ~= nil and get_wave() > 0

        StartTime = getrenv()["time"]()

        while true do
            if get_game_speed() > 1 then
                TimeOffset = TimeOffset + ((get_game_speed() - 1) * 0.015)
            end
            task.wait(0.015)
            -- print("Macro Calculated Time:", ElapsedTime())
            -- print("Macro Calculated Time w/o Offset:", ElapsedTime() - TimeOffset)
        end
    end)
end

local function SendWebhook(fields)
    local status, error_message = pcall(function()
        local request = request or http_request or (http and http.request) or
                            syn.request

        local content = {}

        if Settings.webhook_user_name then
            table.insert(content, {
                ["name"] = "Username",
                ["value"] = "||" .. Player.Name .. "||"
            })
        end

        content = TableConcat(content, fields)

        local ping_message = ""

        if Settings.webhook_discord_id ~= "" and Settings.webhook_ping_user then
            ping_message = "<@" .. Settings.webhook_discord_id .. ">"
        end

        request({
            Url = Settings.webhook_url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = game:GetService("HttpService"):JSONEncode({
                ["content"] = ping_message,
                ["embeds"] = {
                    {
                        ["author"] = {
                            ["name"] = "KarmaPanda",
                            ["url"] = "https://discord.gg/d9Y7VDCQ7Z",
                            -- If this doesn't show, right-click image on imgur -> Copy Image Address and paste here
                            ["icon_url"] = "https://i.imgur.com/54Etjtw.png"
                        },
                        ["title"] = "discord.gg/d9Y7VDCQ7Z",
                        ["url"] = "https://discord.gg/d9Y7VDCQ7Z",
                        ["type"] = "rich",
                        ["color"] = tonumber(Settings.webhook_color, 16),
                        ["fields"] = content
                    }
                }
            })
        })
    end)

    if not status then print("Webhook error:", error_message) end
end

-- https://www.lua.org/pil/11.4.html
Queue = {}
function Queue.new() return {first = 0, last = -1} end
function Queue.pushleft(list, value)
    local first = list.first - 1
    list.first = first
    list[first] = value
end
function Queue.pushright(list, value)
    local last = list.last + 1
    list.last = last
    list[last] = value
end
function Queue.popleft(list)
    local first = list.first
    if first > list.last then error("list is empty") end
    local value = list[first]
    list[first] = nil -- to allow garbage collection
    list.first = first + 1
    return value
end
function Queue.popright(list)
    local last = list.last
    if list.first > last then error("list is empty") end
    local value = list[last]
    list[last] = nil -- to allow garbage collection
    list.last = last - 1
    return value
end
function Queue.length(list) return (list.last - list.first) + 1 end

-- Action Queue
local Action_Queue = Queue.new()
local Upgrade_Counter = 0

local function ActionQueueHelper()
    while task.wait() do
        if Queue.length(Action_Queue) > 0 then
            print("Actions in queue:", Queue.length(Action_Queue))
            local current = Queue.popleft(Action_Queue)
            local remote_method = current["Method"]
            local remote_args = current["Args"]
            print("Current Action", remote_method)
            for k, v in pairs(remote_args) do print(k, v) end
            if tostring(remote_method) == "Input" then
                game:GetService("ReplicatedStorage").Remotes.Input:FireServer(
                    unpack(remote_args))
            end
            if tostring(remote_method) == "Server" then
                game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer(
                    unpack(remote_args))
            end
            task.wait(Settings.action_queue_remote_fire_delay)
            if remote_args[1] == "Upgrade" then
                Upgrade_Counter = Upgrade_Counter - 1
            end
        end
    end
end

local function StartActionQueue()
    local success, error_message = pcall(ActionQueueHelper)

    -- Rerun code if something breaks in the action queue.
    while not success do
        print("Error with action queue found: " .. error_message)
        success, error_message = pcall(ActionQueueHelper)
        task.wait()
    end
end

-- Action Queue Functions
local function AddToQueue(remote_method, remote_args)
    Queue.pushright(Action_Queue,
                    {["Method"] = remote_method, ["Args"] = remote_args})
end

local function SummonUnit(rotation, cframe, unit_name)
    local status, err = pcall(function()
        local function CheckUnitExist(unit)
            local owner = unit:FindFirstChild("Owner")
            local hrp = unit:FindFirstChild("HumanoidRootPart")

            if owner ~= nil and hrp ~= nil then
                local magnitude =
                    (cframe.Position - hrp.CFrame.Position).magnitude

                if tostring(owner.Value) == Player.Name and unit.Name ==
                    unit_name and magnitude <= Settings.macro_magnitude then
                    return true
                end
            end

            return false
        end

        if type(cframe) == "string" then cframe = StringToCFrame(cframe) end

        if Settings.macro_money_tracking then
            repeat task.wait() until get_money() >= get_summon_cost(unit_name)
        end

        local summoned = false
        local connection = game:GetService("Workspace").Unit.ChildAdded:Connect(
                               function(unit)
                if CheckUnitExist(unit) then summoned = true end
            end)

        AddToQueue(game:GetService("ReplicatedStorage").Remotes.Input, {
            [1] = "Summon",
            [2] = {
                ["Rotation"] = rotation,
                ["cframe"] = cframe,
                ["Unit"] = unit_name
            }
        })

        if Settings.action_queue_remote_on_fail then
            task.spawn(function()
                task.wait(Settings.action_queue_remote_on_fail_delay)
                while not summoned do
                    if Queue.length(Action_Queue) == 0 then
                        for _, unit in pairs(
                                           game:GetService("Workspace").Unit:GetChildren()) do
                            if CheckUnitExist(unit, cframe) then
                                summoned = true
                                break
                            end
                        end
                        if not summoned then
                            AddToQueue(
                                game:GetService("ReplicatedStorage").Remotes
                                    .Input, {
                                    [1] = "Summon",
                                    [2] = {
                                        ["Rotation"] = rotation,
                                        ["cframe"] = cframe,
                                        ["Unit"] = unit_name
                                    }
                                })
                        end
                    end
                    task.wait(Settings.action_queue_remote_on_fail_delay_loop)
                end
                connection:Disconnect()
            end)
        else
            connection:Disconnect()
        end
    end)

    if not status then print("Error on Summon Unit: " .. err) end
end

local function UpgradeUnit(unit, upgrade_level)
    local status, err = pcall(function()
        local unit_upgrade_level = unit:FindFirstChild("UpgradeTag")
        local unit_max_upgrade_level = get_max_upgrade_level(unit.Name)

        local function UnitIsUpgraded()
            if unit_upgrade_level.Value >= upgrade_level or
                unit_upgrade_level.Value >= unit_max_upgrade_level then
                return true
            else
                return false
            end
        end

        -- repeat task.wait() until Upgrade_Counter == 0

        -- if Settings.macro_money_tracking then
        local total_upgrade_cost = 0
        local total_upgrade_levels = upgrade_level - unit_upgrade_level.Value

        for i = unit_upgrade_level.Value + 1, upgrade_level do
            total_upgrade_cost = total_upgrade_cost +
                                     get_upgrade_cost(unit.Name, i)
        end

        repeat
            task.wait()
            print(string.format(
                      "Macro money tracking, current money %s. Upgrade cost %s.",
                      get_money(), total_upgrade_cost))
            if UnitIsUpgraded() then return end
        until get_money() >= total_upgrade_cost
        -- end

        local upgraded = false

        local connection = unit_upgrade_level:GetPropertyChangedSignal("Value")
                               :Connect(function()
                if UnitIsUpgraded() then upgraded = true end
            end)

        for i = unit_upgrade_level.Value + 1, upgrade_level do
            -- Upgrade_Counter = Upgrade_Counter + 1
            game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer(
                "Upgrade", unit)
            -- AddToQueue(game:GetService("ReplicatedStorage").Remotes.Server, {[1] = "Upgrade", [2] = unit})
        end

        task.spawn(function()
            task.wait(1)
            while not upgraded do
                if Queue.length(Action_Queue) == 0 then
                    if UnitIsUpgraded() then break end
                    if not upgraded then
                        -- Upgrade_Counter = Upgrade_Counter + 1
                        game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer(
                            "Upgrade", unit)
                    end
                end
                task.wait(1)
            end
            connection:Disconnect()
        end)

        --[[if Settings.action_queue_remote_on_fail then
            task.spawn(function()
                task.wait(Settings.action_queue_remote_on_fail_delay)
                while not upgraded do
                    if Queue.length(Action_Queue) == 0 then
                        if UnitIsUpgraded() then break end
                        if not upgraded then
                            Upgrade_Counter = Upgrade_Counter + 1
                            AddToQueue(
                                game:GetService("ReplicatedStorage").Remotes
                                    .Server, {[1] = "Upgrade", [2] = unit})
                        end
                    end
                    task.wait(Settings.action_queue_remote_on_fail_delay_loop)
                end
                connection:Disconnect()
            end)
        else
            connection:Disconnect()
        end]] --
    end)

    if not status then print("Error on Upgrade Unit: " .. err) end
end

local function UseAbilityUnit(unit, ability_string)
    task.spawn(function()
        local status, err = pcall(function()
            local special_move = unit:FindFirstChild("SpecialMove")
            local special_move_enabled =
                special_move:FindFirstChild("Special_Enabled2")

            repeat task.wait() until not CheckStun(unit) and
                not special_move_enabled.Value

            local ability_used = false
            local connection = special_move_enabled:GetPropertyChangedSignal(
                                   "Value")
                                   :Connect(function()
                    ability_used = true
                end)

            AddToQueue(game:GetService("ReplicatedStorage").Remotes.Input, {
                [1] = "UseSpecialMove",
                [2] = unit,
                [3] = ability_string
            })

            if Settings.action_queue_remote_on_fail then
                task.spawn(function()
                    task.wait(Settings.action_queue_remote_on_fail_delay)
                    while not ability_used do
                        if Queue.length(Action_Queue) == 0 then
                            if special_move_enabled.Value then
                                break
                            end
                            if not ability_used then
                                AddToQueue(
                                    game:GetService("ReplicatedStorage").Remotes
                                        .Input, {
                                        [1] = "UseSpecialMove",
                                        [2] = unit,
                                        [3] = ability_string
                                    })
                            end
                        end
                        task.wait(
                            Settings.action_queue_remote_on_fail_delay_loop)
                    end
                    connection:Disconnect()
                end)
            else
                connection:Disconnect()
            end
        end)

        if not status then print("Error on Use Unit Ability: " .. err) end
    end)
end

local function UseMultipleAbilitiesGUI(ability_name)
    task.spawn(function()
        local gui = GUI:WaitForChild("MultipleAbilities")
        for k, v in pairs(gui:WaitForChild("Frame"):GetChildren()) do
            if v.Name == "ImageButton" then
                local text = v:WaitForChild("TextLabel")
                if text.Text == ability_name then
                    firesignal(v.Activated)
                    break
                end
            end
        end
    end)
end

local function UseKilluaWishesGUI(ability_name)
    task.spawn(function()
        local gui = GUI:WaitForChild("KilluaWishes")
        local Options = gui:WaitForChild("TextBackground"):WaitForChild(
                            "OptionsContainer")
        for k, v in pairs(Options:GetChildren()) do
            if v.Name == "Option" then
                if v.Text == ability_name then
                    print("Attempting to activate!")
                    for k, v in pairs(getconnections(v)) do
                        print(k, v)
                    end
                    -- TODO: Fix firesignal MouseButton1Click
                    pcall(function()
                        firesignal(v.MouseButton1Click)
                    end)
                    gui:Destroy()
                    break
                end
            end
        end
    end)
end

local function UseMultipleAbilitiesUnit(unit, ability_string, ability_name)
    -- TODO: Add check to make sure that unit is leveled for ability
    UseAbilityUnit(unit, ability_string)
    UseMultipleAbilitiesGUI(ability_name)
end

local function ActivateAutoAbilityUnit(unit, ability_string, toggled)
    AddToQueue(game:GetService("ReplicatedStorage").Remotes.Input,
               {[1] = "AutoToggle", [2] = unit, [3] = toggled})
    UseAbilityUnit(unit, ability_string)
end

local function ChangePriorityUnit(unit)
    AddToQueue(game:GetService("ReplicatedStorage").Remotes.Input,
               {[1] = "ChangePriority", [2] = unit})
end

local function SellUnit(unit)
    AddToQueue(game:GetService("ReplicatedStorage").Remotes.Input,
               {[1] = "Sell", [2] = unit})
end

local function SkipWave(wave)
    task.spawn(function()
        -- TODO: Use FindFirstChild etc
        repeat task.wait() until GUI.HUD.NextWaveVote.Visible

        -- TODO: Add remote refiring
        while get_wave() == wave and GUI.HUD.NextWaveVote.Visible do
            AddToQueue(game:GetService("ReplicatedStorage").Remotes.Input,
                       {[1] = "VoteWaveConfirm"})
            task.wait(1)
        end
    end)
end

local function AutoSkipWaveToggle(wave, status)
    task.spawn(function()
        repeat task.wait() until get_wave() >= wave

        local CategoryName = GUI:WaitForChild("HUD"):WaitForChild("Setting")
                                 :WaitForChild("Page"):WaitForChild("Main")
                                 :WaitForChild("Scroll"):WaitForChild(
                                     "SettingV2"):WaitForChild("AutoSkip")
                                 :WaitForChild("Options"):WaitForChild("Toggle")
                                 :WaitForChild("CategoryName")

        if CategoryName.Text ~= status then
            AddToQueue(game:GetService("ReplicatedStorage").Remotes.Input,
                       {[1] = "AutoSkipWaves_CHANGE"})
        end
    end)
end

local record_connections = {}

-- TODO: pcall this
local function GetUnitIndex(unit)
    if Macros[Settings.macro_profile]["Units"][unit.Name] == nil then
        Macros[Settings.macro_profile]["Units"][unit.Name] = {}
    end

    local index = nil
    local exists = false

    for i, v in ipairs(Macros[Settings.macro_profile]["Units"][unit.Name]) do
        local hrp = unit:WaitForChild("HumanoidRootPart", 1)

        if hrp ~= nil then
            local magnitude = (StringToCFrame(v["Position"]).Position -
                                  hrp.CFrame.Position).magnitude

            if magnitude <= Settings.macro_magnitude then
                exists = true
                index = i
                break
            end
        end
    end

    if index == nil then
        -- TODO: Find new rotation variable if needed.
        local rotation = 0

        --[[if getrenv()["_G"] ~= nil then
            rotation = getrenv()["_G"].RotateUnitPlacementValue
        end

        if rotation == nil then rotation = 0 end]] --

        table.insert(Macros[Settings.macro_profile]["Units"][unit.Name], {
            ["Rotation"] = rotation,
            ["Position"] = tostring(unit.HumanoidRootPart.CFrame)
        })
        index = #Macros[Settings.macro_profile]["Units"][unit.Name]
    end

    return index
end

-- TODO: pcall this
local function GetUnitByTargetInfo(Target)
    local unit_name = Target["Name"]
    local index = Target["Index"]

    local unit_info = Macros[Settings.macro_profile]["Units"][unit_name][index]
    local rotation = unit_info["Rotation"] -- only used for summons
    local cframe = StringToCFrame(unit_info["Position"]) -- used for identifying unit

    local unit = nil

    for _, v in pairs(game:GetService("Workspace").Unit:GetChildren()) do
        local hrp = v:WaitForChild("HumanoidRootPart", 1)

        if hrp ~= nil then
            local magnitude = (cframe.Position - hrp.CFrame.Position).magnitude

            if magnitude <= Settings.macro_magnitude then
                unit = v
                break
            end
        end
    end

    return unit, cframe, rotation
end

local function MacroRecordElapsedTime()
    return ElapsedTime() + Settings.macro_record_time_offset
end

local CurrentStep = nil

local function InsertToMacro(action)
    table.insert(Macros[Settings.macro_profile]["Macro"], action)
    Save()
    if CurrentStep ~= nil then
        CurrentStep = CurrentStep + 1
    else
        CurrentStep = 1
    end
end

local function HookUpgrade(unit, index)
    local upgrade_level = unit:WaitForChild("UpgradeTag", 60)

    if upgrade_level ~= nil then
        return upgrade_level:GetPropertyChangedSignal("Value"):Connect(
                   function()
                if Settings.macro_record and Settings.macro_upgrade then
                    InsertToMacro({
                        ["Time"] = MacroRecordElapsedTime(),
                        ["Target"] = {["Name"] = unit.Name, ["Index"] = index},
                        ["Remote"] = {[1] = "Upgrade", [2] = "Target"},
                        ["Parameter"] = {["Level"] = upgrade_level.Value}
                    })
                end
            end)
    else
        return nil
    end
end

local function HookAbility(unit, index)
    local special_move = unit:WaitForChild("SpecialMove", 15)

    if special_move ~= nil then
        local ability_2 = special_move:WaitForChild("Special_Enabled2", 15)

        if ability_2 == nil then return nil end

        local ability_1 = special_move:WaitForChild("Special_Enabled", 1)
        local ability_string = ""

        if ability_1 ~= nil then
            local special_enabled_string =
                ability_1:WaitForChild("Special_Enabled_String", 1)

            if special_enabled_string ~= nil then
                ability_string = special_enabled_string.Value
            end
        end

        return ability_2.ChildAdded:Connect(function(c)
            local status, err = pcall(function()
                if special_move:GetAttribute("Auto") then return end

                if Settings.macro_record and Settings.macro_ability and
                    table.find(Settings.macro_ability_blacklist, unit.Name) ==
                    nil then
                    if c.Name == "SpecialStart" then
                        InsertToMacro({
                            ["Time"] = MacroRecordElapsedTime(),
                            ["Target"] = {
                                ["Name"] = unit.Name,
                                ["Index"] = index
                            },
                            ["Remote"] = {
                                [1] = "UseSpecialMove",
                                [2] = "Target",
                                [3] = ability_string
                            }
                        })
                    end
                end
            end)

            if not status then
                print("Error on use ability hook: " .. err)
            end
        end)
    end

    return nil
end

local function HookAutoAbility(unit, index)
    local special_move = unit:WaitForChild("SpecialMove", 15)

    if special_move ~= nil then
        local special_enabled = special_move:WaitForChild("Special_Enabled", 1)
        local ability_string = ""

        if special_enabled ~= nil then
            local special_enabled_string =
                special_enabled:WaitForChild("Special_Enabled_String", 1)

            if special_enabled_string ~= nil then
                ability_string = special_enabled_string.Value
            end
        end

        return special_move:GetAttributeChangedSignal("Auto"):Connect(function()
            if Settings.macro_record and Settings.macro_auto_ability then
                InsertToMacro({
                    ["Time"] = MacroRecordElapsedTime(),
                    ["Target"] = {["Name"] = unit.Name, ["Index"] = index},
                    ["Remote"] = {
                        [1] = "AutoToggle",
                        [2] = "Target",
                        [3] = special_move:GetAttribute("Auto")
                    },
                    ["Parameter"] = {["Ability String"] = ability_string}
                })
            end
        end)
    end

    return nil
end

--[[local function HookPriority(unit, index)
    local priority = unit:WaitForChild("PriorityAttack", 60)

    if priority ~= nil then
        return priority:GetPropertyChangedSignal("Value"):Connect(function()
            if Settings.macro_record and Settings.macro_priority then
                InsertToMacro({
                    ["Time"] = MacroRecordElapsedTime(),
                    ["Target"] = {["Name"] = unit.Name, ["Index"] = index},
                    ["Remote"] = {[1] = "ChangePriority", [2] = "Target"},
                    ["Parameter"] = {["Priority"] = priority.Value}
                })
            end
        end)
    end

    return nil
end]] --

local function HookNextWave()
    local HUD = GUI:WaitForChild("HUD", 15)

    if HUD ~= nil then
        local next_wave_gui = HUD:WaitForChild("NextWaveVote", 15)

        if next_wave_gui == nil then return nil end

        local yes_button = next_wave_gui:WaitForChild("YesButton", 15)

        if yes_button ~= nil then
            return yes_button.MouseButton1Click:Connect(function()
                if Settings.macro_record and Settings.macro_skipwave then
                    InsertToMacro({
                        ["Time"] = MacroRecordElapsedTime(),
                        ["Remote"] = {[1] = "VoteWaveConfirm"},
                        ["Parameter"] = {["Wave"] = get_wave()}
                    })
                end
            end)
        end
    end

    return nil
end

local function HookAutoSkipWave()
    local Toggle = GUI:WaitForChild("HUD"):WaitForChild("Setting"):WaitForChild(
                       "Page"):WaitForChild("Main"):WaitForChild("Scroll")
                       :WaitForChild("SettingV2"):WaitForChild("AutoSkip")
                       :WaitForChild("Options"):WaitForChild("Toggle")
    local CategoryName = Toggle:WaitForChild("CategoryName")
    local Button = Toggle:WaitForChild("TextButton")

    if Button ~= nil then
        return Button.MouseButton1Click:Connect(function()
            if Settings.macro_record and Settings.macro_autoskipwave then
                InsertToMacro({
                    ["Time"] = MacroRecordElapsedTime(),
                    ["Remote"] = {[1] = "AutoSkipWaves_CHANGE"},
                    ["Parameter"] = {
                        ["Wave"] = get_wave(),
                        ["Status"] = CategoryName.Text
                    }
                })
            end
        end)
    else
        return nil
    end
end

local function HookMultipleAbilitiesGUI()
    local function Hook(c)
        if c.Name == "MultipleAbilities" then
            local Frame = c:WaitForChild("Frame")

            repeat task.wait() until #Frame:GetChildren() > 1

            for k, v in pairs(Frame:GetChildren()) do
                if v.Name == "ImageButton" then
                    local connection = v.MouseButton1Click:Connect(function()
                        local text = v:WaitForChild("TextLabel")
                        if Settings.macro_record and Settings.macro_ability then
                            InsertToMacro({
                                ["Time"] = MacroRecordElapsedTime(),
                                ["Remote"] = {[1] = "MultipleAbilities"},
                                ["Parameter"] = {["Ability Name"] = text.Text}
                            })
                        end
                    end)
                end
            end
        end
        if c.Name == "KilluaWishes" then
            local Options = c:WaitForChild("TextBackground"):WaitForChild(
                                "OptionsContainer")
            for k, v in pairs(Options:GetChildren()) do
                if v.Name == "Option" then
                    local connection = v.MouseButton1Click:Connect(function()
                        if Settings.macro_record and Settings.macro_ability then
                            InsertToMacro({
                                ["Time"] = MacroRecordElapsedTime(),
                                ["Remote"] = {[1] = "KilluaWishes"},
                                ["Parameter"] = {["Ability Name"] = v.Text}
                            })
                        end
                    end)
                end
            end
        end
    end

    for _, v in pairs(GUI:GetChildren()) do
        Hook(v) -- ensures all previous multiple abilities guis are found
    end

    return GUI.ChildAdded:Connect(function(c) Hook(c) end)
end

local function HookSpeedChanges()
    return
        game:GetService("ReplicatedStorage"):WaitForChild("SpeedUP").Changed:Connect(
            function(v)
                if Settings.macro_record and Settings.macro_speedchange then
                    InsertToMacro({
                        ["Time"] = MacroRecordElapsedTime(),
                        ["Remote"] = {[1] = "SpeedChange"},
                        ["Parameter"] = {["Speed"] = v}
                    })
                end
            end)
end

local function AddHooks(unit, index)
    -- TODO: Print error message if one of the hooks are nil.
    table.insert(record_connections, HookUpgrade(unit, index))
    table.insert(record_connections, HookAbility(unit, index))
    table.insert(record_connections, HookAutoAbility(unit, index))
    -- table.insert(record_connections, HookPriority(unit, index))
end

-- Temporary fix for priority recording
local game_metatable = getrawmetatable(game)
local namecall_original = game_metatable.__namecall

setreadonly(game_metatable, false)

game_metatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local script = getcallingscript()

    local Args = {...}

    if Settings.macro_record and Settings.macro_priority then
        if Args ~= nil and #Args > 1 and
            (method == "FireServer" or method == "InvokeServer") then
            if Args[1] == "ChangePriority" then
                task.spawn(function()
                    InsertToMacro({
                        ["Time"] = MacroRecordElapsedTime(),
                        ["Target"] = {
                            ["Name"] = Args[2].Name,
                            ["Index"] = GetUnitIndex(Args[2])
                        },
                        ["Remote"] = {[1] = "ChangePriority", [2] = "Target"}
                        -- ["Parameter"] = {["Priority"] = nil}
                    })
                end)
            end
        end
    end

    return namecall_original(self, ...)
end)

function StartMacroRecord()
    if Macros[Settings.macro_profile]["Macro"] == nil then
        Macros[Settings.macro_profile]["Macro"] = {}
    end

    if Macros[Settings.macro_profile]["Settings"] == nil then
        Macros[Settings.macro_profile]["Settings"] = {}
    end

    if Macros[Settings.macro_profile]["Map"] == nil then
        Macros[Settings.macro_profile]["Map"] = {}
    end

    if Macros[Settings.macro_profile]["Units"] == nil then
        Macros[Settings.macro_profile]["Units"] = {}
    end

    if is_lobby() then return end

    local Units = game:GetService("Workspace"):WaitForChild("Unit")
    for _, unit in pairs(get_units()) do AddHooks(unit, GetUnitIndex(unit)) end
    print("Hooked Units In Workspace...")

    task.spawn(function()
        table.insert(record_connections, Units.ChildAdded:Connect(function(unit)
            local owner = unit:WaitForChild("Owner")

            if tostring(owner.Value) == Player.Name then
                local index = GetUnitIndex(unit)

                if Settings.macro_record and Settings.macro_summon then
                    InsertToMacro({
                        ["Time"] = MacroRecordElapsedTime(),
                        ["Target"] = {["Name"] = unit.Name, ["Index"] = index},
                        ["Remote"] = {[1] = "Summon", [2] = "Target"}
                    })
                end

                AddHooks(unit, index)
            end
        end))
        print("Hooked Unit Summoning...")
    end)

    task.spawn(function()
        table.insert(record_connections,
                     Units.ChildRemoved:Connect(function(unit)
            if Settings.macro_record and Settings.macro_sell then
                local owner = unit:WaitForChild("Owner")

                if tostring(owner.Value) == Player.Name then
                    local index = GetUnitIndex(unit)

                    InsertToMacro({
                        ["Time"] = MacroRecordElapsedTime(),
                        ["Target"] = {["Name"] = unit.Name, ["Index"] = index},
                        ["Remote"] = {[1] = "Sell", [2] = "Target"}
                    })

                    Save()
                end
            end
        end))
        print("Hooked Units Selling...")
    end)

    task.spawn(function()
        table.insert(record_connections, HookNextWave())
        print("Hooked Next Wave...")
    end)

    task.spawn(function()
        table.insert(record_connections, HookMultipleAbilitiesGUI())
        print("Hooked Multiple Abilities GUI...")
    end)

    task.spawn(function()
        table.insert(record_connections, HookAutoSkipWave())
        print("Hooked Auto Skip Wave...")
    end)

    task.spawn(function()
        table.insert(record_connections, HookSpeedChanges())
        print("Hooked Speed Changes...")
    end)

    Rayfield:Notify({
        Title = "Macro Recording",
        Content = "Started Macro Recording...",
        Duration = 6.5,
        Image = 4483362458
    })
end

function StopMacroRecord()
    for _, v in pairs(record_connections) do v:Disconnect() end
    record_connections = {}
    Rayfield:Notify({
        Title = "Macro Recording",
        Content = "Stopped Macro Recording...",
        Duration = 6.5,
        Image = 4483362458
    })
end

function StartMacroPlayback()
    if is_lobby() then return end

    table.sort(Macros[Settings.macro_profile]["Macro"],
               function(a, b) return a["Time"] < b["Time"] end)

    CurrentStep, _ = next(Macros[Settings.macro_profile]["Macro"], CurrentStep)

    while CurrentStep do
        local Current = Macros[Settings.macro_profile]["Macro"][CurrentStep]

        repeat task.wait() until ElapsedTime() +
            Settings.macro_playback_time_offset >= Current["Time"] or
            not Settings.macro_playback

        if not Settings.macro_playback then break end

        local Remote = Current["Remote"]

        if Current["Target"] == nil then
            if Remote[1] == "VoteWaveConfirm" then
                SkipWave(Current["Parameter"]["Wave"])
            elseif Remote[1] == "AutoSkipWaves_CHANGE" then
                AutoSkipWaveToggle(Current["Parameter"]["Wave"],
                                   Current["Parameter"]["Status"])
            elseif Remote[1] == "MultipleAbilities" then
                UseMultipleAbilitiesGUI(Current["Parameter"]["Ability Name"])
            elseif Remote[1] == "KilluaWishes" then
                UseKilluaWishesGUI(Current["Parameter"]["Ability Name"])
            elseif Remote[1] == "SpeedChange" then
                ChangeSpeed(Current["Parameter"]["Speed"])
            else
                print(string.format(
                          "Macro error! Invalid target found for remote %s at step %s",
                          Remote[1], CurrentStep))
            end
        else
            local unit, position, rotation =
                GetUnitByTargetInfo(Current["Target"])

            if unit == nil and position and rotation then
                if Remote[1] == "Summon" and Settings.macro_summon then
                    SummonUnit(rotation, position, Current["Target"]["Name"])
                else
                    local attempts = 0
                    repeat
                        task.wait(Settings.macro_playback_search_delay)
                        unit, position, rotation =
                            GetUnitByTargetInfo(Current["Target"])
                        print(string.format(
                                  "Macro is attempting to find the unit for %s. Increase magnitude if this continues to occur or check if unit is being summoned.",
                                  Remote[1]))
                        attempts = attempts + 1
                    until unit ~= nil or attempts >=
                        Settings.macro_playback_search_attempts or
                        not Settings.macro_playback

                    if attempts >= Settings.macro_playback_search_attempts then
                        print(string.format(
                                  "Macro skipped step %s for action %s, target %s, time %s. Please check if unit is being summoned correctly, or if it is a issue with macro playback.",
                                  CurrentStep, Remote[1],
                                  Current["Target"]["Name"], Current["Time"]))
                    end
                end
            end

            if unit ~= nil then
                if Remote[1] == "Upgrade" and Settings.macro_upgrade then
                    UpgradeUnit(unit, Current["Parameter"]["Level"])
                elseif Remote[1] == "UseSpecialMove" and Settings.macro_ability and
                    table.find(Settings.macro_ability_blacklist, unit.Name) ==
                    nil then
                    UseAbilityUnit(unit, Remote[3])
                elseif Remote[1] == "AutoToggle" and Settings.macro_auto_ability then
                    ActivateAutoAbilityUnit(unit,
                                            Current["Parameter"]["Ability String"],
                                            Remote[3])
                elseif Remote[1] == "ChangePriority" and Settings.macro_priority then
                    ChangePriorityUnit(unit)
                elseif Remote[1] == "Sell" and Settings.macro_sell then
                    SellUnit(unit)
                elseif Remote[1] == "Summon" then
                    print(
                        "Macro attempting to summon a unit that already exists!")
                else
                    print("Macro error! Remote %s is not a valid for ASTD.")
                end
            elseif unit ~= nil and Remote[1] ~= "Summon" then
                print(string.format(
                          "Macro error! Cannot find unit for remote %s at step %s",
                          Remote[1], CurrentStep))
            end
        end

        CurrentStep, _ = next(Macros[Settings.macro_profile]["Macro"],
                              CurrentStep)
        task.wait()
    end
end

function StopMacroPlayback() if is_lobby() then return end end

function AutoVoteExtreme()
    repeat task.wait() until GUI.HUD.ModeVoteFrame.Visible

    repeat
        game:GetService("ReplicatedStorage").Remotes.Input:FireServer(unpack({
            [1] = "VoteGameMode",
            [2] = "Extreme"
        }))
        task.wait(1)
    until not GUI.HUD.ModeVoteFrame.Visible
end

function AutoBattle()
    repeat task.wait() until GUI.HUD.FastForward.Autoplay.Visible

    if get_gems() < Settings.auto_battle_gems then
        Settings.auto_battle = false
        Rayfield:Notify({
            Title = "You have no gems to run Auto Battle!",
            Content = "Auto battle paused until you have more gems!",
            Duration = 6.5,
            Image = 4483362458,
            Actions = {Ignore = {Name = "Okay!", Callback = function() end}}
        })
        return
    end

    local function pressKey(keyCode)
        game:GetService("VirtualInputManager"):SendKeyEvent(true, keyCode, false, game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, keyCode, false, game)
    end

    if GUI.HUD.FastForward.Autoplay.Visible then
        pressKey(Enum.KeyCode.BackSlash)
        task.wait(0.5)
        pressKey(Enum.KeyCode.Right)
        task.wait(0.5)
        pressKey(Enum.KeyCode.Return)
        task.wait(0.5)
        pressKey(Enum.KeyCode.BackSlash)
    end

    repeat task.wait() until GUI.Notification:WaitForChild("Message").Visible or
        CompareColor3(GUI.HUD.FastForward.Autoplay.BackgroundColor3, Color3.fromRGB(10, 230, 0))

    if not CompareColor3(GUI.HUD.FastForward.Autoplay.BackgroundColor3, Color3.fromRGB(10, 230, 0)) then
        local autoplay_popup = GUI.Notification:WaitForChild("Message")
                                   :WaitForChild("Message"):WaitForChild("Main")

        if autoplay_popup.Text.Text == "Want to spend 20 gems on AutoPlay" then
            pressKey(Enum.KeyCode.BackSlash)
            task.wait(0.5)
            pressKey(Enum.KeyCode.Right)
            task.wait(0.5)
            pressKey(Enum.KeyCode.Right)
            task.wait(0.5)
            pressKey(Enum.KeyCode.Return)
            task.wait(0.5)
            pressKey(Enum.KeyCode.BackSlash)
        end
    end
end

local function ManualUpgrade() -- added for pc
    if GUI.HUD.UpgradeV2.Actions.Upgrade.Visible then
        firesignal(GUI.HUD.UpgradeV2.Actions.Upgrade.MouseButton1Click)
    end
end

local function ManualSell() -- added for pc
    if GUI.HUD.UpgradeV2.Actions.Sell.Visible then
        firesignal(GUI.HUD.UpgradeV2.Actions.Sell.MouseButton1Click)
    end
end

game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        ManualUpgrade()
    elseif input.KeyCode == Enum.KeyCode.Q then
        ManualSell()
    end
end)

function ChangeSpeed(speed)
    task.spawn(function()
        while get_game_speed() ~= tonumber(speed) do
            local args = {[1] = "SpeedChange", [2] = true}
            if get_game_speed() < tonumber(speed) then
                game:GetService("ReplicatedStorage").Remotes.Input:FireServer(
                    unpack(args))
            elseif get_game_speed() > tonumber(speed) then
                args[2] = false
                game:GetService("ReplicatedStorage").Remotes.Input:FireServer(
                    unpack(args))
            end
            task.wait(1)
        end
    end)
end

function AutoChangeSpeed()
    repeat task.wait(1) until get_game_speed() ~= nil

    while Settings.auto_2x or Settings.auto_3x do
        local args = {[1] = "SpeedChange", [2] = true}

        if (Settings.auto_3x and get_game_speed() < 3) or
            (Settings.auto_2x and get_game_speed() < 2) then
            game:GetService("ReplicatedStorage").Remotes.Input:FireServer(
                unpack(args))
        elseif (Settings.auto_2x and get_game_speed() > 2) then
            args[2] = false
            game:GetService("ReplicatedStorage").Remotes.Input:FireServer(
                unpack(args))
        end

        task.wait(1)
    end
end

function OnGameEnd()
    if not is_lobby() then
        local end_gui = GUI.HUD:WaitForChild("MissionEnd")

        repeat task.wait() until end_gui.Visible

        -- DO ANY GAME ENDING ACTIONS HERE
        if Settings.webhook_end_game then
            local webhook_args = {}
            local bg = end_gui:FindFirstChild("BG")

            if bg ~= nil then
                if bg:FindFirstChild("Times") ~= nil then
                    local GameTimeElapsed = Split(
                                                Split(bg:FindFirstChild("Times").Text,
                                                      '\n')[2], "seconds")[1]
                    local time_elapsed = tostring(
                                             math.round(tonumber(GameTimeElapsed)))

                    table.insert(webhook_args, {
                        ["name"] = "Game Time Elapsed",
                        ["value"] = ":timer: " .. time_elapsed,
                        ["inline"] = true
                    })
                end
            end

            table.insert(webhook_args, {
                ["name"] = "Macro Time Elapsed",
                ["value"] = ":timer: " .. tostring(math.round(ElapsedTime())),
                ["inline"] = true
            })

            table.insert(webhook_args, {
                ["name"] = "Macro Time Elapsed (1x)",
                ["value"] = ":timer: " ..
                    tostring(math.round(ElapsedTime() - TimeOffset)),
                ["inline"] = true
            })

            local GameStatus = get_game_status()
            local GameStatusEmoji = ""

            if GameStatus == "Success!" then
                GameStatusEmoji = ":green_square: "
            elseif GameStatus == "Failed!" then
                GameStatusEmoji = ":red_square: "
            end

            table.insert(webhook_args, {
                ["name"] = "Status",
                ["value"] = GameStatusEmoji .. get_game_status(),
                ["inline"] = true
            })

            table.insert(webhook_args, {
                ["name"] = "Stage / Floor",
                ["value"] = ":stadium: " .. get_stage(),
                ["inline"] = true
            })

            table.insert(webhook_args, {
                ["name"] = "Waves",
                ["value"] = ":ocean: " .. get_wave(),
                ["inline"] = true
            })

            table.insert(webhook_args, {
                ["name"] = "Current Level",
                ["value"] = ":star2: " .. get_level(),
                ["inline"] = true
            })

            table.insert(webhook_args, {
                ["name"] = "Current Gems",
                ["value"] = ":gem: " .. get_gems(),
                ["inline"] = true
            })

            table.insert(webhook_args, {
                ["name"] = "Current Gold",
                ["value"] = ":coin: " .. get_gold(),
                ["inline"] = true
            })

            table.insert(webhook_args, {
                ["name"] = "Current Stardust",
                ["value"] = ":star: " .. get_stardust(),
                ["inline"] = true
            })

            table.insert(webhook_args, {
                ["name"] = "Battle Pass Tier",
                ["value"] = ":signal_strength: " .. get_battle_pass_tier(),
                ["inline"] = true
            })

            SendWebhook(webhook_args)
        end
    end
end

-- webhookbanner removed (external script was spamming "Banner" to logs)

function FpsBoost()
    local Lighting = game:GetService("Lighting")
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, effect in ipairs(Lighting:GetChildren()) do
        pcall(function() if effect:IsA("PostEffect") then effect.Enabled = false end end)
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic; obj.CastShadow = false end
            if obj:IsA("Texture") or obj:IsA("Decal") then obj.Transparency = 1 end
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then obj.Enabled = false end
        end)
    end
    workspace.DescendantAdded:Connect(function(obj)
        pcall(function()
            if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic; obj.CastShadow = false end
            if obj:IsA("Texture") or obj:IsA("Decal") then obj.Transparency = 1 end
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then obj.Enabled = false end
        end)
    end)
    print("[KarmaPanda] FPS Boost enabled.")
end

local linkport = ""
local linkport2 = ""

local function extractFileName(url)
    local nameWithParams = url:match("^.+/(.+)$")
    return nameWithParams:match("^[^?]+")
end

local function importMacro(url)
    local fileName = extractFileName(url)
    local savePath = folder_name .. "\\" .. fileName

    local success, response = pcall(function() return game:HttpGet(url) end)

    if success then
        writefile(savePath, response)

        local jsonData
        success, jsonData = pcall(function()
            return game:GetService("HttpService"):JSONDecode(response)
        end)

        if success and jsonData then
            -- Load the imported profiles into memory
            local imported = {}
            for k, v in pairs(jsonData) do
                if Macros[k] == nil then
                    Macros[k] = v
                    if not table.find(MacroProfileList, k) then
                        table.insert(MacroProfileList, k)
                    end
                    table.insert(imported, k)
                else
                    -- Profile name already exists, overwrite
                    Macros[k] = v
                    table.insert(imported, k .. " (overwritten)")
                end
            end
            Save()
            Rayfield:Notify({
                Title = "Macro Imported!",
                Content = "Loaded: " .. table.concat(imported, ", ") .. ". Use Refresh Profiles to see it in the dropdown.",
                Duration = 6
            })
        else
            warn("Error parsing JSON: " .. tostring(jsonData))
        end
    else
        warn("Error downloading JSON: " .. response)
    end
end

local function importSettings(url)
    local fileName = extractFileName(url)
    local tempSavePath = "KarmaPanda\\ASTD\\Settings\\" .. fileName
    local success, response = pcall(function() return game:HttpGet(url) end)

    if success then
        writefile(tempSavePath, response)

        local success, jsonData = pcall(function()
            return game:GetService("HttpService"):JSONDecode(response)
        end)

        writefile(SettingsFile, response)
        delfile(tempSavePath) -- Delete the Settings.json file after userid.json is created

        if success then
            Rayfield:Notify({
                Title = "Settings Imported!",
                Content = "Settings Imported Rejoin to See the changes!",
                Duration = 4,
                Image = 4483362458
            })
        else
            warn("Error parsing JSON: " .. jsonData)
        end
    else
        warn("Error downloading JSON: " .. response)
    end
end

function AutoReplay()
    local end_gui = GUI.HUD:WaitForChild("MissionEnd")

    repeat task.wait() until end_gui.Visible

    local replay_button = end_gui:WaitForChild("BG"):WaitForChild("Actions")
                              :WaitForChild("Replay")
    local next_button = end_gui:WaitForChild("BG"):WaitForChild("Actions")
                            :WaitForChild("Next")

    while Settings.auto_replay do
        if Settings.auto_next_story and next_button.Visible then break end

        if replay_button.Visible then firesignal(replay_button.Activated) end
        task.wait(1)
    end
end

function AutoNextStory()
    local end_gui = GUI.HUD:WaitForChild("MissionEnd")

    repeat task.wait() until end_gui.Visible

    local next_button = end_gui:WaitForChild("BG"):WaitForChild("Actions")
                            :WaitForChild("Next")

    while Settings.auto_next_story do
        if next_button.Visible then firesignal(next_button.Activated) end
        task.wait(1)
    end
end

function AutoUpgrade()
    -- Wait until the game actually starts
    repeat task.wait(1) until tonumber(get_wave()) > 0

    -- Wait for the target wave
    local startWave = tonumber(Settings.auto_upgrade_wave) or 0
    if startWave > 0 then
        repeat task.wait(1) until tonumber(get_wave()) >= startWave or not Settings.auto_upgrade
    end

    while Settings.auto_upgrade do
        local wave = tonumber(get_wave()) or 0
        local stopWave = tonumber(Settings.auto_upgrade_wave_stop) or 999
        local minMoney = tonumber(Settings.auto_upgrade_money) or 0

        if wave >= stopWave then
            warn("Auto-upgrade stopped at wave", stopWave)
            Settings.auto_upgrade = false
            break
        end

        if tonumber(get_money()) >= minMoney then
            local targets = Settings.auto_upgrade_targets
            local hasTargets = targets and #targets > 0

            for _, unit in ipairs(get_units()) do
                if not Settings.auto_upgrade then break end
                -- If targets are set, only upgrade those specific units
                if hasTargets and not table.find(targets, unit.Name) then continue end

                local upgradeTag = unit:FindFirstChild("UpgradeTag")
                local currentLevel = upgradeTag and upgradeTag.Value or 0
                if currentLevel < get_max_upgrade_level(unit.Name) then
                    game:GetService("ReplicatedStorage").Remotes.Server:InvokeServer("Upgrade", unit)
                    task.wait(0.1)
                end
            end
        end

        task.wait(1)
    end
end

function AutoSell()
    -- Wait until the game actually starts
    repeat task.wait(1) until tonumber(get_wave()) > 0

    -- Wait for the target sell wave
    local sellWave = tonumber(Settings.auto_upgrade_wave_sell) or 1
    repeat task.wait(1) until tonumber(get_wave()) >= sellWave or not Settings.auto_upgrade_sell

    if not Settings.auto_upgrade_sell then return end

    local function TrySellUnit(unit)
        task.spawn(function()
            local has_sold = false
            local attempts = 0
            local conn = workspace.Unit.ChildRemoved:Connect(function(x)
                if unit == x then has_sold = true end
            end)
            repeat
                if not has_sold then
                    game:GetService("ReplicatedStorage").Remotes.Input:FireServer("Sell", unit)
                end
                attempts = attempts + 1
                task.wait(0.6)
            until has_sold or attempts >= 3
            conn:Disconnect()
        end)
    end

    while Settings.auto_upgrade_sell do
        local units = get_units()
        if #units == 0 then break end
        for _, unit in ipairs(units) do
            if not Settings.auto_upgrade_sell then break end
            TrySellUnit(unit)
            task.wait(0.6)
        end
        task.wait(1)
    end
end

local function AutoBuffHelper(Units, unit, checks, ability_type, ability_name)
    for _, check in pairs(checks) do
        if check == "attack" then
            repeat task.wait() until not CheckAttackBuff(Units)
        elseif check == "range" then
            repeat task.wait() until not CheckRangeBuff(Units)
        end
    end

    if ability_type == "Multiple" then
        UseMultipleAbilitiesUnit(unit, "", ability_name)
    else
        UseAbilityUnit(unit, "")
    end
end

function AutoBuff()
    for k, v in pairs(Settings.auto_buff_units) do
        task.spawn(function()
            while Settings.auto_buff do
                local Units = {}

                for _, unit in pairs(get_units()) do
                    if unit.Name == k and unit:WaitForChild("SpecialMove").Value ~=
                        "" then table.insert(Units, unit) end
                end

                local checks = v["Checks"]
                local ability_type = v["Ability Type"]
                local ability_name = nil
                local time = v["Time"]

                if ability_type == "Multiple" then
                    ability_name = v["Ability Name"]
                end

                if v["Mode"] == "Box" then
                    local Units2 = {}

                    if #Units > 4 and #Units < 8 then
                        repeat
                            task.wait(1)
                            table.remove(Units, #Units)
                        until #Units == 4
                    end

                    if #Units == 8 then
                        for i = 1, 4 do
                            table.insert(Units2, Units[1])
                            table.remove(Units, 1)
                        end
                    end

                    if #Units == 4 or #Units2 == 4 then
                        for i = 1, 4 do
                            if not Settings.auto_buff or
                                Settings.auto_buff_units[k] == nil then
                                break
                            end
                            if #Units == 4 then
                                AutoBuffHelper(Units, Units[i], checks,
                                               ability_type, ability_name)
                            end
                            if #Units2 == 4 then
                                AutoBuffHelper(Units2, Units2[i], checks,
                                               ability_type, ability_name)
                            end
                            Delay(time, Settings.auto_buff and
                                      Settings.auto_buff_units[k] ~= nil)
                        end
                    end
                elseif v["Mode"] == "Pair" then
                    if #Units >= 2 then
                        for i, v in pairs(Units) do
                            if i % 2 ~= 0 then
                                AutoBuffHelper(Units, Units[i], checks,
                                               ability_type, ability_name)
                            end
                        end

                        Delay(time, Settings.auto_buff and
                                  Settings.auto_buff_units[k] ~= nil)

                        for i, v in pairs(Units) do
                            if i % 2 == 0 then
                                AutoBuffHelper(Units, Units[i], checks,
                                               ability_type, ability_name)
                            end
                        end

                        Delay(time, Settings.auto_buff and
                                  Settings.auto_buff_units[k] ~= nil)
                    end
                elseif v["Mode"] == "Spam" then
                    for i, unit in pairs(Units) do
                        AutoBuffHelper(Units, Units[i], checks, ability_type,
                                       ability_name)
                    end
                    Delay(time, Settings.auto_buff and
                              Settings.auto_buff_units[k] ~= nil)

                elseif v["Mode"] == "Cycle" then
                    local cycle_units = 8

                    if v["Cycle Units"] ~= nil then
                        cycle_units = v["Cycle Units"]
                    end

                    if #Units >= cycle_units then
                        for i, v in pairs(Units) do
                            if Settings.auto_buff and
                                Settings.auto_buff_units[k] ~= nil and #Units >=
                                cycle_units then
                                AutoBuffHelper(Units, Units[i], checks,
                                               ability_type, ability_name)
                            else
                                break
                            end
                            Delay(time,
                                  Settings.auto_buff and
                                      Settings.auto_buff_units[k] ~= nil and
                                      #Units >= cycle_units)
                        end
                    end
                end

                if v["Delay"] ~= nil then
                    Delay(v["Delay"], Settings.auto_buff)
                end

                task.wait()
            end
        end)
    end
end

local isEvolvingEXP = false

function AutoEvolveEXP()
    local function GetInventory()
        local units = game.ReplicatedStorage.Remotes.Server:InvokeServer("Data",
                                                                         "Units")
        return units
    end

    local function CountEXP()
        local inventory = GetInventory()
        local exp1 = 0
        local exp2 = 0
        local exp3 = 0
        local exp4 = 0

        for _, v in pairs(inventory) do
            if v.Name == "EXP IV" then exp4 = exp4 + 1 end

            if v.Name == "EXP III" then exp3 = exp3 + 1 end

            if v.Name == "EXP II" then exp2 = exp2 + 1 end

            if v.Name == "EXP I" then exp1 = exp1 + 1 end
        end

        return exp1, exp2, exp3, exp4
    end

    local function GetEXPUnitID(name)
        local inventory = GetInventory()

        for _, v in pairs(inventory) do
            if v.Name == name then return v.ID end
        end

        return nil
    end

    local function EvolveHelper(unit_name)
        local unit_id = GetEXPUnitID(unit_name)

        if unit_id ~= nil then
            local args = {[1] = "UpgradeUnit", [2] = unit_name, [3] = unit_id}
            game:GetService("ReplicatedStorage").Remotes.Input:FireServer(
                unpack(args))
            task.wait(0.25)
        end

        return CountEXP()
    end

    local exp1, exp2, exp3, exp4 = CountEXP()

    if exp3 >= 3 or exp2 >= 3 or exp1 >= 2 then
        isEvolvingEXP = true
        while exp3 >= 3 or exp2 >= 3 or exp1 >= 2 do
            if exp3 >= 3 then
                exp1, exp2, exp3, exp4 = EvolveHelper("EXP III")
            end

            if exp2 >= 3 then
                exp1, exp2, exp3, exp4 = EvolveHelper("EXP II")
            end

            if exp3 >= 3 or exp2 >= 3 then
                isEvolvingEXP = true
            elseif exp1 >= 2 then
                exp1, exp2, exp3, exp4 = EvolveHelper("EXP I")
            else
                break
            end
        end
        if Settings.webhook_exp_evolve then
            SendWebhook({
                {["name"] = "EXP IV", ["value"] = exp4, ["inline"] = true},
                {["name"] = "EXP III", ["value"] = exp3, ["inline"] = true},
                {["name"] = "EXP II", ["value"] = exp2, ["inline"] = true},
                {["name"] = "EXP I", ["value"] = exp1, ["inline"] = true}
            })
        end
    end

    HideSummonGUI()
    isEvolvingEXP = false
end

function AutoTower()
    local player = game:GetService("Players").LocalPlayer
    local towerteleporter = workspace.Queue.InteractionsV2:FindFirstChild(
                                "Script633")

    local function UseTeleporter(teleporter)
        if teleporter ~= nil then
            firetouchinterest(player.Character.HumanoidRootPart, teleporter, 0)
            task.wait()
            firetouchinterest(player.Character.HumanoidRootPart, teleporter, 1)
            task.wait(1)
        end
    end

    local function pressKey(keyCode)
        game:GetService("VirtualInputManager"):SendKeyEvent(true, keyCode,
                                                            false, game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, keyCode,
                                                            false, game)
    end

    UseTeleporter(towerteleporter)

    if player.PlayerGui.HUD.TowerLevelSelector.StoryModeChooser.StoryModeChooser
        .Visible then
        pressKey(Enum.KeyCode.BackSlash)
        task.wait(0.5)
        pressKey(Enum.KeyCode.Right)
        task.wait(0.5)
        pressKey(Enum.KeyCode.Return)
        task.wait(0.5)
        pressKey(Enum.KeyCode.BackSlash)

        game:GetService("ReplicatedStorage").Remotes.Input:FireServer(unpack({
            [1] = towerteleporter.Name .. "Start"
        }))
    end
end

function AutoJoinGame()
    local function UseTeleporter(teleporter)
        if teleporter ~= nil then
            firetouchinterest(Player.Character.HumanoidRootPart, teleporter, 0)
            task.wait()
            firetouchinterest(Player.Character.HumanoidRootPart, teleporter, 1)
            task.wait(1)
        end
    end

    local function QuickStartTeleporter(teleporter)
        task.wait(1)
        Player.Character.HumanoidRootPart.CFrame =
            game:GetService("Workspace").SpawnLocation.CFrame
        task.wait(1)
        if teleporter ~= nil then
            game:GetService("ReplicatedStorage").Remotes.Input:FireServer(
                unpack({[1] = teleporter.Name .. "Start"}))
        end
    end

    if Settings.auto_evolve_exp then
        repeat task.wait() until not isEvolvingEXP or
            not Settings.auto_evolve_exp
    end

    if not Settings.auto_join_game then return end

    task.wait(Settings.auto_join_delay)

    local args = {}
    local teleporter = nil

    -- TODO: Add server hopper on teleport failed.
    if get_world() == 1 then
        -- TODO: Teleport to teleporter location if no teleporters loaded.
        local function FindTeleporter(Teleporters)
            local Found = false

            while not Found do
                for _, v in pairs(Teleporters) do
                    if v.ClassName == "Part" and
                        v.SurfaceGui.Frame.TextLabel.Text == "Empty" then
                        Found = true
                        return v
                    end
                end

                task.wait()
            end

            return nil
        end
        local function GetStoryTeleporters()
            local Teleporters = {}
            local TeleporterNames = {
                "Script170", "Script158", "Script395", "Script408", "Script523",
                "Script539", "Script573", "Script600", "Script624", "Script958"
            }

            for _, v in pairs(
                            game:GetService("Workspace").Queue.InteractionsV2:GetChildren()) do
                if table.find(TeleporterNames, v.Name) ~= nil then
                    table.insert(Teleporters, v)
                end
            end

            return Teleporters
        end
        local function GetInfiniteTeleporters()
            local Teleporters = {}
            local TeleporterNames = {
                "Script209", "Script222", "Script381", "Script405", "Script448",
                "Script58", "Script647", "Script716"
            }

            for _, v in pairs(
                            game:GetService("Workspace").Queue.InteractionsV2:GetChildren()) do
                if table.find(TeleporterNames, v.Name) ~= nil then
                    table.insert(Teleporters, v)
                end
            end

            return Teleporters
        end
        local function SetStoryMap(teleporter)
            if teleporter ~= nil then
                game:GetService("ReplicatedStorage").Remotes.Input:FireServer(
                    unpack({
                        [1] = teleporter.Name .. "Level",
                        [2] = tostring(Settings.auto_join_story_level),
                        [3] = false
                    }))
            end
        end
        local function SetInfiniteMap(teleporter)
            if teleporter ~= nil then
                game:GetService("ReplicatedStorage").Remotes.Input:FireServer(
                    unpack({
                        [1] = teleporter.Name .. "Level",
                        [2] = Settings.auto_join_infinite_level,
                        [3] = false
                    }))
            end
        end
        local function TeleportToWorld2()
            UseTeleporter(get_world_teleporter())
        end
        if Settings.auto_join_mode == "Story" then
            if Settings.auto_join_story_level > 120 then
                TeleportToWorld2()
                return
            end
            teleporter = FindTeleporter(GetStoryTeleporters())
            UseTeleporter(teleporter)
            SetStoryMap(teleporter)
        elseif Settings.auto_join_mode == "Infinite" then
            if InfiniteMapTable[Settings.auto_join_infinite_level] == "Gauntlet" or
                InfiniteMapTable[Settings.auto_join_infinite_level] ==
                "Training" then
                TeleportToWorld2()
                return
            end
            teleporter = FindTeleporter(GetInfiniteTeleporters())
            UseTeleporter(teleporter)
            SetInfiniteMap(teleporter)
        elseif Settings.auto_join_mode == "Adventure" then
            TeleportToWorld2()
            return
        elseif Settings.auto_join_mode == "Time Chamber" then
            UseTeleporter(game:GetService("Workspace").Queue.Interactions
                              .Script548)
        elseif Settings.auto_join_mode == "Team Event" then
            for _, v in pairs(game:GetService("Workspace").Queue:GetChildren()) do
                if v.Name == "Model" and v:FindFirstChild("PortalPart") ~= nil then
                    UseTeleporter(v:FindFirstChild("PortalPart"))
                    break
                end
            end
        elseif Settings.auto_join_mode == "Bakugan Event" then
            UseTeleporter(game:GetService("Workspace").Queue.BakuganEventArea
                              .Script412)
        end
        QuickStartTeleporter(teleporter)
    elseif get_world() == 2 then
        local function FindTeleporter(Teleporters, Mode)
            local Found = false

            while not Found do
                for _, v in pairs(Teleporters) do
                    if (Mode == nil or v.Name == Mode) and v.ClassName == "Part" and
                        v.SurfaceGui.Frame.TextLabel.Text == "Empty" then
                        Found = true
                        return v
                    end
                end

                task.wait()
            end

            return nil
        end
        local function SetStoryMap(teleporter)
            if teleporter ~= nil then
                game:GetService("ReplicatedStorage").Remotes.Input:FireServer(
                    unpack({
                        [1] = "StoryModeLevel",
                        [2] = tostring(Settings.auto_join_story_level),
                        [3] = true
                    }))
            end
        end
        local function SetInfiniteMap(teleporter)
            if teleporter ~= nil then
                game:GetService("ReplicatedStorage").Remotes.Input:FireServer(
                    unpack({
                        [1] = "InfiniteModeLevel",
                        [2] = Settings.auto_join_infinite_level,
                        [3] = false
                    }))
            end
        end
        local function SetAdventureMap(teleporter)
            if teleporter ~= nil then
                game:GetService("ReplicatedStorage").Remotes.Input:FireServer(
                    unpack({
                        [1] = "AdventureModeLevel",
                        [2] = Settings.auto_join_adventure_level,
                        [3] = false
                    }))
            end
        end
        local function TeleportToWorld1()
            UseTeleporter(get_world_teleporter())
        end
        local teleporter = nil
        if Settings.auto_join_mode == "Story" then
            if Settings.auto_join_story_level < 121 then
                TeleportToWorld1()
                return
            end
            repeat task.wait() until #game:GetService("Workspace").Joinables:GetChildren() >
                0
            teleporter = FindTeleporter(
                             game:GetService("Workspace").Joinables:GetChildren(),
                             "StoryMode")
            UseTeleporter(teleporter)
            SetStoryMap(teleporter)
        elseif Settings.auto_join_mode == "Infinite" then
            if InfiniteMapTable[Settings.auto_join_infinite_level] == "Farm" then
                TeleportToWorld1()
                return
            end
            repeat task.wait() until #game:GetService("Workspace").Joinables:GetChildren() >
                0
            teleporter = FindTeleporter(
                             game:GetService("Workspace").Joinables:GetChildren(),
                             "InfiniteMode")
            UseTeleporter(teleporter)
            SetInfiniteMap(teleporter)
        elseif Settings.auto_join_mode == "Adventure" then
            repeat task.wait() until #game:GetService("Workspace").Joinables:GetChildren() >
                0
            teleporter = FindTeleporter(
                             game:GetService("Workspace").Joinables:GetChildren(),
                             "AdventureMode")
            UseTeleporter(teleporter)
            SetAdventureMap(teleporter)
        elseif Settings.auto_join_mode == "Time Chamber" then
            TeleportToWorld1()
            return
        elseif Settings.auto_join_mode == "Team Event" then
            TeleportToWorld1()
            return
        elseif Settings.auto_join_mode == "Bakugan Event" then
            TeleportToWorld1()
            return
        end
        QuickStartTeleporter(teleporter)
        --[[elseif get_world() == -2 then -- team event map (reaper's base)
        for _, v in pairs(game:GetService("Workspace"):GetChildren()) do
            if v.Name == "Model" and v:FindFirstChild("Meshes/senkaimon2 (1)") ~=
                nil then
                Player.Character.HumanoidRootPart.CFrame = v:FindFirstChild(
                                                               "Meshes/senkaimon2 (1)").CFrame
                break
            end
        end]] --
    end
end

function AutoSkipGUI()
    local SummonGUI = GUI:WaitForChild("Summon")

    while Settings.auto_skip_gui do
        local status, err = pcall(function()
            -- TODO: Stop when other things are opened.
            if SummonGUI:FindFirstChild('Skip').Visible then
                game:GetService('VirtualUser'):ClickButton1(Vector2.new(
                                                                workspace.CurrentCamera
                                                                    .ViewportSize
                                                                    .X / 2,
                                                                workspace.CurrentCamera
                                                                    .ViewportSize
                                                                    .Y / 2))
            end
        end)

        if not status then print("Error on Auto Skip GUI: " .. err) end

        task.wait()
    end
end

local function AnonMode()
    local player = game.Players.LocalPlayer
    local userId = "p_" .. tostring(player.UserId)

    local success, err = pcall(function()
        local playerName = game:GetService("CoreGui").PlayerList
                               .PlayerListMaster.OffsetFrame.PlayerScrollList
                               .SizeOffsetFrame.ScrollingFrameContainer
                               .ScrollingFrameClippingFrame.ScollingFrame
                               .OffsetUndoFrame[userId].ChildrenFrame.NameFrame
                               .BGFrame.OverlayFrame.PlayerName.PlayerName

        playerName.Text = Settings.anonymous_mode_name
    end)
    
    if not success then
        warn("Failed to change name in leaderboard: " .. err)
    end

    if not success then warn("Failed to change name in leaderboard: " .. err) end

    local nameLabel = game:GetService("Workspace").Camera:WaitForChild(
                          Player.Name).Head:WaitForChild("NameLevelBBGUI")
                          :WaitForChild("NameFrame"):WaitForChild("TextLabel")
    nameLabel.Text = Settings.anonymous_mode_name
end

-- TODO: Change all task.spawns to coroutines for easier management on re-executes and prevent double execution of the same function.
if get_world() ~= -1 and get_world() ~= -2 then
    repeat task.wait() until not GUI:WaitForChild("LoadingScreen").Frame.Visible

    if not is_lobby() then
        CalculateTimeOffset()
        task.spawn(StartActionQueue)
        if Settings.auto_buff then task.spawn(AutoBuff) end
        if Settings.auto_vote_extreme then task.spawn(AutoVoteExtreme) end
        if Settings.auto_2x or Settings.auto_3x then
            task.spawn(AutoChangeSpeed)
        end
        if Settings.auto_battle then task.spawn(AutoBattle) end
        if Settings.auto_replay then task.spawn(AutoReplay) end
        if Settings.auto_next_story then task.spawn(AutoNextStory) end
        if Settings.macro_record then task.spawn(StartMacroRecord) end
        if Settings.macro_playback then task.spawn(StartMacroPlayback) end
        if Settings.auto_upgrade then task.spawn(AutoUpgrade) end
        if Settings.auto_upgrade_sell then task.spawn(AutoSell) end
        task.spawn(OnGameEnd)
    else
        if Settings.auto_evolve_exp then task.spawn(AutoEvolveEXP) end
        task.wait(1)
        if Settings.auto_join_game then task.spawn(AutoJoinGame) end
        if Settings.auto_join_tower then task.spawn(AutoTower) end
        -- webhookbanner removed
    end

    if Settings.auto_skip_gui then task.spawn(AutoSkipGUI) end
    if Settings.FPSBoost then task.spawn(FpsBoost) end
    if Settings.anonymous_mode then task.spawn(AnonMode) end
end

if get_world() == -2 and Settings.auto_join_game then task.spawn(AutoJoinGame) end

-- Tasks that run regardless if its in lobby or in game.
task.spawn(function()
    if Settings.disable_3d_rendering then
        game:GetService("RunService"):Set3dRenderingEnabled(
            not Settings.disable_3d_rendering)
    end
    if Settings.anti_afk then
        for _, v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
            v:Disable()
        end
    end
end)

print("[KarmaPanda] Functions Loaded: " .. os.clock() - benchmark_time)
benchmark_time = os.clock()



function InitializeUI()
    local UnitList = get_all_units()

    local function MainSettings()
        local Main = Window:CreateTab("Main", 4483362458)

        local GameplayScriptsSection = Main:CreateSection("Gameplay Scripts")
        Main:CreateParagraph({
            Title = "Advanced Options",
            Content = "Additional configuration for Auto Battle, Auto Upgrade, Auto Sell, and Auto Unit Buffing is available in the Advanced Settings tab.",
            SectionParent = GameplayScriptsSection
        })
        Main:CreateToggle({
            Name = "Auto Unit Buffing",
            Info = "Automatically activates unit buff abilities during gameplay. Configure units in the Advanced Settings tab.",
            CurrentValue = Settings.auto_buff,
            Callback = function(value)
                Settings.auto_buff = value
                Save()
                if not is_lobby() and value then AutoBuff() end
            end,
            SectionParent = GameplayScriptsSection
        })
        Main:CreateToggle({
            Name = "Auto Battle",
            Info = "Automatically starts battle when your gem count meets the threshold set in Advanced Settings.",
            CurrentValue = Settings.auto_battle,
            SectionParent = GameplayScriptsSection,
            Callback = function(value)
                Settings.auto_battle = value
                Save()
                if not is_lobby() and value then AutoBattle() end
            end
        })
        Main:CreateToggle({
            Name = "Auto Sell",
            Info = "Automatically sells units at the wave configured in Advanced Settings.",
            CurrentValue = Settings.auto_upgrade_sell,
            Callback = function(value)
                Settings.auto_upgrade_sell = value
                Save()
                if not is_lobby() and value then AutoSell() end
            end,
            SectionParent = GameplayScriptsSection
        })
        Main:CreateToggle({
            Name = "Auto Upgrade",
            Info = "Automatically upgrades units when your money meets the threshold set in Advanced Settings. If targets are selected below, only those units will be upgraded.",
            CurrentValue = Settings.auto_upgrade,
            Callback = function(value)
                Settings.auto_upgrade = value
                Save()
                if not is_lobby() and value then AutoUpgrade() end
            end,
            SectionParent = GameplayScriptsSection
        })

        -- Unit target dropdown for Auto Upgrade (reads from loadout slots)
        local loadoutUnits = get_loadout_units()
        if #loadoutUnits > 0 then
            local currentTargets = Settings.auto_upgrade_targets or {}
            -- If saved targets are empty, default display to all
            local displayCurrent = #currentTargets > 0 and currentTargets or loadoutUnits

            Main:CreateDropdown({
                Name = "Upgrade Targets",
                Info = "Select which units to auto upgrade. If none selected, all units will be upgraded.",
                Options = loadoutUnits,
                CurrentOption = displayCurrent,
                MultipleOptions = true,
                Flag = "AutoUpgradeTargets",
                Callback = function(opts)
                    -- If all are selected, treat as "upgrade all" (empty list)
                    if #opts >= #loadoutUnits then
                        Settings.auto_upgrade_targets = {}
                    else
                        Settings.auto_upgrade_targets = opts
                    end
                    Save()
                end,
                SectionParent = GameplayScriptsSection
            })
        end

        local GUIScriptsSection = Main:CreateSection("GUI Scripts")
        Main:CreateToggle({
            Name = "Auto Vote Extreme",
            Info = "Automatically votes for Extreme difficulty when the vote screen appears.",
            CurrentValue = Settings.auto_vote_extreme,
            Callback = function(value)
                Settings.auto_vote_extreme = value
                Save()
                if not is_lobby() and value then AutoVoteExtreme() end
            end,
            SectionParent = GUIScriptsSection
        })
        local speedOptions = {"Off", "2x", "3x"}
        local currentSpeed = "Off"
        if Settings.auto_3x then currentSpeed = "3x"
        elseif Settings.auto_2x then currentSpeed = "2x" end
        Main:CreateDropdown({
            Name = "Auto Speed",
            Info = "Sets the game speed multiplier automatically. Tap outside to close.",
            Options = speedOptions,
            CurrentOption = {currentSpeed},
            MultipleOptions = false,
            Flag = "AutoSpeedDropdown",
            Callback = function(opts)
                local v = opts[1]
                Settings.auto_2x = (v == "2x")
                Settings.auto_3x = (v == "3x")
                Save()
                if not is_lobby() then AutoChangeSpeed() end
            end,
            SectionParent = GUIScriptsSection
        })

        local GameEndScriptsSection = Main:CreateSection("Game End Scripts")
        Main:CreateToggle({
            Name = "Auto Replay",
            Info = "Automatically replays the current game mode when it ends.",
            CurrentValue = Settings.auto_replay,
            SectionParent = GameEndScriptsSection,
            Callback = function(value)
                Settings.auto_replay = value
                Save()
                if not is_lobby() and value then AutoReplay() end
            end
        })
        Main:CreateToggle({
            Name = "Auto Next Story",
            Info = "Automatically moves to the next story level upon completion.",
            CurrentValue = Settings.auto_next_story,
            SectionParent = GameEndScriptsSection,
            Callback = function(value)
                Settings.auto_next_story = value
                Save()
                if not is_lobby() and value then AutoNextStory() end
            end
        })
    end

    local function MacroSettings()
        local Macro = Window:CreateTab("Macro", 4483362458)
        local MacrosSection = Macro:CreateSection("Macros")
        local MacroProfileDropdown = Macro:CreateDropdown({
            Name = "Selected Profile",
            Options = MacroProfileList,
            CurrentOption = {Settings.macro_profile},
            MultipleOptions = false,
            Callback = function(opts)
                Settings.macro_profile = opts[1]
                if Macros[Settings.macro_profile] == nil then
                    Macros[Settings.macro_profile] = {}
                end
                Save()
            end,
            SectionParent = MacrosSection
        })
        Macro:CreateButton({
            Name = "Refresh Profiles",
            Info = "Reloads all macro profiles from disk and updates the dropdown.",
            Callback = function()
                -- Reload from files
                for _, file in pairs(listfiles(folder_name)) do
                    pcall(function()
                        local json_content = game:GetService("HttpService"):JSONDecode(readfile(file))
                        for k, v in pairs(json_content) do
                            if Macros[k] == nil then
                                Macros[k] = v
                                if not table.find(MacroProfileList, k) then
                                    table.insert(MacroProfileList, k)
                                end
                            end
                        end
                    end)
                end
                MacroProfileDropdown:Refresh(MacroProfileList)
                MacroProfileDropdown:Set({Settings.macro_profile})
                Rayfield:Notify({
                    Title = "Profiles Refreshed",
                    Content = "Found " .. #MacroProfileList .. " profile(s): " .. table.concat(MacroProfileList, ", "),
                    Duration = 5
                })
            end,
            SectionParent = MacrosSection
        })
        local MacroProfileInfo = Macro:CreateParagraph({
            Title = "Current Profile Info",
            Content = string.format("Waiting for information...\n"),
            SectionParent = MacrosSection
        })
        task.spawn(function()
            while MacroProfileInfo ~= nil do
                if Macros[Settings.macro_profile]["Macro"] ~= nil and
                    Macros[Settings.macro_profile]["Units"] ~= nil then
                    MacroProfileInfo:Set({
                        Title = "Current Profile Info",
                        Content = string.format("Total Steps: %s\nUnits: %s",
                                                tostring(
                                                    #Macros[Settings.macro_profile]["Macro"]),
                                                table.concat(
                                                    get_keys(
                                                        Macros[Settings.macro_profile]["Units"]),
                                                    ", "))
                    })
                end
                task.wait()
            end
        end)
        local ControlsSection = Macro:CreateSection("Controls")
        local RecordMacroToggle = Macro:CreateToggle({
            Name = "Record Macro",
            CurrentValue = Settings.macro_record,
            Callback = function(value)
                Settings.macro_record = value
                Save()

                if not is_lobby() then
                    if value then
                        StartMacroRecord()
                    else
                        StopMacroRecord()
                    end
                end
            end,
            SectionParent = ControlsSection
        })
        local PlaybackMacroToggle = Macro:CreateToggle({
            Name = "Playback Macro",
            CurrentValue = Settings.macro_playback,
            Callback = function(value)
                Settings.macro_playback = value
                Save()

                if not is_lobby() then
                    if value then
                        Rayfield:Notify({
                            Title = "Macro Playback",
                            Content = "Starting Macro Playback...",
                            Duration = 6.5,
                            Image = 4483362458
                        })
                        StartMacroPlayback()
                    else
                        Rayfield:Notify({
                            Title = "Macro Playback",
                            Content = "Stopping Macro Playback...",
                            Duration = 6.5,
                            Image = 4483362458
                        })
                        StopMacroPlayback()
                    end
                end
            end,
            SectionParent = ControlsSection
        })
        local MacroStatus = Macro:CreateParagraph({
            Title = "Status",
            Content = "Waiting for status...\n\n\n\n\n\n",
            SectionParent = ControlsSection
        })
        task.spawn(function()
            while MacroStatus ~= nil do
                if CurrentStep ~= nil then
                    local MacroCurrentStep =
                        Macros[Settings.macro_profile]["Macro"][CurrentStep]

                    if MacroCurrentStep ~= nil then
                        local Target = nil
                        local TargetName = nil
                        local TargetIndex = nil
                        local Time = MacroCurrentStep["Time"]
                        local Remote = nil
                        local Parameters = nil

                        if MacroCurrentStep["Target"] ~= nil then
                            Target = MacroCurrentStep["Target"]

                            if Target ~= nil then
                                TargetName = Target["Name"]
                                TargetIndex = Target["Index"]
                            end
                        end

                        if MacroCurrentStep["Remote"] ~= nil then
                            Remote = MacroCurrentStep["Remote"][1]
                        end

                        if MacroCurrentStep["Parameter"] ~= nil then
                            Parameters = ""
                            for k, v in pairs(MacroCurrentStep["Parameter"]) do
                                Parameters =
                                    Parameters .. tostring(k) .. ": " ..
                                        tostring(v) .. "; "
                            end
                        end

                        MacroStatus:Set({
                            Title = "Status",
                            Content = string.format(
                                "Current Step: %s\nTarget: %s[%s]\nTime: %s\nGame Elapsed Time: %s\nAction: %s\nParameters: %s",
                                tostring(CurrentStep), tostring(TargetName),
                                tostring(TargetIndex), tostring(Time),
                                tostring(ElapsedTime()), tostring(Remote),
                                tostring(Parameters))
                        })
                    else
                        MacroStatus:Set({
                            Title = "Status",
                            Content = string.format(
                                "Error at step %s!\nGame Elapsed Time: %s",
                                tostring(CurrentStep), tostring(ElapsedTime()))
                        })
                    end
                else
                    MacroStatus:Set({
                        Title = "Status",
                        Content = string.format(
                            "Idle...\nGame Elapsed Time: %s",
                            tostring(ElapsedTime()))
                    })
                end

                task.wait()
            end
        end)
        local PreviousStepButton = Macro:CreateButton({
            Name = "Previous Macro Step",
            Callback = function()
                if CurrentStep ~= nil and CurrentStep > 0 then
                    CurrentStep = CurrentStep - 1
                else
                    CurrentStep = 1
                end
            end,
            SectionParent = ControlsSection
        })
        local NextStepButton = Macro:CreateButton({
            Name = "Next Macro Step",
            Callback = function()
                if (CurrentStep == nil or CurrentStep < 0) and
                    #Macros[Settings.macro_profile]["Macro"] > 0 then
                    CurrentStep = 1
                elseif CurrentStep ~= nil and CurrentStep > 0 and CurrentStep <
                    #Macros[Settings.macro_profile]["Macro"] then
                    CurrentStep = CurrentStep + 1
                end
            end,
            SectionParent = ControlsSection
        })
        local ResetStepButton = Macro:CreateButton({
            Name = "Reset Macro Step",
            Callback = function()
                if CurrentStep ~= nil then CurrentStep = nil end
            end,
            SectionParent = ControlsSection
        })
        local ProfileManagementSection =
            Macro:CreateSection("Profile Management")
        local ProfileNameInput = ""
        Macro:CreateInput({
            Name = "New Macro Profile Name",
            Info = "Type a name for the new profile, then press Create New Macro Profile.",
            PlaceholderText = "Default Profile",
            RemoveTextAfterFocusLost = false,
            Callback = function(text) ProfileNameInput = text end,
            SectionParent = ProfileManagementSection
        })
        local CreateNewMacroProfileButton =
            Macro:CreateButton({
                Name = "Create New Macro Profile",
                Info = "Creates a new macro profile using the name entered above.",
                Callback = function()
                    local profile_name = ProfileNameInput
                    if string.match(profile_name, '[^%w%s]') ~= nil then
                        Rayfield:Notify({
                            Title = "Macro",
                            Content = string.format(
                                "%s contains illegal characters.", profile_name),
                            Duration = 6.5,
                            Image = 4483362458
                        })
                    elseif Macros[profile_name] ~= nil then
                        Rayfield:Notify({
                            Title = "Macro",
                            Content = string.format("Profile \"%s\" already exists.",
                                                    profile_name),
                            Duration = 6.5,
                            Image = 4483362458
                        })
                    else
                        Macros[profile_name] = DeepCopy(
                                                   IndividualMacroDefaultSettings)
                        Settings.macro_profile = profile_name
                        Save()
                        table.insert(MacroProfileList, profile_name)
                        MacroProfileDropdown:Refresh(MacroProfileList)
                        MacroProfileDropdown:Set({Settings.macro_profile})
                        Rayfield:Notify({
                            Title = "Macro",
                            Content = string.format("Profile \"%s\" created.",
                                                    profile_name),
                            Duration = 6.5,
                            Image = 4483362458
                        })
                    end
                end,
                SectionParent = ProfileManagementSection
            })
        local _profileConfirmAction = nil
        local DeleteMacroProfileButton =
            Macro:CreateButton({
                Name = "Delete Selected Profile",
                Info = "Marks this profile for deletion. Press Confirm Action below to confirm.",
                Callback = function()
                    if #MacroProfileList == 1 then
                        Rayfield:Notify({
                            Title = "Macro",
                            Content = "Cannot delete the last remaining profile.",
                            Duration = 6.5,
                            Image = 4483362458
                        })
                        return
                    end
                    _profileConfirmAction = "delete"
                    Rayfield:Notify({
                        Title = "Macro",
                        Content = string.format("Press Confirm Action to delete profile \"%s\".", Settings.macro_profile),
                        Duration = 6.5,
                        Image = 4483362458
                    })
                end,
                SectionParent = ProfileManagementSection
            })
        local ClearMacroProfileButton = Macro:CreateButton({
            Name = "Clear All Macro Data On Selected Profile",
            Info = "Marks this profile for a full data wipe. Press Confirm Action below to confirm.",
            Callback = function()
                _profileConfirmAction = "clear"
                Rayfield:Notify({
                    Title = "Macro",
                    Content = string.format("Press Confirm Action to clear all data on profile \"%s\".", Settings.macro_profile),
                    Duration = 6.5,
                    Image = 4483362458
                })
            end,
            SectionParent = ProfileManagementSection
        })
        Macro:CreateButton({
            Name = "Confirm Action",
            Info = "Confirms the pending Delete or Clear action. No effect if neither is pending.",
            Callback = function()
                if _profileConfirmAction == "delete" then
                    local removed_profile_name = Settings.macro_profile
                    delfile(folder_name .. "\\" .. Settings.macro_profile .. ".json")
                    Macros[Settings.macro_profile] = nil
                    table.remove(MacroProfileList, table.find(MacroProfileList, removed_profile_name))
                    for _, v in pairs(MacroProfileList) do
                        if v ~= nil then Settings.macro_profile = v; break end
                    end
                    Save()
                    MacroProfileDropdown:Refresh(MacroProfileList)
                    MacroProfileDropdown:Set({Settings.macro_profile})
                    Rayfield:Notify({
                        Title = "Macro",
                        Content = string.format("Profile \"%s\" deleted.", removed_profile_name),
                        Duration = 6.5,
                        Image = 4483362458
                    })
                elseif _profileConfirmAction == "clear" then
                    Macros[Settings.macro_profile] = DeepCopy(IndividualMacroDefaultSettings)
                    CurrentStep = nil
                    Save()
                    Rayfield:Notify({
                        Title = "Macro",
                        Content = string.format("All macro data on profile \"%s\" cleared.", Settings.macro_profile),
                        Duration = 6.5,
                        Image = 4483362458
                    })
                else
                    Rayfield:Notify({
                        Title = "Macro",
                        Content = "No pending action to confirm.",
                        Duration = 4,
                        Image = 4483362458
                    })
                end
                _profileConfirmAction = nil
            end,
            SectionParent = ProfileManagementSection
        })
        local ImportSection = Macro:CreateSection("Importing")
        Macro:CreateInput({
            Name = "Import Macro",
            Info = "Paste a macro URL here, then press Import Start.",
            PlaceholderText = "Place Link Here",
            RemoveTextAfterFocusLost = false,
            Callback = function(text) linkport = text end,
            SectionParent = ImportSection
        })
        Macro:CreateInput({
            Name = "Import Settings",
            Info = "Paste a settings URL here, then press Import Start.",
            PlaceholderText = "Place Link Here",
            RemoveTextAfterFocusLost = false,
            Callback = function(text) linkport2 = text end,
            SectionParent = ImportSection
        })
        Macro:CreateButton({
            Name = "Import Start",
            Info = "Imports the macro or settings from the URL entered above.",
            Callback = function()
                if linkport ~= nil and linkport ~= "" then
                    importMacro(linkport)
                end
                if linkport2 ~= nil and linkport2 ~= "" then
                    importSettings(linkport2)
                end
            end,
            SectionParent = ImportSection
        })
        Macro:CreateButton({
            Name = "Equip Macro Units",
            Info = "Reads the selected macro profile, finds the units it uses, and equips them to your team. Notifies you if any units are missing from your inventory.",
            Callback = function()
                task.spawn(EquipMacroUnits)
            end,
            SectionParent = ImportSection
        })
        Macro:CreateButton({
            Name = "Export Macro to Link",
            Info = "Uploads the selected macro profile and copies a shareable import link to your clipboard.",
            Callback = function()
                task.spawn(function()
                    local profile = Macros[Settings.macro_profile]
                    if not profile then
                        Rayfield:Notify({Title = "Export", Content = "No profile selected.", Duration = 4})
                        return
                    end

                    Rayfield:Notify({Title = "Export", Content = "Uploading macro...", Duration = 3})

                    local exportData = {}
                    exportData[Settings.macro_profile] = profile
                    local json = game:GetService("HttpService"):JSONEncode(exportData)

                    local request = request or http_request or (http and http.request) or syn.request

                    -- Try paste.ee (no API key needed for basic usage)
                    local success, result = pcall(function()
                        local response = request({
                            Url = "https://paste.ee/api",
                            Method = "POST",
                            Headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
                            Body = "key=public&paste=" .. game:GetService("HttpService"):UrlEncode(json) .. "&description=" .. game:GetService("HttpService"):UrlEncode(Settings.macro_profile)
                        })
                        if response and response.Body then
                            local data = game:GetService("HttpService"):JSONDecode(response.Body)
                            if data and data.paste and data.paste.raw then
                                return data.paste.raw
                            end
                        end
                        return nil
                    end)

                    -- Fallback: try hastebin-style
                    if not success or not result then
                        success, result = pcall(function()
                            local response = request({
                                Url = "https://hst.sh/documents",
                                Method = "POST",
                                Headers = {["Content-Type"] = "text/plain"},
                                Body = json
                            })
                            if response and response.Body then
                                local data = game:GetService("HttpService"):JSONDecode(response.Body)
                                if data and data.key then
                                    return "https://hst.sh/raw/" .. data.key
                                end
                            end
                            return nil
                        end)
                    end

                    -- Fallback: try dpaste
                    if not success or not result then
                        success, result = pcall(function()
                            local response = request({
                                Url = "https://dpaste.com/api/",
                                Method = "POST",
                                Headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
                                Body = "content=" .. game:GetService("HttpService"):UrlEncode(json) .. "&expiry_days=30"
                            })
                            if response and response.Body then
                                local url = response.Body:gsub("%s+", "")
                                if url:find("dpaste.com") then
                                    return url .. ".txt"
                                end
                            end
                            return nil
                        end)
                    end

                    if success and result then
                        setclipboard(result)
                        Rayfield:Notify({
                            Title = "Export Complete",
                            Content = "Link copied to clipboard! Share it with anyone to import.",
                            Duration = 8
                        })
                    else
                        -- Last resort: just copy raw JSON
                        setclipboard(json)
                        Rayfield:Notify({
                            Title = "Export",
                            Content = "Could not upload — raw JSON copied to clipboard instead. Paste it into pastebin.com manually.",
                            Duration = 8
                        })
                    end
                end)
            end,
            SectionParent = ImportSection
        })
        local RecordingOptionsSection = Macro:CreateSection("Recording Options")
        Macro:CreateParagraph({
            Title = "Recording Options",
            Content = "Only change these if you're having recording issues. Try adjusting playback offset before touching recording offset. Time offset is useful when loading into a game that's already in progress.",
            SectionParent = RecordingOptionsSection
        })
        -- TODO: Convert all sliders to input or make sliders mobile friendly.
        --[[Macro:CreateInput({
            Name = "Time Offset",
            Info = "Positive time offset means that actions will performed earlier. Negative time offset means that actions will be performed later."
            CurrentValue = Settings.macro_record_time_offset,
            Callback = function(value)
                Settings.macro_record_time_offset = value
                Save()
            end
        })]] --
        Macro:CreateSlider({
            Name = "Time Offset",
            Range = {-10, 10},
            Increment = 0.1,
            CurrentValue = Settings.macro_record_time_offset,
            Callback = function(value)
                Settings.macro_record_time_offset = value
                Save()
            end,
            SectionParent = RecordingOptionsSection
        })
        local PlaybackOptionsSection = Macro:CreateSection("Playback Options")
        Macro:CreateParagraph({
            Title = "Playback Options",
            Content = "These settings only affect macro playback and do not alter recorded data. Adjusting the time offset here can help fix playback issues caused by mismatched recording offsets.",
            SectionParent = PlaybackOptionsSection
        })
        Macro:CreateToggle({
            Name = "Money Tracking",
            Info = "Delays remote calls until you have enough money to complete the action.",
            CurrentValue = Settings.macro_money_tracking,
            Callback = function(value)
                Settings.macro_money_tracking = value
                Save()
            end,
            SectionParent = PlaybackOptionsSection
        })
        Macro:CreateSlider({
            Name = "Time Offset",
            Range = {-10, 10},
            Increment = 0.1,
            CurrentValue = Settings.macro_playback_time_offset,
            Callback = function(value)
                Settings.macro_playback_time_offset = value
                Save()
            end,
            SectionParent = PlaybackOptionsSection
        })
        Macro:CreateSlider({
            Name = "Magnitude",
            Info = "Finds units with less than or equal magnitude to the slider.",
            Range = {0, 2},
            Increment = 0.01,
            CurrentValue = Settings.macro_magnitude,
            Callback = function(value)
                Settings.macro_magnitude = value
                Save()
            end,
            SectionParent = PlaybackOptionsSection
        })
        Macro:CreateSlider({
            Name = "Attempts before action skip",
            Info = "# of attempts finding unit within magnitude before skipping action.",
            Range = {0, 120},
            Increment = 1,
            CurrentValue = Settings.macro_playback_search_attempts,
            Callback = function(value)
                Settings.macro_playback_search_attempts = value
                Save()
            end,
            SectionParent = PlaybackOptionsSection
        })
        Macro:CreateSlider({
            Name = "Action skip search delay",
            Info = "Delay for the unit search loop.",
            Range = {0, 1},
            Increment = 0.01,
            CurrentValue = Settings.macro_playback_search_delay,
            Callback = function(value)
                Settings.macro_playback_search_delay = value
                Save()
            end,
            SectionParent = PlaybackOptionsSection
        })
        local MacroOptionsSection = Macro:CreateSection("Macro Options")
        Macro:CreateParagraph({
            Title = "Macro Options",
            Content = "Keep all toggles on for full macro functionality. Disable specific action types only if you want to exclude them from recording or playback.",
            SectionParent = MacroOptionsSection
        })
        Macro:CreateDropdown({
            Name = "Elapsed Time Mode",
            Options = {"Version 2", "Version 1"},
            CurrentOption = {Settings.macro_timer_version},
            MultipleOptions = false,
            Callback = function(opts)
                Settings.macro_timer_version = opts[1]
                Save()
            end,
            SectionParent = MacroOptionsSection
        })
        Macro:CreateToggle({
            Name = "Summon Unit",
            CurrentValue = Settings.macro_summon,
            Callback = function(value)
                Settings.macro_summon = value
                Save()
            end,
            SectionParent = MacroOptionsSection
        })
        Macro:CreateToggle({
            Name = "Sell Unit",
            CurrentValue = Settings.macro_sell,
            Callback = function(value)
                Settings.macro_sell = value
                Save()
            end,
            SectionParent = MacroOptionsSection
        })
        Macro:CreateToggle({
            Name = "Upgrade Unit",
            CurrentValue = Settings.macro_upgrade,
            Callback = function(value)
                Settings.macro_upgrade = value
                Save()
            end,
            SectionParent = MacroOptionsSection
        })
        Macro:CreateToggle({
            Name = "Change Unit Priority",
            CurrentValue = Settings.macro_priority,
            Callback = function(value)
                Settings.macro_priority = value
                Save()
            end,
            SectionParent = MacroOptionsSection
        })
        Macro:CreateToggle({
            Name = "Unit Ability",
            CurrentValue = Settings.macro_ability,
            Callback = function(value)
                Settings.macro_ability = value
                Save()
            end,
            SectionParent = MacroOptionsSection
        })
        Macro:CreateToggle({
            Name = "Unit Auto Ability",
            CurrentValue = Settings.macro_auto_ability,
            Callback = function(value)
                Settings.macro_auto_ability = value
                Save()
            end,
            SectionParent = MacroOptionsSection
        })
        Macro:CreateToggle({
            Name = "Skip Wave",
            CurrentValue = Settings.macro_skipwave,
            Callback = function(value)
                Settings.macro_skipwave = value
                Save()
            end,
            SectionParent = MacroOptionsSection
        })
        Macro:CreateToggle({
            Name = "Auto Skip Wave",
            CurrentValue = Settings.macro_autoskipwave,
            Callback = function(value)
                Settings.macro_autoskipwave = value
                Save()
            end,
            SectionParent = MacroOptionsSection
        })
        Macro:CreateToggle({
            Name = "Speed Change",
            CurrentValue = Settings.macro_speedchange,
            Callback = function(value)
                Settings.macro_speedchange = value
                Save()
            end,
            SectionParent = MacroOptionsSection
        })
        local AbilityBlacklistConfigurationSection =
            Macro:CreateSection("Ability Blacklist Configuration")
        Macro:CreateParagraph({
            Title = "Ability Blacklist",
            Content = "Exclude specific units from macro recording and playback. This list should include any units used by the Auto Unit Buffing script.",
            SectionParent = AbilityBlacklistConfigurationSection
        })

        local AbilityBlacklistDropdown

        if #Settings.macro_ability_blacklist > 0 then
            AbilityBlacklistDropdown = Macro:CreateDropdown({
                Name = "Blacklisted Units",
                Options = Settings.macro_ability_blacklist,
                CurrentOption = {Settings.macro_ability_blacklist[#Settings.macro_ability_blacklist]},
                Callback = function(Option) end,
                SectionParent = AbilityBlacklistConfigurationSection
            })
        else
            AbilityBlacklistDropdown = Macro:CreateDropdown({
                Name = "Blacklisted Units",
                Options = {"None"},
                CurrentOption = {"None"},
                Callback = function(Option) end,
                SectionParent = AbilityBlacklistConfigurationSection
            })
        end

        local AbilityBlacklistUnitListDropdown =
            Macro:CreateDropdown({
                Name = "Unit List",
                Options = {"None"},
                CurrentOption = {"None"},
                Callback = function(Option) end,
                SectionParent = AbilityBlacklistConfigurationSection
            })

        if #UnitList > 0 then
            AbilityBlacklistUnitListDropdown:Refresh(UnitList)
            AbilityBlacklistUnitListDropdown:Set({UnitList[1]})
        end

        local AbilityBlacklistAdd = Macro:CreateButton({
            Name = "Add Selected Unit To Ability Blacklist",
            Callback = function()
                local v = AbilityBlacklistUnitListDropdown.CurrentOption[1]
                if table.find(Settings.macro_ability_blacklist, v) == nil then
                    table.insert(Settings.macro_ability_blacklist, v)
                    Save()
                    AbilityBlacklistDropdown:Refresh(Settings.macro_ability_blacklist)
                    AbilityBlacklistDropdown:Set({v})
                    Rayfield:Notify({
                        Title = "Ability Blacklist",
                        Content = string.format(
                            "Unit %s added to ability blacklist", v),
                        Duration = 6.5,
                        Image = 4483362458
                    })
                else
                    Rayfield:Notify({
                        Title = "Ability Blacklist",
                        Content = "Unit already exists in ability blacklist",
                        Duration = 6.5,
                        Image = 4483362458
                    })
                end
            end,
            SectionParent = AbilityBlacklistConfigurationSection
        })

        local AbilityBlacklistDelete = Macro:CreateButton({
            Name = "Remove Selected Blacklisted Unit",
            Callback = function()
                local v = AbilityBlacklistDropdown.CurrentOption[1]
                local idx = table.find(Settings.macro_ability_blacklist, v)
                if idx ~= nil then
                    table.remove(Settings.macro_ability_blacklist, idx)
                    Save()
                    AbilityBlacklistDropdown:Refresh(Settings.macro_ability_blacklist)
                    AbilityBlacklistDropdown:Set({Settings.macro_ability_blacklist[#Settings.macro_ability_blacklist]})
                    Rayfield:Notify({
                        Title = "Ability Blacklist",
                        Content = string.format(
                            "Unit %s removed from ability blacklist", v),
                        Duration = 6.5,
                        Image = 4483362458
                    })
                else
                    Rayfield:Notify({
                        Title = "Ability Blacklist",
                        Content = string.format(
                            "Unit %s does not exist in ability blacklist", v),
                        Duration = 6.5,
                        Image = 4483362458
                    })
                end
            end,
            SectionParent = AbilityBlacklistConfigurationSection
        })

        if not is_lobby() then
            local OffsetSettingsSection = Macro:CreateSection("Offset Settings")
            Macro:CreateParagraph({
                Title = "CAUTION",
                Content = "Experimental. Recalculates unit positions if the map changed after a game update. The previous spawn position must have been saved to this profile first. All changes are permanent — use with caution.",
                SectionParent = OffsetSettingsSection
            })
            local SetMacroMapButton = Macro:CreateButton({
                Name = "Save Current Spawn Position To Profile",
                Callback = function()
                    Macros[Settings.macro_profile]["Map"] = {
                        ["SpawnLocation"] = tostring(
                            game:GetService("Workspace").SpawnLocation.CFrame)
                    }
                    Save()
                    Rayfield:Notify({
                        Title = "Macro",
                        Content = "Current map has been set to macro profile.",
                        Duration = 6.5,
                        Image = 4483362458
                    })
                end,
                SectionParent = OffsetSettingsSection
            })
            local SetMacroMapOffsetButton =
                Macro:CreateButton({
                    Name = "Update Placement Locations",
                    Callback = function()
                        if Macros[Settings.macro_profile]["Map"] ~= nil then
                            local SpawnLocation =
                                Macros[Settings.macro_profile]["Map"]["SpawnLocation"]

                            if SpawnLocation ~= nil then
                                local offset =
                                    game:GetService("Workspace").SpawnLocation
                                        .CFrame *
                                        StringToCFrame(SpawnLocation):Inverse()

                                for _, v in pairs(
                                                Macros[Settings.macro_profile]["Units"]) do
                                    v["Position"] = v["Position"] * offset
                                end
                            end
                        end

                        Macros[Settings.macro_profile]["Map"] = {
                            ["SpawnLocation"] = tostring(
                                game:GetService("Workspace").SpawnLocation
                                    .CFrame)
                        }
                        Save()
                    end,
                    SectionParent = OffsetSettingsSection
                })
        end
    end

    local function AdvancedSettings()
        local AdvancedSettingsTab = Window:CreateTab("Advanced Settings",
                                                     4483362458)
        local function AutoUnitBuffingSettings()
            local AutoUnitBuffingSection =
                AdvancedSettingsTab:CreateSection("Auto Unit Buffing")
            AdvancedSettingsTab:CreateParagraph({
                Title = "How Auto Buffing Works",
                Content = "Select a unit from your game's unit list, configure how it buffs, then add it. The script will automatically use that unit's ability based on the mode and checks you set. Toggle Auto Unit Buffing in the Main tab to start.",
                SectionParent = AutoUnitBuffingSection
            })

            -- Current buff units display
            local AutoBuffUnitList = get_keys(Settings.auto_buff_units)
            local AutoBuffSelectedUnitInformation =
                AdvancedSettingsTab:CreateParagraph({
                    Title = "Selected Unit Info",
                    Content = "Select a unit below to view its config.",
                    SectionParent = AutoUnitBuffingSection
                })

            local function AutoBuffDropdownCallback(opts)
                local value = opts[1]
                if AutoBuffSelectedUnitInformation ~= nil and
                    Settings.auto_buff_units[value] ~= nil then
                    local u = Settings.auto_buff_units[value]
                    local checks = type(u["Checks"]) == "table" and table.concat(u["Checks"], ", ") or tostring(u["Checks"])
                    AutoBuffSelectedUnitInformation:Set({
                        Title = "Selected Unit Info",
                        Content = string.format(
                            "Mode: %s\nChecks: %s\nAbility Type: %s\nAbility Name: %s\nTime: %ss\nDelay: %ss",
                            tostring(u["Mode"]),
                            checks,
                            tostring(u["Ability Type"]),
                            tostring(u["Ability Name"] or "N/A"),
                            tostring(u["Time"]),
                            tostring(u["Delay"] or 0))
                    })
                end
            end

            local AutoBuffDropdown
            if #AutoBuffUnitList > 0 then
                AutoBuffDropdown = AdvancedSettingsTab:CreateDropdown({
                    Name = "Your Buff Units",
                    Info = "Units currently configured for auto buffing.",
                    Options = AutoBuffUnitList,
                    CurrentOption = {AutoBuffUnitList[1]},
                    Callback = AutoBuffDropdownCallback,
                    SectionParent = AutoUnitBuffingSection
                })
                AutoBuffDropdownCallback({AutoBuffUnitList[1]})
            else
                AutoBuffDropdown = AdvancedSettingsTab:CreateDropdown({
                    Name = "Your Buff Units",
                    Info = "No units configured yet. Add one below.",
                    Options = {"None"},
                    CurrentOption = {"None"},
                    Callback = AutoBuffDropdownCallback,
                    SectionParent = AutoUnitBuffingSection
                })
            end

            -- Add new buff unit section
            local AddBuffSection = AdvancedSettingsTab:CreateSection("Add Buff Unit")

            local AutoBuffUnitListDropdown =
                AdvancedSettingsTab:CreateDropdown({
                    Name = "Unit to Add",
                    Info = "Pick a unit from the game's full unit list.",
                    Options = {"None"},
                    CurrentOption = {"None"},
                    Callback = function() end,
                    SectionParent = AddBuffSection
                })
            if #UnitList > 0 then
                AutoBuffUnitListDropdown:Refresh(UnitList)
                AutoBuffUnitListDropdown:Set({UnitList[1]})
            end

            local AutoBuffModeDropdown =
                AdvancedSettingsTab:CreateDropdown({
                    Name = "Buffing Mode",
                    Info = "Box = groups of 4, Pair = alternating pairs, Cycle = one at a time through all units, Spam = all at once.",
                    Options = {"Box", "Pair", "Cycle", "Spam"},
                    CurrentOption = {"Box"},
                    Callback = function() end,
                    SectionParent = AddBuffSection
                })

            local AutoBuffChecks = AdvancedSettingsTab:CreateDropdown({
                Name = "Buff Checks",
                Info = "What to check before re-buffing. Attack = wait until attack buff fades. Range = wait until range buff fades.",
                Options = {"Attack Buff", "Range Buff", "Multiple Abilities"},
                CurrentOption = {"Attack Buff", "Range Buff"},
                MultiSelection = true,
                Callback = function() end,
                SectionParent = AddBuffSection
            })

            local AutoBuffMultipleAbilitiesNameInput = nil
            AdvancedSettingsTab:CreateInput({
                Name = "Multiple Ability Name",
                Info = "Only needed if the unit has multiple abilities. Enter the exact ability name to use.",
                PlaceholderText = "Buff Ability",
                RemoveTextAfterFocusLost = false,
                Callback = function(text)
                    AutoBuffMultipleAbilitiesNameInput = text
                end,
                SectionParent = AddBuffSection
            })

            local AutoBuffAbilityTime = 15
            AdvancedSettingsTab:CreateInput({
                Name = "Ability Cooldown",
                Info = "Seconds to wait before buffing the next unit in the rotation.",
                PlaceholderText = "15",
                NumbersOnly = true,
                RemoveTextAfterFocusLost = false,
                Callback = function(text)
                    AutoBuffAbilityTime = tonumber(text) or 15
                end,
                SectionParent = AddBuffSection
            })

            local CycleUnits = 8
            AdvancedSettingsTab:CreateSlider({
                Name = "Cycle Units",
                Info = "For Cycle mode only: minimum number of units before cycling starts.",
                Range = {1, 8},
                Increment = 1,
                CurrentValue = CycleUnits,
                Callback = function(value) CycleUnits = value end,
                SectionParent = AddBuffSection
            })

            local AutoBuffDelay = 0
            AdvancedSettingsTab:CreateSlider({
                Name = "Post Loop Delay",
                Info = "Extra delay (seconds) after the full buff rotation completes.",
                Range = {0, 60},
                Increment = 1,
                CurrentValue = AutoBuffDelay,
                Callback = function(value) AutoBuffDelay = value end,
                SectionParent = AddBuffSection
            })

            AdvancedSettingsTab:CreateButton({
                Name = "Add Unit to Auto Buff",
                Info = "Adds the selected unit with the configured settings.",
                Callback = function()
                    local v = AutoBuffUnitListDropdown.CurrentOption
                    if type(v) == "table" then v = v[1] end
                    if v == nil or v == "None" then
                        Rayfield:Notify({Title = "Auto Buff", Content = "Select a unit first.", Duration = 4})
                        return
                    end
                    if Settings.auto_buff_units[v] ~= nil then
                        Rayfield:Notify({Title = "Auto Buff", Content = v .. " is already in the buff list.", Duration = 4})
                        return
                    end

                    local AbilityType = "Normal"
                    local AbilityName = nil
                    local Checks = {}
                    local ChecksGUI = AutoBuffChecks.CurrentOption

                    for _, c in pairs(ChecksGUI) do
                        if c == "Attack Buff" then table.insert(Checks, "attack")
                        elseif c == "Range Buff" then table.insert(Checks, "range")
                        elseif c == "Multiple Abilities" then
                            AbilityType = "Multiple"
                            AbilityName = AutoBuffMultipleAbilitiesNameInput
                        end
                    end

                    local mode = AutoBuffModeDropdown.CurrentOption
                    if type(mode) == "table" then mode = mode[1] end

                    Settings.auto_buff_units[v] = {
                        ["Mode"] = mode,
                        ["Checks"] = Checks,
                        ["Ability Type"] = AbilityType,
                        ["Ability Name"] = AbilityName,
                        ["Time"] = AutoBuffAbilityTime,
                        ["Cycle Units"] = CycleUnits,
                        ["Delay"] = AutoBuffDelay
                    }
                    Save()
                    AutoBuffDropdown:Refresh(get_keys(Settings.auto_buff_units))
                    AutoBuffDropdown:Set({v})
                    Rayfield:Notify({Title = "Auto Buff", Content = v .. " added.", Duration = 4})
                end,
                SectionParent = AddBuffSection
            })

            AdvancedSettingsTab:CreateButton({
                Name = "Remove Selected Buff Unit",
                Info = "Removes the unit selected in 'Your Buff Units' above.",
                Callback = function()
                    local v = AutoBuffDropdown.CurrentOption
                    if type(v) == "table" then v = v[1] end
                    if v == nil or v == "None" or Settings.auto_buff_units[v] == nil then
                        Rayfield:Notify({Title = "Auto Buff", Content = "Nothing to remove.", Duration = 4})
                        return
                    end
                    Settings.auto_buff_units[v] = nil
                    Save()
                    local remaining = get_keys(Settings.auto_buff_units)
                    if #remaining == 0 then remaining = {"None"} end
                    AutoBuffDropdown:Refresh(remaining)
                    AutoBuffDropdown:Set({remaining[1]})
                    Rayfield:Notify({Title = "Auto Buff", Content = v .. " removed.", Duration = 4})
                end,
                SectionParent = AddBuffSection
            })
        end

        local function ActionQueueSettings()
            local ActionQueueSection = AdvancedSettingsTab:CreateSection("Action Queue")
            AdvancedSettingsTab:CreateParagraph({
                Title = "Action Queue",
                Content = "Controls how the script sends remote calls to the server. Lower delays = faster but more likely to get throttled. Only change these if you're having issues with actions not going through.",
                SectionParent = ActionQueueSection
            })
            AdvancedSettingsTab:CreateSlider({
                Name = "Remote Action Delay",
                Info = "Seconds to wait between each queued remote call.",
                Range = {0, 1},
                Increment = 0.01,
                CurrentValue = Settings.action_queue_remote_fire_delay,
                Callback = function(value)
                    Settings.action_queue_remote_fire_delay = value
                    Save()
                end,
                SectionParent = ActionQueueSection
            })
            AdvancedSettingsTab:CreateToggle({
                Name = "Retry Failed Remotes",
                Info = "If a remote call fails (unit didn't summon, upgrade didn't apply), retry it automatically.",
                CurrentValue = Settings.action_queue_remote_on_fail,
                Callback = function(value)
                    Settings.action_queue_remote_on_fail = value
                    Save()
                end,
                SectionParent = ActionQueueSection
            })
            AdvancedSettingsTab:CreateSlider({
                Name = "Retry Initial Delay",
                Info = "Seconds to wait before the first retry attempt.",
                Range = {0, 1},
                Increment = 0.01,
                CurrentValue = Settings.action_queue_remote_on_fail_delay,
                Callback = function(value)
                    Settings.action_queue_remote_on_fail_delay = value
                    Save()
                end,
                SectionParent = ActionQueueSection
            })
            AdvancedSettingsTab:CreateSlider({
                Name = "Retry Loop Delay",
                Info = "Seconds between each retry attempt in the loop.",
                Range = {0, 1},
                Increment = 0.01,
                CurrentValue = Settings.action_queue_remote_on_fail_delay_loop,
                Callback = function(value)
                    Settings.action_queue_remote_on_fail_delay_loop = value
                    Save()
                end,
                SectionParent = ActionQueueSection
            })
        end

        local function AutomationSettings()
            local AutomationSection = AdvancedSettingsTab:CreateSection("Automation Thresholds")
            AdvancedSettingsTab:CreateParagraph({
                Title = "Automation",
                Content = "Set when Auto Battle, Auto Upgrade, and Auto Sell activate. These work with the toggles in the Main tab.",
                SectionParent = AutomationSection
            })
            AdvancedSettingsTab:CreateSlider({
                Name = "Auto Battle Gems",
                Info = "Minimum gems required before Auto Battle will activate.",
                Range = {0, 10000},
                Increment = 50,
                CurrentValue = tonumber(Settings.auto_battle_gems) or 0,
                Callback = function(value)
                    Settings.auto_battle_gems = value
                    Save()
                end,
                SectionParent = AutomationSection
            })
            AdvancedSettingsTab:CreateSlider({
                Name = "Auto Upgrade Min Money",
                Info = "Auto Upgrade only fires when your in-game money is at or above this.",
                Range = {0, 10000},
                Increment = 50,
                CurrentValue = tonumber(Settings.auto_upgrade_money) or 100,
                Callback = function(value)
                    Settings.auto_upgrade_money = value
                    Save()
                end,
                SectionParent = AutomationSection
            })
            AdvancedSettingsTab:CreateSlider({
                Name = "Auto Upgrade Start Wave",
                Info = "Auto Upgrade starts at this wave.",
                Range = {0, 200},
                Increment = 1,
                CurrentValue = tonumber(Settings.auto_upgrade_wave) or 0,
                Callback = function(value)
                    Settings.auto_upgrade_wave = value
                    Save()
                end,
                SectionParent = AutomationSection
            })
            AdvancedSettingsTab:CreateSlider({
                Name = "Auto Upgrade Stop Wave",
                Info = "Auto Upgrade stops at this wave.",
                Range = {0, 200},
                Increment = 1,
                CurrentValue = tonumber(Settings.auto_upgrade_wave_stop) or 100,
                Callback = function(value)
                    Settings.auto_upgrade_wave_stop = value
                    Save()
                end,
                SectionParent = AutomationSection
            })
            AdvancedSettingsTab:CreateSlider({
                Name = "Auto Sell At Wave",
                Info = "Auto Sell triggers at this wave.",
                Range = {0, 200},
                Increment = 1,
                CurrentValue = tonumber(Settings.auto_upgrade_wave_sell) or 100,
                Callback = function(value)
                    Settings.auto_upgrade_wave_sell = value
                    Save()
                end,
                SectionParent = AutomationSection
            })
        end

        AutoUnitBuffingSettings()
        ActionQueueSettings()
        AutomationSettings()
    end

    local function LobbySettings()
        local Lobby = Window:CreateTab("Lobby", 4483362458)
        local LobbyScriptsSection = Lobby:CreateSection("Lobby Scripts")
        Lobby:CreateToggle({
            Name = "Auto Join Game",
            Info = "Automatically joins a game using the settings configured in the Auto Join Settings section.",
            CurrentValue = Settings.auto_join_game,
            Callback = function(value)
                Settings.auto_join_game = value
                Save()

                if value and is_lobby() then
                    task.spawn(AutoJoinGame)
                end
            end,
            SectionParent = LobbyScriptsSection
        })
        Lobby:CreateToggle({
            Name = "Auto Join Tower",
            Info = "Automatically joins the Infinite Tower at the highest available level.",
            CurrentValue = Settings.auto_join_tower,
            Callback = function(value)
                Settings.auto_join_tower = value
                Save()
                if value and is_lobby() then
                    task.spawn(AutoTower)
                end
            end,
            SectionParent = LobbyScriptsSection
        })
        Lobby:CreateToggle({
            Name = "Auto Evolve EXP",
            Info = "Automatically evolves EXP units in your inventory up to EXP IV.",
            CurrentValue = Settings.auto_evolve_exp,
            Callback = function(value)
                Settings.auto_evolve_exp = value
                Save()

                if value and is_lobby() then
                    task.spawn(AutoEvolveEXP)
                end
            end,
            SectionParent = LobbyScriptsSection
        })
        Lobby:CreateToggle({
            Name = "Auto Click Popup",
            Info = "Automatically dismisses popup dialogs that appear during gameplay.",
            CurrentValue = Settings.auto_skip_gui,
            Callback = function(value)
                Settings.auto_skip_gui = value
                Save()

                if value then task.spawn(AutoSkipGUI) end
            end,
            SectionParent = LobbyScriptsSection
        })
        local AutoJoinSection = Lobby:CreateSection("Auto Join Settings")
        Lobby:CreateDropdown({
            Name = "Mode",
            Info = "Select which game mode Auto Join will target.",
            Options = {
                "Story", "Infinite", "Adventure"
            },
            CurrentOption = {Settings.auto_join_mode},
            MultipleOptions = false,
            Callback = function(opts)
                Settings.auto_join_mode = opts[1]
                Save()
            end,
            SectionParent = AutoJoinSection
        })
        if InfiniteMapTable[Settings.auto_join_infinite_level] == nil then
            Settings.auto_join_infinite_level = "-1"
            Save()
        end
        Lobby:CreateDropdown({
            Name = "Infinite Map Selection",
            Info = "Select which Infinite map to target when Mode is set to Infinite.",
            Options = GetMapsFromTable(InfiniteMapTable),
            CurrentOption = {InfiniteMapTable[Settings.auto_join_infinite_level]},
            MultipleOptions = false,
            Callback = function(opts)
                local option = opts[1]
                for k, v in pairs(InfiniteMapTable) do
                    if v == option then
                        Settings.auto_join_infinite_level = k
                        Save()
                        break
                    end
                end
            end,
            SectionParent = AutoJoinSection
        })
        if AdventureMapTable[Settings.auto_join_adventure_level] == nil then
            Settings.auto_join_adventure_level = "-1133"
            Save()
        end
        Lobby:CreateDropdown({
            Name = "Adventure Map Selection",
            Info = "Select which Adventure map to target when Mode is set to Adventure.",
            Options = GetMapsFromTable(AdventureMapTable),
            CurrentOption = {AdventureMapTable[Settings.auto_join_adventure_level]},
            MultipleOptions = false,
            Callback = function(opts)
                local option = opts[1]
                for k, v in pairs(AdventureMapTable) do
                    if v == option then
                        Settings.auto_join_adventure_level = k
                        Save()
                        break
                    end
                end
            end,
            SectionParent = AutoJoinSection
        })
        Lobby:CreateSlider({
            Name = "Story Level",
            Info = "Select which Story level to target when Mode is set to Story.",
            Range = {1, get_number_missions()},
            Increment = 1,
            CurrentValue = Settings.auto_join_story_level,
            Callback = function(value)
                Settings.auto_join_story_level = value
                Save()
            end,
            SectionParent = AutoJoinSection
        })
        Lobby:CreateSlider({
            Name = "Delay",
            Info = "Seconds to wait before attempting to join the teleporter.",
            Range = {0, 60},
            Increment = 1,
            CurrentValue = Settings.auto_join_delay,
            Callback = function(value)
                Settings.auto_join_delay = value
                Save()
            end,
            SectionParent = AutoJoinSection
        })
    end

    local function WebhookSettings()
        local Webhook = Window:CreateTab("Webhooks", 4483362458)
        local SettingsSection = Webhook:CreateSection("Settings")
        Webhook:CreateInput({
            Name = "URL",
            Info = "Enter your Discord webhook URL here.",
            PlaceholderText = Settings.webhook_url,
            RemoveTextAfterFocusLost = false,
            Callback = function(text)
                Settings.webhook_url = text
                Save()
            end,
            SectionParent = SettingsSection
        })
        Webhook:CreateInput({
            Name = "Discord ID",
            Info = "Your Discord User ID. Enable Developer Mode in Discord, then right-click your profile and select Copy User ID.",
            PlaceholderText = Settings.webhook_discord_id,
            RemoveTextAfterFocusLost = false,
            Callback = function(text)
                Settings.webhook_discord_id = text
                Save()
            end,
            SectionParent = SettingsSection
        })
        Webhook:CreateButton({
            Name = "Test Webhook",
            Callback = function()
                SendWebhook({
                    {
                        ["name"] = "Webhook Test",
                        ["value"] = "Webhook sent successfully!"
                    }
                })
            end,
            SectionParent = SettingsSection
        })
        Webhook:CreateColorPicker({
            Name = "Webhook color",
            Info = "Sets the accent color displayed on the left side of the Discord webhook embed.",
            Color = Color3.fromHex(Settings.webhook_color),
            Callback = function(value)
                Settings.webhook_color = value:ToHex()
                Save()
            end,
            SectionParent = SettingsSection
        })
        local TogglesSection = Webhook:CreateSection("Toggles")
        Webhook:CreateToggle({
            Name = "Ping User",
            Info = "Pings your Discord account when a webhook is sent. Requires your Discord ID to be set in the Settings section.",
            CurrentValue = Settings.webhook_ping_user,
            Callback = function(value)
                Settings.webhook_ping_user = value
                Save()
            end,
            SectionParent = TogglesSection
        })
        Webhook:CreateToggle({
            Name = "Send Webhook On Game End",
            Info = "Sends a webhook notification when the current game ends.",
            CurrentValue = Settings.webhook_end_game,
            Callback = function(value)
                Settings.webhook_end_game = value
                Save()
            end,
            SectionParent = TogglesSection
        })
        Webhook:CreateToggle({
            Name = "Send Webhook After EXP Evolve",
            Info = "Sends a webhook notification when Auto EXP Evolve completes.",
            CurrentValue = Settings.webhook_exp_evolve,
            Callback = function(value)
                Settings.webhook_exp_evolve = value
                Save()
            end,
            SectionParent = TogglesSection
        })
    end

    local function MiscellaneousSettings()
        local Miscellaneous = Window:CreateTab("Miscellaneous", 4483362458)
        local GameSettingsSection = Miscellaneous:CreateSection("Game Settings")

        Miscellaneous:CreateToggle({
            Name = "FPS Boost",
            Info = "Reduces visual effects to improve frame rate.",
            CurrentValue = Settings.fps_boost,
            Callback = function(value)
                Settings.fps_boost = value
                Save()
            end,
            SectionParent = GameSettingsSection
        })
        Miscellaneous:CreateToggle({
            Name = "Anti-AFK",
            Info = "Prevents the game from disconnecting you for inactivity.",
            CurrentValue = Settings.anti_afk,
            Callback = function(value)
                Settings.anti_afk = value
                Save()
                for _, v in
                    pairs(getconnections(game.Players.LocalPlayer.Idled)) do
                    v:Disable()
                end
            end,
            SectionParent = GameSettingsSection
        })
        Miscellaneous:CreateToggle({
            Name = "Disable 3D Rendering",
            Info = "Disables 3D rendering to improve performance.",
            CurrentValue = Settings.disable_3d_rendering,
            Callback = function(value)
                Settings.disable_3d_rendering = value
                Save()
                game:GetService("RunService"):Set3dRenderingEnabled(not value)
            end,
            SectionParent = GameSettingsSection
        })

        Miscellaneous:CreateToggle({
            Name = "Auto Execute",
            Info = "Automatically re-executes the script after teleporting to a new place.",
            CurrentValue = Settings.auto_execute,
            Callback = function(value)
                Settings.auto_execute = value
                Save()
                      end,
            SectionParent = GameSettingsSection
        })

        Miscellaneous:CreateToggle({
            Name = "Close UI on Execution",
            Info = "Hides the Rayfield UI automatically after loading. Press K or Left Ctrl to reopen it anytime.",
            CurrentValue = Settings.close_on_injection,
            Callback = function(value)
                Settings.close_on_injection = value
                Save()
            end,
            SectionParent = GameSettingsSection
        })

        if get_world() ~= -1 and get_world() ~= -2 then
            Miscellaneous:CreateToggle({
                Name = "Anonymous Mode",
                Info = "Hides your name on the leaderboard (client-side only).",
                CurrentValue = Settings.anonymous_mode,
                Callback = function(value)
                    Settings.anonymous_mode = value
                    Save()
                    if value then AnonMode() end
                end,
                SectionParent = GameSettingsSection
            })

            Miscellaneous:CreateInput({
                Name = "Change Name",
                Info = "The name shown on the leaderboard when Anonymous Mode is enabled.",
                PlaceholderText = Settings.anonymous_mode_name,
                RemoveTextAfterFocusLost = false,
                Callback = function(text)
                    Settings.anonymous_mode_name = text
                    Save()
                    if Settings.anonymous_mode then
                        AnonMode()
                    end
                end,
                SectionParent = GameSettingsSection
            })

            local WorldTeleportsSection =
                Miscellaneous:CreateSection("World Teleports")

            local function UseWorldTeleporter(Teleporter)
                firetouchinterest(Player.Character.HumanoidRootPart, Teleporter,
                                  0)
                task.wait()
                firetouchinterest(Player.Character.HumanoidRootPart, Teleporter,
                                  1)
            end

            if get_world() == 1 then
                Miscellaneous:CreateButton({
                    Name = "Teleport to World 2",
                    Callback = function()
                        UseWorldTeleporter(get_world_teleporter())
                    end,
                    SectionParent = WorldTeleportsSection
                })
            elseif get_world() == 2 then
                Miscellaneous:CreateButton({
                    Name = "Teleport to World 1",
                    Callback = function()
                        UseWorldTeleporter(get_world_teleporter())
                    end,
                    SectionParent = WorldTeleportsSection
                })
            end
        end

        local ResetSection = Miscellaneous:CreateSection("Reset")
        -- TODO: Implement UI reload after settings are reset.
        Miscellaneous:CreateButton({
            Name = "Reset Settings To Default",
            Callback = function()
                Settings = DefaultSettings
                Save()
                Rayfield:Notify({
                    Title = "Reset",
                    Content = "All settings have been restored to their defaults.",
                    Duration = 6.5,
                    Image = 4483362458
                })
                task.wait(2)
            end,
            SectionParent = ResetSection
        })
    end

    local function CreditsSettings()
        local Credits = Window:CreateTab("Credits", 4483362458)
        local CreditsSection = Credits:CreateSection("Credits")
        Credits:CreateParagraph({
            Title = "Made by KarmaPanda — Fork by bm210",
            Content = "Additional credits to Jeikaru for maintaining this version of the script, allowing it to be expanded and built upon. Join the Discord using the button below to get the latest macros and announcements.",
            SectionParent = CreditsSection
        })
        Credits:CreateButton({
            Name = "Join Discord",
            Info = "Copies the Discord invite link to your clipboard.",
            Callback = function()
                setclipboard("https://discord.gg/d9Y7VDCQ7Z")
                Rayfield:Notify({
                    Title = "Discord",
                    Content = "Invite link copied to clipboard.",
                    Duration = 4,
                    Image = 4483362458
                })
            end,
            SectionParent = CreditsSection
        })
    end

    MainSettings()
    MacroSettings()
    LobbySettings()
    WebhookSettings()
    AdvancedSettings()
    MiscellaneousSettings()
    CreditsSettings()
    -- CreateMiniGUI and CreateHideButtonGUI removed
end

InitializeUI()

print("[KarmaPanda] UI Loaded: " .. os.clock() - benchmark_time)
benchmark_time = os.clock()

-- ============================================================
--  Close on Execution notification + Left Ctrl Toggle
-- ============================================================
task.spawn(function()
    task.wait(2)

    -- Show notification if close on execution is active
    if Settings.close_on_injection then
        Rayfield:Notify({
            Title = "UI Hidden",
            Content = "Close on Execution is enabled. Press K or Left Ctrl to reopen.",
            Duration = 6
        })
    end

    -- Left Ctrl as alternative toggle (simulates K press)
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.LeftControl then
            local vim = game:GetService("VirtualInputManager")
            vim:SendKeyEvent(true, Enum.KeyCode.K, false, game)
            task.wait(0.1)
            vim:SendKeyEvent(false, Enum.KeyCode.K, false, game)
        end
    end)
end)
