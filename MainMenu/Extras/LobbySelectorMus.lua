local Menu = _G.Menu
if not Menu then return end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpGet = game.HttpGet
local random = math.random
local insert = table.insert
local FOLDER = "ScriptedMemories/cache"

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
		name = "Tea Time Waltz (Lobby-Ver.)",
		credits = "Juno!",
		description = "Se reemplazó debido a que funcionaba únicamente como un placeholder en el prototipo.",
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/Images/TeaTimeWaltz.png",
		duration = "3:41"
	},
	upon_the_hill_v1 = {
		name = "Upon The Hill",
		credits = "ThatGuyNamedPanther",
		description = "Actualmente la canción del lobby debido a la polémica con CosmicCoffee.",
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/Images/Hillv1.png",
		duration = "2:58"
	},
	upon_the_hill_v2 = {
		name = "Upon The Hill v2",
		credits = "ThatGuyNamedPanther & CosmicCoffee",
		description = "Se descartó debido a la salida de ThatGuyNamedPanther en ese momento.",
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Lobby/Images/Hillv2.png",
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
	},
	random_select = {
		name = "Aleatorio (Selección)",
		credits = "Scripted Memories",
		description = "Reproduce solo las canciones que elijas.",
		image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png",
		duration = "∞"
	}
}

local SONG_ORDER = {"tea_time_waltz", "upon_the_hill_v1", "upon_the_hill_v2", "random", "random_favorites", "random_select"}

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

if lobbyMus and masterGroup then
	lobbyMus.SoundGroup = masterGroup
end

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

local function getSelectIndex()
	local sel = Menu.Settings.lobby_random_select_list or {}
	local available = {}
	for _, id in ipairs(sel) do
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
		elseif mode == "random_select" then
			id = getSelectIndex()
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
	elseif songId == "random_select" then
		startRandom("random_select")
	elseif SONGS_CACHED[songId] then
		lobbyMus.SoundId = SONGS_CACHED[songId]
		lobbyMus.Looped = true
		lobbyMus.TimePosition = 0
		lobbyMus:Play()
	else
		startRandom("random")
	end
end

local savedSong = Menu.Settings.lobby_song or "upon_the_hill_v1"
if not Menu.Settings.lobby_favorites then
	Menu.Settings.lobby_favorites = {}
end
if not Menu.Settings.lobby_random_select_list then
	Menu.Settings.lobby_random_select_list = {}
end
applySongSetting(savedSong)

