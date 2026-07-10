local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage("Info", "ℹ️")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

local function NewLabel(text, size, color, bold)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -12, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	label.TextSize = size
	label.TextColor3 = color
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.RichText = true
	label.Text = text
	label.Parent = page.Frame
	return label
end

local function Divider()
	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, -12, 0, 1)
	line.BorderSizePixel = 0
	line.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
	line.Parent = page.Frame
end

-- Título
NewLabel("<font size='22'><b>ℹ️ Scripted Memories</b></font>", 16, Color3.fromRGB(255, 255, 255), true)
NewLabel("<font color='#A0A0A0'>Version 0.2.5</font>", 12, Color3.fromRGB(170, 170, 170), false)

Divider()

-- ¿Qué es?
NewLabel("<font color='#7DC4FF'><b>❓ ¿Qué es Scripted Memories?</b></font>", 15, Color3.fromRGB(125, 196, 255), true)

NewLabel([[
Scripted Memories es un paquete de scripts desarrollado para ampliar y mejorar la experiencia de <b>Outcome Memories</b> mediante funciones opcionales, mejoras de calidad de vida y contenido adicional.

Su objetivo es complementar la experiencia original del juego sin modificar su jugabilidad principal ni afectar la experiencia de otros jugadores.
]], 14, Color3.fromRGB(235, 235, 235), false)

Divider()

-- Optimizado
NewLabel("<font color='#80C8FF'><b>🛠 Optimizado</b></font>", 15, Color3.fromRGB(128, 200, 255), true)

NewLabel([[
• Optimización general de todos los scripts.
• Nuevo <b>Código Madre</b> encargado de cargar todos los módulos.
• Mejorado el sistema de selección aleatoria de las canciones del lobby.
• Todas las canciones añadidas ahora respetan el volumen configurado dentro del juego.
]], 13, Color3.fromRGB(225, 225, 225), false)

Divider()

-- Corregido
NewLabel("<font color='#8CFFB2'><b>🐞 Corregido</b></font>", 15, Color3.fromRGB(140, 255, 178), true)

NewLabel([[
• 2011X (Classic / RetroX) ahora reproduce correctamente el END del Last Life.
• MikuX reproduce correctamente Ready or Not.
• El END del Rage de MikuX ahora tiene la duración correcta.
]], 13, Color3.fromRGB(225, 225, 225), false)

Divider()

-- Mejoras
NewLabel("<font color='#FFD36B'><b>✨ Mejoras</b></font>", 15, Color3.fromRGB(255, 211, 107), true)

NewLabel([[
• MikuX ahora dispone de su propia Terror Radius.
• Los nuevos iconos de la tienda fueron reajustados para ocupar menos espacio.
• Renovado el icono del inicializador de scripts.
• Nuevo banner dedicado a 2011X.
]], 13, Color3.fromRGB(225, 225, 225), false)

Divider()

-- Añadido
NewLabel("<font color='#FFB86C'><b>🎵 Añadido</b></font>", 15, Color3.fromRGB(255, 184, 108), true)

NewLabel([[
<b>Nuevas canciones para la Tienda</b>

• Involuntaria Score (Unfinished) — Juno!
• Lost & Found (Unfinished) — Juno!
• Uncanny Valley (Unfinished) — Juno!

<b>Nueva canción para el Lobby</b>

• Tea Time Waltz
]], 13, Color3.fromRGB(225, 225, 225), false)

Divider()

-- Nota
NewLabel("<font color='#BDBDBD'><b>📝 Nota</b></font>", 15, Color3.fromRGB(189, 189, 189), true)

NewLabel([[
Tea Time Waltz fue la música utilizada originalmente en el lobby del Prototype de Outcome Memories.
]], 13, Color3.fromRGB(200, 200, 200), false)

task.wait(0.1)

if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end