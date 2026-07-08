local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

_G.MemoryMenu = {
	Settings = {},
	LoadedScripts = {},
	Sections = {},
	WindowVisible = false,
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptedMemoriesMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 550, 0, 420)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "Scripted Memories | MainMenu"
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "X"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TitleBar
CloseButton.MouseButton1Click:Connect(function()
	_G.MemoryMenu.WindowVisible = false
	MainFrame.Visible = false
end)

local TabScroller = Instance.new("ScrollingFrame")
TabScroller.Size = UDim2.new(1, 0, 0, 25)
TabScroller.Position = UDim2.new(0, 0, 0, 30)
TabScroller.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TabScroller.BorderSizePixel = 0
TabScroller.ScrollBarThickness = 3
TabScroller.CanvasSize = UDim2.new(0, 0, 0, 25)
TabScroller.ScrollingDirection = Enum.ScrollingDirection.X
TabScroller.VerticalScrollBarInset = Enum.ScrollBarInset.None
TabScroller.Parent = MainFrame

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 0, 1, 0)
TabContainer.AutomaticSize = Enum.AutomaticSize.X
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = TabScroller

local UIListTabs = Instance.new("UIListLayout")
UIListTabs.FillDirection = Enum.FillDirection.Horizontal
UIListTabs.SortOrder = Enum.SortOrder.LayoutOrder
UIListTabs.Parent = TabContainer

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -10, 1, -60)
ContentFrame.Position = UDim2.new(0, 5, 0, 60)
ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ScrollingDirection = Enum.ScrollingDirection.XY
ContentFrame.Parent = MainFrame

local colTab = Color3.fromRGB(40, 40, 40)
local colTabSel = Color3.fromRGB(60, 60, 60)
local colBg1 = Color3.fromRGB(45, 45, 45)
local colBg2 = Color3.fromRGB(50, 50, 50)
local colBg3 = Color3.fromRGB(35, 35, 35)
local colGreen = Color3.fromRGB(0, 170, 0)
local colRed = Color3.fromRGB(170, 0, 0)
local colWhite = Color3.new(1, 1, 1)
local fontGotham = Enum.Font.Gotham
local fontGothamBold = Enum.Font.GothamBold

local TabsList = {}
local activeTab = nil

local function switchTab(tab)
	if activeTab then
		activeTab.Button.BackgroundColor3 = colTab
		activeTab.Frame.Visible = false
	end
	tab.Button.BackgroundColor3 = colTabSel
	tab.Frame.Visible = true
	activeTab = tab
end

local function createSection(name)
	local tabButton = Instance.new("TextButton")
	tabButton.Text = name
	tabButton.Size = UDim2.new(0, 0, 1, 0)
	tabButton.AutomaticSize = Enum.AutomaticSize.X
	tabButton.BackgroundColor3 = colTab
	tabButton.TextColor3 = colWhite
	tabButton.Font = fontGotham
	tabButton.TextSize = 14
	tabButton.BorderSizePixel = 0
	tabButton.Parent = TabContainer

	local sectionFrame = Instance.new("Frame")
	sectionFrame.Size = UDim2.new(1, -10, 0, 10)
	sectionFrame.Position = UDim2.new(0, 5, 0, 5)
	sectionFrame.BackgroundColor3 = colBg3
	sectionFrame.BorderSizePixel = 0
	sectionFrame.Visible = false
	sectionFrame.Parent = ContentFrame

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 5)
	uiPadding.PaddingBottom = UDim.new(0, 5)
	uiPadding.PaddingLeft = UDim.new(0, 5)
	uiPadding.PaddingRight = UDim.new(0, 5)
	uiPadding.Parent = sectionFrame

	local uiList = Instance.new("UIListLayout")
	uiList.Padding = UDim.new(0, 5)
	uiList.Parent = sectionFrame

	local section = {
		Name = name,
		Button = tabButton,
		Frame = sectionFrame,
		Elements = {},
	}

	tabButton.MouseButton1Click:Connect(function()
		switchTab(section)
	end)

	table.insert(TabsList, section)
	return section
end

function _G.MemoryMenu.AddSection(name)
	if _G.MemoryMenu.Sections[name] then
		return _G.MemoryMenu.Sections[name]
	end
	local section = createSection(name)
	_G.MemoryMenu.Sections[name] = section

	if #TabsList == 1 then
		switchTab(section)
	end

	TabScroller.CanvasSize = UDim2.new(0, TabContainer.AbsoluteSize.X, 0, 25)

	return section
end

