local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SONGS_URLS = {
    "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv1.mp3",
    "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv2.mp3",
    "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/TeaTimeWaltzLobby.mp3"
}

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

local SONGS_CACHED = {}
for i, url in ipairs(SONGS_URLS) do
    local name = url:match("([^/]+)%.mp3$")
    local id = getOrDownloadAsset(url, folderName .. "/" .. name .. ".mp3")
    if id then
        table.insert(SONGS_CACHED, id)
    end
end
if #SONGS_CACHED == 0 then return end

local endedConnection
local lastIndex = 0

local function setupAlternatingLobbyMus(lobbyMus)
    if endedConnection then
        endedConnection:Disconnect()
    end
    local MusicGroup = ReplicatedStorage:WaitForChild("ClientAssets", 10)
    if MusicGroup then
        MusicGroup = MusicGroup:WaitForChild("Sounds", 10)
        if MusicGroup then
            MusicGroup = MusicGroup:WaitForChild("musg", 10)
        end
    end
    if MusicGroup then
        lobbyMus.SoundGroup = MusicGroup
    end

    local function getRandomIndex()
        local newIndex
        repeat
            newIndex = math.random(#SONGS_CACHED)
        until newIndex ~= lastIndex or #SONGS_CACHED == 1
        return newIndex
    end

    local function playCurrent()
        lobbyMus:Stop()
        lobbyMus.Looped = false
        local idx = getRandomIndex()
        lastIndex = idx
        lobbyMus.SoundId = SONGS_CACHED[idx]
        lobbyMus.TimePosition = 0
        lobbyMus:Play()
    end

    endedConnection = lobbyMus.Ended:Connect(playCurrent)
    playCurrent()
end

task.spawn(function()
    local lobby = workspace:WaitForChild("Lobby", 15)
    if not lobby then return end
    local lobbyMus = lobby:WaitForChild("LobbyMus", 15)
    if lobbyMus and lobbyMus:IsA("Sound") then
        setupAlternatingLobbyMus(lobbyMus)
    end
end)