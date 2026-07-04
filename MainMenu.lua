local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

pcall(function()
	local old = PlayerGui:FindFirstChild("OutcomePanel")
	if old then old:Destroy() end
	local oldBlur = Lighting:FindFirstChild("PanelBlur")
	if oldBlur then oldBlur:Destroy() end
end)

if not _G.OutcomeSections then
	_G.OutcomeSections = {}
end

local SECTION_URLS = {
	Characters = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/sections/Characters.lua"
}

local panelOpen = false
local currentTab = nil

local function tween(obj, props, duration, easingStyle, easingDir)
	local info = TweenInfo.new(
		duration or 0.3,
		easingStyle or Enum.EasingStyle.Quad,
		easingDir or Enum.EasingDirection.Out
	)
	local t = TweenService:Create(obj, info, props)
	t:Play()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OutcomePanel"
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local Blur = Instance.new("BlurEffect")
Blur.Name = "PanelBlur"
Blur.Size = 0
Blur.Parent = Lighting

local MainPanel = Instance.new("Frame")
MainPanel.Name = "Main"
MainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
MainPanel.Size = UDim2.fromOffset(800, 550)
MainPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainPanel.Visible = false
MainPanel.Parent = ScreenGui

Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainPanel)
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Transparency = 0.8

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainPanel

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "Scripted Memories | Main Menu"
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(35, 35)
CloseBtn.Position = UDim2.new(1, -50, 0.5, -17.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0, 200, 0, 30)
SearchBox.Position = UDim2.new(1, -350, 0.5, -15)
SearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SearchBox.Text = "Search..."
SearchBox.TextColor3 = Color3.fromRGB(180, 180, 180)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 14
SearchBox.PlaceholderText = "Search..."
SearchBox.Parent = TopBar
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(1, 0)

local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainPanel.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
UIS.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
		local delta = input.Position - dragStart
		MainPanel.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -20, 1, -60)
Body.Position = UDim2.fromOffset(10, 55)
Body.BackgroundTransparency = 1
Body.Parent = MainPanel

local CategoriesFrame = Instance.new("ScrollingFrame")
CategoriesFrame.Size = UDim2.new(0, 200, 1, 0)
CategoriesFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
CategoriesFrame.BackgroundTransparency = 0.2
CategoriesFrame.BorderSizePixel = 0
CategoriesFrame.ScrollBarThickness = 0
CategoriesFrame.Parent = Body
Instance.new("UICorner", CategoriesFrame).CornerRadius = UDim.new(0, 10)

local CatLayout = Instance.new("UIListLayout")
CatLayout.SortOrder = Enum.SortOrder.LayoutOrder
CatLayout.Padding = UDim.new(0, 5)
CatLayout.Parent = CategoriesFrame

local ControlsFrame = Instance.new("ScrollingFrame")
ControlsFrame.Size = UDim2.new(1, -210, 1, 0)
ControlsFrame.Position = UDim2.fromOffset(210, 0)
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.BorderSizePixel = 0
ControlsFrame.ScrollBarThickness = 4
ControlsFrame.Parent = Body

local ControlsLayout = Instance.new("UIListLayout")
ControlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ControlsLayout.Padding = UDim.new(0, 8)
ControlsLayout.Parent = ControlsFrame

local CategoryNames = {
	"Characters",
	"Visuals",
	"Shop",
	"Lobby",
}

local CategoryButtons = {}

local function SelectCategory(tabName)
	for _, b in ipairs(CategoryButtons) do
		local strip = b:FindFirstChild("SideStrip")
		if strip then strip:Destroy() end
		b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		b.TextColor3 = Color3.fromRGB(200, 200, 200)
		tween(b, {Size = UDim2.new(1, -10, 0, 40)}, 0.2)
	end

	local activeBtn
	for _, b in ipairs(CategoryButtons) do
		if b.Text == tabName then
			activeBtn = b
			break
		end
	end

	if activeBtn then
		activeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		activeBtn.TextColor3 = Color3.new(1,1,1)
		tween(activeBtn, {Size = UDim2.new(1, 0, 0, 40)}, 0.2)

		local strip = Instance.new("Frame")
		strip.Name = "SideStrip"
		strip.Size = UDim2.new(0, 4, 1, 0)
		strip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		strip.BorderSizePixel = 0
		strip.Parent = activeBtn
	end

	currentTab = tabName

	for _, child in ipairs(ControlsFrame:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	ControlsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

	local sectionFunc = _G.OutcomeSections[tabName]
	if not sectionFunc and SECTION_URLS[tabName] then
		local success, result = pcall(function() return game:HttpGet(SECTION_URLS[tabName]) end)
		if success and result then
			local loadSuccess, loadErr = pcall(loadstring(result))
			if loadSuccess then
				sectionFunc = _G.OutcomeSections[tabName]
			else
				warn("Error loading section " .. tabName .. ": " .. loadErr)
			end
		end
	end

	if sectionFunc then
		sectionFunc(ControlsFrame)
	else
		local placeholder = Instance.new("TextLabel")
		placeholder.Size = UDim2.new(1, 0, 0, 30)
		placeholder.Position = UDim2.new(0, 0, 0, 10)
		placeholder.BackgroundTransparency = 1
		placeholder.Text = tabName .. " (no module loaded)"
		placeholder.TextColor3 = Color3.fromRGB(180, 180, 180)
		placeholder.Font = Enum.Font.Gotham
		placeholder.TextSize = 14
		placeholder.Parent = ControlsFrame
	end
end

for _, catName in ipairs(CategoryNames) do
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, -10, 0, 40)
	Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Btn.Text = catName
	Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 13
	Btn.Parent = CategoriesFrame
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

	Btn.MouseButton1Click:Connect(function()
		SelectCategory(catName)
	end)

	table.insert(CategoryButtons, Btn)

	if catName == CategoryNames[1] then
		SelectCategory(catName)
	end
end

task.wait(0.1)
CategoriesFrame.CanvasSize = UDim2.fromOffset(0, CatLayout.AbsoluteContentSize.Y + 10)
CatLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	CategoriesFrame.CanvasSize = UDim2.fromOffset(0, CatLayout.AbsoluteContentSize.Y + 10)
end)

SearchBox.Focused:Connect(function()
	if SearchBox.Text == "Search..." then SearchBox.Text = "" end
end)
SearchBox.FocusLost:Connect(function()
	if SearchBox.Text == "" then SearchBox.Text = "Search..." end
end)

local function SetPanelState(state)
	panelOpen = state
	if state then
		MainPanel.Visible = true
		tween(MainPanel, {Size = UDim2.fromOffset(800, 550)}, 0.5, Enum.EasingStyle.Back)
		tween(MainPanel, {BackgroundTransparency = 0}, 0.3)
		tween(Blur, {Size = 16}, 0.3)
	else
		tween(MainPanel, {Size = UDim2.fromOffset(400, 300)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		tween(MainPanel, {BackgroundTransparency = 1}, 0.3)
		tween(Blur, {Size = 0}, 0.3)
		task.wait(0.3)
		MainPanel.Visible = false
	end
end

CloseBtn.MouseButton1Click:Connect(function()
	if panelOpen then SetPanelState(false) end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
		SetPanelState(not panelOpen)
	end
end)