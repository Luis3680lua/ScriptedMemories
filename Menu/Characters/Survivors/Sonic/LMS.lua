repeat task.wait() until _G.MemoryMenu

local section = _G.MemoryMenu.Sections["Characters"]
if not section then return end

for _, child in ipairs(section.Frame:GetChildren()) do
	if child:IsA("GuiObject") then child:Destroy() end
end

local backFrame = Instance.new("Frame")
backFrame.Size = UDim2.new(1, -10, 0, 0)
backFrame.Position = UDim2.new(0, 5, 0, 5)
backFrame.BackgroundTransparency = 1
backFrame.Parent = section.Frame

local backButton = Instance.new("TextButton")
backButton.Text = "< Back to Sonic"
backButton.Size = UDim2.new(0, 200, 0, 30)
backButton.Position = UDim2.new(0, 0, 0, 0)
backButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
backButton.TextColor3 = Color3.new(1, 1, 1)
backButton.Font = Enum.Font.GothamBold
backButton.TextSize = 14
backButton.BorderSizePixel = 0
backButton.Parent = backFrame

backButton.MouseButton1Click:Connect(function()
	if _G.SonicRebuild then
		_G.SonicRebuild()
	end
end)

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -10, 1, -45)
contentFrame.Position = UDim2.new(0, 5, 0, 40)
contentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = section.Frame

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 5)
uiPadding.PaddingBottom = UDim.new(0, 5)
uiPadding.PaddingLeft = UDim.new(0, 5)
uiPadding.PaddingRight = UDim.new(0, 5)
uiPadding.Parent = contentFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 5)
uiList.Parent = contentFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "Sonic LMS Settings"
titleLabel.Size = UDim2.new(1, -10, 0, 25)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = contentFrame

local selectedSongLabel = Instance.new("TextLabel")
selectedSongLabel.Size = UDim2.new(1, -10, 0, 20)
selectedSongLabel.BackgroundTransparency = 1
selectedSongLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
selectedSongLabel.Font = Enum.Font.Gotham
selectedSongLabel.TextSize = 14
selectedSongLabel.Text = "Current Song: Don't Blink"
selectedSongLabel.Parent = contentFrame

local selectSongButton = Instance.new("TextButton")
selectSongButton.Text = "Select Song"
selectSongButton.Size = UDim2.new(1, -10, 0, 36)
selectSongButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
selectSongButton.TextColor3 = Color3.new(1, 1, 1)
selectSongButton.Font = Enum.Font.GothamBold
selectSongButton.TextSize = 14
selectSongButton.BorderSizePixel = 0
selectSongButton.Parent = contentFrame

local restoreButton = Instance.new("TextButton")
restoreButton.Text = "Restore Defaults"
restoreButton.Size = UDim2.new(1, -10, 0, 36)
restoreButton.BackgroundColor3 = Color3.fromRGB(170, 100, 0)
restoreButton.TextColor3 = Color3.new(1, 1, 1)
restoreButton.Font = Enum.Font.GothamBold
restoreButton.TextSize = 14
restoreButton.BorderSizePixel = 0
restoreButton.Parent = contentFrame

local songs = {
	{
		name = "Break Free",
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/BreakFree.mp3",
		file = "BreakFree.mp3",
		endTime = 289,
		credits = "Créditos: Placeholder BreakFree",
		imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/BreakFree.png",
		imageFile = "BreakFree.png",
		section = "Official"
	},
	{
		name = "Don't Blink",
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/DontBlink.mp3",
		file = "DontBlink.mp3",
		endTime = 289,
		credits = "Créditos: Placeholder DontBlink",
		imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Sonic.png",
		imageFile = "Sonic_DontBlink.png",
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
		name = "Speed of Sound Round 2",
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/SpeedOfSoundRound2.mp3",
		file = "SpeedOfSoundRound2.mp3",
		endTime = 289,
		credits = "Créditos: Placeholder Round2",
		imageUrl = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Sonic/Images/SpeedOfSoundRound2.png",
		imageFile = "SpeedOfSoundRound2.png",
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
	}
}

local selectedSongIndex = _G.MemoryMenu.Settings["Sonic_SelectedSongIndex"] or 2
local activeSongIndex = selectedSongIndex

local function updateSelectedSongLabel()
	local song = songs[selectedSongIndex]
	if song then
		selectedSongLabel.Text = "Current Song: " .. song.name
	end
end
updateSelectedSongLabel()

local function saveSelectedSong()
	_G.MemoryMenu.Settings["Sonic_SelectedSongIndex"] = selectedSongIndex
	task.defer(_G.MemoryMenu.SaveSettings)
end

