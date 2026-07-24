local Menu = _G.Menu
if not Menu then return end

local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

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

local THEMES = {
	Default = {
		Background = Color3.fromRGB(20, 20, 25),
		Secondary = Color3.fromRGB(30, 30, 38),
		Tertiary = Color3.fromRGB(42, 42, 50),
		Hover = Color3.fromRGB(55, 55, 65),
		Text = Color3.fromRGB(240, 240, 245),
		TextDim = Color3.fromRGB(180, 180, 195),
		Accent = Color3.fromRGB(70, 150, 255),
		Green = Color3.fromRGB(70, 210, 110),
		Red = Color3.fromRGB(220, 80, 80),
		Border = Color3.fromRGB(60, 60, 75),
	},
	Light = {
		Background = Color3.fromRGB(240, 240, 245),
		Secondary = Color3.fromRGB(220, 220, 230),
		Tertiary = Color3.fromRGB(200, 200, 210),
		Hover = Color3.fromRGB(180, 180, 190),
		Text = Color3.fromRGB(20, 20, 25),
		TextDim = Color3.fromRGB(80, 80, 90),
		Accent = Color3.fromRGB(0, 120, 255),
		Green = Color3.fromRGB(0, 180, 80),
		Red = Color3.fromRGB(220, 60, 60),
		Border = Color3.fromRGB(160, 160, 170),
	},
	Blue = {
		Background = Color3.fromRGB(10, 20, 40),
		Secondary = Color3.fromRGB(20, 30, 55),
		Tertiary = Color3.fromRGB(30, 45, 70),
		Hover = Color3.fromRGB(45, 60, 90),
		Text = Color3.fromRGB(220, 230, 255),
		TextDim = Color3.fromRGB(150, 170, 200),
		Accent = Color3.fromRGB(80, 160, 255),
		Green = Color3.fromRGB(80, 220, 120),
		Red = Color3.fromRGB(230, 90, 90),
		Border = Color3.fromRGB(50, 60, 80),
	},
	Green = {
		Background = Color3.fromRGB(15, 35, 20),
		Secondary = Color3.fromRGB(25, 45, 30),
		Tertiary = Color3.fromRGB(35, 55, 40),
		Hover = Color3.fromRGB(50, 70, 55),
		Text = Color3.fromRGB(220, 255, 220),
		TextDim = Color3.fromRGB(150, 200, 150),
		Accent = Color3.fromRGB(100, 255, 100),
		Green = Color3.fromRGB(100, 255, 100),
		Red = Color3.fromRGB(255, 100, 100),
		Border = Color3.fromRGB(60, 80, 60),
	},
	Purple = {
		Background = Color3.fromRGB(30, 15, 40),
		Secondary = Color3.fromRGB(40, 25, 55),
		Tertiary = Color3.fromRGB(55, 35, 70),
		Hover = Color3.fromRGB(70, 50, 90),
		Text = Color3.fromRGB(240, 220, 255),
		TextDim = Color3.fromRGB(180, 160, 200),
		Accent = Color3.fromRGB(180, 100, 255),
		Green = Color3.fromRGB(100, 255, 100),
		Red = Color3.fromRGB(255, 100, 100),
		Border = Color3.fromRGB(70, 50, 80),
	},
}

if not Menu.Settings.menu_theme then
	Menu.Settings.menu_theme = "Default"
end
if not Menu.Settings.custom_theme then
	Menu.Settings.custom_theme = THEMES.Default
end

local currentThemeName = Menu.Settings.menu_theme

-- Guarda los colores originales ANTES de modificarlos
local oldTheme = {}
for k, v in pairs(Menu.THEME) do
	if typeof(v) == "Color3" then
		oldTheme[k] = v
	end
end

local function applyTheme(themeName)
	local theme
	if themeName == "Custom" then
		theme = Menu.Settings.custom_theme
	else
		theme = THEMES[themeName] or THEMES.Default
	end

	-- Actualiza Menu.THEME
	for k, v in pairs(theme) do
		Menu.THEME[k] = v
	end

	-- Busca la ventana principal
	local gui = PlayerGui:FindFirstChild("ScriptedMemoriesUI")
	if not gui then return end
	local main = gui:FindFirstChild("MainWindow")
	if not main then return end

	-- Construye tablas de mapeo para reemplazo masivo
	local frameReplacements = {}
	local textReplacements = {}
	local strokeReplacements = {}
	for key, oldColor in pairs(oldTheme) do
		local newColor = Menu.THEME[key]
		if newColor and oldColor ~= newColor then
			frameReplacements[oldColor] = newColor
			strokeReplacements[oldColor] = newColor
		end
	end
	textReplacements[oldTheme.Text] = Menu.THEME.Text
	textReplacements[oldTheme.TextDim] = Menu.THEME.TextDim

	-- Función recursiva para actualizar colores
	local function updateColors(object)
		if object:IsA("Frame") then
			local bg = object.BackgroundColor3
			if frameReplacements[bg] then
				object.BackgroundColor3 = frameReplacements[bg]
			end
		elseif object:IsA("TextLabel") or object:IsA("TextButton") then
			local tc = object.TextColor3
			if textReplacements[tc] then
				object.TextColor3 = textReplacements[tc]
			end
		end
		if object:IsA("UIStroke") then
			local sc = object.Color
			if strokeReplacements[sc] then
				object.Color = strokeReplacements[sc]
			end
		end
		-- Recursión para todos los hijos
		for _, child in ipairs(object:GetChildren()) do
			updateColors(child)
		end
	end

	updateColors(main)

	-- Guardamos los colores viejos para la próxima actualización
	oldTheme = {}
	for k, v in pairs(Menu.THEME) do
		if typeof(v) == "Color3" then
			oldTheme[k] = v
		end
	end
