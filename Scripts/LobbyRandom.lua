local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HttpGet = game.HttpGet
local random = math.random
local insert = table.insert

local SONGS_URLS = {
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv1.mp3",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv2.mp3",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/TeaTimeWaltzLobby.mp3"
}

local FOLDER = ".cache"
if makefolder and isfolder and not isfolder(FOLDER) then
	pcall(makefolder, FOLDER)
end

local function getOrDownloadAsset(url, filename)
	if isfile and getcustomasset and isfile(filename) then
		return getcustomasset(filename)
	end
	if writefile and getcustomasset then
		local ok, data = pcall(HttpGet, game, url)
		if ok and data then
			writefile(filename, data)
			return getcustomasset(filename)
		end
	end
	return nil
end

local SONGS_CACHED = {}
for i = 1, #SONGS_URLS do
	local url = SONGS_URLS[i]
	local name = url:match("([^/]+)%.mp3$")
	local asset = getOrDownloadAsset(url, FOLDER .. "/" .. name .. ".mp3")
	if asset then
		insert(SONGS_CACHED, asset)
	end
end
if #SONGS_CACHED == 0 then return end

local masterGroup
pcall(function()
	local clientAssets = ReplicatedStorage:WaitForChild("ClientAssets", 10)
	local sounds = clientAssets:WaitForChild("Sounds", 10)
	masterGroup = sounds:WaitForChild("musg", 10)
end)

local endedConnection
local lastIndex = 0

local function getRandomIndex()
	if #SONGS_CACHED == 1 then
		return 1
	end
	local idx
	repeat
		idx = random(#SONGS_CACHED)
	until idx ~= lastIndex
	lastIndex = idx
	return idx
end

local function setupAlternatingLobbyMus(lobbyMus)
	if endedConnection then
		endedConnection:Disconnect()
	end
	if masterGroup then
		lobbyMus.SoundGroup = masterGroup
	end
	lobbyMus.Looped = false

	local function playNext()
		lobbyMus.SoundId = SONGS_CACHED[getRandomIndex()]
		lobbyMus.TimePosition = 0
		lobbyMus:Play()
	end

	endedConnection = lobbyMus.Ended:Connect(playNext)
	playNext()
end

local lobby = workspace:WaitForChild("Lobby", 15)
if not lobby then return end

local lobbyMus = lobby:WaitForChild("LobbyMus", 15)
if lobbyMus and lobbyMus:IsA("Sound") then
	setupAlternatingLobbyMus(lobbyMus)
end