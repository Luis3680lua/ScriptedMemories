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
            Title = "📝 Novedades de la versión",
            Color = Color3.fromRGB(128, 200, 255),
            Items = {
                "✨ Menú completamente rediseñado con una interfaz más moderna, organizada e intuitiva.",
                "⚡ Optimizaciones generales para mejorar el rendimiento y la estabilidad.",
                "🎨 Nuevas opciones de personalización para adaptar la apariencia del menú.",
                "👥 Sistema ampliado de personalización para personajes, incluyendo selección de LMS y Chase cuando está disponible.",
                "🏪 Nuevas opciones para personalizar distintos elementos del Lobby y la Tienda.",
                "💾 Sistema de configuración renovado con un guardado más fiable y organizado.",
                "🧹 Herramientas para limpiar la caché, restablecer configuraciones y facilitar el mantenimiento.",
                "🔧 Mejoras internas para una mayor compatibilidad entre módulos y futuras actualizaciones."
            }
        },
        {
            Title = "🎯 Filosofía del proyecto",
            Color = Color3.fromRGB(255, 200, 100),
            Items = {
                "Preservar la esencia y la identidad de Outcome Memories.",
                "Restaurar contenido oficial descartado siempre que sea técnicamente posible.",
                "Integrar contenido creado por la comunidad que mantenga una calidad y estilo coherentes con el juego.",
                "Aprovechar tanto contenido oficial como de la comunidad para ampliar la experiencia del jugador.",
                "Ofrecer la mayor cantidad posible de opciones de personalización, permitiendo que cada jugador decida qué funciones desea utilizar y cuáles no.",
                "Incorporar mejoras de calidad de vida completamente opcionales, sin modificar la experiencia base para quien prefiera mantenerla.",
                "Explorar posibilidades que Outcome Memories no puede ofrecer de forma nativa, siempre respetando la identidad del proyecto.",
                "Mantener una estructura modular que facilite futuras ampliaciones y permita añadir nuevas funciones de forma organizada.",
                "Priorizar la estabilidad, el rendimiento y la compatibilidad en todas las características implementadas.",
                "Desarrollar nuevas funciones respetando el estilo, la ambientación y la dirección artística del juego original."
            }
        }
    }
}

local Menu = _G.Menu
if not Menu then return end

local T = Menu.THEME

local function roundFrame(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or T.Radius or 6)
    corner.Parent = frame
    return corner
end

local page = Menu:RegisterPage(CONFIG.PageName, CONFIG.PageIcon)
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 0, 0)
container.BackgroundTransparency = 1
container.AutomaticSize = Enum.AutomaticSize.Y
container.Parent = page.Frame

local containerPadding = Instance.new("UIPadding")
containerPadding.PaddingLeft = UDim.new(0, 4)
containerPadding.PaddingRight = UDim.new(0, 4)
containerPadding.PaddingTop = UDim.new(0, 4)
containerPadding.PaddingBottom = UDim.new(0, 4)
containerPadding.Parent = container

local mainLayout = Instance.new("UIListLayout")
mainLayout.Padding = UDim.new(0, 8)
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainLayout.Parent = container

local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 0)
headerFrame.BackgroundTransparency = 1
headerFrame.AutomaticSize = Enum.AutomaticSize.Y
headerFrame.Parent = container

local headerLayout = Instance.new("UIListLayout")
headerLayout.Padding = UDim.new(0, 2)
headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
headerLayout.Parent = headerFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 32)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = T.FontBold
titleLabel.TextSize = 22
titleLabel.TextColor3 = T.Text
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = CONFIG.Title
titleLabel.Parent = headerFrame

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(1, 0, 0, 20)
versionLabel.BackgroundTransparency = 1
versionLabel.Font = T.Font
versionLabel.TextSize = 13
versionLabel.TextColor3 = T.TextDim
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.Text = CONFIG.Version .. " " .. CONFIG.AuthorPrefix .. " " .. CONFIG.Author
versionLabel.Parent = headerFrame