end

-- UI
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
header.Text = "🎨 Tema"
header.Parent = sectionFrame

local themeNames = {"Default", "Light", "Blue", "Green", "Purple", "Custom"}
local themeDropdown = Instance.new("TextButton")
themeDropdown.Size = UDim2.new(1, 0, 0, 42)
themeDropdown.BackgroundColor3 = T.Tertiary
themeDropdown.TextColor3 = T.Text
themeDropdown.Font = T.FontBold
themeDropdown.TextSize = 14
themeDropdown.BorderSizePixel = 0
themeDropdown.Text = "Tema: " .. currentThemeName
themeDropdown.AutoButtonColor = false
roundFrame(themeDropdown, 6)
themeDropdown.Parent = sectionFrame

local customFrame = Instance.new("Frame")
customFrame.Size = UDim2.new(1, 0, 0, 0)
customFrame.BackgroundTransparency = 1
customFrame.AutomaticSize = Enum.AutomaticSize.Y
customFrame.Visible = (currentThemeName == "Custom")
customFrame.Parent = sectionFrame

local customLayout = Instance.new("UIListLayout")
customLayout.Padding = UDim.new(0, 4)
customLayout.SortOrder = Enum.SortOrder.LayoutOrder
customLayout.Parent = customFrame

local function createColorPicker(name, key)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundTransparency = 1
	row.Parent = customFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 100, 0, 20)
	label.Position = UDim2.new(0, 0, 0, 5)
	label.BackgroundTransparency = 1
	label.Font = T.Font
	label.TextSize = 13
	label.TextColor3 = T.TextDim
	label.Text = name
	label.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0, 120, 0, 24)
	box.Position = UDim2.new(0, 105, 0, 3)
	box.BackgroundColor3 = T.Tertiary
	box.TextColor3 = T.Text
	box.Font = T.Font
	box.TextSize = 13
	box.Text = string.format("%d,%d,%d", math.round(Menu.Settings.custom_theme[key].R*255), math.round(Menu.Settings.custom_theme[key].G*255), math.round(Menu.Settings.custom_theme[key].B*255))
	box.Parent = row
	roundFrame(box, 4)

	box.FocusLost:Connect(function()
		local r, g, b = box.Text:match("(%d+),(%d+),(%d+)")
		if r and g and b then
			local color = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
			Menu.Settings.custom_theme[key] = color
			if Menu.SaveSettings then Menu.SaveSettings() end
		end
	end)
end

local colorKeys = {
	{"Fondo", "Background"},
	{"Secundario", "Secondary"},
	{"Terciario", "Tertiary"},
	{"Resaltado", "Hover"},
	{"Texto", "Text"},
	{"Texto atenuado", "TextDim"},
	{"Acento", "Accent"},
	{"Verde", "Green"},
	{"Rojo", "Red"},
	{"Borde", "Border"},
}

for _, pair in ipairs(colorKeys) do
	createColorPicker(pair[1], pair[2])
end

local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(1, 0, 0, 38)
applyBtn.BackgroundColor3 = T.Accent
applyBtn.TextColor3 = T.Text
applyBtn.Font = T.FontBold
applyBtn.TextSize = 14
applyBtn.BorderSizePixel = 0
applyBtn.Text = "Aplicar tema personalizado"
applyBtn.AutoButtonColor = false
roundFrame(applyBtn, 6)
applyBtn.Parent = sectionFrame

applyBtn.MouseButton1Click:Connect(function()
	Menu.Settings.menu_theme = "Custom"
	applyTheme("Custom")
	if Menu.SaveSettings then Menu.SaveSettings() end
end)

local themeIndex = 1
for i, name in ipairs(themeNames) do
	if name == currentThemeName then
		themeIndex = i
		break
	end
end

themeDropdown.MouseButton1Click:Connect(function()
	themeIndex = themeIndex % #themeNames + 1
	currentThemeName = themeNames[themeIndex]
	themeDropdown.Text = "Tema: " .. currentThemeName
	customFrame.Visible = (currentThemeName == "Custom")

	if currentThemeName ~= "Custom" then
		Menu.Settings.menu_theme = currentThemeName
		applyTheme(currentThemeName)
		if Menu.SaveSettings then Menu.SaveSettings() end
	end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end