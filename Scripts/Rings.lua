local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local gameUI = PlayerGui:WaitForChild("GameUI")

local function addCommas(num)
    if #num < 4 then return num end
    return num:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function formatText(text)
    text = text:gsub("%f[%w](%d+)(%a+)%f[^%w]", function(num, letters)
        if letters:lower() == "x" then return num .. letters end
        return addCommas(num) .. letters
    end)
    text = text:gsub("%f[%d](%d+)%f[^%w]", addCommas)
    return text
end

local function hookObject(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton")) then return end
    if not (obj.Name == "Rings" or obj.Name == "CharPrice" or obj.Name == "Price") then return end
    local function update()
        local formatted = formatText(obj.Text)
        if formatted ~= obj.Text then obj.Text = formatted end
    end
    update()
    obj:GetPropertyChangedSignal("Text"):Connect(update)
end

local function isShopContainer(obj)
    if not obj:IsA("Frame") and not obj:IsA("Folder") then return false end
    if obj.Name ~= "shop" and obj.Name ~= "shopTemp" then return false end
    local bottom = obj:FindFirstChild("bottom")
    if bottom then
        local bg = bottom:FindFirstChild("bg")
        if bg and bg:FindFirstChild("Rings") then
            return true
        end
    end
    return false
end

local function hookShopContainer(container)
    for _, obj in ipairs(container:GetDescendants()) do
        hookObject(obj)
    end
    container.DescendantAdded:Connect(function(obj)
        hookObject(obj)
    end)
end

for _, child in ipairs(gameUI:GetChildren()) do
    if isShopContainer(child) then
        hookShopContainer(child)
    end
end

gameUI.ChildAdded:Connect(function(child)
    if isShopContainer(child) then
        hookShopContainer(child)
    end
end)