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
		description = "Reproduce todas las canciones del lobby.",
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png",
		duration = "∞"
	},
	random_favorites = {
		name = "Aleatorio (Favoritos)",
		credits = "Scripted Memories",
		description = "Reproduce solo tus canciones favoritas.",
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png",
		duration = "∞"
	}
}

local SONG_ORDER = {"tea_time_waltz", "upon_the_hill_v1", "upon_the_hill_v2", "random", "random_favorites"}

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

local function getRandomIndexFromList(list)
	if #list == 0 then return nil end
	if #list == 1 then return list[1] end
	local idx
	repeat
		idx = list[random(#list)]
	until idx ~= lastIndex
	lastIndex = idx
	return idx
end

local function getRandomIndex()
	local cachedIds = {}
	for id, _ in pairs(SONGS_CACHED) do
		insert(cachedIds, id)
	end
	return getRandomIndexFromList(cachedIds)
end

local function getFavoriteIndex()
	local favs = Menu.Settings.lobby_favorites or {}
	local available = {}
	for _, id in ipairs(favs) do
		if SONGS_CACHED[id] then
			insert(available, id)
		end
	end
	return getRandomIndexFromList(available)
end

local function stopRandom()
	if endedConnection then
		endedConnection:Disconnect()
		endedConnection = nil
	end
end

local function startRandom(mode)
	stopRandom()
	if not lobbyMus then return end
	lobbyMus.Looped = false
	local function playNext()
		local id
		if mode == "random_favorites" then
			id = getFavoriteIndex()
		else
			id = getRandomIndex()
		end
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
		startRandom("random")
	elseif songId == "random_favorites" then
		startRandom("random_favorites")
	elseif SONGS_CACHED[songId] then
		lobbyMus.SoundId = SONGS_CACHED[songId]
		lobbyMus.Looped = true
		lobbyMus.TimePosition = 0
		lobbyMus:Play()
	else
		startRandom("random")
	end
end

local function applyMuteSetting(muted)
	if lobbyMus then
		lobbyMus.Volume = muted and 0 or 1
	end
end

local savedMuted = Menu.Settings.lobby_muted or false
local savedSong = Menu.Settings.lobby_song or "upon_the_hill_v1"
if not Menu.Settings.lobby_favorites then
	Menu.Settings.lobby_favorites = {}
end
applyMuteSetting(savedMuted)
applySongSetting(savedSong)

-- ====================== VISTA PRINCIPAL ======================
local mainView = Instance.new("Frame")
mainView.Size = UDim2.new(1, 0, 1, 0)
mainView.BackgroundTransparency = 1
mainView.Visible = true
mainView.Parent = page.Frame

-- Título y descripción
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 28)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(245, 245, 250)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "🎵 Lobby"
title.Parent = mainView

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
description.Parent = mainView

local divider1 = Instance.new("Frame")
divider1.Size = UDim2.new(1, -12, 0, 1)
divider1.BorderSizePixel = 0
divider1.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
divider1.Parent = mainView

local sectionMute = Instance.new("TextLabel")
sectionMute.Size = UDim2.new(1, -12, 0, 22)
sectionMute.BackgroundTransparency = 1
sectionMute.Font = Enum.Font.GothamBold
sectionMute.TextSize = 15
sectionMute.TextColor3 = Color3.fromRGB(235, 235, 240)
sectionMute.TextXAlignment = Enum.TextXAlignment.Left
sectionMute.Text = "🔇 Silencio"
sectionMute.Parent = mainView

-- Interruptor de silencio
local muteFrame = Instance.new("Frame")
muteFrame.Size = UDim2.new(1, -12, 0, 50)
muteFrame.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
muteFrame.BackgroundTransparency = 0.3
muteFrame.BorderSizePixel = 0
local muteCorner = Instance.new("UICorner")
muteCorner.CornerRadius = UDim.new(0, 6)
muteCorner.Parent = muteFrame
muteFrame.Parent = mainView

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
divider2.Parent = mainView

local sectionSong = Instance.new("TextLabel")
sectionSong.Size = UDim2.new(1, -12, 0, 22)
sectionSong.BackgroundTransparency = 1
sectionSong.Font = Enum.Font.GothamBold
sectionSong.TextSize = 15
sectionSong.TextColor3 = Color3.fromRGB(235, 235, 240)
sectionSong.TextXAlignment = Enum.TextXAlignment.Left
sectionSong.Text = "🎶 Canción del lobby"
sectionSong.Parent = mainView

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
songBtn.Parent = mainView

local songInfoLabel = Instance.new("TextLabel")
songInfoLabel.Size = UDim2.new(1, -12, 0, 20)
songInfoLabel.BackgroundTransparency = 1
songInfoLabel.Font = Enum.Font.Gotham
songInfoLabel.TextSize = 12
songInfoLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
songInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
songInfoLabel.Text = (SONGS_DATA[savedSong] and SONGS_DATA[savedSong].duration and "Duración: " .. SONGS_DATA[savedSong].duration) or ""
songInfoLabel.Parent = mainView

songBtn.MouseEnter:Connect(function()
	TweenService:Create(songBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(55, 55, 66)}):Play()
end)
songBtn.MouseLeave:Connect(function()
	TweenService:Create(songBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(42, 42, 50)}):Play()
