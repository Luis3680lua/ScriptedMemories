local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage("Info", "ℹ️")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

local COLORS = {
    Title = Color3.fromRGB(255,255,255),
    Subtitle = Color3.fromRGB(95,190,255),
    Text = Color3.fromRGB(225,225,230),
    Divider = Color3.fromRGB(55,55,65),
    Note = Color3.fromRGB(170,170,180),
    Card = Color3.fromRGB(33,33,40),
}

local function CreateLabel(text,size,font,color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1,-20,0,0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.Font = font
    label.TextSize = size
    label.TextColor3 = color
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Text = text
    return label
end

local function AddDivider(parent)
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1,-20,0,1)
    line.BackgroundColor3 = COLORS.Divider
    line.BorderSizePixel = 0
    line.Parent = parent
end

local function AddSpacing(parent,height)
    local space = Instance.new("Frame")
    space.BackgroundTransparency = 1
    space.Size = UDim2.new(1,0,0,height)
    space.Parent = parent
end

local function AddCard(parent,title,body)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1,-8,0,0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = COLORS.Card
    card.BorderSizePixel = 0
    card.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60,60,70)
    stroke.Thickness = 1
    stroke.Parent = card

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0,10)
    padding.PaddingBottom = UDim.new(0,10)
    padding.PaddingLeft = UDim.new(0,12)
    padding.PaddingRight = UDim.new(0,12)
    padding.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,6)
    layout.Parent = card

    CreateLabel(title,16,Enum.Font.GothamBold,COLORS.Subtitle).Parent = card
    CreateLabel(body,13,Enum.Font.Gotham,COLORS.Text).Parent = card
end

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,10)
layout.Parent = page.Frame

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0,8)
padding.PaddingRight = UDim.new(0,8)
padding.PaddingTop = UDim.new(0,8)
padding.PaddingBottom = UDim.new(0,8)
padding.Parent = page.Frame

CreateLabel("ℹ️ Scripted Memories",20,Enum.Font.GothamBold,COLORS.Title).Parent = page.Frame
CreateLabel("Version 0.2.5",13,Enum.Font.GothamMedium,COLORS.Note).Parent = page.Frame

AddDivider(page.Frame)

CreateLabel(
    "Scripted Memories es un paquete de scripts diseñado para mejorar tu experiencia en Outcome Memories sin afectar a otros jugadores.\n\nNo es un hack. Son mejoras de calidad de vida, nuevas músicas y pequeños añadidos que respetan la experiencia original del juego.",
    14,
    Enum.Font.Gotham,
    COLORS.Text
).Parent = page.Frame

AddCard(page.Frame,"🛠 Optimizado",[[
• Optimización general de todos los scripts.
• Nuevo Código Madre encargado de cargar todos los módulos.
• Mejorado el sistema de selección aleatoria de canciones del lobby.
• Todas las canciones añadidas ahora respetan el volumen configurado dentro del juego.
]])

AddCard(page.Frame,"🐞 Corregido",[[
• 2011X (Classic/RetroX) ahora reproduce correctamente el END del Last Life.
• MikuX reproduce correctamente Ready or Not.
• El END del Rage de MikuX ahora tiene la duración correcta.
]])

AddCard(page.Frame,"✨ Mejoras",[[
• MikuX ahora posee Terror Radius.
• Los nuevos iconos de la tienda ocupan menos espacio.
• Renovado el icono del inicializador.
• Nuevo banner dedicado a 2011X.
]])

AddCard(page.Frame,"🎵 Añadido",[[
Nuevas canciones para la Tienda

• Involuntaria Score (Unfinished) — Juno!
• Lost & Found (Unfinished) — Juno!
• Uncanny Valley (Unfinished) — Juno!

Nueva canción para el Lobby

• Tea Time Waltz
]])

AddCard(page.Frame,"📝 Nota",[[
Tea Time Waltz fue la música utilizada originalmente en el lobby del Prototype de Outcome Memories.
]])

AddSpacing(page.Frame,4)

CreateLabel(
    "Changelog #4 • Fixed Bugs and Stuff #3",
    11,
    Enum.Font.Gotham,
    COLORS.Note
).Parent = page.Frame

task.wait(0.1)

if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end