local function restoreDefaults()
	selectedSongIndex = 2
	activeSongIndex = 2
	updateSelectedSongLabel()
	saveSelectedSong()
	if _G.MusicApplyFunc then
		_G.MusicApplyFunc(2)
	end
end

restoreButton.MouseButton1Click:Connect(restoreDefaults)

local pickerOpen = false
local pickerGui
local itemFrames = {}
local debounce = false

local function highlightItem(index)
	for i, frame in ipairs(itemFrames) do
		frame.BackgroundColor3 = (i == index) and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(45, 45, 45)
		frame.BorderColor3 = (i == index) and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(0, 0, 0)
		frame.BorderSizePixel = (i == index) and 2 or 0
	end
	selectedSongIndex = index
	updateSelectedSongLabel()
	saveSelectedSong()
end

local function closePicker()
	if pickerGui then
		pickerGui:Destroy()
		pickerGui = nil
	end
	pickerOpen = false
end

selectSongButton.MouseButton1Click:Connect(function()
	if pickerOpen then return end
	if debounce then return end
	debounce = true
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
	pickerFrame.Size = UDim2.new(0, 350, 0, 480)
	pickerFrame.Position = UDim2.new(0.5, -175, 0.5, -240)
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

		local itemFrame = Instance.new("Frame")
		itemFrame.Size = UDim2.new(1, -10, 0, 80)
		itemFrame.BackgroundColor3 = (itemIndex == selectedSongIndex) and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(45, 45, 45)
		itemFrame.BorderColor3 = (itemIndex == selectedSongIndex) and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(0, 0, 0)
		itemFrame.BorderSizePixel = (itemIndex == selectedSongIndex) and 2 or 0
		itemFrame.Parent = scrollFrame

		local image = Instance.new("ImageLabel")
		image.Size = UDim2.new(0, 50, 0, 50)
		image.Position = UDim2.new(0, 5, 0.5, -25)
		image.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		image.Image = song.imageUrl
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
				highlightItem(itemIndex)
			end
		end)

		itemFrames[itemIndex] = itemFrame
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

	local acceptDebounce = false
	acceptButton.MouseButton1Click:Connect(function()
		if acceptDebounce then return end
		acceptDebounce = true
		activeSongIndex = selectedSongIndex
		saveSelectedSong()
		if _G.MusicApplyFunc then
			_G.MusicApplyFunc(selectedSongIndex)
		end
		closePicker()
		debounce = false
	end)

	local cancelDebounce = false
	cancelButton.MouseButton1Click:Connect(function()
		if cancelDebounce then return end
		cancelDebounce = true
		closePicker()
		debounce = false
	end)

	background.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not pickerFrame:IsAncestorOf(input.Target) then
			closePicker()
			debounce = false
		end
	end)
end)

-- Descarga y aplicación de música en segundo plano
task.spawn(function()
	local folderBlink = ".cache"
	if makefolder and not isfolder(folderBlink) then
		makefolder(folderBlink)
	end

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
		downloadFile(song.url, folderBlink .. "/" .. song.file)
		song.assetId = getAssetPath(folderBlink .. "/" .. song.file)
	end

	local RS = game:GetService("ReplicatedStorage")
	local GameProperties = workspace:FindFirstChild("GameProperties")
	if not GameProperties then return end
	local stateValue = GameProperties:FindFirstChild("State")
	if not stateValue then return end

	local sonicSound
	local currentMusicId = songs[activeSongIndex] and songs[activeSongIndex].assetId

	local function applyMusic(newId)
		if not newId or not sonicSound then return end
		currentMusicId = newId
		sonicSound.SoundId = newId
		sonicSound.Looped = true
		sonicSound.Volume = RS.ClientAssets.Sounds.musg.Volume
	end

	_G.MusicApplyFunc = function(index)
		local song = songs[index]
		if not song or not song.assetId then return end
		if sonicSound then
			applyMusic(song.assetId)
		end
		activeSongIndex = index
		updateSelectedSongLabel()
	end

	local sonicSolo = RS:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("SoloTheme"):WaitForChild("SonicSolo")
	if sonicSolo and sonicSolo:IsA("Sound") then
		sonicSound = sonicSolo
		if currentMusicId then
			applyMusic(currentMusicId)
		end
		sonicSound:GetPropertyChangedSignal("SoundId"):Connect(function()
			if sonicSound.SoundId ~= currentMusicId then
				sonicSound.SoundId = currentMusicId
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

section.Frame.Size = UDim2.new(1, -10, 0, 200)
local contentFrameParent = section.Frame.Parent
if contentFrameParent and contentFrameParent:IsA("ScrollingFrame") then
	contentFrameParent.CanvasSize = UDim2.new(0, 0, 0, section.Frame.Size.Y.Offset + 30)
end