local RS = game:GetService("ReplicatedStorage")
local folder = ".cache"
if makefolder and not isfolder(folder) then makefolder(folder) end

math.randomseed(tick())

local REPLACEMENTS = {

    -- blaze
    ["86638249245610"] = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Blaze/ChineseCatDance.mp3",
    ["126064088265111"] = {
        "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Blaze/ReleaseTheGhoulsV1.mp3",
        "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Blaze/ReleaseTheGhoulsV2.mp3",
        "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Blaze/ReleaseTheGhoulsV3.mp3",
    },
}

local lastUsed = {}

local function getCustomSoundFor(oldId)
    local entry = REPLACEMENTS[oldId]
    if not entry then return nil end

    local urls
    local single = false
    if type(entry) == "string" then
        urls = { entry }
        single = true
    else
        urls = entry
    end

    if #urls == 0 then return nil end

    local function getFilenameFromURL(url)
        local name = url:match("([^/]+)%.mp3$")
        if name then
            return name .. ".mp3"
        else
            return oldId .. ".mp3"
        end
    end

    if single then
        local filename = folder .. "/" .. getFilenameFromURL(urls[1])
        if not isfile(filename) then
            local data = game:HttpGet(urls[1])
            if data then writefile(filename, data) end
        end
        return getcustomasset(filename)
    end

    local last = lastUsed[oldId]
    local available = {}
    for _, url in ipairs(urls) do
        if url ~= last then
            table.insert(available, url)
        end
    end

    if #available == 0 then
        available = urls
    end

    local chosen = available[math.random(1, #available)]
    lastUsed[oldId] = chosen

    local filename = folder .. "/" .. getFilenameFromURL(chosen)
    if not isfile(filename) then
        local data = game:HttpGet(chosen)
        if data then writefile(filename, data) end
    end
    return getcustomasset(filename)
end

local function getOldIdFromSoundId(soundId)
    for oldId in pairs(REPLACEMENTS) do
        if soundId == "rbxassetid://" .. oldId then
            return oldId
        end
    end
    return nil
end

local masterSound = RS:FindFirstChild("ClientAssets"):FindFirstChild("Sounds"):FindFirstChild("musg")
local overridden = {}

local function applyOverride(sound)
    if not sound or not sound:IsA("Sound") then return end

    local soundIdStr = tostring(sound.SoundId)
    local oldId = getOldIdFromSoundId(soundIdStr)
    if not oldId then return end

    local newId = getCustomSoundFor(oldId)
    if not newId then return end

    if sound.SoundId ~= newId then
        sound.SoundId = newId
    end
    sound.Looped = true
    if masterSound then sound.Volume = masterSound.Volume end
    overridden[sound] = true
end

local function hookSound(sound)
    if not sound or not sound:IsA("Sound") then return end
    local oldId = getOldIdFromSoundId(tostring(sound.SoundId))
    if not oldId then return end

    applyOverride(sound)

    local conn = sound:GetPropertyChangedSignal("SoundId"):Connect(function()
        local newOldId = getOldIdFromSoundId(tostring(sound.SoundId))
        if newOldId then
            applyOverride(sound)
        end
    end)

    sound.AncestryChanged:Connect(function()
        if not sound.Parent then conn:Disconnect() end
    end)
end

local playersFolder = workspace:WaitForChild("Players")

local function scanCharacter(character)
    local sound = character:FindFirstChild("EmoteSong", true)
    if sound and sound:IsA("Sound") then
        hookSound(sound)
    end
end

for _, character in ipairs(playersFolder:GetChildren()) do
    scanCharacter(character)
end

playersFolder.ChildAdded:Connect(scanCharacter)
playersFolder.DescendantAdded:Connect(function(obj)
    if obj:IsA("Sound") and obj.Name == "EmoteSong" then
        hookSound(obj)
    end
end)

if masterSound then
    masterSound:GetPropertyChangedSignal("Volume"):Connect(function()
        local vol = masterSound.Volume
        for sound in pairs(overridden) do
            if sound and sound.Parent then
                sound.Volume = vol
            else
                overridden[sound] = nil
            end
        end
    end)
end