local function createSection(title, accentColor, items)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(1, 0, 0, 0)
    sectionFrame.BackgroundColor3 = T.Secondary
    sectionFrame.BackgroundTransparency = 0.15
    sectionFrame.BorderSizePixel = 0
    sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
    roundFrame(sectionFrame, T.Radius or 6)
    sectionFrame.Parent = container

    local sectionPadding = Instance.new("UIPadding")
    sectionPadding.PaddingLeft = UDim.new(0, 12)
    sectionPadding.PaddingRight = UDim.new(0, 12)
    sectionPadding.PaddingTop = UDim.new(0, 10)
    sectionPadding.PaddingBottom = UDim.new(0, 10)
    sectionPadding.Parent = sectionFrame

    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.Padding = UDim.new(0, 4)
    sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sectionLayout.Parent = sectionFrame

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 24)
    header.BackgroundTransparency = 1
    header.Font = T.FontBold
    header.TextSize = 16
    header.TextColor3 = accentColor or T.Text
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.TextYAlignment = Enum.TextYAlignment.Bottom
    header.Text = title
    header.Parent = sectionFrame

    for _, itemText in ipairs(items) do
        if itemText == "" then
            local spacer = Instance.new("Frame")
            spacer.Size = UDim2.new(1, 0, 0, 6)
            spacer.BackgroundTransparency = 1
            spacer.Parent = sectionFrame
        else
            local item = Instance.new("TextLabel")
            item.Size = UDim2.new(1, 0, 0, 0)
            item.BackgroundTransparency = 1
            item.Font = T.Font
            item.TextSize = 13
            item.TextColor3 = T.TextDim
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.TextYAlignment = Enum.TextYAlignment.Top
            item.TextWrapped = true
            item.AutomaticSize = Enum.AutomaticSize.Y
            item.Text = itemText
            item.Parent = sectionFrame
        end
    end
end

local descSection = Instance.new("Frame")
descSection.Size = UDim2.new(1, 0, 0, 0)
descSection.BackgroundColor3 = T.Secondary
descSection.BackgroundTransparency = 0.15
descSection.BorderSizePixel = 0
descSection.AutomaticSize = Enum.AutomaticSize.Y
roundFrame(descSection, T.Radius or 6)
descSection.Parent = container

local descPadding = Instance.new("UIPadding")
descPadding.PaddingLeft = UDim.new(0, 12)
descPadding.PaddingRight = UDim.new(0, 12)
descPadding.PaddingTop = UDim.new(0, 10)
descPadding.PaddingBottom = UDim.new(0, 10)
descPadding.Parent = descSection

local descLayout = Instance.new("UIListLayout")
descLayout.Padding = UDim.new(0, 4)
descLayout.SortOrder = Enum.SortOrder.LayoutOrder
descLayout.Parent = descSection

local descTitle = Instance.new("TextLabel")
descTitle.Size = UDim2.new(1, 0, 0, 24)
descTitle.BackgroundTransparency = 1
descTitle.Font = T.FontBold
descTitle.TextSize = 16
descTitle.TextColor3 = T.Accent
descTitle.TextXAlignment = Enum.TextXAlignment.Left
descTitle.Text = CONFIG.AboutTitle
descTitle.Parent = descSection

local descBody = Instance.new("TextLabel")
descBody.Size = UDim2.new(1, 0, 0, 0)
descBody.BackgroundTransparency = 1
descBody.Font = T.Font
descBody.TextSize = 13
descBody.TextColor3 = T.TextDim
descBody.TextXAlignment = Enum.TextXAlignment.Left
descBody.TextYAlignment = Enum.TextYAlignment.Top
descBody.TextWrapped = true
descBody.AutomaticSize = Enum.AutomaticSize.Y
descBody.Text = CONFIG.Description
descBody.Parent = descSection

for _, sectionData in ipairs(CONFIG.Sections) do
    createSection(sectionData.Title, sectionData.Color, sectionData.Items)
end