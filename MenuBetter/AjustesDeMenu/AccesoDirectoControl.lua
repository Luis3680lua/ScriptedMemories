local Menu = _G.Menu
if not Menu then return end

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

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

local function gamepadButtonToName(buttonEnum)
	if not buttonEnum then return "Desconocido" end
	local name = tostring(buttonEnum):gsub("^Enum%.KeyCode%.", "")
	local map = {
		ButtonA = "A", ButtonB = "B", ButtonX = "X", ButtonY = "Y",
		ButtonL1 = "LB", ButtonR1 = "RB", ButtonL2 = "LT", ButtonR2 = "RT",
		ButtonL3 = "L3", ButtonR3 = "R3",
		DPadUp = "D-Pad Arriba", DPadDown = "D-Pad Abajo",
		DPadLeft = "D-Pad Izquierda", DPadRight = "D-Pad Derecha",
		Start = "Start", Select = "Select"
	}
	if map[name] then return map[name] end
	name = name:gsub("Button", "Botón ")
	name = name:gsub("DPad", "D-Pad ")
	return name
end

local currentControllerKeyName = Menu.Settings.menu_controller_keybind or "ButtonL3"
local currentControllerKeyCode = Enum.KeyCode[currentControllerKeyName] or Enum.KeyCode.ButtonL3

local sectionFrame = Instance.new("Frame")
sectionFrame.Size = UDim2.new(1, 0, 0, 0)
sectionFrame.BackgroundColor3 = T.Tertiary
sectionFrame.BackgroundTransparency = 0.3
sectionFrame.BorderSizePixel = 0
sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
roundFrame(sectionFrame, 6)
sectionFrame.Parent = page.Frame

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.Parent = sectionFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = sectionFrame

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 22)
header.BackgroundTransparency = 1
header.Font = T.FontBold
header.TextSize = 15
header.TextColor3 = T.Text
header.TextXAlignment = Enum.TextXAlignment.Left
header.Text = "🎮 Atajo de Control"
header.Parent = sectionFrame

local controllerBtn = Instance.new("TextButton")
controllerBtn.Size = UDim2.new(1, 0, 0, 42)
controllerBtn.BackgroundColor3 = T.Tertiary
controllerBtn.BorderSizePixel = 0
controllerBtn.AutoButtonColor = false
controllerBtn.Font = T.FontBold
controllerBtn.TextSize = 15
controllerBtn.TextColor3 = T.Text
controllerBtn.Text = "🎮 Cambiar botón"
roundFrame(controllerBtn, 6)
controllerBtn.Parent = sectionFrame

local controllerLabel = Instance.new("TextLabel")
controllerLabel.Size = UDim2.new(1, 0, 0, 20)
controllerLabel.BackgroundTransparency = 1
controllerLabel.Font = T.Font
controllerLabel.TextSize = 12
controllerLabel.TextColor3 = T.TextDim
controllerLabel.TextXAlignment = Enum.TextXAlignment.Left
controllerLabel.Text = "Atajo actual: " .. gamepadButtonToName(currentControllerKeyCode)
controllerLabel.Parent = sectionFrame

local capturingController = false
local captureControllerConn

local function stopControllerCapture()
	capturingController = false
	Menu._capturingKey = false
	if captureControllerConn then
		captureControllerConn:Disconnect()
		captureControllerConn = nil
	end
	controllerBtn.Text = "🎮 Cambiar botón"
	TweenService:Create(controllerBtn, TweenInfo.new(.15), {BackgroundColor3 = T.Tertiary}):Play()
end

local function startControllerCapture()
	if capturingController then return end
	capturingController = true
	Menu._capturingKey = true
	TweenService:Create(controllerBtn, TweenInfo.new(.15), {BackgroundColor3 = Color3.fromRGB(70,90,145)}):Play()
	local dots = 0
	task.spawn(function()
		while capturingController do
			dots = (dots % 3) + 1
			controllerBtn.Text = "🎮 Presiona un botón" .. string.rep(".", dots)
			task.wait(0.4)
		end
	end)
	captureControllerConn = UIS.InputBegan:Connect(function(input)
		if not capturingController then return end
		if input.UserInputType ~= Enum.UserInputType.Gamepad1 then return end
		local btn = input.KeyCode
		if btn == Enum.KeyCode.Unknown then return end
		local newKey = tostring(btn):gsub("^Enum%.KeyCode%.","")
		Menu.Settings.menu_controller_keybind = newKey
		if Menu.SaveSettings then Menu.SaveSettings() end
		controllerLabel.Text = "Atajo actual: " .. gamepadButtonToName(btn)
		stopControllerCapture()
	end)
end

controllerBtn.MouseButton1Click:Connect(function()
	if not capturingController then startControllerCapture() end
end)

controllerBtn.MouseEnter:Connect(function()
	if not capturingController then
		TweenService:Create(controllerBtn, TweenInfo.new(.15), {BackgroundColor3 = T.Hover}):Play()
	end
end)
controllerBtn.MouseLeave:Connect(function()
	if not capturingController then
		TweenService:Create(controllerBtn, TweenInfo.new(.15), {BackgroundColor3 = T.Tertiary}):Play()
	end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end