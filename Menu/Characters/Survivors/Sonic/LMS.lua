if _G.SonicMusicInitialized then
	_G.OpenSonicPicker()
	return
end
if _G.SonicSongs then
	_G.SonicSongs = nil
	_G.SonicMusicInitialized = nil
end

repeat task.wait() until _G.MemoryMenu

local FOLDER = ".cache"
if makefolder and not isfolder(FOLDER) then
	makefolder(FOLDER)
end

local getAsset = getsynasset or getcustomasset or function() end

local songs = {
	{
		name = "Break Free",
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/BreakFree.mp3",
		file = "BreakFree.mp3",
		endTime = 260.97,
		credits = "Créditos: ThatGuyRamon cantado por Rob Lundgren",
		imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/BreakFree.png",
		imageFile = "BreakFree.png",
		section = "Official"
	},
	{
		name = "Speed of Sound Round 2",
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound2.mp3",
		file = "SpeedOfSoundRound2.mp3",
		endTime = 211.46,
		credits = "Créditos: ThatGuyNamedPanther junto con Kookiemusicc, mezclado y masterizado por Kadatonical, con lineas de voz de ExpresslyVOs",
		imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/SpeedOfSoundRound2.png",
		imageFile = "SpeedOfSoundRound2.png",
		section = "Official"
	},
	{
		name = "Don't Blink",
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/DontBlink.mp3",
		file = "DontBlink.mp3",
		endTime = 245.94,
		credits = "Créditos: Astranova junto con ThatGuyNamedPanther cantado por Johnny Gioeli",
		imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/DontBlink.png",
		imageFile = "DontBlink.png",
		section = "Official"
	},
	{
		name = "Speed of Sound Round 1",
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound1.mp3",
		file = "SpeedOfSoundRound1.mp3",
		endTime = 289,
		credits = "Créditos: Placeholder Round1",
		imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/SpeedOfSoundRound1.png",
		imageFile = "SpeedOfSoundRound1.png",
		section = "SinUsar"
	},
	{
		name = "Speed of Sound Round 2 (Bonus Mix)",
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound2BonusMix.mp3",
		file = "SpeedOfSoundRound2BonusMix.mp3",
		endTime = 289,
		credits = "Créditos: Placeholder BonusMix",
		imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/SpeedOfSoundRound2BonusMix.png",
		imageFile = "SpeedOfSoundRound2BonusMix.png",
		section = "SinUsar"
	},
	{
		name = "Don't Blink (Old Lyrics)",
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/DontBlinkOLD.mp3",
		file = "DontBlinkOLD.mp3",
		endTime = 289,
		credits = "Créditos: Placeholder Old Lyrics",
		imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/DontBlinkOld.png",
		imageFile = "DontBlinkOld.png",
		section = "SinUsar"
	},
	{
		name = "So, Don't Blink",
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SoDontBlink.mp3",
		file = "SoDontBlink.mp3",
		endTime = 289,
		credits = "Créditos: Placeholder SoDontBlink",
		imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/SoDontBlink.png",
		imageFile = "SoDontBlink.png",
		section = "SinUsar"
	}
}

_G.SonicSongs = songs

local SECTION_ORDER = {
	Official = 1,
	Fanmade = 2,
	Remixes = 3,
	Beta = 4,
	Unused = 5
}

local function getSectionOrder(sectionName)
	return SECTION_ORDER[sectionName] or math.huge
end

local sections = {}
for _, song in ipairs(songs) do
	local sec = song.section
	if not sections[sec] then
		sections[sec] = {}
	end
	table.insert(sections[sec], song)
end

local sortedSectionNames = {}
for secName in pairs(sections) do
	table.insert(sortedSectionNames, secName)
end
table.sort(sortedSectionNames, function(a, b)
	local orderA = getSectionOrder(a)
	local orderB = getSectionOrder(b)
	if orderA == orderB then
		return a < b
	end
	return orderA < orderB
end)

local songIndexToInfo = {}
local sectionSongCount = {}
for _, secName in ipairs(sortedSectionNames) do
	local list = sections[secName]
	sectionSongCount[secName] = #list
	for _, song in ipairs(list) do
		table.insert(songIndexToInfo, { song = song, section = secName })
	end
end
local totalSongs = #songIndexToInfo

