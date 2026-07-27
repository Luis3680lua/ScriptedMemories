local CONFIG = {
    PageName = "Lobby",
    PageIcon = "🏠",
    HeaderTitle = "🏠 Lobby",
    HeaderDescription = "Ajustes y personalización relacionados con el lobby: música, iconos y más.",
    Modules = {
        { name = "MuteLobby", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Lobby/MuteLobby.lua" },
        { name = "LobbySelectorMus", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Lobby/LobbySelectorMus.lua" }
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

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 32)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = T.FontBold
titleLabel.TextSize = T.TitleSize or 22
titleLabel.TextColor3 = T.Text
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = CONFIG.HeaderTitle
titleLabel.Parent = headerFrame

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