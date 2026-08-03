local BASE_ICON_URL = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/"
local BASE_MODULE_URL = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Personajes/"
local PLACEHOLDER_ICON = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/placeholder.png"
local SONIC_ICON = BASE_ICON_URL .. "Sonic.png"

local CONFIG = {
    Folder = "ScriptedMemories/cache",
    SortSettingKey = "personajes_sort_mode",

    Categories = {
        { Key = "survivors", Name = "Sobrevivientes", List = "Survivors" },
        { Key = "killers", Name = "Asesinos", List = "Killers" },
        { Key = "survivors_sp", Name = "Sobrevivientes (SP)", List = "SurvivorsSP" },
    },

    Survivors = {
        { Key = "tails", Name = "Tails", Icon = BASE_ICON_URL .. "Tails.png", ModuleUrl = BASE_MODULE_URL .. "Sobrevivientes/Tails.lua" },
        { Key = "knuckles", Name = "Knuckles", Icon = BASE_ICON_URL .. "Knuckles.png", ModuleUrl = BASE_MODULE_URL .. "Sobrevivientes/Knuckles.lua" },
        { Key = "eggman", Name = "Eggman", Icon = BASE_ICON_URL .. "Eggman.png", ModuleUrl = BASE_MODULE_URL .. "Sobrevivientes/Eggman.lua" },
        { Key = "amy", Name = "Amy", Icon = BASE_ICON_URL .. "Amy.png", ModuleUrl = BASE_MODULE_URL .. "Sobrevivientes/Amy.lua" },
        { Key = "cream", Name = "Cream", Icon = BASE_ICON_URL .. "Cream.png", ModuleUrl = BASE_MODULE_URL .. "Sobrevivientes/Cream.lua" },
        { Key = "metalsonic", Name = "Metal Sonic", Icon = BASE_ICON_URL .. "MetalSonic.png", ModuleUrl = BASE_MODULE_URL .. "Sobrevivientes/MetalSonic.lua" },
        { Key = "sonic", Name = "Sonic", Icon = SONIC_ICON, ModuleUrl = BASE_MODULE_URL .. "Sobrevivientes/Sonic/Sonic.lua" },
        { Key = "blaze", Name = "Blaze", Icon = BASE_ICON_URL .. "Blaze.png", ModuleUrl = BASE_MODULE_URL .. "Sobrevivientes/Blaze.lua" },
        { Key = "silver", Name = "Silver", Icon = BASE_ICON_URL .. "Silver.png", ModuleUrl = BASE_MODULE_URL .. "Sobrevivientes/Silver.lua" },
    },

    Killers = {
        { Key = "2011x", Name = "2011x", Icon = SONIC_ICON, ModuleUrl = BASE_MODULE_URL .. "Asesinos/2011x/2011x.lua" },
        { Key = "kolossos", Name = "Kolossos", Icon = SONIC_ICON, ModuleUrl = BASE_MODULE_URL .. "Asesinos/Kolossos/Kolossos.lua" },
        { Key = "tripwire", Name = "Tripwire", Icon = SONIC_ICON, ModuleUrl = BASE_MODULE_URL .. "Asesinos/Tripwire/Tripwire.lua" },
        { Key = "fleetway", Name = "Fleetway", Icon = SONIC_ICON, ModuleUrl = BASE_MODULE_URL .. "Asesinos/Fleetway/Fleetway.lua" },
    },

    SurvivorsSP = {
        { Key = "shadow", Name = "Shadow", Icon = PLACEHOLDER_ICON, ModuleUrl = BASE_MODULE_URL .. "Sobrevivientes/Shadow.lua" },
    },

    CardPadding = 10,
    RowSizing = {
        [1] = { CardHeight = 220, IconSize = 160 },
        [2] = { CardHeight = 190, IconSize = 130 },
        [3] = { CardHeight = 160, IconSize = 100 },
    }
}

local Menu = _G.Menu
if not Menu then return end

local TweenService = game:GetService("TweenService")
local HttpGet = game.HttpGet
local T = Menu.THEME
local RADIUS = T.Radius or 6

local function roundFrame(frame, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or RADIUS)
    c.Parent = frame
    return c
end

local hasFS = pcall(function() return isfolder end) and isfolder ~= nil
local canCustomAsset = pcall(function() return getcustomasset end) and getcustomasset ~= nil

if hasFS and makefolder and not isfolder(CONFIG.Folder) then
    pcall(makefolder, CONFIG.Folder)
end

local function getOrDownloadAsset(url, filename)
    if not canCustomAsset then return nil end
    if hasFS and isfile and isfile(filename) then
        local ok, asset = pcall(getcustomasset, filename)
        if ok then return asset end
        return nil
    end
    if hasFS and writefile then
        local ok, data = pcall(HttpGet, game, url)
        if ok and data and #data > 0 then
            local wok = pcall(writefile, filename, data)
            if wok then
                local cok, asset = pcall(getcustomasset, filename)
                if cok then return asset end
            end
        end
    end
    return nil
end

local ICON_CACHE = {}

