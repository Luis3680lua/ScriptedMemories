local Menu = _G.Menu
if not Menu then return end

local pages = {
    { name = "Info", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Informacion/Informacion.lua" },
    { name = "Visuales", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Visuales/Visuales.lua" },
    { name = "Lobby", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Lobby/Lobby.lua" },
    { name = "Shop", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Shop/Shop.lua" },
    { name = "Ajustes", url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/AjustesDeMenu/AjustesDeMenu.lua" },
}

for _, page in ipairs(pages) do
    local success, err = pcall(function()
        Menu:LoadRemoteModule(page.url)
    end)
    if not success then
        warn("Error al cargar " .. page.name .. ": " .. tostring(err))
    end
end

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end