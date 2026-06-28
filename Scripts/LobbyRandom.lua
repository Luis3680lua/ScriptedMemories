local Players = game:GetService("Players")

-- Enlaces raw de tus audios en tu repositorio
local SONGS = {
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv1.mp3",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv2.mp3",
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/TeaTimeWaltzLobby.mp3"
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
		-- Asignamos directamente la URL raw del archivo de audio
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