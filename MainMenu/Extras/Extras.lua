local Menu = _G.Menu
if not Menu then return end

local function safeLoadAndExecute(url)
    local success, result = pcall(function()
        local ok, source = pcall(game.HttpGet, game, url)
        if not ok or not source then return end
        local fn, err = loadstring(source)
        if not fn then return end
        fn()
    end)
    if not success then
        warn("Error en " .. url .. ": " .. tostring(result))
    end
end

local page = Menu:RegisterPage("Extras", "🛒")
page.Frame.AutomaticSize = Enum.AutomaticSize.Y

local pageLayout = Instance.new("UIListLayout")
pageLayout.Padding = UDim.new(0, 8)
pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
pageLayout.Parent = page.Frame

local shopTitle = Instance.new("TextLabel")
shopTitle.Size = UDim2.new(1, 0, 0, 28)
shopTitle.BackgroundTransparency = 1
shopTitle.Font = Enum.Font.GothamBold
shopTitle.TextSize = 20
shopTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
shopTitle.TextXAlignment = Enum.TextXAlignment.Left
shopTitle.Text = "🛒 Tienda"
shopTitle.Parent = page.Frame

safeLoadAndExecute("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/ShopMusicExtra.lua")
safeLoadAndExecute("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/CorrecionDeJuno.lua")
safeLoadAndExecute("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/Comas.lua")
safeLoadAndExecute("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/SurvivorIconosDescartados.lua")

local lobbyTitle = Instance.new("TextLabel")
lobbyTitle.Size = UDim2.new(1, 0, 0, 28)
lobbyTitle.BackgroundTransparency = 1
lobbyTitle.Font = Enum.Font.GothamBold
lobbyTitle.TextSize = 20
lobbyTitle.TextColor3 = Color3.fromRGB(240, 240, 245)
lobbyTitle.TextXAlignment = Enum.TextXAlignment.Left
lobbyTitle.Text = "🎵 Lobby"
lobbyTitle.Parent = page.Frame

safeLoadAndExecute("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/LobbySelectorMus.lua")
safeLoadAndExecute("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Extras/MuteLobby.lua")

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end