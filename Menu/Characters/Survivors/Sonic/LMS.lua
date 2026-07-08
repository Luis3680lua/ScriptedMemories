-- Si el sistema de música ya está vivo, solo abrimos el picker
if _G.SonicMusicInitialized then
	_G.OpenSonicPicker()
	return
end

-- Si ya existen las canciones (pero no el sistema) significa que algo falló; forzamos reinicio limpio
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
		section = "Official"
	},
	{
		name = "Speed of Sound Round 2 (Bonus Mix)",
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound2BonusMix.mp3",
		file = "SpeedOfSoundRound2BonusMix.mp3",
		endTime = 289,
		credits = "Créditos: Placeholder BonusMix",
		imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/SpeedOfSoundRound2BonusMix.png",
		imageFile = "SpeedOfSoundRound2BonusMix.png",
		section = "Official"
	},
	{
		name = "Don't Blink (Old Lyrics)",
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/DontBlinkOLD.mp3",
		file = "DontBlinkOLD.mp3",
		endTime = 289,
		credits = "Créditos: Placeholder Old Lyrics",
		imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/DontBlinkOld.png",
		imageFile = "DontBlinkOld.png",
		section = "Official"
	},
	{
		name = "So, Don't Blink",
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SoDontBlink.mp3",
		file = "SoDontBlink.mp3",
		endTime = 289,
		credits = "Créditos: Placeholder SoDontBlink",
		imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/SoDontBlink.png",
		imageFile = "SoDontBlink.png",
		section = "Official"
	}
}

_G.SonicSongs = songs

local imageCache = {}
local function getImageAsset(imageUrl, imageFile)
	local path = FOLDER .. "/" .. imageFile
	if imageCache[path] then
		return imageCache[path]
	end
	if not isfile(path) then
		local ok, data = pcall(game.HttpGet, game, imageUrl .. "?t=" .. tick())
		if not ok or not data or #data <= 100 then return nil end
		writefile(path, data)
	end
	local ok, asset = pcall(function()
		return getAsset(path)
	end)
	if ok and asset then
		imageCache[path] = asset
		return asset
	end
	return nil
end

for _, song in ipairs(songs) do
	song.cachedImage = getImageAsset(song.imageUrl, song.imageFile)
end

-- ---------------------- Configuración global ----------------------
local selectedSongIndex = _G.MemoryMenu.Settings["Sonic_SelectedSongIndex"] or 3
local activeSongIndex = selectedSongIndex
local pickerOpen = false
local pickerGui
local itemFrames = {}
local acceptButton
local lastSelectedFrame   -- para highlight eficiente

-- Debounce para guardar configuración
local saveDebounce = false
local function SaveSettings()
	if saveDebounce then return end
	saveDebounce = true
	task.delay(0.3, function()
		_G.MemoryMenu.SaveSettings()
		saveDebounce = false
	end)
end

local function highlightItem(index)
	-- Restaurar el frame anterior
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
		acceptButton.Visible = (selectedSongIndex ~= activeSongIndex)
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
end

function _G.OpenSonicPicker()
	if pickerOpen then return end
	pickerOpen = true

	-- Eliminar cualquier ScreenGui anterior con el mismo nombre
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
	pickerFrame.Size = UDim2.new(0, 450, 0, 480)
	pickerFrame.Position = UDim2.new(0.5, -225, 0.5, -240)
	pickerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	pickerFrame.BorderSizePixel = 0
	pickerFrame.Parent = pickerGui

	local title = Instance.new("TextLabel")
	title.Text = "Last Man Standing"
	title.Size = UDim2.new(1, 0, 0, 30)
	title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.Parent = pickerFrame

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -10, 1, -70)
	scrollFrame.Position = UDim2.new(0, 5, 0, 35)
	scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 4
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.Parent = pickerFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 5)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scrollFrame

	table.clear(itemFrames)
	local lastSection = nil
	local itemIndex = 0

	for i, song in ipairs(songs) do
		if song.section ~= lastSection then
			local sectionHeader = Instance.new("TextLabel")
			sectionHeader.Text = song.section
			sectionHeader.Size = UDim2.new(1, -10, 0, 25)
			sectionHeader.BackgroundTransparency = 1
			sectionHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
			sectionHeader.Font = Enum.Font.GothamBold
			sectionHeader.TextSize = 16
			sectionHeader.TextXAlignment = Enum.TextXAlignment.Left
			sectionHeader.Parent = scrollFrame
			lastSection = song.section
		end

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

		itemFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				highlightItem(currentIndex)
			end
		end)

		itemFrames[currentIndex] = itemFrame
	end

	-- Ajustar canvas
	local numHeaders = 0
	local last = nil
	for _, s in ipairs(songs) do
		if s.section ~= last then
			numHeaders = numHeaders + 1
			last = s.section
		end
	end
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, numHeaders * 30 + #itemFrames * 105)

	-- Resaltar la canción activa actual (la que está sonando)
	if itemFrames[activeSongIndex] then
		highlightItem(activeSongIndex)
		local targetFrame = itemFrames[activeSongIndex]
		local offset = targetFrame.AbsolutePosition.Y - scrollFrame.AbsolutePosition.Y
		scrollFrame.CanvasPosition = Vector2.new(0, math.max(0, offset - 100))
	elseif itemFrames[selectedSongIndex] then
		highlightItem(selectedSongIndex)
		local targetFrame = itemFrames[selectedSongIndex]
		local offset = targetFrame.AbsolutePosition.Y - scrollFrame.AbsolutePosition.Y
		scrollFrame.CanvasPosition = Vector2.new(0, math.max(0, offset - 100))
	end

	-- Botón Volver
	local backButton = Instance.new("TextButton")
	backButton.Text = "Volver"
	backButton.Size = UDim2.new(0, 100, 0, 30)
	backButton.Position = UDim2.new(0.5, 20, 1, -40)
	backButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	backButton.TextColor3 = Color3.new(1, 1, 1)
	backButton.Font = Enum.Font.GothamBold
	backButton.TextSize = 14
	backButton.BorderSizePixel = 0
	backButton.Parent = pickerFrame

	backButton.MouseButton1Click:Connect(function()
		closePicker()
		if _G.SonicRebuild then
			_G.SonicRebuild()
		end
	end)

	-- Botón Aceptar
	acceptButton = Instance.new("TextButton")
	acceptButton.Text = "Accept"
	acceptButton.Size = UDim2.new(0, 100, 0, 30)
	acceptButton.Position = UDim2.new(0.5, -120, 1, -40)
	acceptButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	acceptButton.TextColor3 = Color3.new(1, 1, 1)
	acceptButton.Font = Enum.Font.GothamBold
	acceptButton.TextSize = 14
	acceptButton.BorderSizePixel = 0
	acceptButton.Parent = pickerFrame
	acceptButton.Visible = (selectedSongIndex ~= activeSongIndex)

	acceptButton.MouseButton1Click:Connect(function()
		if selectedSongIndex ~= activeSongIndex then
			_G.MemoryMenu.Settings["Sonic_SelectedSongIndex"] = selectedSongIndex
			SaveSettings()  -- Debounced
			activeSongIndex = selectedSongIndex
			pcall(function()
				if _G.MusicApplyFunc then
					_G.MusicApplyFunc(selectedSongIndex)
				end
			end)
			acceptButton.Visible = false
		end
	end)
