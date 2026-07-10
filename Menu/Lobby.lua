local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage("Lobby", "🎵")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpGet = game.HttpGet
local random = math.random
local insert = table.insert

local SONGS_URLS = {
	["upon_the_hill_v1"] = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv1.mp3",
	["upon_the_hill_v2"] = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv2.mp3",
	["tea_time_waltz"] = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/TeaTimeWaltzLobby.mp3"
}

local SONGS_DATA = {
	random = {
		name = "Aleatorio",
		credits = "Scripted Memories",
		description = "Reproduce canciones aleatorias del lobby.",
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png"
	},
	upon_the_hill_v1 = {
		name = "Upon The Hill v1",
		credits = "Desconocido",
		description = "Placeholder description for v1.",
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png"
	},
	upon_the_hill_v2 = {
		name = "Upon The Hill v2",
		credits = "Desconocido",
		description = "Placeholder description for v2.",
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png"
	},
	tea_time_waltz = {
		name = "Tea Time Waltz",
		credits = "Desconocido",
		description = "Placeholder description for Tea Time Waltz.",
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png"
	}
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
for id, url in pairs(SONGS_URLS) do
	local name = url:match("([^/]+)%.mp3$")
	if name then
		local asset = getOrDownloadAsset(url, FOLDER .. "/" .. name .. ".mp3")
		if asset then
			SONGS_CACHED[id] = asset
		end
	end
end

local lobby = workspace:WaitForChild("Lobby", 15)
local lobbyMus = lobby and lobby:WaitForChild("LobbyMus", 15)
if not lobbyMus or not lobbyMus:IsA("Sound") then
	lobbyMus = nil
end

local masterGroup
pcall(function()
	local clientAssets = ReplicatedStorage:WaitForChild("ClientAssets", 10)
	local sounds = clientAssets:WaitForChild("Sounds", 10)
	masterGroup = sounds:WaitForChild("musg", 10)
end)

local endedConnection
local lastIndex = 0

local function getRandomIndex()
	local cachedIds = {}
	for id, _ in pairs(SONGS_CACHED) do
		insert(cachedIds, id)
	end
	if #cachedIds == 0 then return nil end
	if #cachedIds == 1 then
		return cachedIds[1]
	end
	local idx
	repeat
		idx = cachedIds[random(#cachedIds)]
	until idx ~= lastIndex
	lastIndex = idx
	return idx
end

local function stopRandom()
	if endedConnection then
		endedConnection:Disconnect()
		endedConnection = nil
	end
end

local function startRandom()
	stopRandom()
	if not lobbyMus then return end
	lobbyMus.Looped = false
	local function playNext()
		local id = getRandomIndex()
		if id and SONGS_CACHED[id] then
			lobbyMus.SoundId = SONGS_CACHED[id]
			lobbyMus.TimePosition = 0
			lobbyMus:Play()
		end
	end
	endedConnection = lobbyMus.Ended:Connect(playNext)
	playNext()
end

local function applySongSetting(songId)
	if not lobbyMus then return end
	stopRandom()
	if songId == "random" then
		startRandom()
	elseif SONGS_CACHED[songId] then
		lobbyMus.SoundId = SONGS_CACHED[songId]
		lobbyMus.Looped = true
		lobbyMus.TimePosition = 0
		lobbyMus:Play()
	else
		startRandom()
	end
end

local function applyMuteSetting(muted)
	if lobbyMus then
		lobbyMus.Volume = muted and 0 or 1
	end
end

local savedMuted = Menu.Settings.lobby_muted or false
local savedSong = Menu.Settings.lobby_song or "random"
applyMuteSetting(savedMuted)
applySongSetting(savedSong)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -12, 0, 30)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Text = "Lobby"
titleLabel.Parent = page.Frame

local muteContainer = Instance.new("Frame")
muteContainer.Size = UDim2.new(1, -12, 0, 60)
muteContainer.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
muteContainer.BackgroundTransparency = 0.3
muteContainer.BorderSizePixel = 0
local muteCorner = Instance.new("UICorner")
muteCorner.CornerRadius = UDim.new(0, 4)
muteCorner.Parent = muteContainer
muteContainer.Parent = page.Frame

local muteLabel = Instance.new("TextLabel")
muteLabel.Size = UDim2.new(0.7, 0, 1, 0)
muteLabel.Position = UDim2.new(0, 8, 0, 0)
muteLabel.BackgroundTransparency = 1
muteLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
muteLabel.Font = Enum.Font.Gotham
muteLabel.TextSize = 14
muteLabel.Text = "Silenciar lobby"
muteLabel.Parent = muteContainer

local muteDesc = Instance.new("TextLabel")
muteDesc.Size = UDim2.new(1, -16, 0, 20)
muteDesc.Position = UDim2.new(0, 8, 0, 28)
muteDesc.BackgroundTransparency = 1
muteDesc.TextColor3 = Color3.fromRGB(180, 180, 195)
muteDesc.Font = Enum.Font.Gotham
muteDesc.TextSize = 12
muteDesc.Text = "Silencia completamente la música del lobby."
muteDesc.Parent = muteContainer

local muteBtn = Instance.new("TextButton")
muteBtn.Size = UDim2.new(0, 60, 0, 28)
muteBtn.Position = UDim2.new(0.8, 0, 0.5, -14)
muteBtn.BackgroundColor3 = savedMuted and Color3.fromRGB(220, 80, 80) or Color3.fromRGB(70, 210, 110)
muteBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
muteBtn.Font = Enum.Font.GothamBold
muteBtn.TextSize = 13
muteBtn.BorderSizePixel = 0
muteBtn.Text = savedMuted and "OFF" or "ON"
muteBtn.AutoButtonColor = false
local muteBtnCorner = Instance.new("UICorner")
muteBtnCorner.CornerRadius = UDim.new(0, 4)
muteBtnCorner.Parent = muteBtn
muteBtn.Parent = muteContainer

muteBtn.MouseButton1Click:Connect(function()
	local newMuted = not Menu.Settings.lobby_muted
	Menu.Settings.lobby_muted = newMuted
	muteBtn.Text = newMuted and "OFF" or "ON"
	muteBtn.BackgroundColor3 = newMuted and Color3.fromRGB(220, 80, 80) or Color3.fromRGB(70, 210, 110)
	applyMuteSetting(newMuted)
	if Menu.SaveSettings then
		Menu.SaveSettings()
	end
end)

local songBtn = Instance.new("TextButton")
songBtn.Size = UDim2.new(1, -12, 0, 40)
songBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
songBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
songBtn.Font = Enum.Font.GothamBold
songBtn.TextSize = 14
songBtn.BorderSizePixel = 0
songBtn.Text = "Canción: " .. (SONGS_DATA[savedSong] and SONGS_DATA[savedSong].name or "Aleatorio")
songBtn.AutoButtonColor = false
local songBtnCorner = Instance.new("UICorner")
songBtnCorner.CornerRadius = UDim.new(0, 4)
songBtnCorner.Parent = songBtn
songBtn.Parent = page.Frame

local selectorFrame = Instance.new("Frame")
selectorFrame.Size = UDim2.new(1, -12, 0, 0)
selectorFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
selectorFrame.BackgroundTransparency = 0.2
selectorFrame.BorderSizePixel = 0
selectorFrame.Visible = false
selectorFrame.AutomaticSize = Enum.AutomaticSize.Y
local selectorCorner = Instance.new("UICorner")
selectorCorner.CornerRadius = UDim.new(0, 6)
selectorCorner.Parent = selectorFrame
selectorFrame.Parent = page.Frame

local selectorTitle = Instance.new("TextLabel")
selectorTitle.Size = UDim2.new(1, -24, 0, 30)
selectorTitle.Position = UDim2.new(0, 12, 0, 6)
selectorTitle.BackgroundTransparency = 1
selectorTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
selectorTitle.Font = Enum.Font.GothamBold
selectorTitle.TextSize = 16
selectorTitle.Text = "Seleccionar Canción"
selectorTitle.Parent = selectorFrame

local songList = Instance.new("ScrollingFrame")
songList.Size = UDim2.new(1, -24, 0, 200)
songList.Position = UDim2.new(0, 12, 0, 40)
songList.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
songList.BorderSizePixel = 0
songList.ScrollBarThickness = 4
songList.CanvasSize = UDim2.new(0, 0, 0, 0)
songList.ScrollingDirection = Enum.ScrollingDirection.Y
songList.Parent = selectorFrame

local songListLayout = Instance.new("UIListLayout")
songListLayout.Padding = UDim.new(0, 8)
songListLayout.SortOrder = Enum.SortOrder.LayoutOrder
songListLayout.Parent = songList

local songEntries = {}

local function createSongEntry(songId, data)
	local entry = Instance.new("Frame")
	entry.Size = UDim2.new(1, 0, 0, 80)
	entry.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
	entry.BorderSizePixel = 0
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = entry

	local img = Instance.new("ImageLabel")
	img.Size = UDim2.new(0, 60, 0, 60)
	img.Position = UDim2.new(0, 8, 0.5, -30)
	img.BackgroundTransparency = 1
	img.Image = data.image or "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png"
	img.ScaleType = Enum.ScaleType.Crop
	img.Parent = entry

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 150, 0, 20)
	nameLabel.Position = UDim2.new(0, 76, 0, 6)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.Text = data.name
	nameLabel.Parent = entry

	local creditsLabel = Instance.new("TextLabel")
	creditsLabel.Size = UDim2.new(0, 150, 0, 16)
	creditsLabel.Position = UDim2.new(0, 76, 0, 26)
	creditsLabel.BackgroundTransparency = 1
	creditsLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
	creditsLabel.Font = Enum.Font.Gotham
	creditsLabel.TextSize = 11
	creditsLabel.Text = "Créditos: " .. data.credits
	creditsLabel.Parent = entry

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0, 150, 0, 20)
	descLabel.Position = UDim2.new(0, 76, 0, 46)
	descLabel.BackgroundTransparency = 1
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 10
	descLabel.Text = data.description or ""
	descLabel.TextWrapped = true
	descLabel.Parent = entry

	local selectBtn = Instance.new("TextButton")
	selectBtn.Size = UDim2.new(0, 100, 0, 30)
	selectBtn.Position = UDim2.new(1, -108, 0.5, -15)
	selectBtn.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
	selectBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
	selectBtn.Font = Enum.Font.GothamBold
	selectBtn.TextSize = 13
	selectBtn.BorderSizePixel = 0
	selectBtn.Text = "Seleccionar"
	selectBtn.AutoButtonColor = false
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = selectBtn
	selectBtn.Parent = entry

	selectBtn.MouseButton1Click:Connect(function()
		Menu.Settings.lobby_song = songId
		if Menu.SaveSettings then
			Menu.SaveSettings()
		end
		applySongSetting(songId)
		songBtn.Text = "Canción: " .. (SONGS_DATA[songId] and SONGS_DATA[songId].name or "Aleatorio")
		selectorFrame.Visible = false
		if Menu.UpdateCanvas then
			Menu.UpdateCanvas()
		end
	end)

	table.insert(songEntries, entry)
	entry.Parent = songList
end

for id, data in pairs(SONGS_DATA) do
	createSongEntry(id, data)
end

songList.CanvasSize = UDim2.new(0, 0, 0, songListLayout.AbsoluteContentSize.Y + 16)

local backBtn = Instance.new("TextButton")
backBtn.Size = UDim2.new(0, 100, 0, 30)
backBtn.Position = UDim2.new(0.5, -50, 1, 10)
backBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
backBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
backBtn.Font = Enum.Font.GothamBold
backBtn.TextSize = 14
backBtn.BorderSizePixel = 0
backBtn.Text = "Volver"
backBtn.AutoButtonColor = false
local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 4)
backCorner.Parent = backBtn
backBtn.Parent = selectorFrame

backBtn.MouseButton1Click:Connect(function()
	selectorFrame.Visible = false
	if Menu.UpdateCanvas then
		Menu.UpdateCanvas()
	end
end)

songBtn.MouseButton1Click:Connect(function()
	local wasVisible = selectorFrame.Visible
	selectorFrame.Visible = not wasVisible
	if Menu.UpdateCanvas then
		Menu.UpdateCanvas()
	end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end