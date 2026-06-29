local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function is2011x()
    local char = LocalPlayer.Character
    return char and char:GetAttribute("Character") == "2011x"
end

-- Destruir cualquier sonido "End" que aparezca en Songs (solo si eres 2011x)
local function onChildAdded(child)
    if not is2011x() then return end
    if child:IsA("Sound") and child.Name == "End" then
        child:Destroy()
    end
end

-- Conectar al folder Songs (donde se crean los sonidos de chase y End)
local songsFolder = workspace:WaitForChild("Assets"):WaitForChild("Songs")
songsFolder.ChildAdded:Connect(onChildAdded)

-- Por si ya existen al iniciar el script
if is2011x() then
    for _, obj in ipairs(songsFolder:GetChildren()) do
        onChildAdded(obj)
    end
end

-- Si cambia el personaje, limpiamos otra vez
LocalPlayer.CharacterAdded:Connect(function(char)
    if char:GetAttribute("Character") == "2011x" then
        for _, obj in ipairs(songsFolder:GetChildren()) do
            onChildAdded(obj)
        end
    end
end)