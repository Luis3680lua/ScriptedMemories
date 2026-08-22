local CONFIG = {
    PageName = "Visuales",
    PageIcon = "🎨",
    HeaderTitle = "🎨 Visuales",
    HeaderDescription = "Ajustes relacionados con la visualización en pantalla: FPS, ping y más.",
    Modules = {
        { name = "MejorPingFPS", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Visuales/MejorPingFPS.lua" },
        { name = "ServerVersion", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Visuales/ServerVersion.lua" }
    }
}

local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage(CONFIG.PageName, CONFIG.PageIcon)
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

local T = Menu.THEME

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

local topRow = Instance.new("Frame")
topRow.Size = UDim2.new(1, 0, 0, 32)
topRow.BackgroundTransparency = 1
topRow.Parent = headerFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -160, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = T.FontBold
titleLabel.TextSize = T.TitleSize or 22
titleLabel.TextColor3 = T.Text
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = CONFIG.HeaderTitle
titleLabel.Parent = topRow

Menu:CreateResetButton(page, topRow)

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

local V = tostring(os.time()) .. tostring(math.random(10000))

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