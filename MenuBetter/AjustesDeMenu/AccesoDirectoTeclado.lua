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

local function keyCodeToName(keyCode)
	if not keyCode then return "Desconocida" end
	local name = tostring(keyCode):gsub("^Enum%.KeyCode%.", "")
	name = name:gsub("RightControl", "Ctrl Der.")
	name = name:gsub("LeftControl", "Ctrl Izq.")
	name = name:gsub("RightShift", "Shift Der.")
	name = name:gsub("LeftShift", "Shift Izq.")
	name = name:gsub("RightAlt", "Alt Der.")
	name = name:gsub("LeftAlt", "Alt Izq.")
	name = name:gsub("Backspace", "Retroceso")
	name = name:gsub("Return", "Enter")
	name = name:gsub("Space", "Espacio")
	return name
end

local currentKeyName = Menu.Settings.menu_keybind or "M"
local currentKeyCode = Enum.KeyCode[currentKeyName] or Enum.KeyCode.M

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
header.Text = "⌨️ Atajo de Teclado"
header.Parent = sectionFrame

local keybindBtn = Instance.new("TextButton")
keybindBtn.Size = UDim2.new(1, 0, 0, 42)
keybindBtn.BackgroundColor3 = T.Tertiary
keybindBtn.BorderSizePixel = 0
keybindBtn.AutoButtonColor = false
keybindBtn.Font = T.FontBold
keybindBtn.TextSize = 15
keybindBtn.TextColor3 = T.Text
keybindBtn.Text = "⌨️ Cambiar tecla"
roundFrame(keybindBtn, 6)
keybindBtn.Parent = sectionFrame

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Size = UDim2.new(1, 0, 0, 20)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Font = T.Font
keybindLabel.TextSize = 12
keybindLabel.TextColor3 = T.TextDim
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.Text = "Atajo actual: " .. keyCodeToName(currentKeyCode)
keybindLabel.Parent = sectionFrame

local capturingKeyboard = false
local captureKeyboardConn

local function stopKeyboardCapture()
	capturingKeyboard = false
	Menu._capturingKey = false
	if captureKeyboardConn then
		captureKeyboardConn:Disconnect()
		captureKeyboardConn = nil
	end
	keybindBtn.Text = "⌨️ Cambiar tecla"
	TweenService:Create(keybindBtn, TweenInfo.new(.15), {BackgroundColor3 = T.Tertiary}):Play()
end

local function startKeyboardCapture()
	if capturingKeyboard then return end
	capturingKeyboard = true
	Menu._capturingKey = true
	TweenService:Create(keybindBtn, TweenInfo.new(.15), {BackgroundColor3 = Color3.fromRGB(70,90,145)}):Play()
	local dots = 0
	task.spawn(function()
		while capturingKeyboard do
			dots = (dots % 3) + 1
			keybindBtn.Text = "⌨️ Presiona una tecla" .. string.rep(".", dots)
			task.wait(0.4)
		end
	end)
	captureKeyboardConn = UIS.InputBegan:Connect(function(input)
		if not capturingKeyboard then return end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if input.KeyCode == Enum.KeyCode.Unknown then return end
		local newKey = tostring(input.KeyCode):gsub("^Enum%.KeyCode%.","")
		Menu.Settings.menu_keybind = newKey
		if Menu.SaveSettings then Menu.SaveSettings() end
		keybindLabel.Text = "Atajo actual: " .. keyCodeToName(input.KeyCode)
		stopKeyboardCapture()
	end)
end

keybindBtn.MouseButton1Click:Connect(function()
	if not capturingKeyboard then startKeyboardCapture() end
end)

keybindBtn.MouseEnter:Connect(function()
	if not capturingKeyboard then
		TweenService:Create(keybindBtn, TweenInfo.new(.15), {BackgroundColor3 = T.Hover}):Play()
	end
end)
keybindBtn.MouseLeave:Connect(function()
	if not capturingKeyboard then
		TweenService:Create(keybindBtn, TweenInfo.new(.15), {BackgroundColor3 = T.Tertiary}):Play()
	end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end