local folderName = "cache"

if makefolder and not isfolder(folderName) then
	makefolder(folderName)
end

local function getOrDownloadAsset(url, filename)
	if not isfile(filename) then
		writefile(filename, game:HttpGet(url))
	end
	return getcustomasset(filename)
end

local LOBBY_V1 = getOrDownloadAsset(
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv1.mp3",
	folderName .. "/UponTheHillv1.mp3"
)

local LOBBY_V2 = getOrDownloadAsset(
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv2.mp3",
	folderName .. "/UponTheHillv2.mp3"
)

local TEA_TIME = getOrDownloadAsset(
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/TeaTimeWaltzLobby.mp3",
	folderName .. "/TeaTimeWaltzLobby.mp3"
)

local SONGS = {
	LOBBY_V1,
	LOBBY_V2,
	TEA_TIME
}

local endedConnection

local function setupAlternatingLobbyMus(lobbyMus)
	if endedConnection then
		endedConnection:Disconnect()
	end

	local currentIndex = math.random(#SONGS)

	local function playCurrent()
		lobbyMus:Stop()
		lobbyMus.Looped = false
		lobbyMus.SoundId = SONGS[currentIndex]
		lobbyMus.TimePosition = 0
		lobbyMus.Volume = 1
		lobbyMus.PlaybackSpeed = 1
		task.wait()
		lobbyMus:Play()
	end

	endedConnection = lobbyMus.Ended:Connect(function()
		currentIndex = currentIndex % #SONGS + 1
		playCurrent()
	end)

	playCurrent()
end

task.spawn(function()
	local lobby = workspace:WaitForChild("Lobby")
	local lobbyMus = lobby:WaitForChild("LobbyMus")

	if lobbyMus:IsA("Sound") then
		setupAlternatingLobbyMus(lobbyMus)
	end
end)