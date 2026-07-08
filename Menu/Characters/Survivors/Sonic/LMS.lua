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

local selectedSongIndex = _G.MemoryMenu.Settings["Sonic_SelectedSongIndex"] or 3
local activeSongIndex = selectedSongIndex
local pickerOpen = false
local pickerGui
local itemFrames = {}

local function highlightItem(index)
	for i, frame in ipairs(itemFrames) do
		frame.BackgroundColor3 = (i == index) and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(45, 45, 45)
		frame.BorderColor3 = (i == index) and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(0, 0, 0)
		frame.BorderSizePixel = (i == index) and 2 or 0
	end
	selectedSongIndex = index
end

local function closePicker()
	if pickerGui then
		pickerGui:Destroy()
		pickerGui = nil
	end
	pickerOpen = false
end

local function openPicker()
	if pickerOpen then return end
	pickerOpen = true

	pickerGui = Instance.new("ScreenGui")
	pickerGui.Name = "SonicPicker"
	pickerGui.ResetOnSpawn = false
	pickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pickerGui.DisplayOrder = 100
	pickerGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

	local background = Instance.new("Frame")
	background.Size = UDim2.new(1, 0, 1, 0)
	background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	background.BackgroundTransparency = 0.5
	background.Parent = pickerGui

	local pickerFrame = Instance.new("Frame")
	pickerFrame.Size = UDim2.new(0, 450, 0, 480)  -- más ancho
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
		itemFrame.Size = UDim2.new(1, -10, 0, 80)
		itemFrame.BackgroundColor3 = (currentIndex == selectedSongIndex) and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(45, 45, 45)
		itemFrame.BorderColor3 = (currentIndex == selectedSongIndex) and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(0, 0, 0)
		itemFrame.BorderSizePixel = (currentIndex == selectedSongIndex) and 2 or 0
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
		creditsLabel.Size = UDim2.new(1, -120, 0, 20)
		creditsLabel.Position = UDim2.new(0, 60, 0, 30)
		creditsLabel.BackgroundTransparency = 1
		creditsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		creditsLabel.Font = Enum.Font.Gotham
		creditsLabel.TextSize = 12
		creditsLabel.TextXAlignment = Enum.TextXAlignment.Left
		creditsLabel.Parent = itemFrame

		itemFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				highlightItem(currentIndex)
			end
		end)

		itemFrames[currentIndex] = itemFrame
	end

	local numHeaders = 0
	local last = nil
	for _, s in ipairs(songs) do
		if s.section ~= last then
			numHeaders = numHeaders + 1
			last = s.section
		end
	end
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, numHeaders * 30 + #itemFrames * 85)

	if itemFrames[selectedSongIndex] then
		local targetFrame = itemFrames[selectedSongIndex]
		local offset = targetFrame.AbsolutePosition.Y - scrollFrame.AbsolutePosition.Y
		scrollFrame.CanvasPosition = Vector2.new(0, math.max(0, offset - 100))
	end

	local acceptButton = Instance.new("TextButton")
	acceptButton.Text = "Accept"
	acceptButton.Size = UDim2.new(0, 100, 0, 30)
	acceptButton.Position = UDim2.new(0.5, -120, 1, -40)
	acceptButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	acceptButton.TextColor3 = Color3.new(1, 1, 1)
	acceptButton.Font = Enum.Font.GothamBold
	acceptButton.TextSize = 14
	acceptButton.BorderSizePixel = 0
	acceptButton.Parent = pickerFrame

	local cancelButton = Instance.new("TextButton")
	cancelButton.Text = "Cancel"
	cancelButton.Size = UDim2.new(0, 100, 0, 30)
	cancelButton.Position = UDim2.new(0.5, 20, 1, -40)
	cancelButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	cancelButton.TextColor3 = Color3.new(1, 1, 1)
	cancelButton.Font = Enum.Font.GothamBold
	cancelButton.TextSize = 14
	cancelButton.BorderSizePixel = 0
	cancelButton.Parent = pickerFrame

	local function finalizar(apply)
		if apply and selectedSongIndex ~= activeSongIndex then
			_G.MemoryMenu.Settings["Sonic_SelectedSongIndex"] = selectedSongIndex
			_G.MemoryMenu.SaveSettings()
			activeSongIndex = selectedSongIndex
			pcall(function()
				if _G.MusicApplyFunc then
					_G.MusicApplyFunc(selectedSongIndex)
				end
			end)
		end
		closePicker()
		if _G.SonicRebuild then
			_G.SonicRebuild()
		end
	end

	acceptButton.MouseButton1Click:Connect(function()
		finalizar(true)
	end)

	cancelButton.MouseButton1Click:Connect(function()
		finalizar(false)
	end)

	background.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not pickerFrame:IsAncestorOf(input.Target) then
			finalizar(false)
		end
	end)
end

-- Descarga de música y aplicación en segundo plano (sin crasheos)
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
	local changingSound = false

	local function safelyApplyMusic(newId)
		if not newId or not sonicSound then return end
		changingSound = true
		currentMusicId = newId
		sonicSound.SoundId = newId
		sonicSound.Looped = true
		sonicSound.Volume = RS.ClientAssets.Sounds.musg.Volume
		changingSound = false
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
		sonicSound:GetPropertyChangedSignal("SoundId"):Connect(function()
			if changingSound then return end  -- ignorar cambios propios
			if sonicSound.SoundId ~= currentMusicId then
				safelyApplyMusic(currentMusicId)
			end
		end)
		RS.ClientAssets.Sounds.musg:GetPropertyChangedSignal("Volume"):Connect(function()
			if sonicSound then
				sonicSound.Volume = RS.ClientAssets.Sounds.musg.Volume
			end
		end)
	end

	if stateValue then
		stateValue.Changed:Connect(function(value)
			if value == "RE" and sonicSound and sonicSound.IsPlaying then
				sonicSound.Looped = false
				sonicSound.TimePosition = songs[activeSongIndex] and songs[activeSongIndex].endTime or 289
			end
		end)
	end
end)

openPicker()