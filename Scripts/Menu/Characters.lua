repeat wait() until _G.Library

local charSection = _G.Library.CreateSection("Characters")

-- Función para actualizar el tamaño de la sección y el canvas
local function updateSectionSize(newHeight)
	charSection.Frame.Size = UDim2.new(1, -10, 0, newHeight)
	-- Recalcular la altura total de todas las secciones y actualizar el ContentFrame
	local totalHeight = 0
	for _, sec in pairs(_G.Library.Sections) do
		totalHeight = totalHeight + sec.Frame.Size.Y.Offset
	end
	-- El ContentFrame es el ScrollingFrame; lo encontramos buscando el padre de charSection.Frame
	local contentFrame = charSection.Frame.Parent  -- Es el ContentFrame original
	if contentFrame and contentFrame:IsA("ScrollingFrame") then
		contentFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
	end
end

-- Sub‑menú principal
local subMenuFrame = Instance.new("Frame")
subMenuFrame.Size = UDim2.new(1, -10, 0, 95)
subMenuFrame.BackgroundTransparency = 1
subMenuFrame.Parent = charSection.Frame

local subMenuLayout = Instance.new("UIListLayout")
subMenuLayout.Padding = UDim.new(0, 5)
subMenuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
subMenuLayout.Parent = subMenuFrame

local survButton = Instance.new("TextButton")
survButton.Text = "Survivors"
survButton.Size = UDim2.new(0, 200, 0, 40)
survButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
survButton.TextColor3 = Color3.new(1, 1, 1)
survButton.Font = Enum.Font.GothamBold
survButton.TextSize = 16
survButton.BorderSizePixel = 0
survButton.Parent = subMenuFrame

local killButton = Instance.new("TextButton")
killButton.Text = "Killers"
killButton.Size = UDim2.new(0, 200, 0, 40)
killButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
killButton.TextColor3 = Color3.new(1, 1, 1)
killButton.Font = Enum.Font.GothamBold
killButton.TextSize = 16
killButton.BorderSizePixel = 0
killButton.Parent = subMenuFrame

-- Ajustar tamaño inicial (95 píxeles, lo mismo que el submenú)
updateSectionSize(95)

-- --- Survivors ---
local survFrame = Instance.new("Frame")
survFrame.Size = UDim2.new(1, -10, 0, 120)
survFrame.BackgroundTransparency = 1
survFrame.Visible = false
survFrame.Parent = charSection.Frame

local backBtn1 = Instance.new("TextButton")
backBtn1.Text = "< Volver"
backBtn1.Size = UDim2.new(0, 100, 0, 25)
backBtn1.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
backBtn1.TextColor3 = Color3.new(1, 1, 1)
backBtn1.Font = Enum.Font.Gotham
backBtn1.TextSize = 14
backBtn1.BorderSizePixel = 0
backBtn1.Position = UDim2.new(0, 5, 0, 5)
backBtn1.Parent = survFrame
backBtn1.MouseButton1Click:Connect(function()
	survFrame.Visible = false
	subMenuFrame.Visible = true
	updateSectionSize(95)
end)

local sonicBtn = Instance.new("TextButton")
sonicBtn.Text = "Sonic LMS"
sonicBtn.Size = UDim2.new(0, 200, 0, 40)
sonicBtn.Position = UDim2.new(0.5, -100, 0, 40)
sonicBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
sonicBtn.TextColor3 = Color3.new(1, 1, 1)
sonicBtn.Font = Enum.Font.GothamBold
sonicBtn.TextSize = 16
sonicBtn.BorderSizePixel = 0
sonicBtn.Parent = survFrame
sonicBtn.MouseButton1Click:Connect(function()
	spawn(function()
		local ok, src = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Menu/Sonic.lua")
		if ok and src then
			local f = loadstring(src)
			if f then pcall(f) end
		end
	end)
end)

-- --- Killers ---
local killFrame = Instance.new("Frame")
killFrame.Size = UDim2.new(1, -10, 0, 120)
killFrame.BackgroundTransparency = 1
killFrame.Visible = false
killFrame.Parent = charSection.Frame

local backBtn2 = Instance.new("TextButton")
backBtn2.Text = "< Volver"
backBtn2.Size = UDim2.new(0, 100, 0, 25)
backBtn2.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
backBtn2.TextColor3 = Color3.new(1, 1, 1)
backBtn2.Font = Enum.Font.Gotham
backBtn2.TextSize = 14
backBtn2.BorderSizePixel = 0
backBtn2.Position = UDim2.new(0, 5, 0, 5)
backBtn2.Parent = killFrame
backBtn2.MouseButton1Click:Connect(function()
	killFrame.Visible = false
	subMenuFrame.Visible = true
	updateSectionSize(95)
end)

local killerPlaceholder = Instance.new("TextLabel")
killerPlaceholder.Text = "Próximamente..."
killerPlaceholder.Size = UDim2.new(0, 200, 0, 30)
killerPlaceholder.Position = UDim2.new(0.5, -100, 0.5, -15)
killerPlaceholder.BackgroundTransparency = 1
killerPlaceholder.TextColor3 = Color3.new(1, 1, 1)
killerPlaceholder.Font = Enum.Font.Gotham
killerPlaceholder.TextSize = 16
killerPlaceholder.Parent = killFrame

-- Conectar botones del submenú
survButton.MouseButton1Click:Connect(function()
	subMenuFrame.Visible = false
	survFrame.Visible = true
	updateSectionSize(120)
end)

killButton.MouseButton1Click:Connect(function()
	subMenuFrame.Visible = false
	killFrame.Visible = true
	updateSectionSize(120)
end)s