end

-- ==================== INICIALIZACIÓN ÚNICA DEL SISTEMA DE MÚSICA ====================
if not _G.SonicMusicInitialized then
	_G.SonicMusicInitialized = true

	-- Limpiar conexiones anteriores si existen (por si acaso)
	if _G.SonicConnections then
		for _, c in pairs(_G.SonicConnections) do
			pcall(function() c:Disconnect() end)
		end
		table.clear(_G.SonicConnections)
	else
		_G.SonicConnections = {}
	end

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

		for _, song in ipairs(songs) do
			downloadFile(song.url, FOLDER .. "/" .. song.file)
			song.assetId = getAssetPath(FOLDER .. "/" .. song.file)
		end

		local RS = game:GetService("ReplicatedStorage")
		local GameProperties = workspace:FindFirstChild("GameProperties")
		if not GameProperties then return end
		local stateValue = GameProperties:FindFirstChild("State")
		if not stateValue then return end

		local sonicSound
		local currentMusicId = songs[activeSongIndex] and songs[activeSongIndex].assetId
		local isApplying = false

		local function safelyApplyMusic(newId)
			if not newId or not sonicSound then return end
			isApplying = true
			currentMusicId = newId
			sonicSound.SoundId = newId
			sonicSound.Looped = true
			sonicSound.Volume = RS.ClientAssets.Sounds.musg.Volume
			isApplying = false
		end

		_G.MusicApplyFunc = function(index)
			local song = songs[index]
			if not song or not song.assetId then return end
			if sonicSound then
				safelyApplyMusic(song.assetId)
			end
			activeSongIndex = index
		end

		local sonicSolo = RS:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("SoloTheme"):WaitForChild("SonicSolo")
		if sonicSolo and sonicSolo:IsA("Sound") then
			sonicSound = sonicSolo
			if currentMusicId then
				safelyApplyMusic(currentMusicId)
			end

			-- Conexión SoundId (se guarda para limpiar)
			local conn1 = sonicSound:GetPropertyChangedSignal("SoundId"):Connect(function()
				if isApplying then return end
				if sonicSound.SoundId ~= currentMusicId then
					safelyApplyMusic(currentMusicId)
				end
			end)
			table.insert(_G.SonicConnections, conn1)

			-- Conexión Volume
			local conn2 = RS.ClientAssets.Sounds.musg:GetPropertyChangedSignal("Volume"):Connect(function()
				if sonicSound then
					sonicSound.Volume = RS.ClientAssets.Sounds.musg.Volume
				end
			end)
			table.insert(_G.SonicConnections, conn2)
		end

		-- Conexión State (cambio a "RE" para forzar final)
		local conn3 = stateValue.Changed:Connect(function(value)
			if value == "RE" and sonicSound and sonicSound.IsPlaying then
				sonicSound.Looped = false
				sonicSound.TimePosition = songs[activeSongIndex] and songs[activeSongIndex].endTime or 289
			end
		end)
		table.insert(_G.SonicConnections, conn3)
	end)
end

-- Abrir el picker inmediatamente después de cargar todo
_G.OpenSonicPicker()