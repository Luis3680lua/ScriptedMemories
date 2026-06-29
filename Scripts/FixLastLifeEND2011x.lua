local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local folderName = ".cache"

-- Función para obtener el asset personalizado (debe coincidir con tu script de reemplazo)
local function getCustomAssetUrl()
    return getcustomasset(folderName .. "/DIE.mp3")  -- El mismo archivo que usas para LastLifeChase de 2011x
end

local CUSTOM_LASTLIFE_ID = getCustomAssetUrl()

-- Solo 2011x y variantes
local function is2011x(char)
    if not char then return false end
    local name = char:GetAttribute("Character")
    return name == "2011x" or name == "2011xClassic" or name == "2011xRetro"
end

-- Contar supervivientes en LastLife cerca
local function countNearbyLastLifeSurvivors()
    local char = LocalPlayer.Character
    if not char then return 0 end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return 0 end
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local other = plr.Character
            if other
                and other:GetAttribute("Team") == "Survivor"
                and other:GetAttribute("LastLife") == true
                and other:GetAttribute("State") ~= "downed"
            then
                local otherRoot = other:FindFirstChild("HumanoidRootPart")
                if otherRoot and (root.Position - otherRoot.Position).Magnitude <= 100 then
                    count = count + 1
                end
            end
        end
    end
    return count
end

local function startLastLifeControl()
    if not is2011x(LocalPlayer.Character) then return end

    -- Buscar el sonido LastLifeChase que tenga nuestro asset personalizado
    local function findOurLastLifeSound()
        local songs = workspace:FindFirstChild("Assets") and workspace.Assets:FindFirstChild("Songs")
        if not songs then return nil end
        for _, sound in ipairs(songs:GetChildren()) do
            if sound:IsA("Sound") and sound.Name == "LastLifeChase" and sound.SoundId == CUSTOM_LASTLIFE_ID then
                return sound
            end
        end
        return nil
    end

    local lastLifeSound = findOurLastLifeSound()
    if not lastLifeSound then
        -- Esperar a que aparezca (se crea poco después de spawnear)
        local conn; conn = game.DescendantAdded:Connect(function(obj)
            if obj:IsA("Sound") and obj.Name == "LastLifeChase" and obj.SoundId == CUSTOM_LASTLIFE_ID then
                lastLifeSound = obj
                conn:Disconnect()
            end
        end)
        repeat task.wait() until lastLifeSound
    end

    -- Silenciar cualquier sonido "End" que aparezca (sin destruirlo)
    local function muteEnd(obj)
        if obj:IsA("Sound") and obj.Name == "End" and is2011x(LocalPlayer.Character) then
            obj.Volume = 0
        end
    end
    game.DescendantAdded:Connect(muteEnd)
    -- Silenciar los que ya existan
    for _, obj in ipairs(workspace:GetDescendants()) do
        muteEnd(obj)
    end

    -- Control de volumen cada 0.5 segundos con fade suave
    task.spawn(function()
        while true do
            task.wait(0.5)
            if not lastLifeSound or not lastLifeSound.Parent then break end
            if not is2011x(LocalPlayer.Character) then
                -- Si ya no soy 2011x, restauro volumen por si acaso
                lastLifeSound.Volume = 0.75
                break
            end
            local target = countNearbyLastLifeSurvivors() > 0 and 0.75 or 0
            lastLifeSound.Volume = lastLifeSound.Volume + (target - lastLifeSound.Volume) * 0.25
        end
    end)
end

-- Iniciar cuando aparezca el personaje
LocalPlayer.CharacterAdded:Connect(function(char)
    if is2011x(char) then
        startLastLifeControl()
    end
end)

if LocalPlayer.Character then
    if is2011x(LocalPlayer.Character) then
        startLastLifeControl()
    end
end