local function cacheIcon(url)
    if not url or url == "" then return nil end
    if ICON_CACHE[url] ~= nil then return ICON_CACHE[url] end
    local filename = url:match("([^/]+)$") or tostring(#ICON_CACHE)
    local asset = getOrDownloadAsset(url, CONFIG.Folder .. "/personajes_" .. filename)
    ICON_CACHE[url] = asset or false
    return asset
end

local function resolveIcon(url)
    return cacheIcon(url) or cacheIcon(PLACEHOLDER_ICON) or ""
end

for _, cat in ipairs(CONFIG.Categories) do
    for _, character in ipairs(CONFIG[cat.List]) do
        cacheIcon(character.Icon)
    end
end

local page = Menu.Pages[#Menu.Pages]
if not page then return end

local rootFrame = Instance.new("Frame")
rootFrame.Size = UDim2.new(1, 0, 0, 0)
rootFrame.BackgroundTransparency = 1
rootFrame.AutomaticSize = Enum.AutomaticSize.Y
rootFrame.Parent = page.Frame

local rootLayout = Instance.new("UIListLayout")
rootLayout.Padding = UDim.new(0, 10)
rootLayout.SortOrder = Enum.SortOrder.LayoutOrder
rootLayout.Parent = rootFrame

local gridView = Instance.new("Frame")
gridView.Size = UDim2.new(1, 0, 0, 0)
gridView.BackgroundTransparency = 1
gridView.AutomaticSize = Enum.AutomaticSize.Y
gridView.Visible = true
gridView.Parent = rootFrame

local gridViewLayout = Instance.new("UIListLayout")
gridViewLayout.Padding = UDim.new(0, 10)
gridViewLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridViewLayout.Parent = gridView

local controlsRow = Instance.new("Frame")
controlsRow.Size = UDim2.new(1, 0, 0, 38)
controlsRow.BackgroundTransparency = 1
controlsRow.Parent = gridView

local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, -110, 1, 0)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = controlsRow

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Padding = UDim.new(0, 8)
tabsLayout.Parent = tabsFrame

local sortBtn = Instance.new("TextButton")
sortBtn.Size = UDim2.new(0, 100, 0, 32)
sortBtn.Position = UDim2.new(1, -100, 0, 3)
sortBtn.BackgroundColor3 = T.Accent
sortBtn.TextColor3 = T.Text
sortBtn.Font = T.FontBold
sortBtn.TextSize = 12
sortBtn.BorderSizePixel = 0
sortBtn.AutoButtonColor = false
sortBtn.Parent = controlsRow
roundFrame(sortBtn, RADIUS)

local cardsGrid = Instance.new("Frame")
cardsGrid.Size = UDim2.new(1, 0, 0, 0)
cardsGrid.BackgroundTransparency = 1
cardsGrid.AutomaticSize = Enum.AutomaticSize.Y
cardsGrid.Parent = gridView

local cardsGridLayout = Instance.new("UIListLayout")
cardsGridLayout.Padding = UDim.new(0, CONFIG.CardPadding)
cardsGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
cardsGridLayout.Parent = cardsGrid

local detailContainer = Instance.new("Frame")
detailContainer.Size = UDim2.new(1, 0, 0, 0)
detailContainer.BackgroundTransparency = 1
detailContainer.AutomaticSize = Enum.AutomaticSize.Y
detailContainer.Visible = false
detailContainer.Parent = rootFrame

local detailLayout = Instance.new("UIListLayout")
detailLayout.Padding = UDim.new(0, 8)
detailLayout.SortOrder = Enum.SortOrder.LayoutOrder
detailLayout.Parent = detailContainer

local function setHeaderVisible(visible)
    if page.HeaderFrame then
        page.HeaderFrame.Visible = visible
    end
end

Menu.CharacterUI = {
    Container = detailContainer,
    Cleanups = {}
}

function Menu.CharacterUI:RegisterCleanup(fn)
    table.insert(self.Cleanups, fn)
end

local function runCleanups()
    for _, fn in ipairs(Menu.CharacterUI.Cleanups) do
        pcall(fn)
    end
    Menu.CharacterUI.Cleanups = {}
end

local function clearDetail()
    runCleanups()
    for _, child in ipairs(detailContainer:GetChildren()) do
        child:Destroy()
    end
end

function Menu.CharacterUI:GoBack()
    clearDetail()
    detailContainer.Visible = false
    gridView.Visible = true
    setHeaderVisible(true)
    if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end

local function openCharacter(character)
    if not character.ModuleUrl then
        if Menu.Notify then Menu:Notify(character.Name .. " aún no está disponible.", "error") end
        return
    end

    clearDetail()

    local ok = pcall(function()
        Menu:LoadRemoteModule(character.ModuleUrl .. "?v=" .. tostring(os.time()))
    end)

    if not ok or #detailContainer:GetChildren() == 0 then
        clearDetail()
        if Menu.Notify then Menu:Notify("No se pudo cargar " .. character.Name .. ".", "error") end
        return
    end

    setHeaderVisible(false)
    gridView.Visible = false
    detailContainer.Visible = true
    if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end

local function createCharacterCard(character, rowFrame, perRow, sizing)
    local cardScale = 1 / perRow
    local cardOffset = -(CONFIG.CardPadding * (perRow - 1)) / perRow

    local cardBtn = Instance.new("TextButton")
    cardBtn.Size = UDim2.new(cardScale, cardOffset, 1, 0)
    cardBtn.BackgroundColor3 = T.Secondary
    cardBtn.BackgroundTransparency = 0.15
    cardBtn.BorderSizePixel = 0
    cardBtn.AutoButtonColor = false
    cardBtn.Text = ""
    cardBtn.Parent = rowFrame
    roundFrame(cardBtn, RADIUS)

    local cardPadding = Instance.new("UIPadding")
    cardPadding.PaddingTop = UDim.new(0, 10)
    cardPadding.PaddingBottom = UDim.new(0, 10)
    cardPadding.Parent = cardBtn

    local cardLayout = Instance.new("UIListLayout")
    cardLayout.Padding = UDim.new(0, 6)
    cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    cardLayout.Parent = cardBtn

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, sizing.IconSize, 0, sizing.IconSize)
    icon.BackgroundColor3 = T.Tertiary
    icon.BackgroundTransparency = 0.2
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Image = resolveIcon(character.Icon)
    icon.Parent = cardBtn
    roundFrame(icon, RADIUS)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -8, 0, 16)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = T.FontBold
    nameLabel.TextSize = 13
    nameLabel.TextColor3 = T.Text
    nameLabel.TextWrapped = true
    nameLabel.Text = character.Name
    nameLabel.Parent = cardBtn

    cardBtn.MouseEnter:Connect(function()
        TweenService:Create(cardBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play()
    end)
    cardBtn.MouseLeave:Connect(function()
        TweenService:Create(cardBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Secondary}):Play()
    end)

    cardBtn.MouseButton1Click:Connect(function()
        openCharacter(character)
    end)
