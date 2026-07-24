local CONFIG = {
    PageName = "Información",
    PageIcon = "ℹ️",
    Title = "ℹ️ Scripted Memories",
    Version = "v0.3.0",
    Description = [[Scripted Memories es un paquete de scripts creado por Luis3680 para potenciar tu experiencia en Outcome Memories. Ofrece funciones opcionales, mejoras de calidad de vida y contenido adicional cuidadosamente integrado. Su propósito es enriquecer la jugabilidad original sin alterar su esencia ni perjudicar la experiencia de los demás jugadores, aprovechando contenido descartado y dándole una nueva vida.]],
    Sections = {
        {
            Title = "❓ ¿Qué es Scripted Memories?",
            Color = Color3.fromRGB(70, 150, 255),
            Items = {
                "Scripted Memories es un paquete de scripts creado por Luis3680 para potenciar tu experiencia en Outcome Memories.",
                "",
                "Ofrece funciones opcionales, mejoras de calidad de vida y contenido adicional cuidadosamente integrado.",
                "",
                "Su propósito es enriquecer la jugabilidad original sin alterar su esencia ni perjudicar la experiencia de los demás jugadores, aprovechando contenido descartado y dándole una nueva vida."
            }
        },
        {
            Title = "📋 Novedades (Changelogs)",
            Color = Color3.fromRGB(128, 200, 255),
            Items = {
                "✨ Nuevo sistema de menú completamente rediseñado.",
                "🎨 Interfaz optimizada con transiciones más suaves y menor consumo de recursos.",
                "👥 Sección de personajes: ahora puedes elegir tu LMS o Chases favoritos.",
                "⚙️ Ajustes visuales personalizables (temas, colores, transparencia).",
                "🎮 Extras: personalización del Lobby y la Tienda.",
                "🔑 Configuración de teclas (abrir menú con cualquier botón).",
                "🧹 Limpieza de caché y restauración de ajustes predeterminados."
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

local line = Instance.new("Frame")
line.Size = UDim2.new(1, 0, 0, 2)
line.BackgroundColor3 = T.Accent
line.BackgroundTransparency = 0.3
line.BorderSizePixel = 0
line.Parent = headerFrame

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(1, 0, 0, 20)
versionLabel.BackgroundTransparency = 1
versionLabel.Font = T.Font
versionLabel.TextSize = 13
versionLabel.TextColor3 = T.TextDim
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.Text = CONFIG.Version .. "  •  Desarrollado por Luis3680"
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
    sectionPadding.PaddingLeft = UDim.new(0, 16)
    sectionPadding.PaddingRight = UDim.new(0, 12)
    sectionPadding.PaddingTop = UDim.new(0, 10)
    sectionPadding.PaddingBottom = UDim.new(0, 10)
    sectionPadding.Parent = sectionFrame

    local sectionLayout = Instance.new("UIListLayout")
    sectionLayout.Padding = UDim.new(0, 6)
    sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sectionLayout.Parent = sectionFrame

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, -12)
    accentBar.Position = UDim2.new(0, 6, 0, 6)
    accentBar.BackgroundColor3 = accentColor or T.Accent
    accentBar.BackgroundTransparency = 0.2
    accentBar.BorderSizePixel = 0
    accentBar.Parent = sectionFrame
    roundFrame(accentBar, 2)

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -12, 0, 24)
    header.Position = UDim2.new(0, 12, 0, 0)
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
            item.Size = UDim2.new(1, -16, 0, 0)
            item.Position = UDim2.new(0, 12, 0, 0)
            item.BackgroundTransparency = 1
            item.Font = T.Font
            item.TextSize = 13.5
            item.TextColor3 = T.TextDim
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.TextYAlignment = Enum.TextYAlignment.Top
            item.TextWrapped = true
            item.AutomaticSize = Enum.AutomaticSize.Y
            if not itemText:match("^[%*•]") then
                itemText = "• " .. itemText
            end
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
descPadding.PaddingLeft = UDim.new(0, 16)
descPadding.PaddingRight = UDim.new(0, 12)
descPadding.PaddingTop = UDim.new(0, 10)
descPadding.PaddingBottom = UDim.new(0, 10)
descPadding.Parent = descSection

local descLayout = Instance.new("UIListLayout")
descLayout.Padding = UDim.new(0, 4)
descLayout.SortOrder = Enum.SortOrder.LayoutOrder
descLayout.Parent = descSection

local descAccent = Instance.new("Frame")
descAccent.Size = UDim2.new(0, 4, 1, -12)
descAccent.Position = UDim2.new(0, 6, 0, 6)
descAccent.BackgroundColor3 = T.Accent
descAccent.BackgroundTransparency = 0.15
descAccent.BorderSizePixel = 0
descAccent.Parent = descSection
roundFrame(descAccent, 2)

local descTitle = Instance.new("TextLabel")
descTitle.Size = UDim2.new(1, -12, 0, 24)
descTitle.Position = UDim2.new(0, 12, 0, 0)
descTitle.BackgroundTransparency = 1
descTitle.Font = T.FontBold
descTitle.TextSize = 16
descTitle.TextColor3 = T.Accent
descTitle.TextXAlignment = Enum.TextXAlignment.Left
descTitle.Text = "📌 Sobre el proyecto"
descTitle.Parent = descSection

local descBody = Instance.new("TextLabel")
descBody.Size = UDim2.new(1, -16, 0, 0)
descBody.Position = UDim2.new(0, 12, 0, 0)
descBody.BackgroundTransparency = 1
descBody.Font = T.Font
descBody.TextSize = 13.5
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