end)

-- ====================== VISTA DE SELECCIÓN ======================
local selectView = Instance.new("Frame")
selectView.Size = UDim2.new(1, 0, 1, 0)
selectView.BackgroundTransparency = 1
selectView.Visible = false
selectView.Parent = page.Frame

local backBtn = Instance.new("TextButton")
backBtn.Size = UDim2.new(0, 100, 0, 32)
backBtn.Position = UDim2.new(0, 0, 0, 0)
backBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
backBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
backBtn.Font = Enum.Font.GothamBold
backBtn.TextSize = 14
backBtn.BorderSizePixel = 0
backBtn.Text = "← Volver"
backBtn.AutoButtonColor = false
local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 6)
backCorner.Parent = backBtn
backBtn.Parent = selectView

local acceptBtn = Instance.new("TextButton")
acceptBtn.Size = UDim2.new(0, 120, 0, 32)
acceptBtn.Position = UDim2.new(1, -120, 0, 0)
acceptBtn.BackgroundColor3 = Color3.fromRGB(70, 210, 110)
acceptBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
acceptBtn.Font = Enum.Font.GothamBold
acceptBtn.TextSize = 14
acceptBtn.BorderSizePixel = 0
acceptBtn.Text = "Aceptar"
acceptBtn.AutoButtonColor = false
local acceptCorner = Instance.new("UICorner")
acceptCorner.CornerRadius = UDim.new(0, 6)
acceptCorner.Parent = acceptBtn
acceptBtn.Parent = selectView

-- Lista de canciones
local cardsFrame = Instance.new("ScrollingFrame")
cardsFrame.Size = UDim2.new(1, 0, 1, -42)
cardsFrame.Position = UDim2.new(0, 0, 0, 38)
cardsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
cardsFrame.BackgroundTransparency = 0.4
cardsFrame.BorderSizePixel = 0
cardsFrame.ScrollBarThickness = 4
cardsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
cardsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
local cardsCorner = Instance.new("UICorner")
cardsCorner.CornerRadius = UDim.new(0, 6)
cardsCorner.Parent = cardsFrame
cardsFrame.Parent = selectView

local cardsLayout = Instance.new("UIListLayout")
cardsLayout.Padding = UDim.new(0, 8)
cardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
cardsLayout.Parent = cardsFrame

local pendingSong = savedSong  -- variable local para la selección pendiente
local selectedCard = nil

local function clearCardHighlights()
	for _, card in ipairs(cardsFrame:GetChildren()) do
		if card:IsA("Frame") and card.Name == "SongCard" then
			card.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
			local border = card:FindFirstChild("SelectBorder")
			if border then
				border.Visible = false
			end
		end
	end
end

local function highlightCard(card)
	clearCardHighlights()
	card.BackgroundColor3 = Color3.fromRGB(65, 70, 85)
	local border = card:FindFirstChild("SelectBorder")
	if border then
		border.Visible = true
	end
	selectedCard = card
	pendingSong = card.SongId
end

local function toggleFavorite(songId)
	local favs = Menu.Settings.lobby_favorites or {}
	local found = false
	for i, id in ipairs(favs) do
		if id == songId then
			table.remove(favs, i)
			found = true
			break
		end
	end
	if not found then
		table.insert(favs, songId)
	end
	Menu.Settings.lobby_favorites = favs
	if Menu.SaveSettings then Menu.SaveSettings() end
	updateFavoriteHearts()
end

