-- ==================== NUEVO SCRIPT START ====================

-- 1. Limpieza de caché
local function limpiarCache()
    if not (isfolder and delfolder) then
        return
    end

    for _, carpeta in ipairs({".cache", "workspace"}) do
        local ok, existe = pcall(isfolder, carpeta)
        if ok and existe then
            pcall(delfolder, carpeta)
        end
    end
end

limpiarCache()
task.wait(0.1)

-- 2. Función para cargar scripts remotos
local function loadScript(url)
    local ok, source = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or type(source) ~= "string" or source == "" then
        return
    end

    local func = loadstring(source)
    if func then
        task.spawn(function()
            pcall(func)
        end)
    end
end

loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Load.lua")
task.wait(0.5) -- esperar a que la animación de entrada termine

-- 4. Cargar información del script
loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Info.lua")
task.wait(0.2)

-- 5. Lista de scripts a cargar
local scripts = {
    "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Rings.lua",
    "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/BetterPing.lua",
    "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/LobbyRandom.lua",
    "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/TerrorRadiusChaseLastLifeRage.lua",
    "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/SoDontBlink.lua",
    "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/FixGodsTrickeryFailLaugh.lua",
    "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/ShopUltimate.lua",
    "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/SurvivorIconShop.lua",
    "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/FixLastLifeEND2011x.lua",
}

local total = #scripts

-- 6. Cargar los scripts actualizando la barra de progreso
for i, url in ipairs(scripts) do
    loadScript(url)
    task.wait(0.05)

    -- Actualizar la pantalla de carga si está disponible
    if _G.LoadingScreen then
        local percent = math.floor(i / total * 100)
        _G.LoadingScreen.SetProgress(percent)
        -- Opcional: extraer el nombre del archivo para mostrarlo
        local scriptName = url:match("([^/]+)%.lua$") or ""
        _G.LoadingScreen.SetText("Cargando " .. scriptName .. "...")
    end
end

task.wait(0.5)

-- 7. Finalizar la pantalla de carga con el mensaje de éxito
if _G.LoadingScreen then
    _G.LoadingScreen.Finish("Scripted Memories", "✔️ Cargo correctamente.", 2)
end

-- Ya NO se carga el antiguo Load.lua al final