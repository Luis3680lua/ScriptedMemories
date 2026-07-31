local CONFIG = {
    PageName = "Información",
    PageIcon = "ℹ️",
    Title = "📖 Scripted Memories v0.3.0",
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

local function heading(parent, text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Font = T.FontBold
    lbl.TextSize = 16
    lbl.TextColor3 = color or T.Text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.Parent = parent
end

local function bodyText(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.BackgroundTransparency = 1
    lbl.Font = T.Font
    lbl.TextSize = T.SmallSize or 13
    lbl.TextColor3 = T.TextDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.TextWrapped = true
    lbl.Text = text
    lbl.Parent = parent
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

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 32)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = T.FontBold
titleLabel.TextSize = T.TitleSize or 22
titleLabel.TextColor3 = T.Text
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = CONFIG.Title
titleLabel.Parent = headerFrame

page.HeaderFrame = headerFrame

local descSection = card(page.Frame)
heading(descSection, CONFIG.AboutTitle, T.Accent)
bodyText(descSection, CONFIG.Description)

for i, sectionData in ipairs(CONFIG.Sections) do
    local sectionFrame = card(page.Frame)
    heading(sectionFrame, sectionData.Title, ACCENTS[((i - 1) % #ACCENTS) + 1])

    for _, itemText in ipairs(sectionData.Items) do
        bodyText(sectionFrame, itemText)
    end
end