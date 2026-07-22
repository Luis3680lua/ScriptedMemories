local Menu = _G.Menu
if not Menu then return end

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local page = Menu:RegisterPage("Ajustes de Menú", "⚙️")
page.Frame.Size = UDim2.new(1, -4, 0, 480)
page.Frame.BackgroundTransparency = 1

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
	DisabledBg = Color3.fromRGB(30, 30, 38),
	DisabledText = Color3.fromRGB(100, 100, 110),
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

local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 0, 0)
container.Position = UDim2.new(0, 0, 0, 0)
container.BackgroundTransparency = 1
container.AutomaticSize = Enum.AutomaticSize.Y
container.Parent = page.Frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 28)
title.Position = UDim2.new(0, 6, 0, 4)
title.BackgroundTransparency = 1
title.Font = T.FontBold
title.TextSize = 20
title.TextColor3 = T.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "⚙️ Ajustes del Menú"
title.Parent = container

local description = Instance.new("TextLabel")
description.Size = UDim2.new(1, -12, 0, 42)
description.Position = UDim2.new(0, 6, 0, 36)
description.BackgroundTransparency = 1
description.Font = T.Font
description.TextSize = 13
description.TextWrapped = true
description.TextColor3 = T.TextDim
description.TextXAlignment = Enum.TextXAlignment.Left
description.TextYAlignment = Enum.TextYAlignment.Top
description.Text = "Personaliza algunos aspectos del menú. Los cambios se guardan automáticamente."
description.Parent = container

local divider1 = Instance.new("Frame")
divider1.Size = UDim2.new(1, -12, 0, 1)
divider1.Position = UDim2.new(0, 6, 0, 84)
divider1.BorderSizePixel = 0
divider1.BackgroundColor3 = T.Border
divider1.Parent = container

local keyboardSection = Instance.new("Frame")
keyboardSection.Size = UDim2.new(1, -12, 0, 0)
keyboardSection.Position = UDim2.new(0, 6, 0, 92)
keyboardSection.BackgroundColor3 = T.Tertiary
keyboardSection.BackgroundTransparency = 0.3
keyboardSection.BorderSizePixel = 0
keyboardSection.AutomaticSize = Enum.AutomaticSize.Y
roundFrame(keyboardSection, 6)
keyboardSection.Parent = container

local keyboardPadding = Instance.new("UIPadding")
keyboardPadding.PaddingLeft = UDim.new(0, 12)
keyboardPadding.PaddingRight = UDim.new(0, 12)
keyboardPadding.PaddingTop = UDim.new(0, 8)
keyboardPadding.PaddingBottom = UDim.new(0, 8)
keyboardPadding.Parent = keyboardSection

local keyboardLayout = Instance.new("UIListLayout")
keyboardLayout.Padding = UDim.new(0, 6)
keyboardLayout.SortOrder = Enum.SortOrder.LayoutOrder
keyboardLayout.Parent = keyboardSection

local kbHeader = Instance.new("TextLabel")
kbHeader.Size = UDim2.new(1, 0, 0, 22)
kbHeader.BackgroundTransparency = 1
kbHeader.Font = T.FontBold
kbHeader.TextSize = 15
kbHeader.TextColor3 = T.Text
kbHeader.TextXAlignment = Enum.TextXAlignment.Left
kbHeader.Text = "⌨️ Atajo de Teclado"
kbHeader.Parent = keyboardSection

local currentKeyName = Menu.Settings.menu_keybind or "M"
local currentKeyCode = Enum.KeyCode[currentKeyName] or Enum.KeyCode.M

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
keybindBtn.Parent = keyboardSection

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Size = UDim2.new(1, 0, 0, 20)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Font = T.Font
keybindLabel.TextSize = 12
keybindLabel.TextColor3 = T.TextDim
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.Text = "Atajo actual: " .. keyCodeToName(currentKeyCode)
keybindLabel.Parent = keyboardSection

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

local divider2 = Instance.new("Frame")
divider2.Size = UDim2.new(1, -12, 0, 1)
divider2.Position = UDim2.new(0, 6, 0, 0)
divider2.BorderSizePixel = 0
divider2.BackgroundColor3 = T.Border
divider2.Parent = container

