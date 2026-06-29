local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local FOLDER = ".cache"
local PROBLEM_SOUND_ID = "rbxassetid://18131809532"
local ASSET_URL = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/2011x/Laugh.mp3"
local ASSET_FILE = FOLDER .. "/Laugh.mp3"

if makefolder and not isfolder(FOLDER) then
    makefolder(FOLDER)
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

local LAUGH_ID = nil
task.spawn(function()
    LAUGH_ID = getOrDownloadAsset(ASSET_URL, ASSET_FILE)
end)

local masterSound = ReplicatedStorage:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("musg")

local overriddenSounds = {}

local function updateAllVolumes()
    local vol = masterSound.Volume
    local toRemove = {}
    for sound in pairs(overriddenSounds) do
        if sound and sound.Parent then
            sound.Volume = vol
        else
            toRemove[sound] = true
        end
    end
    for sound in pairs(toRemove) do
        overriddenSounds[sound] = nil
    end
end

masterSound:GetPropertyChangedSignal("Volume"):Connect(updateAllVolumes)

local hooked = setmetatable({}, { __mode = "k" })

local function hookSound(sound)
    if not sound or not sound:IsA("Sound") then return end
    if hooked[sound] then return end
    hooked[sound] = true

    if not LAUGH_ID then
        repeat task.wait() until LAUGH_ID
    end

    local updating = false

    local function apply()
        if updating then return end
        updating = true

        if sound.SoundId ~= LAUGH_ID then
            if sound.IsPlaying then
                sound:Stop()
            end
            sound.SoundId = LAUGH_ID
        end

        sound.Volume = masterSound.Volume
        sound.PlaybackSpeed = 1
        updating = false
    end

    apply()
    overriddenSounds[sound] = true

    local conn = sound.Changed:Connect(function(property)
        if property == "SoundId" then
            if not updating and sound.SoundId ~= LAUGH_ID then
                task.defer(apply)
            end
        end
    end)

    local destroyConn = sound.Destroying:Connect(function()
        conn:Disconnect()
        destroyConn:Disconnect()
        overriddenSounds[sound] = nil
        hooked[sound] = nil
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

local containers = { Workspace, ReplicatedStorage, ReplicatedFirst }

for _, container in ipairs(containers) do
    container.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Sound") and descendant.SoundId == PROBLEM_SOUND_ID then
            hookSound(descendant)
        end
    end)
end

for _, container in ipairs(containers) do
    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("Sound") and obj.SoundId == PROBLEM_SOUND_ID then
            hookSound(obj)
        end
    end
end