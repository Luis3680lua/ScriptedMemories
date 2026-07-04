local folder = ".cache"
if makefolder and not isfolder(folder) then makefolder(folder) end

local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local GameProperties = workspace:WaitForChild("GameProperties")
local stateValue = GameProperties:WaitForChild("State")

local function downloadAudio(url, filename)
    if not isfile(filename) then
        local ok, data = pcall(function() return game:HttpGet(url) end)
        if ok and data then writefile(filename, data) end
    end
    if getcustomasset then return getcustomasset(filename) end
    return nil
end

local options = {
    {
        name = "Don't Blink",
        url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/DontBlink.mp3",
        endTime = 245.94,
        credits = "Placeholder"
    },
    {
        name = "Don't Blink (Old Lyrics)",
        url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/DontBlinkOLD.mp3",
        endTime = 261.49,
        credits = "Placeholder"
    },
    {
        name = "Speed of Sound Round 1",
        url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound1.mp3",
        endTime = 189.36,
        credits = "Placeholder"
    },
    {
        name = "Speed of Sound Round 2",
        url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound2.mp3",
        endTime = 211.48,
        credits = "Placeholder"
    },
    {
        name = "Speed of Sound Round 2 Bonus Mix",
        url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound2BonusMix.mp3",
        endTime = 211.48,
        credits = "Placeholder"
    }
}

local activeOverride = nil
local activeConnection = nil

local function stopOverride()
    if activeConnection then
        activeConnection:Disconnect()
        activeConnection = nil
    end
    activeOverride = nil
end

local function applyLMS(characterName, optionName)
    if characterName ~= "Sonic" then return end

    local opt = nil
    for _, o in ipairs(options) do
        if o.name == optionName then
            opt = o
            break   -- Se agregó el break como línea independiente
        end
    end
    if not opt then return end

    stopOverride()

    local filePath = folder .. "/" .. optionName:gsub("%s", "_") .. ".mp3"
    local soundId = downloadAudio(opt.url, filePath)
    if not soundId then return end

    local masterMusic = RS:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("musg")
    local sonicSolo = RS:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("SoloTheme"):WaitForChild("SonicSolo")

    sonicSolo.SoundId = soundId
    sonicSolo.Looped = true
    sonicSolo.Volume = masterMusic.Volume

    local function onSoundIdChange()
        if sonicSolo.SoundId ~= soundId then
            sonicSolo.SoundId = soundId
        end
    end
    sonicSolo:GetPropertyChangedSignal("SoundId"):Connect(onSoundIdChange)

    local function onVolumeChange()
        sonicSolo.Volume = masterMusic.Volume
    end
    masterMusic:GetPropertyChangedSignal("Volume"):Connect(onVolumeChange)

    local function onStateChange(newState)
        if newState == "RE" and sonicSolo.IsPlaying then
            sonicSolo.Looped = false
            sonicSolo.TimePosition = opt.endTime
        end
    end
    activeConnection = stateValue.Changed:Connect(onStateChange)

    activeOverride = sonicSolo
end

return {
    Options = options,
    Apply = applyLMS,
    Stop = stopOverride
}