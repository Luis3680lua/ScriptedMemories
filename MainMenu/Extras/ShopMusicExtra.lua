local Menu = _G.Menu
if not Menu then return end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
	{ key = "Lone", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/Lone.mp3", archivo = FOLDER .. "/Lone.mp3", nombre = "Lone", creador = "ThatGuyRamon" },
	{ key = "OfAnotherDreamv2", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/OfAnotherDreamv2.mp3", archivo = FOLDER .. "/OfAnotherDreamv2.mp3", nombre = "Of Another Dream v2", creador = "Juno!" },
	{ key = "OnceUponRemix", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/OnceUponRemix.mp3", archivo = FOLDER .. "/OnceUponRemix.mp3", nombre = "Once Upon (Remix)", creador = "Astranova" },
	{ key = "InvoluntariaScore", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/InvoluntariaScore.mp3", archivo = FOLDER .. "/InvoluntariaScore.mp3", nombre = "Involuntaria Score (Unfinished)", creador = "Juno!" },
	{ key = "LostAndFound", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/LostAndFound.mp3", archivo = FOLDER .. "/LostAndFound.mp3", nombre = "Lost & Found (Unfinished)", creador = "Juno!" },
	{ key = "UncannyValley", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/UncannyValley.mp3", archivo = FOLDER .. "/UncannyValley.mp3", nombre = "Uncanny Valley (Unfinished)", creador = "Juno!" }
}

local CACHED_SONGS = {}
for _, datos in ipairs(DATOS_CANCIONES) do
	local asset = getOrDownloadAsset(datos.url, datos.archivo)
	if asset then
		CACHED_SONGS[datos.key] = asset
	end
end

local activeCustomSounds = {}

if not Menu.Settings.shop_extra_music_enabled then
	Menu.Settings.shop_extra_music_enabled = {}
end

local function getShopMusFolder()
	local clientAssets = ReplicatedStorage:WaitForChild("ClientAssets", 10)
	if not clientAssets then return nil end
	local sounds = clientAssets:WaitForChild("Sounds", 10)
	if not sounds then return nil end
	local mus = sounds:WaitForChild("mus", 10)
	if not mus then return nil end
	local menu = mus:WaitForChild("Menu", 10)
	if not menu then return nil end
	return menu:WaitForChild("ShopMus", 10)
end

local function getMusicGroup()
	local clientAssets = ReplicatedStorage:WaitForChild("ClientAssets", 10)
	if not clientAssets then return nil end
	local sounds = clientAssets:WaitForChild("Sounds", 10)
	if not sounds then return nil end
	return sounds:WaitForChild("musg", 10)
end

local function applyMusicToggle(key, enabled)
	local shopMus = getShopMusFolder()
	if not shopMus then return end
	local musicGroup = getMusicGroup()
	local datos = nil
	for _, d in ipairs(DATOS_CANCIONES) do
		if d.key == key then datos = d break end
	end
	if not datos then return end
	local soundName = "Custom_" .. key
	local soundTitle = datos.nombre .. " by " .. datos.creador

	if enabled then
		if not activeCustomSounds[key] and CACHED_SONGS[key] then
			local s = Instance.new("Sound")
			s.Name = soundName
			s.SoundId = CACHED_SONGS[key]
			s.Volume = 2
			if musicGroup then s.SoundGroup = musicGroup end
			s:SetAttribute("Title", soundTitle)
			s:SetAttribute("Loops", false)
			s.Parent = shopMus
			activeCustomSounds[key] = s
		end
	else
		local s = activeCustomSounds[key]
		if s then
			s:Destroy()
			activeCustomSounds[key] = nil
		end
	end
end

-- Aplicar estado guardado al iniciar
for _, datos in ipairs(DATOS_CANCIONES) do
	if Menu.Settings.shop_extra_music_enabled[datos.key] then
		applyMusicToggle(datos.key, true)
	end
end

-- UI
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

local musicSection = Instance.new("Frame")
musicSection.Size = UDim2.new(1, 0, 0, 0)
musicSection.BackgroundColor3 = T.Tertiary
musicSection.BackgroundTransparency = 0.3
musicSection.BorderSizePixel = 0
musicSection.AutomaticSize = Enum.AutomaticSize.Y
roundFrame(musicSection, 6)
musicSection.Parent = mainContainer

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.Parent = musicSection

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = musicSection

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 22)
header.BackgroundTransparency = 1
header.Font = T.FontBold
header.TextSize = 15
header.TextColor3 = T.Accent
header.TextXAlignment = Enum.TextXAlignment.Left
header.Text = "🎵 Canciones extra"
header.Parent = musicSection

for _, datos in ipairs(DATOS_CANCIONES) do
	local songKey = datos.key
	local enabled = Menu.Settings.shop_extra_music_enabled[songKey] or false

	local toggleFrame = Instance.new("Frame")
	toggleFrame.Size = UDim2.new(1, 0, 0, 80)
	toggleFrame.BackgroundColor3 = T.Tertiary
	toggleFrame.BackgroundTransparency = 0.3
	toggleFrame.BorderSizePixel = 0
	roundFrame(toggleFrame, 6)
	toggleFrame.Parent = musicSection

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 200, 0, 22)
	nameLabel.Position = UDim2.new(0, 12, 0, 6)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = T.FontBold
	nameLabel.TextSize = 15
	nameLabel.TextColor3 = T.Text
	nameLabel.Text = datos.nombre
	nameLabel.Parent = toggleFrame

	local creditLabel = Instance.new("TextLabel")
	creditLabel.Size = UDim2.new(0, 200, 0, 16)
	creditLabel.Position = UDim2.new(0, 12, 0, 30)
	creditLabel.BackgroundTransparency = 1
	creditLabel.Font = T.Font
	creditLabel.TextSize = 12
	creditLabel.TextColor3 = T.TextDim
	creditLabel.Text = "Hecho por " .. datos.creador
	creditLabel.Parent = toggleFrame

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(0, 200, 0, 16)
	descLabel.Position = UDim2.new(0, 12, 0, 50)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = T.Font
	descLabel.TextSize = 10
	descLabel.TextColor3 = T.TextDim
	descLabel.Text = "Descripción próximamente..."
	descLabel.Parent = toggleFrame

	local toggleBg = Instance.new("Frame")
	toggleBg.Size = UDim2.new(0, 44, 0, 22)
	toggleBg.Position = UDim2.new(1, -56, 0, 29)
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
			applyMusicToggle(songKey, newState)
		end
	end)
end

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end