local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage("Ajustes de Menu", "⚙️")

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
title.Size = UDim2.new(1, -12, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(240, 240, 245)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Text = "Ajustes del Menú"
title.Parent = page.Frame

local keybindBtn = Instance.new("TextButton")
keybindBtn.Size = UDim2.new(1, -12, 0, 40)
keybindBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
keybindBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
keybindBtn.Font = Enum.Font.GothamBold
keybindBtn.TextSize = 14
keybindBtn.BorderSizePixel = 0
keybindBtn.Text = "Tecla: " .. keyCodeToName(currentKeyCode)
keybindBtn.AutoButtonColor = false
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 4)
corner.Parent = keybindBtn
keybindBtn.Parent = page.Frame

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Size = UDim2.new(1, -12, 0, 20)
keybindLabel.BackgroundTransparency = 1
keybindLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
keybindLabel.Font = Enum.Font.Gotham
keybindLabel.TextSize = 12
keybindLabel.Text = "Tecla actual: " .. keyCodeToName(currentKeyCode)
keybindLabel.Parent = page.Frame

local capturing = false
local captureConnection = nil

local function stopCapture()
    capturing = false
    Menu._capturingKey = false
    if captureConnection then
        captureConnection:Disconnect()
        captureConnection = nil
    end
    local savedKey = Enum.KeyCode[Menu.Settings.menu_keybind or "M"] or Enum.KeyCode.M
    keybindBtn.Text = "Tecla: " .. keyCodeToName(savedKey)
end

local function startCapture()
    if capturing then return end
    capturing = true
    Menu._capturingKey = true

    keybindBtn.Text = "Presiona una tecla"

    local dots = 0
    task.spawn(function()
        while capturing do
            dots = (dots % 3) + 1
            keybindBtn.Text = "Presiona una tecla" .. string.rep(".", dots)
            task.wait(0.4)
        end
    end)

    captureConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not capturing then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Unknown then return end

            local newKeyName = tostring(input.KeyCode):gsub("^Enum%.KeyCode%.", "")
            Menu.Settings.menu_keybind = newKeyName

            if Menu.SaveSettings then
                Menu.SaveSettings()
            end

            keybindBtn.Text = "Tecla: " .. keyCodeToName(input.KeyCode)
            keybindLabel.Text = "Tecla actual: " .. keyCodeToName(input.KeyCode)

            stopCapture()
        end
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