local page = Menu.Pages[#Menu.Pages]
if not page then return end

local T = {
	Bg = Color3.fromRGB(20, 20, 25),
	Secondary = Color3.fromRGB(30, 30, 38),
	Tertiary = Color3.fromRGB(42, 42, 50),
	Hover = Color3.fromRGB(55, 55, 65),
	Text = Color3.fromRGB(240, 240, 245),
	TextDim = Color3.fromRGB(180, 180, 195),
	Accent = Color3.fromRGB(70, 150, 255),
	Green = Color3.fromRGB(70, 210, 110),
	Red = Color3.fromRGB(220, 80, 80),
	Border = Color3.fromRGB(60, 60, 75),
	Font = Enum.Font.Gotham,
	FontBold = Enum.Font.GothamBold,
}

local function roundFrame(frame, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = frame
end

local mainContainer = page.Frame:FindFirstChildWhichIsA("Frame") or page.Frame

local songSectionFrame = Instance.new("Frame")
songSectionFrame.Size = UDim2.new(1, 0, 0, 0)
songSectionFrame.BackgroundColor3 = T.Tertiary
songSectionFrame.BackgroundTransparency = 0.3
songSectionFrame.BorderSizePixel = 0
songSectionFrame.AutomaticSize = Enum.AutomaticSize.Y
roundFrame(songSectionFrame, 6)
songSectionFrame.Parent = mainContainer

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.Parent = songSectionFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = songSectionFrame

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 22)
header.BackgroundTransparency = 1
header.Font = T.FontBold
header.TextSize = 15
header.TextColor3 = T.Text
header.TextXAlignment = Enum.TextXAlignment.Left
header.Text = "🎶 Canción del lobby"
header.Parent = songSectionFrame

local songBtn = Instance.new("TextButton")
songBtn.Size = UDim2.new(1, 0, 0, 52)
songBtn.BackgroundColor3 = T.Tertiary
songBtn.TextColor3 = T.Text
songBtn.Font = T.FontBold
songBtn.TextSize = 14
songBtn.BorderSizePixel = 0
songBtn.Text = "🎵 " .. (SONGS_DATA[savedSong] and SONGS_DATA[savedSong].name or "Aleatorio") .. " ▼"
songBtn.AutoButtonColor = false
roundFrame(songBtn, 6)
songBtn.Parent = songSectionFrame

local songInfoLabel = Instance.new("TextLabel")
songInfoLabel.Size = UDim2.new(1, 0, 0, 20)
songInfoLabel.BackgroundTransparency = 1
songInfoLabel.Font = T.Font
songInfoLabel.TextSize = 12
songInfoLabel.TextColor3 = T.TextDim
songInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
songInfoLabel.Text = ""
songInfoLabel.Parent = songSectionFrame

songBtn.MouseEnter:Connect(function()
	TweenService:Create(songBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play()
end)
songBtn.MouseLeave:Connect(function()
	TweenService:Create(songBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Tertiary}):Play()
end)

local selectView = Instance.new("Frame")
selectView.Size = UDim2.new(1, 0, 0, 0)
selectView.BackgroundTransparency = 1
selectView.Visible = false
selectView.AutomaticSize = Enum.AutomaticSize.Y
selectView.Parent = songSectionFrame

local selectList = Instance.new("UIListLayout")
selectList.Padding = UDim.new(0, 8)
selectList.SortOrder = Enum.SortOrder.LayoutOrder
selectList.Parent = selectView

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.BackgroundTransparency = 1
topBar.Parent = selectView

local backBtn = Instance.new("TextButton")
backBtn.Size = UDim2.new(0, 100, 0, 32)
backBtn.Position = UDim2.new(0, 0, 0, 0)
backBtn.BackgroundColor3 = T.Tertiary
backBtn.TextColor3 = T.Text
backBtn.Font = T.FontBold
backBtn.TextSize = 14
backBtn.BorderSizePixel = 0
backBtn.Text = "← Volver"
backBtn.AutoButtonColor = false
roundFrame(backBtn, 6)
backBtn.Parent = topBar

local acceptBtn = Instance.new("TextButton")
acceptBtn.Size = UDim2.new(0, 120, 0, 32)
acceptBtn.Position = UDim2.new(1, -120, 0, 0)
acceptBtn.BackgroundColor3 = T.Green
acceptBtn.TextColor3 = T.Text
acceptBtn.Font = T.FontBold
acceptBtn.TextSize = 14
acceptBtn.BorderSizePixel = 0
acceptBtn.Text = "Aceptar"
acceptBtn.AutoButtonColor = false
roundFrame(acceptBtn, 6)
acceptBtn.Parent = topBar

local sectionHeader = Instance.new("TextLabel")
sectionHeader.Size = UDim2.new(1, 0, 0, 22)
sectionHeader.BackgroundTransparency = 1
sectionHeader.Font = T.FontBold
sectionHeader.TextSize = 15
sectionHeader.TextColor3 = T.Text
sectionHeader.TextXAlignment = Enum.TextXAlignment.Left
sectionHeader.Text = "🎧 OST"
sectionHeader.Parent = selectView

local cardsContainer = Instance.new("Frame")
cardsContainer.Size = UDim2.new(1, 0, 0, 0)
cardsContainer.BackgroundTransparency = 1
cardsContainer.AutomaticSize = Enum.AutomaticSize.Y
cardsContainer.Parent = selectView

local cardsLayout = Instance.new("UIListLayout")
cardsLayout.Padding = UDim.new(0, 8)
cardsLayout.SortOrder = Enum.SortOrder.LayoutOrder
cardsLayout.Parent = cardsContainer

local pendingSong = savedSong
local selectedCard = nil
local selectedSongs = {}

local function clearCardHighlights()
	for _, card in ipairs(cardsContainer:GetChildren()) do
		if card:IsA("Frame") and card.Name == "SongCard" then
			card.BackgroundColor3 = T.Tertiary
			local stroke = card:FindFirstChild("SelectBorder")
			if stroke then stroke.Enabled = false end
		end
	end
end

local function highlightCard(card)
	clearCardHighlights()
	card.BackgroundColor3 = Color3.fromRGB(65, 70, 85)
	local stroke = card:FindFirstChild("SelectBorder")
	if stroke then stroke.Enabled = true end
	selectedCard = card
	pendingSong = card:GetAttribute("SongId")
end

local function updateFavoriteHearts()
	for _, card in ipairs(cardsContainer:GetChildren()) do
		if card:IsA("Frame") and card.Name == "SongCard" then
			local heart = card:FindFirstChild("HeartBtn")
			if heart then
				local favs = Menu.Settings.lobby_favorites or {}
				local isFav = false
				for _, id in ipairs(favs) do
					if id == card:GetAttribute("SongId") then
						isFav = true
						break
					end
				end
				heart.Text = isFav and "❤️" or "🤍"
			end
		end
	end
end

local function updateSelectCheckboxes()
	for _, card in ipairs(cardsContainer:GetChildren()) do
		if card:IsA("Frame") and card.Name == "SongCard" then
			local checkbox = card:FindFirstChild("SelectCheck")
			if checkbox then
				local id = card:GetAttribute("SongId")
				if id == "random" or id == "random_favorites" or id == "random_select" then
					checkbox.Visible = false
				else
					checkbox.Visible = (pendingSong == "random_select")
					if checkbox.Visible then
						checkbox.Text = selectedSongs[id] and "✅" or "⬜"
					end
				end
			end
		end
	end
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

local function createSongCard(id, data)
	local card = Instance.new("Frame")
	card.Name = "SongCard"
	card.Size = UDim2.new(1, 0, 0, 0)
	card.BackgroundColor3 = T.Tertiary
	card.BorderSizePixel = 0
	card.AutomaticSize = Enum.AutomaticSize.Y
	card:SetAttribute("SongId", id)
	roundFrame(card, 6)

	local stroke = Instance.new("UIStroke")
	stroke.Name = "SelectBorder"
	stroke.Color = T.Accent
	stroke.Thickness = 2
	stroke.Enabled = false
	stroke.Parent = card

	local clickButton = Instance.new("TextButton")
	clickButton.Size = UDim2.new(1, 0, 1, 0)
	clickButton.BackgroundTransparency = 1
	clickButton.Text = ""
	clickButton.BorderSizePixel = 0
	clickButton.ZIndex = 2
	clickButton.Parent = card

	local img = Instance.new("ImageLabel")
	img.Size = UDim2.new(0, 70, 0, 70)
	img.Position = UDim2.new(0, 8, 0, 10)
	img.BackgroundTransparency = 1
	img.Image = CACHED_IMAGES[id] or ""
	img.ScaleType = Enum.ScaleType.Crop
	img.ZIndex = 3
	img.Parent = card

	local textContainer = Instance.new("Frame")
	textContainer.Size = UDim2.new(1, -136, 1, -20)
	textContainer.Position = UDim2.new(0, 86, 0, 10)
	textContainer.BackgroundTransparency = 1
	textContainer.ZIndex = 3
	textContainer.Parent = card

	local textList = Instance.new("UIListLayout")
	textList.Padding = UDim.new(0, 2)
	textList.SortOrder = Enum.SortOrder.LayoutOrder
	textList.Parent = textContainer

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 22)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = T.Text
	nameLabel.Font = T.FontBold
	nameLabel.TextSize = 16
	nameLabel.Text = data.name
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 3
	nameLabel.Parent = textContainer

	local creditsLabel = Instance.new("TextLabel")
	creditsLabel.Size = UDim2.new(1, 0, 0, 18)
	creditsLabel.BackgroundTransparency = 1
	creditsLabel.TextColor3 = T.TextDim
	creditsLabel.Font = T.Font
	creditsLabel.TextSize = 12
	creditsLabel.Text = "Por " .. data.credits
	creditsLabel.TextXAlignment = Enum.TextXAlignment.Left
	creditsLabel.ZIndex = 3
	creditsLabel.Parent = textContainer

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, 0, 0, 0)
	descLabel.BackgroundTransparency = 1
	descLabel.TextColor3 = T.TextDim
	descLabel.Font = T.Font
	descLabel.TextSize = 11
	descLabel.Text = data.description
	descLabel.TextWrapped = true
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.AutomaticSize = Enum.AutomaticSize.Y
	descLabel.ZIndex = 3
	descLabel.Parent = textContainer

	if id ~= "random" and id ~= "random_favorites" and id ~= "random_select" then
		local heartBtn = Instance.new("TextButton")
		heartBtn.Name = "HeartBtn"
		heartBtn.Size = UDim2.new(0, 30, 0, 30)
		heartBtn.Position = UDim2.new(1, -46, 0, 4)
		heartBtn.BackgroundTransparency = 1
		heartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		heartBtn.Font = T.Font
		heartBtn.TextSize = 18
		heartBtn.Text = "🤍"
		heartBtn.ZIndex = 4
		heartBtn.Parent = card

		heartBtn.MouseButton1Click:Connect(function()
			toggleFavorite(id)
		end)

		local selectCheck = Instance.new("TextButton")
		selectCheck.Name = "SelectCheck"
		selectCheck.Size = UDim2.new(0, 30, 0, 30)
		selectCheck.Position = UDim2.new(1, -82, 0, 4)
		selectCheck.BackgroundTransparency = 1
		selectCheck.TextColor3 = Color3.fromRGB(255, 255, 255)
		selectCheck.Font = T.Font
		selectCheck.TextSize = 18
		selectCheck.Text = "⬜"
		selectCheck.ZIndex = 4
		selectCheck.Visible = false
		selectCheck.Parent = card

		selectCheck.MouseButton1Click:Connect(function()
			if pendingSong == "random_select" then
				local songId = card:GetAttribute("SongId")
				selectedSongs[songId] = not selectedSongs[songId]
				selectCheck.Text = selectedSongs[songId] and "✅" or "⬜"
			end
		end)
	end

	clickButton.MouseButton1Click:Connect(function()
		highlightCard(card)
		updateSelectCheckboxes()
		if card:GetAttribute("SongId") ~= "random_select" then
			pendingSong = card:GetAttribute("SongId")
		else
			pendingSong = "random_select"
		end
	end)

	card.Parent = cardsContainer
	return card
