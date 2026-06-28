local Players = game:GetService("Players")

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
    if not isfile(filename) then
        writefile(filename, game:HttpGet(url))
    end
    return getcustomasset(filename)
end

local SONGS_CACHED = {
    getOrDownloadAsset(SONGS_URLS[1], folderName .. "/v1.mp3"),
    getOrDownloadAsset(SONGS_URLS[2], folderName .. "/v2.mp3"),
    getOrDownloadAsset(SONGS_URLS[3], folderName .. "/tea.mp3")
}

local endedConnection
local lastIndex = 0

local function setupAlternatingLobbyMus(lobbyMus)
    if endedConnection then
        endedConnection:Disconnect()
    end

    local function getRandomIndex()
        local newIndex
        repeat
            newIndex = math.random(#SONGS_CACHED)
        until newIndex ~= lastIndex or #SONGS_CACHED <= 1
        return newIndex
    end

    local function playCurrent()
        lobbyMus:Stop()
        lobbyMus.Looped = false
        
        local currentIndex = getRandomIndex()
        lastIndex = currentIndex
        
        lobbyMus.SoundId = SONGS_CACHED[currentIndex]
        lobbyMus.TimePosition = 0
        lobbyMus.PlaybackSpeed = 1
        task.wait(0.1)
        lobbyMus:Play()
    end

    endedConnection = lobbyMus.Ended:Connect(playCurrent)
    playCurrent()
end

task.spawn(function()
    local lobby = workspace:WaitForChild("Lobby")
    local lobbyMus = lobby:WaitForChild("LobbyMus")

    if lobbyMus:IsA("Sound") then
        setupAlternatingLobbyMus(lobbyMus)
    end
end)