local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage("Visuales", "🎨")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Menu/Visuales/PingFPS.lua")

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end