local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local folderName = ".cache"
if makefolder and not isfolder(folderName) then
    makefolder(folderName)
end

local function getOrDownloadAsset(url, filename)
    if isfile(filename) then
        return getcustomasset(filename)
    end
    local ok, data = pcall(game.HttpGet, game, url)
    if ok and data then
        writefile(filename, data)
        return getcustomasset(filename)
    end
    return nil
end

local LAUGH_ID = getOrDownloadAsset(
    "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Laugh.mp3",
    folderName .. "/Laugh.mp3"
)

local masterSound = ReplicatedStorage:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("musg")

local overriddenSounds = {}

local function updateAllVolumes()
    local vol = masterSound.Volume
    local toRemove = nil
    for sound, _ in pairs(overriddenSounds) do
        if sound and sound.Parent then
            sound.Volume = vol
        else
            if not toRemove then toRemove = {} end
            toRemove[sound] = true
        end
    end
    if toRemove then
        for sound in pairs(toRemove) do overriddenSounds[sound] = nil end
    end
end

masterSound:GetPropertyChangedSignal("Volume"):Connect(updateAllVolumes)

local PROBLEM_SOUND_ID = "rbxassetid://18131809532"

local function hookSound(sound)
    if not sound or not sound:IsA("Sound") then return end
    local updating = false

    local function apply()
        if updating then return end
        updating = true
        sound:Stop()
        sound.SoundId = LAUGH_ID
        sound.Volume = masterSound.Volume
        sound.PlaybackSpeed = 1
        updating = false
    end

    apply()
    overriddenSounds[sound] = true

    sound:GetPropertyChangedSignal("SoundId"):Connect(function()
        if not updating and sound.SoundId ~= LAUGH_ID then
            task.defer(apply)
        end
    end)
end

task.spawn(function()
    local clientHandler = ReplicatedFirst:WaitForChild("CLIENTHANDLER")
    local connections = clientHandler:WaitForChild("Connections")

    local laughSound = connections:FindFirstChild("laugh")
    if not laughSound then
        laughSound = Instance.new("Sound")
        laughSound.Name = "laugh"
        laughSound.Parent = connections
    end

    hookSound(laughSound)
end)

task.spawn(function()
    local remakeLaugh = ReplicatedStorage
        :WaitForChild("ClientAssets")
        :WaitForChild("Stats")
        :WaitForChild("EXE")
        :WaitForChild("2011x")
        :WaitForChild("Sonic exe remake Laugh")

    hookSound(remakeLaugh)
end)

game.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Sound") and descendant.SoundId == PROBLEM_SOUND_ID then
        hookSound(descendant)
    end
end)

for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("Sound") and obj.SoundId == PROBLEM_SOUND_ID then
        hookSound(obj)
    end
end