local function updateFavoriteHearts()
	for _, card in ipairs(cardsFrame:GetChildren()) do
		if card:IsA("Frame") and card.Name == "SongCard" then
			local heart = card:FindFirstChild("HeartBtn")
			if heart then
				local favs = Menu.Settings.lobby_favorites or {}
				local isFav = false
				for _, id in ipairs(favs) do
					if id == card.SongId then
						isFav = true
						break
					end
				end
				heart.Text = isFav and "❤️" or "🤍"
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

	-- Borde de selección
	local border = Instance.new("Frame")
	border.Name = "SelectBorder"
	border.Size = UDim2.new(1, 0, 1, 0)
	border.BackgroundTransparency = 1
	border.BorderSizePixel = 2
	border.BorderColor3 = Color3.fromRGB(90, 170, 255)
	border.Visible = false
	border.ZIndex = 0
	border.Parent = card

	local img = Instance.new("ImageLabel")
	img.Size = UDim2.new(0, 70, 0, 70)
	img.Position = UDim2.new(0, 8, 0, 10)
	img.BackgroundTransparency = 1
	img.Image = CACHED_IMAGES[id] or ""
	img.ScaleType = Enum.ScaleType.Crop
	img.Parent = card

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 180, 0, 22)
	nameLabel.Position = UDim2.new(0, 86, 0, 6)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.Text = data.name
	nameLabel.Parent = card

	local creditsLabel = Instance.new("TextLabel")
	creditsLabel.Size = UDim2.new(0, 180, 0, 16)
	creditsLabel.Position = UDim2.new(0, 86, 0, 28)
	creditsLabel.BackgroundTransparency = 1
	creditsLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
	creditsLabel.Font = Enum.Font.Gotham
	creditsLabel.TextSize = 11
	creditsLabel.Text = "Por " .. data.credits
	creditsLabel.Parent = card

	local durationLabel = Instance.new("TextLabel")
	durationLabel.Size = UDim2.new(0, 180, 0, 16)
	durationLabel.Position = UDim2.new(0, 86, 0, 44)
	durationLabel.BackgroundTransparency = 1
	durationLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
	durationLabel.Font = Enum.Font.Gotham
	durationLabel.TextSize = 10
	durationLabel.Text = data.duration and "Duración " .. data.duration or ""
	durationLabel.Parent = card

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0, 180, 0, 16)
	descLabel.Position = UDim2.new(0, 86, 0, 60)
	descLabel.BackgroundTransparency = 1
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 10
	descLabel.Text = data.description
	descLabel.TextWrapped = true
	descLabel.Parent = card

	-- Corazón de favorito
	local heartBtn = Instance.new("TextButton")
	heartBtn.Name = "HeartBtn"
	heartBtn.Size = UDim2.new(0, 30, 0, 30)
	heartBtn.Position = UDim2.new(1, -36, 0, 4)
	heartBtn.BackgroundTransparency = 1
	heartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	heartBtn.Font = Enum.Font.Gotham
	heartBtn.TextSize = 18
	heartBtn.Text = "🤍"
	heartBtn.ZIndex = 3
	heartBtn.Parent = card

	heartBtn.MouseButton1Click:Connect(function()
		toggleFavorite(id)
	end)

	card.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			highlightCard(card)
		end
	end)

	card.Parent = cardsFrame
	return card
end

-- Construir tarjetas
for _, id in ipairs(SONG_ORDER) do
	createSongCard(id, SONGS_DATA[id])
end

updateFavoriteHearts()

-- Resaltar la canción actual al entrar
local function updateSelectionHighlight()
	for _, card in ipairs(cardsFrame:GetChildren()) do
		if card:IsA("Frame") and card.Name == "SongCard" and card.SongId == pendingSong then
			highlightCard(card)
			break
		end
	end
end

-- Botones de la vista de selección
backBtn.MouseButton1Click:Connect(function()
	-- Volver sin guardar
	selectView.Visible = false
	mainView.Visible = true
	pendingSong = savedSong  -- restaurar
	if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

acceptBtn.MouseButton1Click:Connect(function()
	-- Guardar selección
	Menu.Settings.lobby_song = pendingSong
	savedSong = pendingSong
	if Menu.SaveSettings then Menu.SaveSettings() end
	applySongSetting(savedSong)
	songBtn.Text = "🎵 " .. (SONGS_DATA[savedSong] and SONGS_DATA[savedSong].name or "Aleatorio") .. " ▼"
	if SONGS_DATA[savedSong] and SONGS_DATA[savedSong].duration then
		songInfoLabel.Text = "Duración: " .. SONGS_DATA[savedSong].duration
	else
		songInfoLabel.Text = ""
	end
	selectView.Visible = false
	mainView.Visible = true
	if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

songBtn.MouseButton1Click:Connect(function()
	-- Abrir vista de selección
	mainView.Visible = false
	selectView.Visible = true
	pendingSong = savedSong  -- empezar con la actual
	clearCardHighlights()
	updateSelectionHighlight()
	updateFavoriteHearts()
	cardsFrame.CanvasSize = UDim2.new(0, 0, 0, cardsLayout.AbsoluteContentSize.Y + 15)
	if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

-- Cerrar vista de selección al cambiar de pestaña
page.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
	if not page.Frame.Visible then
		selectView.Visible = false
		mainView.Visible = true
	end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end