local controllerSection = Instance.new("Frame")
controllerSection.Size = UDim2.new(1, -12, 0, 0)
controllerSection.BackgroundColor3 = T.Tertiary
controllerSection.BackgroundTransparency = 0.3
controllerSection.BorderSizePixel = 0
controllerSection.AutomaticSize = Enum.AutomaticSize.Y
roundFrame(controllerSection, 6)
controllerSection.Parent = container

local controllerPadding = Instance.new("UIPadding")
controllerPadding.PaddingLeft = UDim.new(0, 12)
controllerPadding.PaddingRight = UDim.new(0, 12)
controllerPadding.PaddingTop = UDim.new(0, 8)
controllerPadding.PaddingBottom = UDim.new(0, 8)
controllerPadding.Parent = controllerSection

local controllerLayout = Instance.new("UIListLayout")
controllerLayout.Padding = UDim.new(0, 6)
controllerLayout.SortOrder = Enum.SortOrder.LayoutOrder
controllerLayout.Parent = controllerSection

local ctrlHeader = Instance.new("TextLabel")
ctrlHeader.Size = UDim2.new(1, 0, 0, 22)
ctrlHeader.BackgroundTransparency = 1
ctrlHeader.Font = T.FontBold
ctrlHeader.TextSize = 15
ctrlHeader.TextColor3 = T.Text
ctrlHeader.TextXAlignment = Enum.TextXAlignment.Left
ctrlHeader.Text = "🎮 Atajo de Control"
ctrlHeader.Parent = controllerSection

local currentControllerKeyName = Menu.Settings.menu_controller_keybind or "ButtonL3"
local currentControllerKeyCode = Enum.KeyCode[currentControllerKeyName] or Enum.KeyCode.ButtonL3

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
controllerBtn.Parent = controllerSection

local controllerLabel = Instance.new("TextLabel")
controllerLabel.Size = UDim2.new(1, 0, 0, 20)
controllerLabel.BackgroundTransparency = 1
controllerLabel.Font = T.Font
controllerLabel.TextSize = 12
controllerLabel.TextColor3 = T.TextDim
controllerLabel.TextXAlignment = Enum.TextXAlignment.Left
controllerLabel.Text = "Atajo actual: " .. gamepadButtonToName(currentControllerKeyCode)
controllerLabel.Parent = controllerSection

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

local divider3 = Instance.new("Frame")
divider3.Size = UDim2.new(1, -12, 0, 1)
divider3.Position = UDim2.new(0, 6, 0, 0)
divider3.BorderSizePixel = 0
divider3.BackgroundColor3 = T.Border
divider3.Parent = container

local maintenanceSection = Instance.new("Frame")
maintenanceSection.Size = UDim2.new(1, -12, 0, 0)
maintenanceSection.BackgroundColor3 = T.Tertiary
maintenanceSection.BackgroundTransparency = 0.3
maintenanceSection.BorderSizePixel = 0
maintenanceSection.AutomaticSize = Enum.AutomaticSize.Y
roundFrame(maintenanceSection, 6)
maintenanceSection.Parent = container

local maintenancePadding = Instance.new("UIPadding")
maintenancePadding.PaddingLeft = UDim.new(0, 12)
maintenancePadding.PaddingRight = UDim.new(0, 12)
maintenancePadding.PaddingTop = UDim.new(0, 8)
maintenancePadding.PaddingBottom = UDim.new(0, 8)
maintenancePadding.Parent = maintenanceSection

local maintenanceLayout = Instance.new("UIListLayout")
maintenanceLayout.Padding = UDim.new(0, 6)
maintenanceLayout.SortOrder = Enum.SortOrder.LayoutOrder
maintenanceLayout.Parent = maintenanceSection

local maintHeader = Instance.new("TextLabel")
maintHeader.Size = UDim2.new(1, 0, 0, 22)
maintHeader.BackgroundTransparency = 1
maintHeader.Font = T.FontBold
maintHeader.TextSize = 15
maintHeader.TextColor3 = T.Text
maintHeader.TextXAlignment = Enum.TextXAlignment.Left
maintHeader.Text = "🧹 Mantenimiento"
maintHeader.Parent = maintenanceSection

