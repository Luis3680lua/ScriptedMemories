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

local currentKeyName = Menu.Settings.menu_keybind or "M"
local currentKeyCode = Enum.KeyCode[currentKeyName] or Enum.KeyCode.M

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-12,0,28)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(245,245,250)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "⚙️ Ajustes del Menú"
title.Parent = page.Frame

local description = Instance.new("TextLabel")
description.Size = UDim2.new(1,-12,0,42)
description.BackgroundTransparency = 1
description.Font = Enum.Font.Gotham
description.TextSize = 13
description.TextWrapped = true
description.TextColor3 = Color3.fromRGB(180,180,195)
description.TextXAlignment = Enum.TextXAlignment.Left
description.TextYAlignment = Enum.TextYAlignment.Top
description.Text = "Personaliza algunos aspectos del menú. Los cambios se guardan automáticamente."
description.Parent = page.Frame

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1,-12,0,1)
divider.BorderSizePixel = 0
divider.BackgroundColor3 = Color3.fromRGB(60,60,70)
divider.Parent = page.Frame

local section = Instance.new("TextLabel")
section.Size = UDim2.new(1,-12,0,22)
section.BackgroundTransparency = 1
section.Font = Enum.Font.GothamBold
section.TextSize = 15
section.TextColor3 = Color3.fromRGB(235,235,240)
section.TextXAlignment = Enum.TextXAlignment.Left
section.Text = "⌨️ Atajo del Menú"
section.Parent = page.Frame

local keybindBtn = Instance.new("TextButton")
keybindBtn.Size = UDim2.new(1,-12,0,42)
keybindBtn.BackgroundColor3 = Color3.fromRGB(42,42,50)
keybindBtn.BorderSizePixel = 0
keybindBtn.AutoButtonColor = false
keybindBtn.Font = Enum.Font.GothamBold
keybindBtn.TextSize = 15
keybindBtn.TextColor3 = Color3.fromRGB(245,245,250)
keybindBtn.Text = "⌨️ Cambiar tecla  [" .. keyCodeToName(currentKeyCode) .. "]"

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,6)
corner.Parent = keybindBtn

keybindBtn.Parent = page.Frame

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Size = UDim2.new(1,-12,0,20)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Font = Enum.Font.Gotham
keybindLabel.TextSize = 12
keybindLabel.TextColor3 = Color3.fromRGB(170,170,180)
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.Text = "Atajo actual: " .. keyCodeToName(currentKeyCode)
keybindLabel.Parent = page.Frame

keybindBtn.MouseEnter:Connect(function()
	if Menu._capturingKey then return end

	TweenService:Create(
		keybindBtn,
		TweenInfo.new(.15),
		{BackgroundColor3 = Color3.fromRGB(55,55,66)}
	):Play()
end)

keybindBtn.MouseLeave:Connect(function()
	if Menu._capturingKey then return end

	TweenService:Create(
		keybindBtn,
		TweenInfo.new(.15),
		{BackgroundColor3 = Color3.fromRGB(42,42,50)}
	):Play()
end)

local capturing = false
local captureConnection

local function stopCapture()
	capturing = false
	Menu._capturingKey = false

	if captureConnection then
		captureConnection:Disconnect()
		captureConnection = nil
	end

	local savedKey = Enum.KeyCode[Menu.Settings.menu_keybind or "M"] or Enum.KeyCode.M

	keybindBtn.Text = "⌨️ Cambiar tecla  [" .. keyCodeToName(savedKey) .. "]"

	TweenService:Create(
		keybindBtn,
		TweenInfo.new(.15),
		{BackgroundColor3 = Color3.fromRGB(42,42,50)}
	):Play()
end

local function startCapture()
	if capturing then
		return
	end

	capturing = true
	Menu._capturingKey = true

	TweenService:Create(
		keybindBtn,
		TweenInfo.new(.15),
		{BackgroundColor3 = Color3.fromRGB(70,90,145)}
	):Play()

	local dots = 0

	task.spawn(function()
		while capturing do
			dots = (dots % 3) + 1
			keybindBtn.Text = "⌨️ Presiona una tecla" .. string.rep(".", dots)
			task.wait(0.4)
		end
	end)

	captureConnection = UIS.InputBegan:Connect(function(input)
		if not capturing then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if input.KeyCode == Enum.KeyCode.Unknown then
			return
		end

		local newKey = tostring(input.KeyCode):gsub("^Enum%.KeyCode%.","")

		Menu.Settings.menu_keybind = newKey

		if Menu.SaveSettings then
			Menu.SaveSettings()
		end

		keybindLabel.Text = "Atajo actual: " .. keyCodeToName(input.KeyCode)

		stopCapture()
	end)
end

keybindBtn.MouseButton1Click:Connect(function()
	if not capturing then
		startCapture()
	end
end)

task.wait(0.1)

if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end