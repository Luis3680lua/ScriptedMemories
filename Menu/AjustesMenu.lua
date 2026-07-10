local Menu = _G.Menu
if not Menu then return end

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local page = Menu:RegisterPage("Ajustes de Menú", "⚙️")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

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

local function gamepadKeyCodeToName(keyCode)
	if not keyCode then return "Desconocido" end
	local name = tostring(keyCode):gsub("^Enum%.KeyCode%.", "")
	name = name:gsub("ButtonA", "A")
	name = name:gsub("ButtonB", "B")
	name = name:gsub("ButtonX", "X")
	name = name:gsub("ButtonY", "Y")
	name = name:gsub("ButtonStart", "Start")
	name = name:gsub("ButtonSelect", "Select")
	name = name:gsub("ButtonL1", "LB")
	name = name:gsub("ButtonR1", "RB")
	name = name:gsub("ButtonL2", "LT")
	name = name:gsub("ButtonR2", "RT")
	name = name:gsub("ButtonL3", "LS")
	name = name:gsub("ButtonR3", "RS")
	name = name:gsub("DPadUp", "D-Pad Arriba")
	name = name:gsub("DPadDown", "D-Pad Abajo")
	name = name:gsub("DPadLeft", "D-Pad Izq.")
	name = name:gsub("DPadRight", "D-Pad Der.")
	return name
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 28)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(245, 245, 250)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "⚙️ Ajustes del Menú"
title.Parent = page.Frame

local description = Instance.new("TextLabel")
description.Size = UDim2.new(1, -12, 0, 42)
description.BackgroundTransparency = 1
description.Font = Enum.Font.Gotham
description.TextSize = 13
description.TextWrapped = true
description.TextColor3 = Color3.fromRGB(180, 180, 195)
description.TextXAlignment = Enum.TextXAlignment.Left
description.TextYAlignment = Enum.TextYAlignment.Top
description.Text = "Personaliza cómo abrir Scripted Memories."
description.Parent = page.Frame

local function createDivider()
	local d = Instance.new("Frame")
	d.Size = UDim2.new(1, -12, 0, 1)
	d.BorderSizePixel = 0
	d.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	d.Parent = page.Frame
	return d
end