local function getSetting(id, default)
	if _G.MemoryMenu.Settings[id] ~= nil then
		return _G.MemoryMenu.Settings[id]
	else
		return default
	end
end

local function setSetting(id, value)
	_G.MemoryMenu.Settings[id] = value
	task.defer(_G.MemoryMenu.SaveSettings)
end

function _G.MemoryMenu.SaveSettings()
	local HttpService = game:GetService("HttpService")
	local data = HttpService:JSONEncode(_G.MemoryMenu.Settings)
	local settingsContainer = PlayerGui:FindFirstChild("ScriptedMemoriesSettings")
	if not settingsContainer then
		settingsContainer = Instance.new("StringValue")
		settingsContainer.Name = "ScriptedMemoriesSettings"
		settingsContainer.ResetOnSpawn = false
		settingsContainer.Parent = PlayerGui
	end
	settingsContainer.Value = data
end

function _G.MemoryMenu.LoadSettings()
	local settingsContainer = PlayerGui:FindFirstChild("ScriptedMemoriesSettings")
	if settingsContainer and settingsContainer.Value ~= "" then
		local HttpService = game:GetService("HttpService")
		local success, decoded = pcall(HttpService.JSONDecode, HttpService, settingsContainer.Value)
		if success and type(decoded) == "table" then
			for k, v in pairs(decoded) do
				_G.MemoryMenu.Settings[k] = v
			end
		end
	end
end

_G.MemoryMenu.LoadSettings()

local infoSection = _G.MemoryMenu.AddSection("Info")
infoSection.Frame.Size = UDim2.new(1, -10, 0, 80)
local infoLabel = Instance.new("TextLabel")
infoLabel.Text = "Scripted Memories\nEs un paquete de scripts que buscan mejorar la experiencia de Outcome Memories sin dañar la experiencia a los demas."
infoLabel.Size = UDim2.new(1, -20, 0, 60)
infoLabel.Position = UDim2.new(0, 10, 0, 10)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = colWhite
infoLabel.Font = fontGotham
infoLabel.TextSize = 14
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Center
infoLabel.TextYAlignment = Enum.TextYAlignment.Center
infoLabel.Parent = infoSection.Frame

local remoteScripts = {
	"https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/Characters.lua",
}

local function loadScript(url)
	local success, source = pcall(game.HttpGet, game, url)
	if not success or not source then return false end
	local f, err = loadstring(source)
	if not f then return false end
	local scriptSuccess, scriptErr = pcall(f)
	if not scriptSuccess then return false end
	return true
end

for _, url in ipairs(remoteScripts) do
	loadScript(url)
end

local function createToggle(id, text, default, parentFrame)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -10, 0, 40)
	container.BackgroundColor3 = colBg1
	container.BorderSizePixel = 0
	container.Parent = parentFrame

	local label = Instance.new("TextLabel")
	label.Text = text
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = colWhite
	label.Font = fontGotham
	label.TextSize = 14
	label.Parent = container

	local button = Instance.new("TextButton")
	button.Text = getSetting(id, default) and "ON" or "OFF"
	button.Size = UDim2.new(0, 60, 0, 28)
	button.Position = UDim2.new(0.8, 0, 0.5, -14)
	button.BackgroundColor3 = getSetting(id, default) and colGreen or colRed
	button.TextColor3 = colWhite
	button.Font = fontGothamBold
	button.TextSize = 14
	button.BorderSizePixel = 0
	button.Parent = container

	local state = getSetting(id, default)
	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = state and "ON" or "OFF"
		button.BackgroundColor3 = state and colGreen or colRed
		setSetting(id, state)
	end)

	return container
end

local function createSlider(id, text, min, max, default, parentFrame)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -10, 0, 60)
	container.BackgroundColor3 = colBg1
	container.BorderSizePixel = 0
	container.Parent = parentFrame

	local label = Instance.new("TextLabel")
	label.Text = text .. ": " .. getSetting(id, default)
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.TextColor3 = colWhite
	label.Font = fontGotham
	label.TextSize = 14
	label.Parent = container

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(0, 120, 0, 24)
	textBox.Position = UDim2.new(0, 0, 0, 28)
	textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	textBox.TextColor3 = colWhite
	textBox.Font = fontGotham
	textBox.TextSize = 14
	textBox.Text = tostring(getSetting(id, default))
	textBox.Parent = container

	textBox.FocusLost:Connect(function()
		local num = tonumber(textBox.Text)
		if num then
			num = math.clamp(num, min, max)
			textBox.Text = tostring(num)
			label.Text = text .. ": " .. num
			setSetting(id, num)
		else
			textBox.Text = tostring(getSetting(id, default))
		end
	end)

	return container
