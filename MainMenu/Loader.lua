local Menu = _G.Menu
if not Menu then return end

local urls = {
    Ajustes = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/AjustesDeMenu/AjustesDeMenu.lua",
    Extras = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/Extras.lua",
    Info = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Informacion/Informacion.lua",
    Visuales = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Visuales/Visuales.lua"
}

for name, url in pairs(urls) do
    pcall(function()
        Menu:LoadRemoteModule(url)
    end)
    if not pcall(function() Menu:LoadRemoteModule(url) end) then
        warn("Error al cargar " .. name .. " desde " .. url)
    end
end

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end