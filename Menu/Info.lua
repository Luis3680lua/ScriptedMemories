local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage("Info", "ℹ️")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

local descLabel = Instance.new("TextLabel")
descLabel.Size = UDim2.new(1, -12, 0, 0)
descLabel.AutomaticSize = Enum.AutomaticSize.Y
descLabel.BackgroundTransparency = 1
descLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
descLabel.Font = Enum.Font.Gotham
descLabel.TextSize = 14
descLabel.TextWrapped = true
descLabel.TextXAlignment = Enum.TextXAlignment.Left
descLabel.Text = [[Scripted Memories es un paquete de scripts diseñado para mejorar tu experiencia en Outcome Memories sin afectar a otros jugadores. No es un hack, solo mejoras de calidad de vida y añadidos divertidos que respetan la experiencia original del juego.]]
descLabel.Parent = page.Frame

local changelogLabel = Instance.new("TextLabel")
changelogLabel.Size = UDim2.new(1, -12, 0, 0)
changelogLabel.AutomaticSize = Enum.AutomaticSize.Y
changelogLabel.BackgroundTransparency = 1
changelogLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
changelogLabel.Font = Enum.Font.Gotham
changelogLabel.TextSize = 12
changelogLabel.TextWrapped = true
changelogLabel.TextXAlignment = Enum.TextXAlignment.Left
changelogLabel.Text = [[# Scripted Memories v0.2.5

### Changelogs #4 – Fixed Bugs and Stuff #3

## Optimizado
* Optimización de todos los scripts.
* Nuevo "Código Madre" encargado de cargar todos los scripts.
* Mejorado el sistema de selección aleatoria de las canciones del lobby.
* Todas las canciones añadidas por el script ahora respetan el volumen de música configurado dentro del juego.

## Corregido
* 2011X (Junto a Classic / RetroX) ahora reproduce correctamente el END del Last Life. (PORFIN.)
* MikuX reproduce correctamente Ready or Not.
* MikuX ahora incluye el END de su Rage correctamente, haciendo que la secuencia tenga la duración correcta.

## Mejoras
* MikuX ahora cuenta con su Terror Radius (NOW).
* Los nuevos iconos de la tienda fueron reajustados para ocupar menos espacio y evitar que cubran el nombre de los survivors.
* Renovado icono del inicializador de scripts.
* Nuevo banner dedicado a 2011X, protagonista de esta actualización.

## Añadido
### Nuevas canciones para la Tienda
* Involuntaria Score (Unfinished) — por Juno!
* Lost & Found (Unfinished) — por Juno!
* Uncanny Valley (Unfinished) — por Juno!

### Nueva canción añadida al Lobby
* Tea Time Waltz-Lobby

Nota: Tea Time Waltz-Lobby fue la música utilizada originalmente en el lobby del Prototype de OM.]]
changelogLabel.Parent = page.Frame

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end