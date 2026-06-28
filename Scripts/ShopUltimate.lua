local ReplicatedStorage = game:GetService("ReplicatedStorage")

local folderName = ".cache"
if makefolder and not isfolder(folderName) then
    makefolder(folderName)
end

local function getOrDownloadAsset(url, filename)
    if not isfile(filename) then
        local success, audioData = pcall(function()
            return game:HttpGet(url)
        end)
        
        if success and audioData and #audioData > 100 then
            writefile(filename, audioData)
            task.wait(0.1)
        else
            warn("Error al descargar el archivo: " .. filename)
            return nil
        end
    end
    return getcustomasset(filename)
end

local ClientAssets = ReplicatedStorage:WaitForChild("ClientAssets")
local Sounds = ClientAssets:WaitForChild("Sounds")
local ShopMus = Sounds:WaitForChild("mus"):WaitForChild("Menu"):WaitForChild("ShopMus")

local MusicGroup = Sounds:WaitForChild("musg")

local DATOS_CANCIONES = {
    {
        Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/Lone.mp3",
        Archivo = folderName .. "/Lone.mp3",
        Creditos = "Lone by ThatGuyRamon"
    },
    {
        Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/OfAnotherDreamv2.mp3",
        Archivo = folderName .. "/OfAnotherDreamv2.mp3",
        Creditos = "Of Another Dream v2 by Juno!"
    },
    {
        Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/OnceUponRemix.mp3",
        Archivo = folderName .. "/OnceUponRemix.mp3",
        Creditos = "Once Upon (Remix) by Astranova"
    },
    {
        Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/InvoluntariaScore.mp3",
        Archivo = folderName .. "/InvoluntariaScore.mp3",
        Creditos = "Involuntaria Score (Unfinished) by Juno!"
    },
    {
        Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/LostAndFound.mp3",
        Archivo = folderName .. "/LostAndFound.mp3",
        Creditos = "Lost & Found (Unfinished) by Juno!"
    },
    {
        Url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Music/UncannyValley.mp3",
        Archivo = folderName .. "/UncannyValley.mp3",
        Creditos = "Uncanny Valley (Unfinished) by Juno!"
    }
}

local nextIndex = #ShopMus:GetChildren() + 1

for _, datos in ipairs(DATOS_CANCIONES) do
    local soundId = getOrDownloadAsset(datos.Url, datos.Archivo)

    if soundId then
        local nuevoSonido = Instance.new("Sound")
        nuevoSonido.Name = "Mus" .. nextIndex
        nextIndex += 1

        nuevoSonido.SoundId = soundId
        nuevoSonido.Volume = 2 
        
        nuevoSonido.SoundGroup = MusicGroup 
        
        nuevoSonido:SetAttribute("Title", datos.Creditos)
        nuevoSonido:SetAttribute("Loops", false)
        
        nuevoSonido.Parent = ShopMus
    end
end

local function corregirCreditosOriginales(nombreBusqueda, nuevosCreditos)
    local buscar = string.lower(nombreBusqueda)

    for _, sonido in ipairs(ShopMus:GetChildren()) do
        if sonido:IsA("Sound") then
            local titulo = string.lower(sonido:GetAttribute("Title") or "")
            local nombre = string.lower(sonido.Name)

            if (titulo:find(buscar, 1, true) or nombre:find(buscar, 1, true))
                and not titulo:find("v2", 1, true) then
                sonido:SetAttribute("Title", nuevosCreditos)
            end
        end
    end
end

corregirCreditosOriginales("Of Another Dream", "Of Another Dream v1 by Juno!")
corregirCreditosOriginales("Dissonance", "Dissonance by Juno!")