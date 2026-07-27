local OPTION_NAME = "Canciones extra a la tienda"
local OPTION_DESCRIPTION = "Añade canciones adicionales a la tienda"
local SETTING_KEY = "shop_extra_music_enabled"
local DEFAULT_VALUE = {}

local Menu = _G.Menu
if not Menu then return end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
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

if not Menu.Settings[SETTING_KEY] then
	Menu.Settings[SETTING_KEY] = DEFAULT_VALUE
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

for _, datos in ipairs(DATOS_CANCIONES) do
	if Menu.Settings[SETTING_KEY][datos.key] then
		applyMusicToggle(datos.key, true)
	end
end

local page = Menu.Pages[#Menu.Pages]
if not page then return end

local T = Menu.THEME
local RADIUS = T.Radius or 6
local PADDING = 12
local SWITCH_WIDTH = 36
local SWITCH_HEIGHT = 20
local KNOB_SIZE = 14
local KNOB_OFFSET = 2

local function roundFrame(frame, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or RADIUS)
	corner.Parent = frame
	return corner
end

local function card(parent)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 0)
	f.BackgroundColor3 = T.Secondary
	f.BackgroundTransparency = 0.15
	f.BorderSizePixel = 0
	f.AutomaticSize = Enum.AutomaticSize.Y
	f.Parent = parent
	roundFrame(f, RADIUS)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, PADDING)
	padding.PaddingRight = UDim.new(0, PADDING)
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.Parent = f

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = f

	return f
end

local function infoText(parent, text, font, size, color)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 0)
	l.AutomaticSize = Enum.AutomaticSize.Y
	l.BackgroundTransparency = 1
	l.Font = font or T.Font
	l.TextSize = size or 14
	l.TextColor3 = color or T.Text
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	l.Text = text
	l:SetAttribute("SM_Protected", true)
	l.Parent = parent
	return l
end

local sectionFrame = card(page.Frame)

local sectionHeader = Instance.new("TextLabel")
sectionHeader.Size = UDim2.new(1, 0, 0, 0)
sectionHeader.AutomaticSize = Enum.AutomaticSize.Y
sectionHeader.BackgroundTransparency = 1
sectionHeader.Font = T.FontBold
sectionHeader.TextSize = 15
sectionHeader.TextColor3 = T.Accent
sectionHeader.TextXAlignment = Enum.TextXAlignment.Left
sectionHeader.TextWrapped = true
sectionHeader.Text = OPTION_NAME
sectionHeader:SetAttribute("SM_Protected", true)
sectionHeader.Parent = sectionFrame

local sectionDesc = infoText(sectionFrame, OPTION_DESCRIPTION, T.Font, 12, T.TextDim)

local div = Instance.new("Frame")
div.Size = UDim2.new(1, 0, 0, 1)
div.BorderSizePixel = 0
div.BackgroundColor3 = T.Border
div.Parent = sectionFrame

for _, datos in ipairs(DATOS_CANCIONES) do
	local songKey = datos.key
	local enabled = Menu.Settings[SETTING_KEY][songKey] or false

	local songCard = Instance.new("Frame")
	songCard.Size = UDim2.new(1, 0, 0, 0)
	songCard.BackgroundColor3 = T.Tertiary
	songCard.BackgroundTransparency = 0.3
	songCard.BorderSizePixel = 0
	songCard.AutomaticSize = Enum.AutomaticSize.Y
	roundFrame(songCard, RADIUS)
	songCard.Parent = sectionFrame

	local cardPadding = Instance.new("UIPadding")
	cardPadding.PaddingLeft = UDim.new(0, PADDING)
	cardPadding.PaddingRight = UDim.new(0, PADDING)
	cardPadding.PaddingTop = UDim.new(0, 6)
	cardPadding.PaddingBottom = UDim.new(0, 6)
	cardPadding.Parent = songCard

	local rowFrame = Instance.new("Frame")
	rowFrame.Size = UDim2.new(1, 0, 0, 0)
	rowFrame.AutomaticSize = Enum.AutomaticSize.Y
	rowFrame.BackgroundTransparency = 1
	rowFrame.Parent = songCard

	local rowLayout = Instance.new("UIListLayout")
	rowLayout.FillDirection = Enum.FillDirection.Horizontal
	rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rowLayout.Padding = UDim.new(0, 10)
	rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	rowLayout.Parent = rowFrame

	local songTextFrame = Instance.new("Frame")
	songTextFrame.Size = UDim2.new(1, -(SWITCH_WIDTH + 10), 0, 0)
	songTextFrame.AutomaticSize = Enum.AutomaticSize.Y
	songTextFrame.BackgroundTransparency = 1
	songTextFrame.Parent = rowFrame

	local songTextLayout = Instance.new("UIListLayout")
	songTextLayout.Padding = UDim.new(0, 2)
	songTextLayout.SortOrder = Enum.SortOrder.LayoutOrder
	songTextLayout.Parent = songTextFrame

	infoText(songTextFrame, datos.nombre, T.FontBold, 14, T.Text)
	infoText(songTextFrame, "Hecho por " .. datos.creador, T.Font, 12, T.TextDim)

	local switchFrame = Instance.new("Frame")
	switchFrame.Size = UDim2.new(0, SWITCH_WIDTH, 0, SWITCH_HEIGHT)
	switchFrame.BackgroundColor3 = enabled and T.Green or T.Red
	switchFrame.BorderSizePixel = 0
	switchFrame.Parent = rowFrame
	roundFrame(switchFrame, SWITCH_HEIGHT / 2)

	local switchKnob = Instance.new("Frame")
	switchKnob.Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE)
	switchKnob.Position = enabled and
		UDim2.new(0, SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET, 0, KNOB_OFFSET) or
		UDim2.new(0, KNOB_OFFSET, 0, KNOB_OFFSET)
	switchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	switchKnob.BorderSizePixel = 0
	switchKnob.Parent = switchFrame
	roundFrame(switchKnob, KNOB_SIZE / 2)

	local function updateVisual(state)
		switchFrame.BackgroundColor3 = state and T.Green or T.Red
		local targetX = state and SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET or KNOB_OFFSET
		TweenService:Create(switchKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
			Position = UDim2.new(0, targetX, 0, KNOB_OFFSET)
		}):Play()
	end

	switchFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local newState = not (Menu.Settings[SETTING_KEY][songKey] or false)
			Menu.Settings[SETTING_KEY][songKey] = newState
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