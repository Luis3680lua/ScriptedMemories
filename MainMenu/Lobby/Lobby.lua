local CONFIG = {
    PageName = "Lobby",
    PageIcon = "🏠",
    Modules = {
        { name = "MuteLobby", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Lobby/MuteLobby.lua" },
        { name = "LobbySelectorMus", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Lobby/LobbySelectorMus.lua" }
    }
}

local Menu = _G.Menu
if not Menu then return end

local page = Menu:RegisterPage(CONFIG.PageName, CONFIG.PageIcon)
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

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