local imageCache = {}
local function getImageAsset(imageUrl, imageFile)
	local path = FOLDER .. "/" .. imageFile
	if imageCache[path] then
		return imageCache[path]
	end

	if isfile(path) then
		local ok, asset = pcall(function()
			return getAsset(path)
		end)
		if ok and asset then
			imageCache[path] = asset
			return asset
		end
		pcall(function() delfile(path) end)
	end

	local ok, data = pcall(game.HttpGet, game, imageUrl .. "?t=" .. tick())
	if not ok or not data or #data <= 100 then
		return nil
	end
	writefile(path, data)

	local ok2, asset = pcall(function()
		return getAsset(path)
	end)
	if ok2 and asset then
		imageCache[path] = asset
		return asset
	end
	return nil
end

for _, info in ipairs(songIndexToInfo) do
	local song = info.song
	song.cachedImage = getImageAsset(song.imageUrl, song.imageFile)
end

local settingsKey = "Sonic_SelectedSongIndex"
local randomModeKey = "Sonic_RandomMode"
local selectedSongIndex = _G.MemoryMenu.Settings[settingsKey] or 3
if selectedSongIndex < 1 or selectedSongIndex > totalSongs then
	selectedSongIndex = 3
end
local currentRandomMode = _G.MemoryMenu.Settings[randomModeKey] or "none"
local activeSongIndex = selectedSongIndex
local lastPlayedSongIndex = activeSongIndex

local pickerOpen = false
local pickerGui
local itemFrames = {}
local sectionHeaders = {}
local acceptButton
local randomSectionButton
local randomAllButton
local searchBox
local totalCountLabel
local lastSelectedFrame
local activeIndicator = {}

local saveDebounce = false
local function SaveSettings()
	if saveDebounce then return end
	saveDebounce = true
	task.delay(0.3, function()
		_G.MemoryMenu.SaveSettings()
		saveDebounce = false
	end)
end

local RS = game:GetService("ReplicatedStorage")
local GameProperties = workspace:FindFirstChild("GameProperties")
local stateValue = GameProperties and GameProperties:FindFirstChild("State")
local sonicSound
local currentMusicId
local isApplying = false
local isLmsActive = false

local function safelyApplyMusic(newId)
	if not newId or not sonicSound then return end
	isApplying = true
	currentMusicId = newId
	sonicSound.SoundId = newId
	sonicSound.Looped = (isLmsActive and currentRandomMode == "none")
	sonicSound.Volume = RS.ClientAssets.Sounds.musg.Volume
	isApplying = false
end

