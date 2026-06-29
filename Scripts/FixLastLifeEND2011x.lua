local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function is2011xVariant(name)
    return name == "2011x" or name == "2011xClassic" or name == "2011xRetro"
end

local function getNearbyLastLifeCount()
    local char = LocalPlayer.Character
    if not char then return 0 end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return 0 end
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local other = plr.Character
            if other and other:GetAttribute("Team") == "Survivor" and other:GetAttribute("LastLife") == true and other:GetAttribute("State") ~= "downed" then
                local otherRoot = other:FindFirstChild("HumanoidRootPart")
                if otherRoot and (root.Position - otherRoot.Position).Magnitude <= 100 then
                    count = count + 1
                end
            end
        end
    end
    return count
end

local function setupLastLifeFade()
    local char = LocalPlayer.Character
    if not char then return end
    local killer = char:GetAttribute("Character")
    if not is2011xVariant(killer) then return end

    local songsFolder = workspace:FindFirstChild("Assets") and workspace.Assets:FindFirstChild("Songs")
    if not songsFolder then return end
    local chaseFolderName = LocalPlayer.Name .. "Chases"
    local chaseFolder = songsFolder:FindFirstChild(chaseFolderName)
    if not chaseFolder then return end
    local lastLifeSound = chaseFolder:FindFirstChild("LastLifeChase")
    if not lastLifeSound then return end

    RunService.Heartbeat:Connect(function()
        local count = getNearbyLastLifeCount()
        local targetVolume = count > 0 and 0.75 or 0
        lastLifeSound.Volume = lastLifeSound.Volume + (targetVolume - lastLifeSound.Volume) * 0.25
    end)
end

LocalPlayer.CharacterAdded:Connect(setupLastLifeFade)
if LocalPlayer.Character then setupLastLifeFade() end