local Menu = _G.Menu
if not Menu then return end

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

local page = Menu:RegisterPage("Info", "ℹ️")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 0, 0)
container.BackgroundTransparency = 1
container.AutomaticSize = Enum.AutomaticSize.Y
container.Parent = page.Frame

local mainLayout = Instance.new("UIListLayout")
mainLayout.Padding = UDim.new(0, 6)
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainLayout.Parent = container

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 28)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = T.FontBold
titleLabel.TextSize = 20
titleLabel.TextColor3 = T.Text
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = "ℹ️ Scripted Memories"
titleLabel.Parent = container

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(1, 0, 0, 18)
versionLabel.BackgroundTransparency = 1
versionLabel.Font = T.Font
versionLabel.TextSize = 12
versionLabel.TextColor3 = T.TextDim
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.Text = "Versión 0.2.5"
versionLabel.Parent = container

local function createSection(title, accentColor, items)
	local sectionFrame = Instance.new("Frame")
	sectionFrame.Size = UDim2.new(1, 0, 0, 0)
	sectionFrame.BackgroundColor3 = T.Tertiary
	sectionFrame.BackgroundTransparency = 0.3
	sectionFrame.BorderSizePixel = 0
	sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
	roundFrame(sectionFrame, 6)
	sectionFrame.Parent = container

	local sectionPadding = Instance.new("UIPadding")
	sectionPadding.PaddingLeft = UDim.new(0, 12)
	sectionPadding.PaddingRight = UDim.new(0, 12)
	sectionPadding.PaddingTop = UDim.new(0, 8)
	sectionPadding.PaddingBottom = UDim.new(0, 8)
	sectionPadding.Parent = sectionFrame

	local sectionLayout = Instance.new("UIListLayout")
	sectionLayout.Padding = UDim.new(0, 4)
	sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sectionLayout.Parent = sectionFrame

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 22)
	header.BackgroundTransparency = 1
	header.Font = T.FontBold
	header.TextSize = 15
	header.TextColor3 = accentColor or T.Accent
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Text = title
	header.Parent = sectionFrame

	for _, itemText in ipairs(items) do
		local item = Instance.new("TextLabel")
		item.Size = UDim2.new(1, 0, 0, 0)
		item.BackgroundTransparency = 1
		item.Font = T.Font
		item.TextSize = 13
		item.TextColor3 = T.TextDim
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.TextWrapped = true
		item.AutomaticSize = Enum.AutomaticSize.Y
		item.Text = "• " .. itemText
		item.Parent = sectionFrame
	end
end

createSection("❓ ¿Qué es Scripted Memories?", T.Accent, {
	"Scripted Memories es un paquete de scripts desarrollado para ampliar y mejorar la experiencia de Outcome Memories mediante funciones opcionales, mejoras de calidad de vida y contenido adicional.",
	"Su objetivo es complementar la experiencia original del juego sin modificar su jugabilidad principal ni afectar la experiencia de otros jugadores."
})

createSection("🛠 Optimizado", Color3.fromRGB(128, 200, 255), {
	"Todo XD"
})

createSection("🐞 Corregido", Color3.fromRGB(140, 255, 178), {
	"Aún sin definir"
})

createSection("✨ Mejoras", Color3.fromRGB(255, 211, 107), {
	"Aún sin definir"
})

createSection("🎵 Añadido", Color3.fromRGB(255, 184, 108), {
	"Un nuevo sistema de aleatoriedad en las canciones del Lobby.",
	"Aún sin definir (otro cambio)"
})

createSection("📝 Nota", Color3.fromRGB(189, 189, 189), {
	"Nota aún sin definir, esperando finalización del changelog."
})

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end