local function pickRandomFromSectionExcluding(sectionName, excludeIndex)
	local list = sections[sectionName]
	if not list or #list == 0 then return nil end
	local candidates = {}
	for idx, info in ipairs(songIndexToInfo) do
		if info.section == sectionName and idx ~= excludeIndex then
			table.insert(candidates, idx)
		end
	end
	if #candidates == 0 then
		local idx = pickRandomFromSection(sectionName)
		return idx
	end
	return candidates[math.random(#candidates)]
end

local function pickRandomFromAllExcluding(excludeIndex)
	if totalSongs <= 1 then return excludeIndex end
	local candidates = {}
	for idx = 1, totalSongs do
		if idx ~= excludeIndex then
			table.insert(candidates, idx)
		end
	end
	return candidates[math.random(#candidates)]
end

local function pickRandomFromSection(sectionName)
	local list = sections[sectionName]
	if not list or #list == 0 then return nil end
	local song = list[math.random(#list)]
	for idx, info in ipairs(songIndexToInfo) do
		if info.song == song then
			return idx
		end
	end
	return nil
end

local function pickRandomFromAll()
	if totalSongs == 0 then return nil end
	return math.random(totalSongs)
end

local function applyRandomSong(avoidLast)
	local newIdx
	if currentRandomMode == "section" then
		local activeSection = songIndexToInfo[activeSongIndex] and songIndexToInfo[activeSongIndex].section
		if activeSection then
			if avoidLast then
				newIdx = pickRandomFromSectionExcluding(activeSection, lastPlayedSongIndex)
			else
				newIdx = pickRandomFromSection(activeSection)
			end
		end
	elseif currentRandomMode == "all" then
		if avoidLast then
			newIdx = pickRandomFromAllExcluding(lastPlayedSongIndex)
		else
			newIdx = pickRandomFromAll()
		end
	end
	if newIdx then
		activeSongIndex = newIdx
		lastPlayedSongIndex = newIdx
		local song = songIndexToInfo[activeSongIndex].song
		if song and song.assetId and sonicSound then
			safelyApplyMusic(song.assetId)
		end
	end
end

_G.MusicApplyFunc = function(index)
	if not songIndexToInfo[index] then return end
	activeSongIndex = index
	lastPlayedSongIndex = index
	if sonicSound then
		safelyApplyMusic(songIndexToInfo[index].song.assetId)
	end
end

if _G.SonicConnections then
	for _, c in pairs(_G.SonicConnections) do
		pcall(function() c:Disconnect() end)
	end
	table.clear(_G.SonicConnections)
else
	_G.SonicConnections = {}
end

if not _G.SonicMusicInitialized then
	_G.SonicMusicInitialized = true

	task.spawn(function()
		local function downloadFile(url, filepath)
			if not isfile(filepath) then
				local ok, data = pcall(game.HttpGet, game, url)
				if ok and data then
					writefile(filepath, data)
					return true
				end
				return false
			end
			return true
		end

		local function getAssetPath(filepath)
			if getcustomasset then
				local ok, asset = pcall(getcustomasset, filepath)
				if ok and asset then
					return asset
				end
			end
			return nil
		end

		for _, info in ipairs(songIndexToInfo) do
			local song = info.song
			downloadFile(song.url, FOLDER .. "/" .. song.file)
			song.assetId = getAssetPath(FOLDER .. "/" .. song.file)
		end

		if not stateValue then return end

		local sonicSolo = RS:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("SoloTheme"):WaitForChild("SonicSolo")
		if sonicSolo and sonicSolo:IsA("Sound") then
			sonicSound = sonicSolo

			local initialSong = songIndexToInfo[activeSongIndex].song
			currentMusicId = initialSong.assetId
			isLmsActive = (stateValue.Value ~= "RE")
			sonicSound.Looped = (isLmsActive and currentRandomMode == "none")
			if currentMusicId then
				sonicSound.SoundId = currentMusicId
			end

			local conn1 = sonicSound:GetPropertyChangedSignal("SoundId"):Connect(function()
				if isApplying then return end
				if sonicSound.SoundId ~= currentMusicId then
					safelyApplyMusic(currentMusicId)
				end
			end)
			table.insert(_G.SonicConnections, conn1)

			local conn2 = RS.ClientAssets.Sounds.musg:GetPropertyChangedSignal("Volume"):Connect(function()
				if sonicSound then
					sonicSound.Volume = RS.ClientAssets.Sounds.musg.Volume
				end
			end)
			table.insert(_G.SonicConnections, conn2)

			local conn3 = sonicSound.Ended:Connect(function()
				if currentRandomMode ~= "none" and isLmsActive then
					applyRandomSong(true)
				end
			end)
			table.insert(_G.SonicConnections, conn3)
		end

		local conn4 = stateValue.Changed:Connect(function(value)
			if value == "RE" then
				if isLmsActive then
					isLmsActive = false
					if sonicSound then
						sonicSound.Looped = false
						local endTime = songIndexToInfo[activeSongIndex].song.endTime or 289
						if sonicSound.TimePosition > endTime then
							sonicSound.TimePosition = endTime
						end
					end
				end
			else
				if not isLmsActive then
					isLmsActive = true
					if sonicSound then
						sonicSound.Looped = (currentRandomMode == "none")
					end
					if currentRandomMode ~= "none" then
						applyRandomSong(true)
					end
				end
			end
		end)
		table.insert(_G.SonicConnections, conn4)

		if stateValue.Value ~= "RE" then
			isLmsActive = true
			if currentRandomMode ~= "none" then
				applyRandomSong(false)
			end
		end
	end)
end

local function highlightItem(index)
	if lastSelectedFrame and itemFrames[lastSelectedFrame] then
		local frame = itemFrames[lastSelectedFrame]
		frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		frame.BorderSizePixel = 0
	end

	local frame = itemFrames[index]
	if not frame then return end
	frame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	frame.BorderColor3 = Color3.fromRGB(0, 120, 255)
	frame.BorderSizePixel = 2

	lastSelectedFrame = index
	selectedSongIndex = index

	if acceptButton then
		acceptButton.Visible = (selectedSongIndex ~= activeSongIndex) or (currentRandomMode ~= "none")
	end
end

local function updateRandomButtonsState()
	if randomSectionButton then
		randomSectionButton.BackgroundColor3 = currentRandomMode == "section" and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(70, 70, 70)
	end
	if randomAllButton then
		randomAllButton.BackgroundColor3 = currentRandomMode == "all" and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(70, 70, 70)
	end
	if acceptButton then
		acceptButton.Visible = (selectedSongIndex ~= activeSongIndex) or (currentRandomMode ~= "none")
	end
end

local function closePicker()
	if pickerGui then
		pickerGui:Destroy()
		pickerGui = nil
	end
	pickerOpen = false
	lastSelectedFrame = nil
	table.clear(itemFrames)
	table.clear(sectionHeaders)
	table.clear(activeIndicator)
end

function _G.OpenSonicPicker()
	if pickerOpen then return end
	pickerOpen = true

	local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
	if pg then
		local old = pg:FindFirstChild("SonicPicker")
		if old then old:Destroy() end
	end

	pickerGui = Instance.new("ScreenGui")
	pickerGui.Name = "SonicPicker"
	pickerGui.ResetOnSpawn = false
	pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pickerGui.DisplayOrder = 100
	pickerGui.Parent = pg

	local background = Instance.new("Frame")
	background.Size = UDim2.new(1, 0, 1, 0)
	background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	background.BackgroundTransparency = 0.5
	background.Parent = pickerGui

	local pickerFrame = Instance.new("Frame")
	pickerFrame.Size = UDim2.new(0, 460, 0, 540)
	pickerFrame.Position = UDim2.new(0.5, -230, 0.5, -270)
	pickerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	pickerFrame.BorderSizePixel = 0
	pickerFrame.Parent = pickerGui

	local title = Instance.new("TextLabel")
	title.Text = "Last Man Standing - Sonic"
	title.Size = UDim2.new(1, 0, 0, 30)
	title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.Parent = pickerFrame

	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, -10, 0, 30)
	topBar.Position = UDim2.new(0, 5, 0, 35)
	topBar.BackgroundTransparency = 1
	topBar.Parent = pickerFrame

	searchBox = Instance.new("TextBox")
	searchBox.Size = UDim2.new(0, 200, 0, 26)
	searchBox.Position = UDim2.new(0, 0, 0, 2)
	searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	searchBox.TextColor3 = Color3.new(1, 1, 1)
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextSize = 14
	searchBox.PlaceholderText = "Buscar canción..."
	searchBox.Text = ""
	searchBox.Parent = topBar

	totalCountLabel = Instance.new("TextLabel")
	totalCountLabel.Size = UDim2.new(0, 200, 0, 26)
	totalCountLabel.Position = UDim2.new(1, -200, 0, 2)
	totalCountLabel.BackgroundTransparency = 1
	totalCountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	totalCountLabel.Font = Enum.Font.Gotham
	totalCountLabel.TextSize = 13
	totalCountLabel.TextXAlignment = Enum.TextXAlignment.Right
	totalCountLabel.Text = "Total: " .. totalSongs .. " canciones"
	totalCountLabel.Parent = topBar

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -10, 1, -140)
	scrollFrame.Position = UDim2.new(0, 5, 0, 70)
	scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 4
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.Parent = pickerFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 4)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scrollFrame

	table.clear(itemFrames)
	table.clear(sectionHeaders)
	table.clear(activeIndicator)

	local totalHeight = 0
	local itemIndex = 0

	for _, secName in ipairs(sortedSectionNames) do
		local songList = sections[secName]
		local sectionHeader = Instance.new("TextLabel")
		sectionHeader.Text = secName .. " (" .. #songList .. ")"
		sectionHeader.Size = UDim2.new(1, -10, 0, 24)
		sectionHeader.BackgroundTransparency = 1
		sectionHeader.TextColor3 = Color3.fromRGB(255, 255, 200)
		sectionHeader.Font = Enum.Font.GothamBold
		sectionHeader.TextSize = 15
		sectionHeader.TextXAlignment = Enum.TextXAlignment.Left
		sectionHeader.Parent = scrollFrame
		sectionHeaders[secName] = sectionHeader
		totalHeight = totalHeight + 28

		for _, song in ipairs(songList) do
			itemIndex = itemIndex + 1
			local currentIndex = itemIndex

			local itemFrame = Instance.new("Frame")
			itemFrame.Size = UDim2.new(1, -10, 0, 100)
			itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			itemFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			itemFrame.BorderSizePixel = 0
			itemFrame.Active = true
			itemFrame.Parent = scrollFrame

			local image = Instance.new("ImageLabel")
			image.Size = UDim2.new(0, 50, 0, 50)
			image.Position = UDim2.new(0, 5, 0.5, -25)
			image.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			image.Image = song.cachedImage or ""
			image.ScaleType = Enum.ScaleType.Fit
			image.Parent = itemFrame

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Text = song.name
			nameLabel.Size = UDim2.new(1, -120, 0, 20)
			nameLabel.Position = UDim2.new(0, 60, 0, 5)
			nameLabel.BackgroundTransparency = 1
			nameLabel.TextColor3 = Color3.new(1, 1, 1)
			nameLabel.Font = Enum.Font.Gotham
			nameLabel.TextSize = 14
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.Parent = itemFrame

			local creditsLabel = Instance.new("TextLabel")
			creditsLabel.Text = song.credits
			creditsLabel.Size = UDim2.new(1, -120, 0, 40)
			creditsLabel.Position = UDim2.new(0, 60, 0, 25)
			creditsLabel.BackgroundTransparency = 1
			creditsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			creditsLabel.Font = Enum.Font.Gotham
			creditsLabel.TextSize = 12
			creditsLabel.TextXAlignment = Enum.TextXAlignment.Left
			creditsLabel.TextYAlignment = Enum.TextYAlignment.Top
			creditsLabel.TextWrapped = true
			creditsLabel.Parent = itemFrame

			local activeIcon = Instance.new("ImageLabel")
			activeIcon.Size = UDim2.new(0, 20, 0, 20)
			activeIcon.Position = UDim2.new(1, -25, 0, 5)
			activeIcon.BackgroundTransparency = 1
			activeIcon.Image = "rbxassetid://10709665217"
			activeIcon.Visible = (currentIndex == activeSongIndex and currentRandomMode == "none")
			activeIcon.Parent = itemFrame
			activeIndicator[currentIndex] = activeIcon

			itemFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					highlightItem(currentIndex)
				end
			end)

			itemFrames[currentIndex] = itemFrame
			totalHeight = totalHeight + 104
		end
	end

	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)

	if itemFrames[activeSongIndex] then
		highlightItem(activeSongIndex)
		local targetFrame = itemFrames[activeSongIndex]
		local offset = targetFrame.AbsolutePosition.Y - scrollFrame.AbsolutePosition.Y
		scrollFrame.CanvasPosition = Vector2.new(0, math.max(0, offset - 100))
	end

	updateRandomButtonsState()

	local function applySearchFilter(searchText)
		local lower = searchText:lower()
		for _, secName in ipairs(sortedSectionNames) do
			local header = sectionHeaders[secName]
			local sectionVisible = false
			for idx, frame in pairs(itemFrames) do
				local info = songIndexToInfo[idx]
				if info and info.section == secName then
					local song = info.song
					local match = (lower == "" or song.name:lower():find(lower, 1, true))
					frame.Visible = match
					if match then
						sectionVisible = true
					end
				end
			end
			if header then
				header.Visible = sectionVisible
			end
		end
		local visibleCount = 0
		for _, frame in pairs(itemFrames) do
			if frame.Visible then visibleCount = visibleCount + 1 end
		end
		totalCountLabel.Text = "Mostrando: " .. visibleCount .. " / " .. totalSongs
	end

	searchBox.Changed:Connect(function(prop)
		if prop == "Text" then
			applySearchFilter(searchBox.Text)
		end
	end)
	applySearchFilter("")

	randomSectionButton = Instance.new("TextButton")
	randomSectionButton.Text = "Random Section"
	randomSectionButton.Size = UDim2.new(0, 130, 0, 28)
	randomSectionButton.Position = UDim2.new(0, 10, 1, -40)
	randomSectionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	randomSectionButton.TextColor3 = Color3.new(1, 1, 1)
	randomSectionButton.Font = Enum.Font.GothamBold
	randomSectionButton.TextSize = 13
	randomSectionButton.BorderSizePixel = 0
	randomSectionButton.Parent = pickerFrame

	randomSectionButton.MouseButton1Click:Connect(function()
		if currentRandomMode == "section" then
			applyRandomSong(true)
		else
			currentRandomMode = "section"
			_G.MemoryMenu.Settings[randomModeKey] = currentRandomMode
			SaveSettings()
			local activeSection = songIndexToInfo[activeSongIndex] and songIndexToInfo[activeSongIndex].section
			if activeSection then
				local idx = pickRandomFromSectionExcluding(activeSection, activeSongIndex)
				if not idx then idx = pickRandomFromSection(activeSection) end
				if idx then
					_G.MusicApplyFunc(idx)
					highlightItem(idx)
					selectedSongIndex = idx
				end
			end
		end
		updateRandomButtonsState()
		for i, icon in pairs(activeIndicator) do
			icon.Visible = (i == activeSongIndex and currentRandomMode == "none")
		end
		if acceptButton then acceptButton.Visible = false end
		if sonicSound then
			sonicSound.Looped = (isLmsActive and currentRandomMode == "none")
		end
	end)

	randomAllButton = Instance.new("TextButton")
	randomAllButton.Text = "Random All"
	randomAllButton.Size = UDim2.new(0, 130, 0, 28)
	randomAllButton.Position = UDim2.new(0, 150, 1, -40)
	randomAllButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	randomAllButton.TextColor3 = Color3.new(1, 1, 1)
	randomAllButton.Font = Enum.Font.GothamBold
	randomAllButton.TextSize = 13
	randomAllButton.BorderSizePixel = 0
	randomAllButton.Parent = pickerFrame

	randomAllButton.MouseButton1Click:Connect(function()
		if currentRandomMode == "all" then
			applyRandomSong(true)
		else
			currentRandomMode = "all"
			_G.MemoryMenu.Settings[randomModeKey] = currentRandomMode
			SaveSettings()
			local idx = pickRandomFromAllExcluding(activeSongIndex)
			if idx then
				_G.MusicApplyFunc(idx)
				highlightItem(idx)
				selectedSongIndex = idx
			end
		end
		updateRandomButtonsState()
		for i, icon in pairs(activeIndicator) do
			icon.Visible = (i == activeSongIndex and currentRandomMode == "none")
		end
		if acceptButton then acceptButton.Visible = false end
		if sonicSound then
			sonicSound.Looped = (isLmsActive and currentRandomMode == "none")
		end
	end)

	acceptButton = Instance.new("TextButton")
	acceptButton.Text = "Accept"
	acceptButton.Size = UDim2.new(0, 100, 0, 28)
	acceptButton.Position = UDim2.new(1, -120, 1, -40)
	acceptButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	acceptButton.TextColor3 = Color3.new(1, 1, 1)
	acceptButton.Font = Enum.Font.GothamBold
	acceptButton.TextSize = 13
	acceptButton.BorderSizePixel = 0
	acceptButton.Parent = pickerFrame
	acceptButton.Visible = (selectedSongIndex ~= activeSongIndex) or (currentRandomMode ~= "none")

	acceptButton.MouseButton1Click:Connect(function()
		if currentRandomMode ~= "none" then
			currentRandomMode = "none"
			_G.MemoryMenu.Settings[randomModeKey] = "none"
			SaveSettings()
			if sonicSound then
				sonicSound.Looped = isLmsActive
			end
		end
		if selectedSongIndex ~= activeSongIndex then
			_G.MusicApplyFunc(selectedSongIndex)
		end
		_G.MemoryMenu.Settings[settingsKey] = selectedSongIndex
		SaveSettings()
		activeSongIndex = selectedSongIndex
		updateRandomButtonsState()
		for i, icon in pairs(activeIndicator) do
			icon.Visible = (i == activeSongIndex and currentRandomMode == "none")
		end
		acceptButton.Visible = false
	end)

	local backButton = Instance.new("TextButton")
	backButton.Text = "Volver"
	backButton.Size = UDim2.new(0, 100, 0, 28)
	backButton.Position = UDim2.new(0.5, -50, 1, -40)
	backButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	backButton.TextColor3 = Color3.new(1, 1, 1)
	backButton.Font = Enum.Font.GothamBold
	backButton.TextSize = 13
	backButton.BorderSizePixel = 0
	backButton.Parent = pickerFrame

	backButton.MouseButton1Click:Connect(function()
		closePicker()
		if _G.SonicRebuild then
			_G.SonicRebuild()
		end
	end)
end

_G.OpenSonicPicker()