local CONFIG = {
    PageName = "Información",
    PageIcon = "ℹ️",
    Title = "📖 Scripted Memories v0.3.0",
    Version = "",
    Author = "Luis3680",
    AuthorPrefix = "Hecho por",
    AboutTitle = "📖 Acerca de Scripted Memories",
    Description = "Scripted Memories es un paquete de scripts que amplía la experiencia de Outcome Memories mediante funciones opcionales, mejoras de calidad de vida, opciones de personalización y la restauración de contenido cuando es posible. Su objetivo es complementar la experiencia original sin reemplazar su identidad ni alterar el funcionamiento principal del juego.",
    Sections = {
        {
            Title = "📝 Changelogs",
            Items = {
                "Nose w, ni fokin idea ya que aun no termino esta vaina, esperate w."
            }
        },
        {
            Title = "🎯 Filosofía del proyecto",
            Items = {
                "Restaurar contenido oficial descartado siempre que no afecte a los demás.",
                "Aprovechar tanto contenido oficial como de la comunidad para ampliar la experiencia del jugador.",
                "Ofrecer la mayor cantidad posible de opciones de personalización, permitiendo que cada jugador decida qué funciones desea utilizar y cuáles no.",
                "Incorporar mejoras de calidad de vida completamente opcionales, sin modificar la experiencia base para quien prefiera mantenerla.",
                "Explorar posibilidades que Outcome Memories no puede ofrecer de forma nativa.",
                "Mantener una estructura modular que facilite futuras ampliaciones y permita añadir nuevas funciones de forma organizada.",
                "Priorizar la estabilidad y el rendimiento."
            }
        }
    }
}

local Menu = _G.Menu
if not Menu then return end

local T = Menu.THEME
local ACCENTS = { T.Accent, T.Green, T.Red }

local function panel(parent, autoY)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 0)
    f.BackgroundTransparency = 1
    f.AutomaticSize = autoY and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
    f.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = f

    return f, layout
end

local function card(parent)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 0)
    f.BackgroundColor3 = T.Secondary
    f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0
    f.AutomaticSize = Enum.AutomaticSize.Y
    f.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, T.Radius or 6)
    corner.Parent = f

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = f

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = f

    return f
end

local function heading(parent, text, color, size)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Font = T.FontBold
    lbl.TextSize = size or 16
    lbl.TextColor3 = color or T.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = parent
    return lbl
end

local function bodyText(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = T.Font
    lbl.TextSize = T.SmallSize or 13
    lbl.TextColor3 = T.TextDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.TextWrapped = true
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.Text = text
    lbl.Parent = parent
    return lbl
end

local page = Menu:RegisterPage(CONFIG.PageName, CONFIG.PageIcon)
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

local container = panel(page.Frame, true)
container.Size = UDim2.new(1, 0, 0, 0)

local containerPadding = Instance.new("UIPadding")
containerPadding.PaddingLeft = UDim.new(0, 4)
containerPadding.PaddingRight = UDim.new(0, 4)
containerPadding.PaddingTop = UDim.new(0, 4)
containerPadding.PaddingBottom = UDim.new(0, 4)
containerPadding.Parent = container

local mainLayout = container.UIListLayout
mainLayout.Padding = UDim.new(0, 8)

local headerFrame = panel(container, true)
headerFrame.UIListLayout.Padding = UDim.new(0, 2)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 32)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = T.FontBold
titleLabel.TextSize = T.TitleSize or 22
titleLabel.TextColor3 = T.Text
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = CONFIG.Title
titleLabel.Parent = headerFrame

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(1, 0, 0, 20)
versionLabel.BackgroundTransparency = 1
versionLabel.Font = T.Font
versionLabel.TextSize = T.SmallSize or 13
versionLabel.TextColor3 = T.TextDim
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.Text = CONFIG.Version .. " " .. CONFIG.AuthorPrefix .. " " .. CONFIG.Author
versionLabel.Parent = headerFrame

local descSection = card(container)
heading(descSection, CONFIG.AboutTitle, T.Accent, 16)
bodyText(descSection, CONFIG.Description)

for i, sectionData in ipairs(CONFIG.Sections) do
    local sectionFrame = card(container)
    local accent = ACCENTS[((i - 1) % #ACCENTS) + 1]
    heading(sectionFrame, sectionData.Title, accent, 16)

    for _, itemText in ipairs(sectionData.Items) do
        if itemText == "" then
            local spacer = Instance.new("Frame")
            spacer.Size = UDim2.new(1, 0, 0, 6)
            spacer.BackgroundTransparency = 1
            spacer.Parent = sectionFrame
        else
            bodyText(sectionFrame, itemText)
        end
    end
end