end

for _, id in ipairs(SONG_ORDER) do
	createSongCard(id, SONGS_DATA[id])
end
updateFavoriteHearts()
selectedSongs = {}
local savedSelectList = Menu.Settings.lobby_random_select_list or {}
for _, id in ipairs(savedSelectList) do
	selectedSongs[id] = true
end
updateSelectCheckboxes()

local function updateSelectionHighlight()
	for _, card in ipairs(cardsContainer:GetChildren()) do
		if card:IsA("Frame") and card.Name == "SongCard" and card:GetAttribute("SongId") == pendingSong then
			highlightCard(card)
			break
		end
	end
end

backBtn.MouseButton1Click:Connect(function()
	selectView.Visible = false
	pendingSong = savedSong
	if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

acceptBtn.MouseButton1Click:Connect(function()
	Menu.Settings.lobby_song = pendingSong
	savedSong = pendingSong
	if savedSong == "random_select" then
		local newList = {}
		for id, checked in pairs(selectedSongs) do
			if checked then
				table.insert(newList, id)
			end
		end
		Menu.Settings.lobby_random_select_list = newList
	else
		Menu.Settings.lobby_random_select_list = {}
	end
	if Menu.SaveSettings then Menu.SaveSettings() end
	applySongSetting(savedSong)
	songBtn.Text = "🎵 " .. (SONGS_DATA[savedSong] and SONGS_DATA[savedSong].name or "Aleatorio") .. " ▼"
	selectView.Visible = false
	if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

songBtn.MouseButton1Click:Connect(function()
	selectView.Visible = true
	pendingSong = savedSong
	selectedSongs = {}
	local savedSelectList = Menu.Settings.lobby_random_select_list or {}
	for _, id in ipairs(savedSelectList) do
		selectedSongs[id] = true
	end
	clearCardHighlights()
	updateSelectionHighlight()
	updateFavoriteHearts()
	updateSelectCheckboxes()
	if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end