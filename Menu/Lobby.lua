local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage("Lobby", "🎵")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpGet = game.HttpGet
local random = math.random
local insert = table.insert
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

local SONGS_URLS = {
	upon_the_hill_v1 = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv1.mp3",
	upon_the_hill_v2 = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/UponTheHillv2.mp3",
	tea_time_waltz  = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/TeaTimeWaltzLobby.mp3"
}

local SONGS_DATA = {
	tea_time_waltz = {
		name = "Tea Time Waltz",
		credits = "Desconocido",
		description = "Placeholder description for Tea Time Waltz.",
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
	random = {
		name = "Aleatorio",
		credits = "Scripted Memories",
		description = "Reproduce canciones aleatorias del lobby.",
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png"
	}
}

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

local CACHED_IMAGES = {}
for id, data in pairs(SONGS_DATA) do
	local imgUrl = data.image
	local imgName = imgUrl:match("([^/]+)$")
	if imgName then
		CACHED_IMAGES[id] = getOrDownloadAsset(imgUrl, FOLDER .. "/img_" .. imgName)
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
	if #cachedIds == 1 then return cachedIds[1] end
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
local savedSong = Menu.Settings.lobby_song or "upon_the_hill_v1"
applyMuteSetting(savedMuted)
applySongSetting(savedSong)

-- Mute toggle switch
local muteFrame = Instance.new("Frame")
muteFrame.Size = UDim2.new(1, -12, 0, 50)
muteFrame.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
muteFrame.BackgroundTransparency = 0.3
muteFrame.BorderSizePixel = 0
local muteCorner = Instance.new("UICorner")
muteCorner.CornerRadius = UDim.new(0, 6)
muteCorner.Parent = muteFrame
muteFrame.Parent = page.Frame

local muteLabel = Instance.new("TextLabel")
muteLabel.Size = UDim2.new(0, 120, 0, 26)
muteLabel.Position = UDim2.new(0, 12, 0, 12)
muteLabel.BackgroundTransparency = 1
muteLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
muteLabel.Font = Enum.Font.Gotham
muteLabel.TextSize = 14
muteLabel.Text = "Silenciar lobby"
muteLabel.Parent = muteFrame

local muteSwitchBg = Instance.new("Frame")
muteSwitchBg.Size = UDim2.new(0, 44, 0, 22)
muteSwitchBg.Position = UDim2.new(1, -56, 0, 14)
muteSwitchBg.BackgroundColor3 = savedMuted and Color3.fromRGB(220, 80, 80) or Color3.fromRGB(70, 210, 110)
muteSwitchBg.BorderSizePixel = 0
local switchCorner = Instance.new("UICorner")
switchCorner.CornerRadius = UDim.new(1, 0)
switchCorner.Parent = muteSwitchBg
muteSwitchBg.Parent = muteFrame

local muteKnob = Instance.new("Frame")
muteKnob.Size = UDim2.new(0, 18, 0, 18)
muteKnob.Position = savedMuted and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
muteKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
muteKnob.BorderSizePixel = 0
local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = muteKnob
muteKnob.Parent = muteSwitchBg

local function updateMuteSwitch(muted)
	muteSwitchBg.BackgroundColor3 = muted and Color3.fromRGB(220, 80, 80) or Color3.fromRGB(70, 210, 110)
	local targetX = muted and 24 or 2
	muteKnob:TweenPosition(UDim2.new(0, targetX, 0, 2), "Out", "Quad", 0.2, true)
end

muteSwitchBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local newMuted = not (Menu.Settings.lobby_muted or false)
		Menu.Settings.lobby_muted = newMuted
		applyMuteSetting(newMuted)
		updateMuteSwitch(newMuted)
		if Menu.SaveSettings then Menu.SaveSettings() end
	end
end)

-- Song selection button
local songBtn = Instance.new("TextButton")
songBtn.Size = UDim2.new(1, -12, 0, 52)
songBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
songBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
songBtn.Font = Enum.Font.GothamBold
songBtn.TextSize = 14
songBtn.BorderSizePixel = 0
songBtn.Text = "🎵 Canción seleccionada\n" .. (SONGS_DATA[savedSong] and SONGS_DATA[savedSong].name or "Aleatorio") .. " ▼"
songBtn.TextWrapped = true
songBtn.AutoButtonColor = false
local songBtnCorner = Instance.new("UICorner")
songBtnCorner.CornerRadius = UDim.new(0, 6)
songBtnCorner.Parent = songBtn
songBtn.Parent = page.Frame

-- Selector catalog (popup)
local selectorFrame = Instance.new("Frame")
selectorFrame.Size = UDim2.new(1, -12, 0, 0)
selectorFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
selectorFrame.BackgroundTransparency = 0.15
selectorFrame.BorderSizePixel = 0
selectorFrame.Visible = false
selectorFrame.AutomaticSize = Enum.AutomaticSize.Y
local selectorCorner = Instance.new("UICorner")
selectorCorner.CornerRadius = UDim.new(0, 6)
selectorCorner.Parent = selectorFrame
selectorFrame.Parent = page.Frame

