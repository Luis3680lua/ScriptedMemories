local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage("Lobby", "🎵")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
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
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png",
		duration = "3:41"
	},
	upon_the_hill_v1 = {
		name = "Upon The Hill v1",
		credits = "Desconocido",
		description = "Placeholder description for v1.",
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png",
		duration = "2:58"
	},
	upon_the_hill_v2 = {
		name = "Upon The Hill v2",
		credits = "Desconocido",
		description = "Placeholder description for v2.",
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png",
		duration = "3:12"
	},
	random = {
		name = "Aleatorio",
		credits = "Scripted Memories",
		description = "Reproduce canciones aleatorias del lobby.",
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png",
		duration = "∞"
	}
}

local SONG_ORDER = {"tea_time_waltz", "upon_the_hill_v1", "upon_the_hill_v2", "random"}

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

-- Título y descripción
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 28)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(245, 245, 250)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "🎵 Lobby"
title.Parent = page.Frame

local description = Instance.new("TextLabel")
description.Size = UDim2.new(1, -12, 0, 42)
description.BackgroundTransparency = 1
description.Font = Enum.Font.Gotham
description.TextSize = 13
description.TextWrapped = true
description.TextColor3 = Color3.fromRGB(180, 180, 195)
description.TextXAlignment = Enum.TextXAlignment.Left
description.TextYAlignment = Enum.TextYAlignment.Top
description.Text = "Personaliza la música del lobby. Selecciona una canción específica o deja que Scripted Memories elija una aleatoriamente."
description.Parent = page.Frame

local divider1 = Instance.new("Frame")
divider1.Size = UDim2.new(1, -12, 0, 1)
divider1.BorderSizePixel = 0
divider1.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
divider1.Parent = page.Frame

local sectionMute = Instance.new("TextLabel")
sectionMute.Size = UDim2.new(1, -12, 0, 22)
sectionMute.BackgroundTransparency = 1
sectionMute.Font = Enum.Font.GothamBold
sectionMute.TextSize = 15
sectionMute.TextColor3 = Color3.fromRGB(235, 235, 240)
sectionMute.TextXAlignment = Enum.TextXAlignment.Left
sectionMute.Text = "🔇 Silencio"
sectionMute.Parent = page.Frame

-- Interruptor de silencio
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

local divider2 = Instance.new("Frame")
divider2.Size = UDim2.new(1, -12, 0, 1)
divider2.BorderSizePixel = 0
divider2.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
divider2.Parent = page.Frame

local sectionSong = Instance.new("TextLabel")
sectionSong.Size = UDim2.new(1, -12, 0, 22)
sectionSong.BackgroundTransparency = 1
sectionSong.Font = Enum.Font.GothamBold
sectionSong.TextSize = 15
sectionSong.TextColor3 = Color3.fromRGB(235, 235, 240)
sectionSong.TextXAlignment = Enum.TextXAlignment.Left
sectionSong.Text = "🎶 Canción del lobby"
sectionSong.Parent = page.Frame

-- Botón de canción actual
local songBtn = Instance.new("TextButton")
songBtn.Size = UDim2.new(1, -12, 0, 52)
songBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
songBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
songBtn.Font = Enum.Font.GothamBold
songBtn.TextSize = 14
songBtn.BorderSizePixel = 0
songBtn.Text = "🎵 " .. (SONGS_DATA[savedSong] and SONGS_DATA[savedSong].name or "Aleatorio") .. " ▼"
songBtn.AutoButtonColor = false
local songBtnCorner = Instance.new("UICorner")
songBtnCorner.CornerRadius = UDim.new(0, 6)
songBtnCorner.Parent = songBtn
songBtn.Parent = page.Frame

local songInfoLabel = Instance.new("TextLabel")
songInfoLabel.Size = UDim2.new(1, -12, 0, 20)
songInfoLabel.BackgroundTransparency = 1
songInfoLabel.Font = Enum.Font.Gotham
songInfoLabel.TextSize = 12
songInfoLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
songInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
songInfoLabel.Text = (SONGS_DATA[savedSong] and SONGS_DATA[savedSong].duration and "Duración: " .. SONGS_DATA[savedSong].duration) or ""
songInfoLabel.Parent = page.Frame

-- Hover del botón de canción
songBtn.MouseEnter:Connect(function()
	TweenService:Create(songBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(55, 55, 66)}):Play()
end)
songBtn.MouseLeave:Connect(function()
	TweenService:Create(songBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(42, 42, 50)}):Play()
end)

-- Ventana modal para seleccionar canción
local MainFrame = page.Frame.Parent.Parent  -- ScreenGui -> MainFrame
local selectorFrame = Instance.new("Frame")
selectorFrame.Size = UDim2.new(0, 500, 0, 380)
selectorFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
selectorFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
selectorFrame.BorderSizePixel = 0
selectorFrame.Visible = false
selectorFrame.ZIndex = 50
selectorFrame.Active = true
selectorFrame.Selectable = false
local selectorCorner = Instance.new("UICorner")
selectorCorner.CornerRadius = UDim.new(0, 10)
selectorCorner.Parent = selectorFrame
selectorFrame.Parent = MainFrame

