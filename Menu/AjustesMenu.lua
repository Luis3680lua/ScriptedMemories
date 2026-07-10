local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage("Ajustes de Menu", "⚙️")

local function keyCodeToName(keyCode)
    if not keyCode then return "Desconocida" end
    local name = keyCode.Name
    name = name:gsub("^Enum%.KeyCode%.", "")
    name = name:gsub("Right", "Der. ")
    name = name:gsub("Left", "Izq. ")
    name = name:gsub("Control", "Ctrl")
    name = name:gsub("Backspace", "Retroceso")
    name = name:gsub("Return", "Enter")
    return name
end

local currentKeyName = Menu.Settings.menu_keybind or "M"
local currentKeyCode = Enum.KeyCode[currentKeyName] or Enum.KeyCode.M

local keybindBtn
local keybindLabel

local capturing = false
local captureConnection, captureEndConnection

local function startCapture()
    if capturing then return end
    capturing = true
    Menu._capturingKey = true

    keybindBtn.Text = "Presiona una tecla"
    local dots = 0
    local dotAnim = coroutine.wrap(function()
        while capturing do
            dots = (dots % 3) + 1
            keybindBtn.Text = "Presiona una tecla" .. string.rep(".", dots)
            task.wait(0.4)
        end
    end)
    dotAnim()

    captureConnection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not capturing then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Unknown then return end

            local newKeyName = input.KeyCode.Name:gsub("^Enum%.KeyCode%.", "")
            Menu.Settings.menu_keybind = newKeyName
            local saveSettings = Menu._saveSettings or function()
                local HttpService = game:GetService("HttpService")
                local json = HttpService:JSONEncode(Menu.Settings)
                local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                local container = PlayerGui:FindFirstChild("ScriptedMemoriesSettings")
                if not container then
                    container = Instance.new("StringValue")
                    container.Name = "ScriptedMemoriesSettings"
                    container.ResetOnSpawn = false
                    container.Parent = PlayerGui
                end
                container.Value = json
            end
            saveSettings()

            keybindBtn.Text = "Tecla: " .. keyCodeToName(input.KeyCode)
            keybindLabel.Text = "Tecla actual: " .. keyCodeToName(input.KeyCode)

            stopCapture()
        end
    end)
end

local function stopCapture()
    capturing = false
    Menu._capturingKey = false
    if captureConnection then
        captureConnection:Disconnect()
        captureConnection = nil
    end
    keybindBtn.Text = "Tecla: " .. keyCodeToName(Enum.KeyCode[Menu.Settings.menu_keybind or "M"])
end

-- Crear UI
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(240, 240, 245)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Text = "Ajustes del Menú"
title.Parent = page.Frame

keybindLabel = Instance.new("TextLabel")
keybindLabel.Size = UDim2.new(1, -12, 0, 20)
keybindLabel.BackgroundTransparency = 1
keybindLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
keybindLabel.Font = Enum.Font.Gotham
keybindLabel.TextSize = 14
keybindLabel.Text = "Tecla actual: " .. keyCodeToName(currentKeyCode)
keybindLabel.Parent = page.Frame

keybindBtn = Instance.new("TextButton")
keybindBtn.Size = UDim2.new(1, -12, 0, 36)
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

keybindBtn.MouseButton1Click:Connect(function()
    if not capturing then
        startCapture()
    end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end