local Menu = _G.Menu
if not Menu then return end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local HttpGet = game.HttpGet

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

local DATOS_CANCIONES = {
	{ key = "Lone", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/Lone.mp3", archivo = FOLDER .. "/Lone.mp3", nombre = "Lone", creditos = "ThatGuyRamon" },
	{ key = "OfAnotherDreamv2", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/OfAnotherDreamv2.mp3", archivo = FOLDER .. "/OfAnotherDreamv2.mp3", nombre = "Of Another Dream v2", creditos = "Juno!" },
	{ key = "OnceUponRemix", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/OnceUponRemix.mp3", archivo = FOLDER .. "/OnceUponRemix.mp3", nombre = "Once Upon (Remix)", creditos = "Astranova" },
	{ key = "InvoluntariaScore", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/InvoluntariaScore.mp3", archivo = FOLDER .. "/InvoluntariaScore.mp3", nombre = "Involuntaria Score (Unfinished)", creditos = "Juno!" },
	{ key = "LostAndFound", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/LostAndFound.mp3", archivo = FOLDER .. "/LostAndFound.mp3", nombre = "Lost & Found (Unfinished)", creditos = "Juno!" },
	{ key = "UncannyValley", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/UncannyValley.mp3", archivo = FOLDER .. "/UncannyValley.mp3", nombre = "Uncanny Valley (Unfinished)", creditos = "Juno!" }
}

local CACHED_SONGS = {}
for _, datos in ipairs(DATOS_CANCIONES) do
	local asset = getOrDownloadAsset(datos.url, datos.archivo)
	if asset then
		CACHED_SONGS[datos.key] = asset
	end
end

local customIcons = {
	amy = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Amy.png", file = "Amy.png" },
	blaze = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Blaze.png", file = "Blaze.png" },
	cream = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Cream.png", file = "Cream.png" },
	eggman = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Eggman.png", file = "Eggman.png" },
	knuckles = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Knuckles.png", file = "Knuckles.png" },
	metalsonic = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/MetalSonic.png", file = "MetalSonic.png" },
	silver = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Silver.png", file = "Silver.png" },
	sonic = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Sonic.png", file = "Sonic.png" },
	tails = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Tails.png", file = "Tails.png" }
}

local CACHED_ICONS = {}
for name, data in pairs(customIcons) do
	local path = FOLDER .. "/" .. data.file
	local asset = getOrDownloadAsset(data.url, path)
	if asset then
		CACHED_ICONS[name] = asset
	end
end

local iconConnection = nil
local formatConnection = nil
local creditCorrectionConn = nil
local shopMusicSound = nil
local shopMusicConnection = nil

if not Menu.Settings.shop_extra_music_enabled then
	Menu.Settings.shop_extra_music_enabled = {}
end
if not Menu.Settings.shop_custom_icons_enabled then
	Menu.Settings.shop_custom_icons_enabled = false
end
if not Menu.Settings.shop_number_format_enabled then
	Menu.Settings.shop_number_format_enabled = false
end
if not Menu.Settings.shop_credit_correction_enabled then
	Menu.Settings.shop_credit_correction_enabled = false
end

local originalSongIds = {}

local function fetchOriginalSongIds()
	local shopMus = nil
	local clientAssets = ReplicatedStorage:WaitForChild("ClientAssets", 10)
	if clientAssets then
		local sounds = clientAssets:WaitForChild("Sounds", 10)
		if sounds then
			local mus = sounds:WaitForChild("mus", 10)
			if mus then
				local menu = mus:WaitForChild("Menu", 10)
				if menu then
					shopMus = menu:WaitForChild("ShopMus", 10)
				end
			end
		end
	end
	if not shopMus then return end

	for _, child in ipairs(shopMus:GetChildren()) do
		if child:IsA("Sound") then
			local name = child.Name:lower()
			local title = (child:GetAttribute("Title") or ""):lower()
			for _, datos in ipairs(DATOS_CANCIONES) do
				local search = datos.key:lower()
				if name:find(search, 1, true) or title:find(search, 1, true) then
					originalSongIds[datos.key] = child.SoundId
				end
			end
			if name:find("ofanotherdream", 1, true) and not name:find("v2", 1, true) then
				originalSongIds["OfAnotherDreamv1"] = child.SoundId
			end
		end
	end
end

local function applyCreditCorrection(enabled)
	if creditCorrectionConn then
		creditCorrectionConn:Disconnect()
		creditCorrectionConn = nil
	end
	if not enabled then return end

	local function correctShopMus(shopMus)
		if not shopMus then return end
		local function correct(buscar, nuevos)
			local lower = buscar:lower()
			for _, s in ipairs(shopMus:GetChildren()) do
				if s:IsA("Sound") then
					local titulo = (s:GetAttribute("Title") or ""):lower()
					local nombre = s.Name:lower()
					if (titulo:find(lower, 1, true) or nombre:find(lower, 1, true)) and not titulo:find("v2", 1, true) then
						s:SetAttribute("Title", nuevos)
					end
				end
			end
		end
		correct("Of Another Dream", "Of Another Dream v1 by Juno!")
		correct("Dissonance", "Dissonance by Juno!")
	end

	local function findAndCorrect()
		local shopMus = nil
		local clientAssets = ReplicatedStorage:WaitForChild("ClientAssets", 10)
		if clientAssets then
			local sounds = clientAssets:WaitForChild("Sounds", 10)
			if sounds then
				local mus = sounds:WaitForChild("mus", 10)
				if mus then
					local menu = mus:WaitForChild("Menu", 10)
					if menu then
						shopMus = menu:WaitForChild("ShopMus", 10)
					end
				end
			end
		end
		correctShopMus(shopMus)
	end

	findAndCorrect()
	creditCorrectionConn = PlayerGui.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "ShopMus" and not descendant:IsA("Sound") then
			task.wait(0.1)
			correctShopMus(descendant)
		end
	end)
end

local function applyCustomIcons(enabled)
	if enabled then
		local function processObject(obj)
			local key = obj.Name:lower()
			if customIcons[key] and (obj:IsA("ImageButton") or obj:IsA("ImageLabel")) then
				local icon = CACHED_ICONS[key]
				if not icon then return end
				local existing = obj:FindFirstChild("CustomShopIcon")
				if existing then existing:Destroy() end
				for _, v in ipairs(obj:GetDescendants()) do
					if v:IsA("ImageLabel") or v:IsA("ImageButton") then
						v.ImageTransparency = 1
					end
				end
				local img = Instance.new("ImageLabel")
				img.Name = "CustomShopIcon"
				img.BackgroundTransparency = 1
				img.Image = icon
				img.Size = UDim2.fromScale(1.5, 1.25)
				img.Position = UDim2.fromScale(-0.20, -0.25)
				img.AnchorPoint = Vector2.zero
				img.ScaleType = Enum.ScaleType.Stretch
				img.ZIndex = 999999
				img.Parent = obj
			end
		end

		local function scan()
			local charSelection = PlayerGui:FindFirstChild("CharSelection", true)
			if charSelection then
				for _, obj in ipairs(charSelection:GetDescendants()) do
					task.defer(processObject, obj)
				end
			end
		end
		scan()
		iconConnection = PlayerGui.DescendantAdded:Connect(function(obj)
			task.defer(processObject, obj)
		end)
	else
		if iconConnection then
			iconConnection:Disconnect()
			iconConnection = nil
		end
		for _, obj in ipairs(PlayerGui:GetDescendants()) do
			local icon = obj:FindFirstChild("CustomShopIcon")
			if icon then
				icon:Destroy()
			end
			if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
				obj.ImageTransparency = 0
			end
		end
	end
end

local function applyNumberFormat(enabled)
	if enabled then
		local function addCommas(num)
			if #num < 4 then return num end
			return num:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
		end
		local function formatText(text)
			text = text:gsub("%f[%w](%d+)(%a+)%f[^%w]", function(num, letters)
				if letters:lower() == "x" then return num .. letters end
				return addCommas(num) .. letters
			end)
			text = text:gsub("%f[%d](%d+)%f[^%w]", addCommas)
			return text
		end
		local function hookObject(obj)
			if not (obj:IsA("TextLabel") or obj:IsA("TextButton")) then return end
			if not (obj.Name == "Rings" or obj.Name == "CharPrice" or obj.Name == "Price") then return end
			local function update()
				local formatted = formatText(obj.Text)
				if formatted ~= obj.Text then obj.Text = formatted end
			end
			update()
			obj:GetPropertyChangedSignal("Text"):Connect(update)
		end
		local function isShopContainer(obj)
			if not obj:IsA("Frame") and not obj:IsA("Folder") then return false end
			if obj.Name ~= "shop" and obj.Name ~= "shopTemp" then return false end
			local bottom = obj:FindFirstChild("bottom")
			if bottom then
				local bg = bottom:FindFirstChild("bg")
				if bg and bg:FindFirstChild("Rings") then
					return true
				end
			end
			return false
		end
		local function hookShopContainer(container)
			for _, obj in ipairs(container:GetDescendants()) do
				hookObject(obj)
			end
			container.DescendantAdded:Connect(function(obj)
				hookObject(obj)
			end)
		end
		local gameUI = PlayerGui:WaitForChild("GameUI", 10)
		if gameUI then
			for _, child in ipairs(gameUI:GetChildren()) do
				if isShopContainer(child) then
					hookShopContainer(child)
				end
			end
			formatConnection = gameUI.ChildAdded:Connect(function(child)
				if isShopContainer(child) then
					hookShopContainer(child)
				end
			end)
		end
	else
		if formatConnection then
			formatConnection:Disconnect()
			formatConnection = nil
		end
	end
end

local function replaceMusicSound(sound)
	if not sound then return end
	local originalId = sound.SoundId
	for key, original in pairs(originalSongIds) do
		if original == originalId and CACHED_SONGS[key] then
			if Menu.Settings.shop_extra_music_enabled[key] then
				sound.SoundId = CACHED_SONGS[key]
			end
			return
		end
	end
end

local function setupShopMusicHooks()
	local gameUI = PlayerGui:WaitForChild("GameUI", 10)
	if not gameUI then return end

	local function findAndHookShopSound(container)
		local sound = container:FindFirstChildWhichIsA("Sound")
		if sound and sound ~= shopMusicSound then
			if shopMusicConnection then shopMusicConnection:Disconnect() end
			shopMusicSound = sound
			shopMusicConnection = sound:GetPropertyChangedSignal("SoundId"):Connect(function()
				replaceMusicSound(sound)
			end)
			replaceMusicSound(sound)
		end
	end

	for _, child in ipairs(gameUI:GetChildren()) do
		if child.Name == "shop" or child.Name == "shopTemp" then
			findAndHookShopSound(child)
		end
	end

	gameUI.ChildAdded:Connect(function(child)
		if child.Name == "shop" or child.Name == "shopTemp" then
			task.wait(0.1)
			findAndHookShopSound(child)
		end
	end)
end

task.spawn(function()
	repeat task.wait(1) until PlayerGui:FindFirstChild("GameUI")
	fetchOriginalSongIds()
	setupShopMusicHooks()
	replaceMusicSound(shopMusicSound)
end)

if Menu.Settings.shop_custom_icons_enabled then
	applyCustomIcons(true)
end
if Menu.Settings.shop_number_format_enabled then
	applyNumberFormat(true)
end
if Menu.Settings.shop_credit_correction_enabled then
	applyCreditCorrection(true)
end

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

local function createSectionCard(titleText, accentColor)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 0)
	card.BackgroundColor3 = T.Tertiary
	card.BackgroundTransparency = 0.3
	card.BorderSizePixel = 0
	card.AutomaticSize = Enum.AutomaticSize.Y
	roundFrame(card, 6)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.Parent = card

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = card

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 22)
	header.BackgroundTransparency = 1
	header.Font = T.FontBold
	header.TextSize = 15
	header.TextColor3 = accentColor or T.Accent
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Text = titleText
	header.Parent = card

	return card, layout
end

local page = Menu:RegisterPage("Tienda", "🛒")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(1, 0, 0, 0)
mainContainer.BackgroundTransparency = 1
mainContainer.AutomaticSize = Enum.AutomaticSize.Y
mainContainer.Parent = page.Frame

local mainList = Instance.new("UIListLayout")
mainList.Padding = UDim.new(0, 8)
mainList.SortOrder = Enum.SortOrder.LayoutOrder
mainList.Parent = mainContainer

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Font = T.FontBold
title.TextSize = 20
title.TextColor3 = T.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "🛒 Tienda"
title.Parent = mainContainer

local desc = Instance.new("TextLabel")
desc.Size = UDim2.new(1, 0, 0, 42)
desc.BackgroundTransparency = 1
desc.Font = T.Font
desc.TextSize = 13
desc.TextWrapped = true
desc.TextColor3 = T.TextDim
desc.TextXAlignment = Enum.TextXAlignment.Left
desc.TextYAlignment = Enum.TextYAlignment.Top
desc.Text = "Personaliza la apariencia de la tienda y reemplaza su música."
desc.Parent = mainContainer

local musicSection, musicLayout = createSectionCard("🎵 Música de la tienda", T.Accent)
musicSection.Parent = mainContainer

for _, datos in ipairs(DATOS_CANCIONES) do
	local songKey = datos.key
	local enabled = Menu.Settings.shop_extra_music_enabled[songKey] or false

	local toggleFrame = Instance.new("Frame")
	toggleFrame.Size = UDim2.new(1, 0, 0, 50)
	toggleFrame.BackgroundColor3 = T.Tertiary
	toggleFrame.BackgroundTransparency = 0.3
	toggleFrame.BorderSizePixel = 0
	roundFrame(toggleFrame, 6)
	toggleFrame.Parent = musicSection

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(0, 200, 0, 26)
	infoLabel.Position = UDim2.new(0, 12, 0, 4)
	infoLabel.BackgroundTransparency = 1
	infoLabel.TextColor3 = T.Text
	infoLabel.Font = T.Font
	infoLabel.TextSize = 14
	infoLabel.Text = datos.nombre
	infoLabel.Parent = toggleFrame

	local creditsLabel = Instance.new("TextLabel")
	creditsLabel.Size = UDim2.new(0, 200, 0, 16)
	creditsLabel.Position = UDim2.new(0, 12, 0, 28)
	creditsLabel.BackgroundTransparency = 1
	creditsLabel.TextColor3 = T.TextDim
	creditsLabel.Font = T.Font
	creditsLabel.TextSize = 11
	creditsLabel.Text = datos.creditos
	creditsLabel.Parent = toggleFrame

	local toggleBg = Instance.new("Frame")
	toggleBg.Size = UDim2.new(0, 44, 0, 22)
	toggleBg.Position = UDim2.new(1, -56, 0, 14)
	toggleBg.BackgroundColor3 = enabled and T.Green or T.Red
	toggleBg.BorderSizePixel = 0
	roundFrame(toggleBg, 11)
	toggleBg.Parent = toggleFrame

	local toggleKnob = Instance.new("Frame")
	toggleKnob.Size = UDim2.new(0, 18, 0, 18)
	toggleKnob.Position = enabled and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
	toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	toggleKnob.BorderSizePixel = 0
	roundFrame(toggleKnob, 9)
	toggleKnob.Parent = toggleBg

	local function updateVisual(state)
		toggleBg.BackgroundColor3 = state and T.Green or T.Red
		local targetX = state and 24 or 2
		toggleKnob:TweenPosition(UDim2.new(0, targetX, 0, 2), "Out", "Quad", 0.2, true)
	end

	toggleBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local newState = not (Menu.Settings.shop_extra_music_enabled[songKey] or false)
			Menu.Settings.shop_extra_music_enabled[songKey] = newState
			updateVisual(newState)
			if Menu.SaveSettings then Menu.SaveSettings() end
			if shopMusicSound then
				replaceMusicSound(shopMusicSound)
			end
		end
	end)
end

local creditsSection, creditsLayout = createSectionCard("✏️ Créditos de Juno!", T.Accent)
creditsSection.Parent = mainContainer

local creditsEnabled = Menu.Settings.shop_credit_correction_enabled

local creditsToggleFrame = Instance.new("Frame")
creditsToggleFrame.Size = UDim2.new(1, 0, 0, 50)
creditsToggleFrame.BackgroundColor3 = T.Tertiary
creditsToggleFrame.BackgroundTransparency = 0.3
creditsToggleFrame.BorderSizePixel = 0
roundFrame(creditsToggleFrame, 6)
creditsToggleFrame.Parent = creditsSection

local creditsLabel = Instance.new("TextLabel")
creditsLabel.Size = UDim2.new(0, 200, 0, 26)
creditsLabel.Position = UDim2.new(0, 12, 0, 12)
creditsLabel.BackgroundTransparency = 1
creditsLabel.TextColor3 = T.Text
creditsLabel.Font = T.Font
creditsLabel.TextSize = 14
creditsLabel.Text = "Corregir créditos originales"
creditsLabel.Parent = creditsToggleFrame

local creditsToggleBg = Instance.new("Frame")
creditsToggleBg.Size = UDim2.new(0, 44, 0, 22)
creditsToggleBg.Position = UDim2.new(1, -56, 0, 14)
creditsToggleBg.BackgroundColor3 = creditsEnabled and T.Green or T.Red
creditsToggleBg.BorderSizePixel = 0
roundFrame(creditsToggleBg, 11)
creditsToggleBg.Parent = creditsToggleFrame

local creditsToggleKnob = Instance.new("Frame")
creditsToggleKnob.Size = UDim2.new(0, 18, 0, 18)
creditsToggleKnob.Position = creditsEnabled and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
creditsToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
creditsToggleKnob.BorderSizePixel = 0
roundFrame(creditsToggleKnob, 9)
creditsToggleKnob.Parent = creditsToggleBg

local function updateCreditsVisual(state)
	creditsToggleBg.BackgroundColor3 = state and T.Green or T.Red
	local targetX = state and 24 or 2
	creditsToggleKnob:TweenPosition(UDim2.new(0, targetX, 0, 2), "Out", "Quad", 0.2, true)
end

creditsToggleBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local newState = not Menu.Settings.shop_credit_correction_enabled
		Menu.Settings.shop_credit_correction_enabled = newState
		updateCreditsVisual(newState)
		if Menu.SaveSettings then Menu.SaveSettings() end
		applyCreditCorrection(newState)
	end
end)

local iconsSection, iconsLayout = createSectionCard("🖼️ Íconos personalizados", T.Accent)
iconsSection.Parent = mainContainer

local iconsEnabled = Menu.Settings.shop_custom_icons_enabled

local iconsToggleFrame = Instance.new("Frame")
iconsToggleFrame.Size = UDim2.new(1, 0, 0, 50)
iconsToggleFrame.BackgroundColor3 = T.Tertiary
iconsToggleFrame.BackgroundTransparency = 0.3
iconsToggleFrame.BorderSizePixel = 0
roundFrame(iconsToggleFrame, 6)
iconsToggleFrame.Parent = iconsSection

local iconsLabel = Instance.new("TextLabel")
iconsLabel.Size = UDim2.new(0, 200, 0, 26)
iconsLabel.Position = UDim2.new(0, 12, 0, 12)
iconsLabel.BackgroundTransparency = 1
iconsLabel.TextColor3 = T.Text
iconsLabel.Font = T.Font
iconsLabel.TextSize = 14
iconsLabel.Text = "Activar íconos personalizados"
iconsLabel.Parent = iconsToggleFrame

local iconsToggleBg = Instance.new("Frame")
iconsToggleBg.Size = UDim2.new(0, 44, 0, 22)
iconsToggleBg.Position = UDim2.new(1, -56, 0, 14)
iconsToggleBg.BackgroundColor3 = iconsEnabled and T.Green or T.Red
iconsToggleBg.BorderSizePixel = 0
roundFrame(iconsToggleBg, 11)
iconsToggleBg.Parent = iconsToggleFrame

local iconsToggleKnob = Instance.new("Frame")
iconsToggleKnob.Size = UDim2.new(0, 18, 0, 18)
iconsToggleKnob.Position = iconsEnabled and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
iconsToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
iconsToggleKnob.BorderSizePixel = 0
roundFrame(iconsToggleKnob, 9)
iconsToggleKnob.Parent = iconsToggleBg

local function updateIconsVisual(state)
	iconsToggleBg.BackgroundColor3 = state and T.Green or T.Red
	local targetX = state and 24 or 2
	iconsToggleKnob:TweenPosition(UDim2.new(0, targetX, 0, 2), "Out", "Quad", 0.2, true)
end

iconsToggleBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local newState = not Menu.Settings.shop_custom_icons_enabled
		Menu.Settings.shop_custom_icons_enabled = newState
		updateIconsVisual(newState)
		if Menu.SaveSettings then Menu.SaveSettings() end
		applyCustomIcons(newState)
	end
end)

