local CONFIG = {
    Folder = "ScriptedMemories/cache",
    PageName = "Sonic the Hedgehog",
    PageIcon = "🦔",
    HeaderTitle = "Sonic the Hedgehog",
    HeaderDescription = "Ajustes y personalización relacionados con Sonic.",
    HeaderIcon = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Sonic.png",
    HeaderIconSize = 64,
    Modules = {
        { name = "LMS", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Sonic/LMS.lua" }
    }
}

local Menu = _G.Menu
if not Menu then return end

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

local page = Menu:RegisterPage(CONFIG.PageName, CONFIG.PageIcon)
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 0)
headerFrame.BackgroundTransparency = 1
headerFrame.AutomaticSize = Enum.AutomaticSize.Y
headerFrame.LayoutOrder = -1
headerFrame.Parent = page.Frame

local headerLayout = Instance.new("UIListLayout")
headerLayout.Padding = UDim.new(0, 2)
headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
headerLayout.Parent = headerFrame

local titleRow = Instance.new("Frame")
titleRow.Size = UDim2.new(1, 0, 0, CONFIG.HeaderIconSize)
titleRow.BackgroundTransparency = 1
titleRow.Parent = headerFrame

local titleRowLayout = Instance.new("UIListLayout")
titleRowLayout.FillDirection = Enum.FillDirection.Horizontal
titleRowLayout.Padding = UDim.new(0, 10)
titleRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
titleRowLayout.Parent = titleRow

local iconLabel = Instance.new("ImageLabel")
iconLabel.Size = UDim2.new(0, CONFIG.HeaderIconSize, 0, CONFIG.HeaderIconSize)
iconLabel.BackgroundColor3 = T.Tertiary
iconLabel.BackgroundTransparency = 0.2
iconLabel.ScaleType = Enum.ScaleType.Fit
iconLabel.Parent = titleRow
roundFrame(iconLabel, RADIUS)

local iconFilename = CONFIG.Folder .. "/personajes_" .. (CONFIG.HeaderIcon:match("([^/]+)$") or "sonic.png")
iconLabel.Image = getCachedOnly(iconFilename) or ""
if iconLabel.Image == "" then
    task.spawn(function()
        local asset = getOrDownload(CONFIG.HeaderIcon, iconFilename)
        if asset and iconLabel.Parent then
            iconLabel.Image = asset
        end
    end)
end

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -(CONFIG.HeaderIconSize + 10), 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = T.FontBold
titleLabel.TextSize = T.TitleSize or 22
titleLabel.TextColor3 = T.Text
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = CONFIG.HeaderTitle
titleLabel.Parent = titleRow

local descLabel = Instance.new("TextLabel")
descLabel.Size = UDim2.new(1, 0, 0, 0)
descLabel.AutomaticSize = Enum.AutomaticSize.Y
descLabel.BackgroundTransparency = 1
descLabel.Font = T.Font
descLabel.TextSize = T.SmallSize or 13
descLabel.TextWrapped = true
descLabel.TextColor3 = T.TextDim
descLabel.TextXAlignment = Enum.TextXAlignment.Left
descLabel.TextYAlignment = Enum.TextYAlignment.Top
descLabel.Text = CONFIG.HeaderDescription
descLabel.Parent = headerFrame

page.HeaderFrame = headerFrame

local V = tostring(os.time())

for _, mod in ipairs(CONFIG.Modules) do
    local success, err = pcall(function()
        Menu:LoadRemoteModule(mod.url .. "?v=" .. V)
    end)
    if not success then
        warn("Error al cargar " .. mod.name .. ": " .. tostring(err))
    end
end

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end