end

local function computePerRow(count)
    if count <= 1 then return 1 end
    if count <= 4 then return 2 end
    return 3
end

local function getSortedList(list)
    if Menu.Settings[CONFIG.SortSettingKey] ~= "alpha" then
        return list
    end
    local copy = {}
    for _, c in ipairs(list) do table.insert(copy, c) end
    table.sort(copy, function(a, b) return a.Name:lower() < b.Name:lower() end)
    return copy
end

local activeCategory = CONFIG.Categories[1].Key

local function renderGrid()
    for _, child in ipairs(cardsGrid:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local list, cat
    for _, c in ipairs(CONFIG.Categories) do
        if c.Key == activeCategory then
            cat = c
            list = CONFIG[c.List]
            break
        end
    end
    if not list then return end

    list = getSortedList(list)
    local perRow = computePerRow(#list)
    local sizing = CONFIG.RowSizing[perRow]
    local rowFrame = nil

    for i, character in ipairs(list) do
        if (i - 1) % perRow == 0 then
            rowFrame = Instance.new("Frame")
            rowFrame.Size = UDim2.new(1, 0, 0, sizing.CardHeight)
            rowFrame.BackgroundTransparency = 1
            rowFrame.Parent = cardsGrid

            local rl = Instance.new("UIListLayout")
            rl.FillDirection = Enum.FillDirection.Horizontal
            rl.Padding = UDim.new(0, CONFIG.CardPadding)
            rl.SortOrder = Enum.SortOrder.LayoutOrder
            rl.Parent = rowFrame
        end
        createCharacterCard(character, rowFrame, perRow, sizing)
    end

    if Menu.UpdateCanvas then Menu.UpdateCanvas() end
end

local function createTab(category)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 0, 1, 0)
    tabBtn.AutomaticSize = Enum.AutomaticSize.X
    tabBtn.BackgroundColor3 = (activeCategory == category.Key) and T.Hover or T.Tertiary
    tabBtn.TextColor3 = T.Text
    tabBtn.Font = T.FontBold
    tabBtn.TextSize = 14
    tabBtn.BorderSizePixel = 0
    tabBtn.AutoButtonColor = false
    tabBtn.Text = "  " .. category.Name .. "  "
    tabBtn.Parent = tabsFrame
    roundFrame(tabBtn, RADIUS)

    tabBtn.MouseButton1Click:Connect(function()
        activeCategory = category.Key
        for _, child in ipairs(tabsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        for _, cat in ipairs(CONFIG.Categories) do
            createTab(cat)
        end
        renderGrid()
    end)
end

local function refreshSortButton()
    local isAlpha = Menu.Settings[CONFIG.SortSettingKey] == "alpha"
    sortBtn.Text = isAlpha and "🔤 A-Z" or "🏬 Tienda"
end

sortBtn.MouseButton1Click:Connect(function()
    local isAlpha = Menu.Settings[CONFIG.SortSettingKey] == "alpha"
    Menu.Settings[CONFIG.SortSettingKey] = isAlpha and "shop" or "alpha"
    if Menu.SaveSettings then Menu.SaveSettings() end
    refreshSortButton()
    renderGrid()
end)

for _, category in ipairs(CONFIG.Categories) do
    createTab(category)
end

refreshSortButton()
renderGrid()

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end