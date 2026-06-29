local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function is2011x(char)
    return char and char:GetAttribute("Character") == "2011x"
end

local function destroyEnd(obj)
    if obj:IsA("Sound") and obj.Name == "End" then
        local char = LocalPlayer.Character
        if is2011x(char) then
            obj:Destroy()
        end
    end
end

game.DescendantAdded:Connect(destroyEnd)

local char = LocalPlayer.Character
if is2011x(char) then
    for _, obj in ipairs(game:GetDescendants()) do
        destroyEnd(obj)
    end
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    if is2011x(newChar) then
        for _, obj in ipairs(game:GetDescendants()) do
            destroyEnd(obj)
        end
    end
end)