-- Top bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 60)
topBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
topBar.BorderSizePixel = 0
local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 10)
topBarCorner.Parent = topBar
topBar.Parent = selectorFrame

local selTitle = Instance.new("TextLabel")
selTitle.Size = UDim2.new(1, -20, 0, 24)
selTitle.Position = UDim2.new(0, 10, 0, 8)
selTitle.BackgroundTransparency = 1
selTitle.TextColor3 = Color3.fromRGB(245, 245, 250)
selTitle.Font = Enum.Font.GothamBold
selTitle.TextSize = 18
selTitle.Text = "🎵 Lobby Music"
selTitle.Parent = topBar

local selDesc = Instance.new("TextLabel")
selDesc.Size = UDim2.new(1, -20, 0, 18)
selDesc.Position = UDim2.new(0, 10, 0, 32)
selDesc.BackgroundTransparency = 1
selDesc.TextColor3 = Color3.fromRGB(180, 180, 195)
selDesc.Font = Enum.Font.Gotham
selDesc.TextSize = 12
selDesc.Text = "Escoge la música que deseas escuchar."
selDesc.Parent = topBar

local line = Instance.new("Frame")
line.Size = UDim2.new(1, -20, 0, 2)
line.Position = UDim2.new(0, 10, 0, 58)
line.BackgroundColor3 = Color3.fromRGB(90, 170, 255)
line.BorderSizePixel = 0
line.Parent = topBar

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

-- Lista de canciones
local cardsFrame = Instance.new("ScrollingFrame")
cardsFrame.Size = UDim2.new(1, -20, 0, 300)
cardsFrame.Position = UDim2.new(0, 10, 0, 70)
cardsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
cardsFrame.BackgroundTransparency = 0.4
cardsFrame.BorderSizePixel = 0
cardsFrame.ScrollBarThickness = 4
cardsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
cardsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
cardsFrame.Selectable = false
local cardsCorner = Instance.new("UICorner")
cardsCorner.CornerRadius = UDim.new(0, 6)
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
				if card.SongId == currentSongId then
					btn.Text = "✓ Seleccionada"
					btn.BackgroundColor3 = Color3.fromRGB(70, 210, 110)
				else
					btn.Text = "Usar"
					btn.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
				end
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
	card.Selectable = false
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
	nameLabel.Size = UDim2.new(0, 220, 0, 22)
	nameLabel.Position = UDim2.new(0, 86, 0, 6)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.Text = data.name
	nameLabel.Parent = card

	local creditsLabel = Instance.new("TextLabel")
	creditsLabel.Size = UDim2.new(0, 220, 0, 16)
	creditsLabel.Position = UDim2.new(0, 86, 0, 28)
	creditsLabel.BackgroundTransparency = 1
	creditsLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
	creditsLabel.Font = Enum.Font.Gotham
	creditsLabel.TextSize = 11
	creditsLabel.Text = "Por " .. data.credits
	creditsLabel.Parent = card

	local durationLabel = Instance.new("TextLabel")
	durationLabel.Size = UDim2.new(0, 220, 0, 16)
	durationLabel.Position = UDim2.new(0, 86, 0, 44)
	durationLabel.BackgroundTransparency = 1
	durationLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
	durationLabel.Font = Enum.Font.Gotham
	durationLabel.TextSize = 10
	durationLabel.Text = data.duration and "Duración " .. data.duration or ""
	durationLabel.Parent = card

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0, 220, 0, 16)
	descLabel.Position = UDim2.new(0, 86, 0, 60)
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
	selectBtn.ZIndex = 2
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = selectBtn
	selectBtn.Parent = card

	selectBtn.MouseButton1Click:Connect(function()
		Menu.Settings.lobby_song = id
		if Menu.SaveSettings then Menu.SaveSettings() end
		applySongSetting(id)
		songBtn.Text = "🎵 " .. (SONGS_DATA[id] and SONGS_DATA[id].name or "Aleatorio") .. " ▼"
		if SONGS_DATA[id] and SONGS_DATA[id].duration then
			songInfoLabel.Text = "Duración: " .. SONGS_DATA[id].duration
		else
			songInfoLabel.Text = ""
		end
		selectorFrame.Visible = false
		updateSongEntries(id)
		if Menu.UpdateCanvas then Menu.UpdateCanvas() end
	end)

	card.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(65, 65, 75)}):Play()
	end)
	card.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}):Play()
	end)

	card.Parent = cardsFrame
	return card
end

for _, id in ipairs(SONG_ORDER) do
	createSongCard(id, SONGS_DATA[id])
end

updateSongEntries(savedSong)
cardsFrame.CanvasSize = UDim2.new(0, 0, 0, cardsLayout.AbsoluteContentSize.Y + 15)

songBtn.MouseButton1Click:Connect(function()
	selectorFrame.Visible = not selectorFrame.Visible
	if selectorFrame.Visible then
		updateSongEntries(Menu.Settings.lobby_song or "upon_the_hill_v1")
		cardsFrame.CanvasSize = UDim2.new(0, 0, 0, cardsLayout.AbsoluteContentSize.Y + 15)
	end
	if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

-- Cerrar modal al cambiar de pestaña
page.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
	if not page.Frame.Visible and selectorFrame.Visible then
		selectorFrame.Visible = false
	end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end