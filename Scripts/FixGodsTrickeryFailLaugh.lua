local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FOLDER = ".cache"
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

local function hookSound(sound)
    if not sound or not sound:IsA("Sound") then return end

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

    local conn = sound.Changed:Connect(function(property)
        if property == "SoundId" then
            if not updating and sound.SoundId ~= LAUGH_ID then
                task.defer(apply)
            end
        end
    end)

    local volConn = masterSound:GetPropertyChangedSignal("Volume"):Connect(function()
        sound.Volume = masterSound.Volume
    end)

    sound.Destroying:Connect(function()
        conn:Disconnect()
        volConn:Disconnect()
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