local function hasCacheFiles()
	local folder = "ScriptedMemories/cache"
	if not isfolder or not isfolder(folder) then return false end
	if listfiles then
		local files = listfiles(folder)
		return files and #files > 0
	end
	return true
end

local function hasSettingsFile()
	if not isfile then return false end
	return isfile("ScriptedMemories/config/settings.json")
end

local function clearCache()
	if not hasCacheFiles() then return end
	local folder = "ScriptedMemories/cache"
	if delfolder and isfolder(folder) then
		delfolder(folder)
	end
	if makefolder then makefolder(folder) end
	updateMaintenanceButtons()
end

local function resetSettings()
	if not hasSettingsFile() then return end
	local file = "ScriptedMemories/config/settings.json"
	if delfile and isfile(file) then
		delfile(file)
	end
	Menu.Settings = {}
	if Menu.SaveSettings then Menu.SaveSettings() end
	updateMaintenanceButtons()
end

local cacheBtn = Instance.new("TextButton")
cacheBtn.Size = UDim2.new(1, 0, 0, 42)
cacheBtn.BackgroundColor3 = T.Tertiary
cacheBtn.BorderSizePixel = 0
cacheBtn.AutoButtonColor = false
cacheBtn.Font = T.FontBold
cacheBtn.TextSize = 15
cacheBtn.TextColor3 = T.Text
cacheBtn.Text = "🗑️ Limpiar caché del menú"
roundFrame(cacheBtn, 6)
cacheBtn.Parent = maintenanceSection

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, 0, 0, 42)
resetBtn.BackgroundColor3 = T.Tertiary
resetBtn.BorderSizePixel = 0
resetBtn.AutoButtonColor = false
resetBtn.Font = T.FontBold
resetBtn.TextSize = 15
resetBtn.TextColor3 = T.Text
resetBtn.Text = "🔄 Restaurar opciones predeterminadas"
roundFrame(resetBtn, 6)
resetBtn.Parent = maintenanceSection

local function updateMaintenanceButtons()
	local cacheOk = hasCacheFiles()
	local settingsOk = hasSettingsFile()

	cacheBtn.BackgroundColor3 = cacheOk and T.Tertiary or T.DisabledBg
	cacheBtn.TextColor3 = cacheOk and T.Text or T.DisabledText
	cacheBtn.AutoButtonColor = cacheOk

	resetBtn.BackgroundColor3 = settingsOk and T.Tertiary or T.DisabledBg
	resetBtn.TextColor3 = settingsOk and T.Text or T.DisabledText
	resetBtn.AutoButtonColor = settingsOk
end

updateMaintenanceButtons()

cacheBtn.MouseButton1Click:Connect(function()
	if not hasCacheFiles() then return end
	clearCache()
end)

resetBtn.MouseButton1Click:Connect(function()
	if not hasSettingsFile() then return end
	resetSettings()
end)

local function repositionAll()
	local yKeyboard = keyboardSection.Position.Y.Offset + keyboardSection.AbsoluteSize.Y + 8
	divider2.Position = UDim2.new(0, 6, 0, yKeyboard)
	controllerSection.Position = UDim2.new(0, 6, 0, yKeyboard + 8)

	local yController = controllerSection.Position.Y.Offset + controllerSection.AbsoluteSize.Y + 8
	divider3.Position = UDim2.new(0, 6, 0, yController)
	maintenanceSection.Position = UDim2.new(0, 6, 0, yController + 8)

	local totalHeight = maintenanceSection.Position.Y.Offset + maintenanceSection.AbsoluteSize.Y + 20
	container.Size = UDim2.new(1, 0, 0, math.max(480, totalHeight))
	if Menu.UpdateCanvas then
		Menu.UpdateCanvas()
	end
end

keyboardSection:GetPropertyChangedSignal("AbsoluteSize"):Connect(repositionAll)
controllerSection:GetPropertyChangedSignal("AbsoluteSize"):Connect(repositionAll)
maintenanceSection:GetPropertyChangedSignal("AbsoluteSize"):Connect(repositionAll)

repositionAll()

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end