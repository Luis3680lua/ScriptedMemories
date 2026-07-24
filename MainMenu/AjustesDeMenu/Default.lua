local Menu = _G.Menu
if not Menu then return end

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
	DisabledBg = Color3.fromRGB(30, 30, 38),
	DisabledText = Color3.fromRGB(100, 100, 110),
}

local function roundFrame(frame, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = frame
end

local function hasSettingsFile()
	if not isfile then return false end
	return isfile("ScriptedMemories/config/settings.json")
end

local function resetSettings()
	if not hasSettingsFile() then return end
	local file = "ScriptedMemories/config/settings.json"
	if delfile and isfile(file) then
		delfile(file)
	end
	Menu.Settings = {}
	if Menu.SaveSettings then Menu.SaveSettings() end
	updateButton()
end

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
header.Text = "⚙️ Configuración"
header.Parent = sectionFrame

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
resetBtn.Parent = sectionFrame

function updateButton()
	local settingsOk = hasSettingsFile()
	resetBtn.BackgroundColor3 = settingsOk and T.Tertiary or T.DisabledBg
	resetBtn.TextColor3 = settingsOk and T.Text or T.DisabledText
	resetBtn.AutoButtonColor = settingsOk
end

updateButton()

resetBtn.MouseButton1Click:Connect(function()
	if not hasSettingsFile() then return end
	resetSettings()
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end