local formatSection, formatLayout = createSectionCard("🔢 Formato de números", T.Accent)
formatSection.Parent = mainContainer

local formatEnabled = Menu.Settings.shop_number_format_enabled

local formatToggleFrame = Instance.new("Frame")
formatToggleFrame.Size = UDim2.new(1, 0, 0, 50)
formatToggleFrame.BackgroundColor3 = T.Tertiary
formatToggleFrame.BackgroundTransparency = 0.3
formatToggleFrame.BorderSizePixel = 0
roundFrame(formatToggleFrame, 6)
formatToggleFrame.Parent = formatSection

local formatLabel = Instance.new("TextLabel")
formatLabel.Size = UDim2.new(0, 200, 0, 26)
formatLabel.Position = UDim2.new(0, 12, 0, 12)
formatLabel.BackgroundTransparency = 1
formatLabel.TextColor3 = T.Text
formatLabel.Font = T.Font
formatLabel.TextSize = 14
formatLabel.Text = "Separadores de miles (1,000)"
formatLabel.Parent = formatToggleFrame

local formatToggleBg = Instance.new("Frame")
formatToggleBg.Size = UDim2.new(0, 44, 0, 22)
formatToggleBg.Position = UDim2.new(1, -56, 0, 14)
formatToggleBg.BackgroundColor3 = formatEnabled and T.Green or T.Red
formatToggleBg.BorderSizePixel = 0
roundFrame(formatToggleBg, 11)
formatToggleBg.Parent = formatToggleFrame

local formatToggleKnob = Instance.new("Frame")
formatToggleKnob.Size = UDim2.new(0, 18, 0, 18)
formatToggleKnob.Position = formatEnabled and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
formatToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
formatToggleKnob.BorderSizePixel = 0
roundFrame(formatToggleKnob, 9)
formatToggleKnob.Parent = formatToggleBg

local function updateFormatVisual(state)
	formatToggleBg.BackgroundColor3 = state and T.Green or T.Red
	local targetX = state and 24 or 2
	formatToggleKnob:TweenPosition(UDim2.new(0, targetX, 0, 2), "Out", "Quad", 0.2, true)
end

formatToggleBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local newState = not Menu.Settings.shop_number_format_enabled
		Menu.Settings.shop_number_format_enabled = newState
		updateFormatVisual(newState)
		if Menu.SaveSettings then Menu.SaveSettings() end
		applyNumberFormat(newState)
	end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end