local function createKeybindSection(icon, sectionTitle, settingKey, defaultKeyCode, inputTypeFilter)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -12, 0, 0)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.Parent = page.Frame

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 22)
	header.BackgroundTransparency = 1
	header.Font = Enum.Font.GothamBold
	header.TextSize = 15
	header.TextColor3 = Color3.fromRGB(235, 235, 240)
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Text = icon .. " " .. sectionTitle
	header.Parent = container

	local currentKeyName = Menu.Settings[settingKey] or defaultKeyCode.Name
	local currentKeyCode = Enum.KeyCode[currentKeyName] or defaultKeyCode

	local displayFrame = Instance.new("Frame")
	displayFrame.Size = UDim2.new(1, 0, 0, 36)
	displayFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	displayFrame.BorderSizePixel = 0
	local displayCorner = Instance.new("UICorner")
	displayCorner.CornerRadius = UDim.new(0, 6)
	displayCorner.Parent = displayFrame
	displayFrame.Parent = container

	local displayLabel = Instance.new("TextLabel")
	displayLabel.Size = UDim2.new(1, -16, 1, 0)
	displayLabel.Position = UDim2.new(0, 8, 0, 0)
	displayLabel.BackgroundTransparency = 1
	displayLabel.Font = Enum.Font.GothamBold
	displayLabel.TextSize = 14
	displayLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
	displayLabel.TextXAlignment = Enum.TextXAlignment.Left
	displayLabel.Text = "Actual"
	displayLabel.Parent = displayFrame

	local keyBox = Instance.new("Frame")
	keyBox.Size = UDim2.new(0, 50, 0, 24)
	keyBox.Position = UDim2.new(0, 8, 0, 6)
	keyBox.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
	keyBox.BorderSizePixel = 0
	local keyBoxCorner = Instance.new("UICorner")
	keyBoxCorner.CornerRadius = UDim.new(0, 4)
	keyBoxCorner.Parent = keyBox
	keyBox.Parent = displayFrame

	local keyBoxLabel = Instance.new("TextLabel")
	keyBoxLabel.Size = UDim2.new(1, 0, 1, 0)
	keyBoxLabel.BackgroundTransparency = 1
	keyBoxLabel.Font = Enum.Font.GothamBold
	keyBoxLabel.TextSize = 14
	keyBoxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyBoxLabel.Text = inputTypeFilter == Enum.UserInputType.Keyboard and keyCodeToName(currentKeyCode) or gamepadKeyCodeToName(currentKeyCode)
	keyBoxLabel.Parent = keyBox

	local changeBtn = Instance.new("TextButton")
	changeBtn.Size = UDim2.new(1, 0, 0, 36)
	changeBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
	changeBtn.BorderSizePixel = 0
	changeBtn.AutoButtonColor = false
	changeBtn.Font = Enum.Font.GothamBold
	changeBtn.TextSize = 14
	changeBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
	changeBtn.Text = "Cambiar " .. (inputTypeFilter == Enum.UserInputType.Keyboard and "tecla" or "botón")
	local changeCorner = Instance.new("UICorner")
	changeCorner.CornerRadius = UDim.new(0, 6)
	changeCorner.Parent = changeBtn
	changeBtn.Parent = container

	local stateLabel = Instance.new("TextLabel")
	stateLabel.Size = UDim2.new(1, 0, 0, 20)
	stateLabel.BackgroundTransparency = 1
	stateLabel.Font = Enum.Font.Gotham
	stateLabel.TextSize = 12
	stateLabel.TextColor3 = Color3.fromRGB(170, 170, 180)
	stateLabel.TextXAlignment = Enum.TextXAlignment.Left
	stateLabel.Text = ""
	stateLabel.Parent = container

	local capturing = false
	local captureConnection

	local function updateDisplay()
		local savedKey = Menu.Settings[settingKey]
		local savedCode = savedKey and Enum.KeyCode[savedKey] or defaultKeyCode
		keyBoxLabel.Text = inputTypeFilter == Enum.UserInputType.Keyboard and keyCodeToName(savedCode) or gamepadKeyCodeToName(savedCode)
	end

	local function stopCapture()
		capturing = false
		Menu._capturingKey = false
		if captureConnection then
			captureConnection:Disconnect()
			captureConnection = nil
		end
		changeBtn.Text = "Cambiar " .. (inputTypeFilter == Enum.UserInputType.Keyboard and "tecla" or "botón")
		stateLabel.Text = ""
		TweenService:Create(changeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(42, 42, 50)}):Play()
		updateDisplay()
	end

	local function startCapture()
		if capturing then return end
		capturing = true
		Menu._capturingKey = true
		TweenService:Create(changeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(70, 90, 145)}):Play()

		local dots = 0
		stateLabel.Text = "Esperando entrada..."
		task.spawn(function()
			while capturing do
				dots = (dots % 3) + 1
				stateLabel.Text = "Esperando entrada" .. string.rep(".", dots)
				changeBtn.Text = "Pulsa " .. (inputTypeFilter == Enum.UserInputType.Keyboard and "una tecla" or "un botón") .. "..." .. string.rep(" ", 10)
				task.wait(0.4)
			end
		end)

		captureConnection = UIS.InputBegan:Connect(function(input)
			if not capturing then return end
			if inputTypeFilter == Enum.UserInputType.Keyboard then
				if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
				if input.KeyCode == Enum.KeyCode.Unknown then return end
			else
				if input.UserInputType ~= Enum.UserInputType.Gamepad1 then return end
				if input.KeyCode == Enum.KeyCode.Unknown then return end
			end

			local newKey = tostring(input.KeyCode):gsub("^Enum%.KeyCode%.", "")
			Menu.Settings[settingKey] = newKey
			if Menu.SaveSettings then Menu.SaveSettings() end
			updateDisplay()
			stopCapture()
		end)
	end

	changeBtn.MouseButton1Click:Connect(function()
		if not capturing then startCapture() end
	end)

	changeBtn.MouseEnter:Connect(function()
		if capturing then return end
		TweenService:Create(changeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(55, 55, 66)}):Play()
	end)

	changeBtn.MouseLeave:Connect(function()
		if capturing then return end
		TweenService:Create(changeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(42, 42, 50)}):Play()
	end)

	return container
end

createDivider()
createKeybindSection("⌨️", "Teclado", "menu_keybind", Enum.KeyCode.M, Enum.UserInputType.Keyboard)
createDivider()
createKeybindSection("🎮", "Gamepad", "menu_gamepadbind", Enum.KeyCode.ButtonStart, Enum.UserInputType.Gamepad1)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end