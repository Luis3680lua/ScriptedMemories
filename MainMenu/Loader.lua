local Menu = _G.Menu
if not Menu then return end
if Menu._SectionsLoaded then return end
Menu._SectionsLoaded = true

local BASE_URL = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/"
local V = tostring(os.time()) .. tostring(math.random(10000))

local pages = {
    { name = "Info", path = "Informacion/Informacion.lua" },
    { name = "Visuales", path = "Visuales/Visuales.lua" },
    { name = "Sonic", path = "Sonic/Sonic.lua" },
    { name = "Lobby", path = "Lobby/Lobby.lua" },
    { name = "Shop", path = "Shop/Shop.lua" },
    { name = "Ajustes", path = "AjustesDeMenu/AjustesDeMenu.lua" },
}

for _, page in ipairs(pages) do
    local success, err = pcall(function()
        Menu:LoadRemoteModule(BASE_URL .. page.path .. "?v=" .. V)
    end)
    if not success then
        warn("Error al cargar " .. page.name .. ": " .. tostring(err))
    end
end

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end