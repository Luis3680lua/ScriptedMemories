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

local CACHE_DIR = "ScriptedMemories/cache"

local function hasCacheFiles()
	if not isfolder or not isfolder(CACHE_DIR) then return false end
	if listfiles then
		local files = listfiles(CACHE_DIR)
		return files and #files > 0
	end
	return true
end

-- Sección UI
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
header.Text = "🧹 Mantenimiento"
header.Parent = sectionFrame

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
cacheBtn.Parent = sectionFrame

-- Función para actualizar el estado visual del botón
local function updateButton()
	local cacheOk = hasCacheFiles()
	cacheBtn.BackgroundColor3 = cacheOk and T.Tertiary or T.DisabledBg
	cacheBtn.TextColor3 = cacheOk and T.Text or T.DisabledText
	cacheBtn.AutoButtonColor = cacheOk
end

-- Ahora sí definimos clearCache (ya existe updateButton)
local function clearCache()
	if not hasCacheFiles() then return end
	if delfolder and isfolder(CACHE_DIR) then
		-- Primero borramos todos los archivos dentro por si delfolder no elimina recursivamente
		if listfiles then
			local files = listfiles(CACHE_DIR)
			if files then
				for _, file in ipairs(files) do
					pcall(function()
						if isfile(file) then delfile(file) end
					end)
				end
			end
		end
		-- Luego eliminamos la carpeta
		pcall(function()
			delfolder(CACHE_DIR)
		end)
	end
	-- Recreamos la carpeta vacía
	if makefolder and not isfolder(CACHE_DIR) then
		makefolder(CACHE_DIR)
	end
	updateButton()
end

-- Estado inicial
updateButton()

cacheBtn.MouseButton1Click:Connect(function()
	if not hasCacheFiles() then return end
	clearCache()
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end