end

local function createDropdown(id, text, options, defaultIndex, parentFrame)
	local currentIndex = getSetting(id, defaultIndex) or defaultIndex
	if currentIndex < 1 or currentIndex > #options then currentIndex = 1 end

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -10, 0, 40)
	container.BackgroundColor3 = colBg1
	container.BorderSizePixel = 0
	container.Parent = parentFrame

	local button = Instance.new("TextButton")
	button.Text = text .. ": " .. options[currentIndex]
	button.Size = UDim2.new(1, -10, 0, 30)
	button.Position = UDim2.new(0, 5, 0, 5)
	button.BackgroundColor3 = colBg2
	button.TextColor3 = colWhite
	button.Font = fontGotham
	button.TextSize = 14
	button.BorderSizePixel = 0
	button.Parent = container

	button.MouseButton1Click:Connect(function()
		currentIndex = currentIndex % #options + 1
		button.Text = text .. ": " .. options[currentIndex]
		setSetting(id, currentIndex)
	end)

	return container
end

local function createButton(text, callback, parentFrame)
	local button = Instance.new("TextButton")
	button.Text = text
	button.Size = UDim2.new(1, -10, 0, 36)
	button.BackgroundColor3 = colBg2
	button.TextColor3 = colWhite
	button.Font = fontGothamBold
	button.TextSize = 14
	button.BorderSizePixel = 0
	button.Parent = parentFrame

	button.MouseButton1Click:Connect(callback)
	return button
end

function _G.MemoryMenu.AddToggle(sectionName, id, text, default)
	local section = _G.MemoryMenu.Sections[sectionName]
	if not section then return end
	local element = createToggle(id, text, default, section.Frame)
	table.insert(section.Elements, element)
	local newHeight = 0
	for _, e in ipairs(section.Elements) do
		newHeight = newHeight + e.AbsoluteSize.Y + 5
	end
	section.Frame.Size = UDim2.new(1, -10, 0, newHeight + 10)
	ContentFrame.CanvasSize = UDim2.new(0, ContentFrame.AbsoluteSize.X, 0, section.Frame.Size.Y.Offset + 30)
end

function _G.MemoryMenu.AddSlider(sectionName, id, text, min, max, default)
	local section = _G.MemoryMenu.Sections[sectionName]
	if not section then return end
	local element = createSlider(id, text, min, max, default, section.Frame)
	table.insert(section.Elements, element)
	local newHeight = 0
	for _, e in ipairs(section.Elements) do
		newHeight = newHeight + e.AbsoluteSize.Y + 5
	end
	section.Frame.Size = UDim2.new(1, -10, 0, newHeight + 10)
	ContentFrame.CanvasSize = UDim2.new(0, ContentFrame.AbsoluteSize.X, 0, section.Frame.Size.Y.Offset + 30)
end

function _G.MemoryMenu.AddDropdown(sectionName, id, text, options, defaultIndex)
	local section = _G.MemoryMenu.Sections[sectionName]
	if not section then return end
	local element = createDropdown(id, text, options, defaultIndex, section.Frame)
	table.insert(section.Elements, element)
	local newHeight = 0
	for _, e in ipairs(section.Elements) do
		newHeight = newHeight + e.AbsoluteSize.Y + 5
	end
	section.Frame.Size = UDim2.new(1, -10, 0, newHeight + 10)
	ContentFrame.CanvasSize = UDim2.new(0, ContentFrame.AbsoluteSize.X, 0, section.Frame.Size.Y.Offset + 30)
end

function _G.MemoryMenu.AddButton(sectionName, text, callback)
	local section = _G.MemoryMenu.Sections[sectionName]
	if not section then return end
	local element = createButton(text, callback, section.Frame)
	table.insert(section.Elements, element)
	local newHeight = 0
	for _, e in ipairs(section.Elements) do
		newHeight = newHeight + e.AbsoluteSize.Y + 5
	end
	section.Frame.Size = UDim2.new(1, -10, 0, newHeight + 10)
	ContentFrame.CanvasSize = UDim2.new(0, ContentFrame.AbsoluteSize.X, 0, section.Frame.Size.Y.Offset + 30)
end

-- Exponer el ContentFrame para builders personalizados
function _G.MemoryMenu.GetContentFrame()
	return ContentFrame
end

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		_G.MemoryMenu.WindowVisible = not _G.MemoryMenu.WindowVisible
		MainFrame.Visible = _G.MemoryMenu.WindowVisible
	end
end)