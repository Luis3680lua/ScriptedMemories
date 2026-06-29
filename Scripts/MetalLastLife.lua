local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function applyMetalSonicLastLifeChase()
    local char = LocalPlayer.Character
    if not char or char:GetAttribute("Character") ~= "MetalSonic" then return end

    local chaseThemes = ReplicatedStorage:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("ChaseThemes")
    local metalTheme = chaseThemes:WaitForChild("MetalSonic")
    local skin = char:GetAttribute("Skin") or "Default"
    local skinFolder = metalTheme:FindFirstChild(skin) or metalTheme:FindFirstChild("Default")
    if not skinFolder then return end

    local lastLifeChase = skinFolder:FindFirstChild("LastLifeChase")
    if not lastLifeChase or not lastLifeChase:IsA("Sound") then return end

    local lastLifeId = lastLifeChase.SoundId

    local songsFolder = workspace:WaitForChild("Assets"):WaitForChild("Songs")

    local function forceLastLife(sound)
        if sound:IsA("Sound") and sound.Name == "NormalChase" then
            sound.SoundId = lastLifeId
        end
    end

    for _, obj in ipairs(songsFolder:GetDescendants()) do
        forceLastLife(obj)
    end

    songsFolder.DescendantAdded:Connect(forceLastLife)
end

LocalPlayer.CharacterAdded:Connect(applyMetalSonicLastLifeChase)
applyMetalSonicLastLifeChase()