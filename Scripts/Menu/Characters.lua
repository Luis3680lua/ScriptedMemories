repeat wait() until _G.Library

local charSection = _G.Library.CreateSection("Characters")

-- Barra de pestañas Survivors / Killers
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -10, 0, 30)
tabBar.BackgroundTransparency = 1
tabBar.Parent = charSection.Frame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

local survTab = Instance.new("TextButton")
survTab.Text = "Survivors"
survTab.Size = UDim2.new(0, 200, 1, 0)
survTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
survTab.TextColor3 = Color3.new(1, 1, 1)
survTab.Font = Enum.Font.GothamBold
survTab.TextSize = 14
survTab.BorderSizePixel = 0
survTab.Parent = tabBar

local killTab = Instance.new("TextButton")
killTab.Text = "Killers"
killTab.Size = UDim2.new(0, 200, 1, 0)
killTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
killTab.TextColor3 = Color3.new(1, 1, 1)
killTab.Font = Enum.Font.GothamBold
killTab.TextSize = 14
killTab.BorderSizePixel = 0
killTab.Parent = tabBar

-- Contenedor inferior
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -10, 1, -40)
contentFrame.Position = UDim2.new(0, 5, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = charSection.Frame

-- Panel Survivors
local survFrame = Instance.new("Frame")
survFrame.Size = UDim2.new(1, 0, 1, 0)
survFrame.BackgroundTransparency = 1
survFrame.Visible = true
survFrame.Parent = contentFrame

-- Panel Killers (placeholder)
local killFrame = Instance.new("Frame")
killFrame.Size = UDim2.new(1, 0, 1, 0)
killFrame.BackgroundTransparency = 1
killFrame.Visible = false
killFrame.Parent = contentFrame

local killerPlaceholder = Instance.new("TextLabel")
killerPlaceholder.Text = "Próximamente..."
killerPlaceholder.Size = UDim2.new(0, 200, 0, 30)
killerPlaceholder.Position = UDim2.new(0.5, -100, 0.5, -15)
killerPlaceholder.BackgroundTransparency = 1
killerPlaceholder.TextColor3 = Color3.new(1, 1, 1)
killerPlaceholder.Font = Enum.Font.Gotham
killerPlaceholder.TextSize = 16
killerPlaceholder.Parent = killFrame

-- Función para cambiar pestaña
local function switchTab(active)
	if active == "Survivors" then
		survTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		killTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		survFrame.Visible = true
		killFrame.Visible = false
	else
		killTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		survTab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		survFrame.Visible = false
		killFrame.Visible = true
	end
end

survTab.MouseButton1Click:Connect(function() switchTab("Survivors") end)
killTab.MouseButton1Click:Connect(function() switchTab("Killers") end)

-- Botón Sonic LMS con icono
local sonicBtn = Instance.new("TextButton")
sonicBtn.Text = ""
sonicBtn.Size = UDim2.new(0, 200, 0, 60)
sonicBtn.Position = UDim2.new(0.5, -100, 0, 20)
sonicBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sonicBtn.BorderSizePixel = 0
sonicBtn.Parent = survFrame

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 40, 0, 40)
icon.Position = UDim2.new(0, 10, 0.5, -20)
icon.BackgroundTransparency = 1
icon.Image = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Sonic.png"
icon.ScaleType = Enum.ScaleType.Fit
icon.Parent = sonicBtn

local btnLabel = Instance.new("TextLabel")
btnLabel.Text = "Sonic LMS"
btnLabel.Size = UDim2.new(1, -60, 1, 0)
btnLabel.Position = UDim2.new(0, 55, 0, 0)
btnLabel.BackgroundTransparency = 1
btnLabel.TextColor3 = Color3.new(1, 1, 1)
btnLabel.Font = Enum.Font.GothamBold
btnLabel.TextSize = 16
btnLabel.Parent = sonicBtn

sonicBtn.MouseButton1Click:Connect(function()
	spawn(function()
		local ok, src = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Menu/Sonic.lua")
		if ok and src then
			local f = loadstring(src)
			if f then
				pcall(f)
				-- Espera un frame por si acaso y luego abre el picker
				wait()
				if createPicker then
					createPicker()
				end
			end
		end
	end)
end)

-- Ajustar tamaño de la sección
charSection.Frame.Size = UDim2.new(1, -10, 0, 150)
local totalHeight = 0
for _, sec in pairs(_G.Library.Sections) do
	totalHeight = totalHeight + sec.Frame.Size.Y.Offset
end
charSection.Frame.Parent.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)