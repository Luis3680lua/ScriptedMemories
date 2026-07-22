local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage("Ajustes de Menú", "⚙️")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/Ajustes/KeyboardShortcut.lua")
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/Ajustes/ControllerShortcut.lua")
Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/Ajustes/Maintenance.lua")

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end