page.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
	if not page.Frame.Visible then
		selectorFrame.Visible = false
	end
end)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
topBar.BorderSizePixel = 0
local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 6)
topBarCorner.Parent = topBar
topBar.Parent = selectorFrame

local selTitle = Instance.new("TextLabel")
selTitle.Size = UDim2.new(1, -48, 1, 0)
selTitle.Position = UDim2.new(0, 12, 0, 0)
selTitle.BackgroundTransparency = 1
selTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
selTitle.Font = Enum.Font.GothamBold
selTitle.TextSize = 16
selTitle.Text = "Elige una canción"
selTitle.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -36, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Text = "✕"
closeBtn.Parent = topBar
closeBtn.MouseButton1Click:Connect(function()
	selectorFrame.Visible = false
	if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

local cardsFrame = Instance.new("ScrollingFrame")
cardsFrame.Size = UDim2.new(1, -24, 0, 320)
cardsFrame.Position = UDim2.new(0, 12, 0, 44)
cardsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
cardsFrame.BackgroundTransparency = 0.5
cardsFrame.BorderSizePixel = 0
cardsFrame.ScrollBarThickness = 4
cardsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
cardsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
local cardsCorner = Instance.new("UICorner")
cardsCorner.CornerRadius = UDim.new(0, 4)
cardsCorner.Parent = cardsFrame
cardsFrame.Parent = selectorFrame

local cardsLayout = Instance.new("UIListLayout")
cardsLayout.Padding = UDim.new(0, 8)
cardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
cardsLayout.Parent = cardsFrame

local function updateSongEntries(currentSongId)
	for _, card in ipairs(cardsFrame:GetChildren()) do
		if card:IsA("Frame") and card.Name == "SongCard" then
			local btn = card:FindFirstChild("SelectBtn")
			if btn then
				btn.Text = (card.SongId == currentSongId) and "Seleccionada ✓" or "Usar"
				btn.BackgroundColor3 = (card.SongId == currentSongId) and Color3.fromRGB(70, 210, 110) or Color3.fromRGB(70, 150, 255)
			end
		end
	end
end

local function createSongCard(id, data)
	local card = Instance.new("Frame")
	card.Name = "SongCard"
	card.Size = UDim2.new(1, 0, 0, 90)
	card.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
	card.BorderSizePixel = 0
	card.SongId = id
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = card

	local img = Instance.new("ImageLabel")
	img.Size = UDim2.new(0, 70, 0, 70)
	img.Position = UDim2.new(0, 8, 0, 10)
	img.BackgroundTransparency = 1
	img.Image = CACHED_IMAGES[id] or ""
	img.ScaleType = Enum.ScaleType.Crop
	img.Parent = card

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 160, 0, 22)
	nameLabel.Position = UDim2.new(0, 86, 0, 6)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.Text = data.name
	nameLabel.Parent = card

	local creditsLabel = Instance.new("TextLabel")
	creditsLabel.Size = UDim2.new(0, 160, 0, 16)
	creditsLabel.Position = UDim2.new(0, 86, 0, 28)
	creditsLabel.BackgroundTransparency = 1
	creditsLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
	creditsLabel.Font = Enum.Font.Gotham
	creditsLabel.TextSize = 11
	creditsLabel.Text = data.credits
	creditsLabel.Parent = card

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0, 160, 0, 20)
	descLabel.Position = UDim2.new(0, 86, 0, 46)
	descLabel.BackgroundTransparency = 1
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 10
	descLabel.Text = data.description
	descLabel.TextWrapped = true
	descLabel.Parent = card

	local selectBtn = Instance.new("TextButton")
	selectBtn.Name = "SelectBtn"
	selectBtn.Size = UDim2.new(0, 110, 0, 32)
	selectBtn.Position = UDim2.new(1, -120, 0.5, -16)
	selectBtn.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
	selectBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
	selectBtn.Font = Enum.Font.GothamBold
	selectBtn.TextSize = 14
	selectBtn.BorderSizePixel = 0
	selectBtn.Text = "Usar"
	selectBtn.AutoButtonColor = false
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = selectBtn
	selectBtn.Parent = card

	selectBtn.MouseButton1Click:Connect(function()
		Menu.Settings.lobby_song = id
		if Menu.SaveSettings then Menu.SaveSettings() end
		applySongSetting(id)
		songBtn.Text = "🎵 Canción seleccionada\n" .. (SONGS_DATA[id] and SONGS_DATA[id].name or "Aleatorio") .. " ▼"
		selectorFrame.Visible = false
		updateSongEntries(id)
		if Menu.UpdateCanvas then Menu.UpdateCanvas() end
	end)

	card.Parent = cardsFrame
	return card
end

for id, data in pairs(SONGS_DATA) do
	createSongCard(id, data)
end

updateSongEntries(savedSong)
cardsFrame.CanvasSize = UDim2.new(0, 0, 0, cardsLayout.AbsoluteContentSize.Y + 16)

songBtn.MouseButton1Click:Connect(function()
	selectorFrame.Visible = not selectorFrame.Visible
	updateSongEntries(Menu.Settings.lobby_song or "upon_the_hill_v1")
	if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end