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

loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Info.lua")
task.wait(0.2)

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

for _, url in ipairs(scripts) do
    loadScript(url)
    task.wait(0.05)
end

task.wait(0.5)

loadScript("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Load.lua")