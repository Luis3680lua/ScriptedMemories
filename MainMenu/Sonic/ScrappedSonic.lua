local CONFIG = {
    Folder = "ScriptedMemories/cache",
    Name = "Sonic The Hedgehog",
    Icon = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Sonic.png",
    IconSize = 130,
    NameSize = 32,
    Modules = {
        { name = "LMS", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Personajes/Sobrevivientes/Sonic/LMS.lua", file = "script_lms.lua" }
    }
}

local Menu = _G.Menu
if not Menu then return end
if not Menu.CharacterUI then return end

local T = Menu.THEME
local RADIUS = T.Radius or 6

local function roundFrame(frame, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or RADIUS)
    c.Parent = frame
    return c
end

local hasFS = pcall(function() return isfolder end) and isfolder ~= nil
local canAsset = pcall(function() return getcustomasset end) and getcustomasset ~= nil

if hasFS and makefolder and not isfolder(CONFIG.Folder) then
    pcall(makefolder, CONFIG.Folder)
end

local function getCachedOnly(filename)
    if not (hasFS and canAsset and isfile and isfile(filename)) then return nil end
    local ok, asset = pcall(getcustomasset, filename)
    return ok and asset or nil
end

local function getOrDownload(url, filename)
    if not canAsset or not url then return nil end
    local ok, result = pcall(function()
        if hasFS and isfile and isfile(filename) then
            return getcustomasset(filename)
        end
        if hasFS and writefile then
            local dok, data = pcall(game.HttpGet, game, url)
            if dok and data and #data > 0 then
                writefile(filename, data)
                return getcustomasset(filename)
            end
        end
        return nil
    end)
    return ok and result or nil
end

local container = Menu.CharacterUI.Container

local headerFrame = Instance.new("Frame")
headerFrame.Name = "SonicHeader"
headerFrame.Size = UDim2.new(1, 0, 0, 0)
headerFrame.BackgroundTransparency = 1
headerFrame.AutomaticSize = Enum.AutomaticSize.Y
headerFrame.LayoutOrder = -1
headerFrame.Parent = container

local headerLayout = Instance.new("UIListLayout")
headerLayout.Padding = UDim.new(0, 10)
headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
headerLayout.Parent = headerFrame

local backBtn = Instance.new("TextButton")
backBtn.Size = UDim2.new(0, 100, 0, 32)
backBtn.BackgroundColor3 = T.Tertiary
backBtn.TextColor3 = T.Text
backBtn.Font = T.FontBold
backBtn.TextSize = 14
backBtn.BorderSizePixel = 0
backBtn.AutoButtonColor = false
backBtn.Text = "← Volver"
backBtn.LayoutOrder = 1
backBtn.Parent = headerFrame
roundFrame(backBtn, RADIUS)

backBtn.MouseButton1Click:Connect(function()
    if Menu.CharacterUI and Menu.CharacterUI.GoBack then
        Menu.CharacterUI:GoBack()
    end
end)

local nameCard = Instance.new("Frame")
nameCard.Size = UDim2.new(0, 0, 0, 0)
nameCard.AutomaticSize = Enum.AutomaticSize.XY
nameCard.BackgroundTransparency = 1
nameCard.LayoutOrder = 2
nameCard.Parent = headerFrame

local nameLayout = Instance.new("UIListLayout")
nameLayout.FillDirection = Enum.FillDirection.Horizontal
nameLayout.Padding = UDim.new(0, 14)
nameLayout.VerticalAlignment = Enum.VerticalAlignment.Center
nameLayout.Parent = nameCard

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, CONFIG.IconSize, 0, CONFIG.IconSize)
icon.BackgroundColor3 = T.Tertiary
icon.BackgroundTransparency = 0.2
icon.ScaleType = Enum.ScaleType.Fit
icon.Parent = nameCard
roundFrame(icon, RADIUS)

local iconFilename = CONFIG.Folder .. "/personajes_" .. (CONFIG.Icon:match("([^/]+)$") or "sonic.png")
icon.Image = getCachedOnly(iconFilename) or ""

if icon.Image == "" then
    task.spawn(function()
        local asset = getOrDownload(CONFIG.Icon, iconFilename)
        if asset and icon.Parent then
            icon.Image = asset
        end
    end)
end

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(0, 0, 0, 0)
nameLabel.AutomaticSize = Enum.AutomaticSize.XY
nameLabel.BackgroundTransparency = 1
nameLabel.Font = T.FontBold
nameLabel.TextSize = CONFIG.NameSize
nameLabel.TextColor3 = T.Text
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Text = CONFIG.Name
nameLabel.Parent = nameCard

local function loadCachedModule(url, filename)
    local path = CONFIG.Folder .. "/" .. filename
    local source = nil

    if hasFS and isfile and isfile(path) then
        local ok, data = pcall(readfile, path)
        if ok and data and #data > 0 then
            source = data
        end
    end

    if not source then
        local ok, data = pcall(game.HttpGet, game, url)
        if ok and data and #data > 0 then
            source = data
            if hasFS and writefile then
                pcall(writefile, path, data)
            end
        end
    end

    if not source then return false, "no se pudo obtener el módulo" end

    local fn, compileErr = loadstring(source)
    if not fn then return false, compileErr end

    local ok, runErr = pcall(fn)
    if not ok then return false, runErr end

    return true
end

for _, mod in ipairs(CONFIG.Modules) do
    local ok, err = loadCachedModule(mod.url, mod.file)
    if not ok then
        warn("Error al cargar " .. mod.name .. ": " .. tostring(err))
    end
end

if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end