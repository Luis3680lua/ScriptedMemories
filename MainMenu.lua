local UIS, TS, Players = game:GetService("UserInputService"), game:GetService("TweenService"), game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")

local Menu = {Pages = {}, ActivePage = nil, Visible = false}
_G.Menu = Menu

local FallbackTheme = {
    Background = Color3.fromRGB(20,20,25), Secondary = Color3.fromRGB(30,30,38),
    Tertiary = Color3.fromRGB(42,42,50), Hover = Color3.fromRGB(55,55,65),
    Text = Color3.fromRGB(240,240,245), TextDim = Color3.fromRGB(180,180,195),
    Accent = Color3.fromRGB(70,150,255), Green = Color3.fromRGB(70,210,110),
    Red = Color3.fromRGB(220,80,80), Border = Color3.fromRGB(60,60,75),
    Font = Enum.Font.Gotham, FontBold = Enum.Font.GothamBold,
    TitleSize = 22, TextSize = 14, SmallSize = 12, Radius = 6,
    Width = 560, Height = 440, Alpha = 0.7, Speed = 0.3,
}

local ThemeModule = _G.MenuThemeModule or { Themes = { Default = FallbackTheme }, Active = "Default" }
Menu.ThemeModule = ThemeModule
Menu.THEME = ThemeModule.Themes[ThemeModule.Active] or FallbackTheme

local THEME = Menu.THEME

function Menu:SetTheme(name)
    local t = self.ThemeModule.Themes[name]
    if not t then return false end
    self.ThemeModule.Active = name
    self.THEME = t
    self.Settings.active_theme = name
    self.SaveSettings()
    self:Notify("Tema cambiado a " .. name .. ". Reabre el menú para aplicarlo.", "info")
    return true
end

local BASE_DIR = "ScriptedMemories"
local CONFIG_DIR = BASE_DIR.."/config"
local MODULES_DIR = BASE_DIR.."/modules"
local SETTINGS_FILE = CONFIG_DIR.."/settings.json"
local hasFS = pcall(function() return isfolder end) and isfolder ~= nil

local function ensureDirs()
    if not hasFS then return end
    for _, d in ipairs({BASE_DIR, CONFIG_DIR, MODULES_DIR}) do
        if not isfolder(d) then makefolder(d) end
    end
end
ensureDirs()

local function loadSettings()
    local raw
    if hasFS and isfile and isfile(SETTINGS_FILE) then
        raw = readfile(SETTINGS_FILE)
    else
        local c = PlayerGui:FindFirstChild("ScriptedMemoriesSettings")
        raw = c and c.Value
    end
    if raw and raw ~= "" then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok and type(data) == "table" then return data end
    end
    return {}
end

local function saveSettings()
    local ok, json = pcall(HttpService.JSONEncode, HttpService, Menu.Settings)
    if not ok then return end
    if hasFS and writefile then
        pcall(writefile, SETTINGS_FILE, json)
    else
        local c = PlayerGui:FindFirstChild("ScriptedMemoriesSettings")
        if not c then
            c = Instance.new("StringValue")
            c.Name, c.ResetOnSpawn, c.Parent = "ScriptedMemoriesSettings", false, PlayerGui
        end
        c.Value = json
    end
end
Menu.SaveSettings = saveSettings
Menu.Settings = loadSettings()

-- Sistema de callbacks para reset
Menu.ResetCallbacks = {}
function Menu:RegisterResetCallback(fn)
    table.insert(self.ResetCallbacks, fn)
end

if ThemeModule.Active == "Default" and Menu.Settings.active_theme then
    if ThemeModule.Themes[Menu.Settings.active_theme] then
        ThemeModule.Active = Menu.Settings.active_theme
        Menu.THEME = ThemeModule.Themes[Menu.Settings.active_theme]
        THEME = Menu.THEME
    end
end

-- ===== CARGA DE MÓDULOS =====
local function safeLoadString(content)
    if type(content) ~= "string" or #content < 10 then return nil end
    if not content:match("^%s*[%a_%(]") then return nil end
    return loadstring(content)
end

function Menu:LoadRemoteModule(url)
    xpcall(function()
        local ok, source = pcall(game.HttpGet, game, url)
        if not ok or not source or source == "" then return end
        local fn = safeLoadString(source)
        if fn then pcall(fn) end
    end, function() end)
end

function Menu:LoadLocalModules()
    if not hasFS or not listfiles then return end
    for _, file in ipairs(listfiles(MODULES_DIR)) do
        if file:match("%.lua$") then
            xpcall(function()
                local chunk = readfile(file)
                if chunk and #chunk > 10 then
                    local fn = safeLoadString(chunk)
                    if fn then pcall(fn) end
                end
            end, function() end)
        end
    end
end

local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    inst.Parent = parent
    return inst
end

local function corner(parent, radius)
    return new("UICorner", {CornerRadius = UDim.new(0, radius or 4)}, parent)
end

local function frame(parent, size, pos, color, trans)
    return new("Frame", {
        Size = size, Position = pos or UDim2.new(),
        BackgroundColor3 = color or THEME.Background,
        BackgroundTransparency = trans or 0, BorderSizePixel = 0,
    }, parent)
end

local function label(parent, text, size, color, font, alignX, alignY)
    return new("TextLabel", {
        Text = text, Size = size or UDim2.new(1,0,1,0), BackgroundTransparency = 1,
        TextColor3 = color or THEME.Text, Font = font or THEME.Font, TextSize = THEME.TextSize,
        TextXAlignment = alignX or Enum.TextXAlignment.Left,
        TextYAlignment = alignY or Enum.TextYAlignment.Center,
    }, parent)
end

local function button(parent, text, size, pos, color, callback)
    local b = new("TextButton", {
        Text = text, Size = size or UDim2.new(0,100,0,30), Position = pos or UDim2.new(),
        BackgroundColor3 = color or THEME.Tertiary, TextColor3 = THEME.Text,
        Font = THEME.FontBold, TextSize = THEME.TextSize, BorderSizePixel = 0,
    }, parent)
    corner(b)
    if callback then b.MouseButton1Click:Connect(callback) end
    return b
end

-- Función de hover mejorada con animación
local function hoverColor(btn, normal, hover)
    btn.MouseEnter:Connect(function()
        TS:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TS:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = normal}):Play()
    end)
end

local existing = PlayerGui:FindFirstChild("ScriptedMemoriesUI")
if existing then
    existing:Destroy()
end

local ScreenGui = new("ScreenGui", {Name = "ScriptedMemoriesUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, PlayerGui)

-- Fondo oscuro semi-transparente (overlay)
local Overlay = frame(ScreenGui, UDim2.new(1,0,1,0), UDim2.new(), Color3.fromRGB(0,0,0), 0.6)
Overlay.Name, Overlay.Visible, Overlay.ZIndex = "Overlay", false, 5
corner(Overlay, 0)

-- MainFrame con escala inicial
local MainFrame = frame(ScreenGui, UDim2.new(0, THEME.Width, 0, THEME.Height), UDim2.new(0.5, -THEME.Width/2, 0.5, -THEME.Height/2), THEME.Background, 1 - THEME.Alpha)
MainFrame.Name, MainFrame.Visible, MainFrame.ZIndex = "MainWindow", false, 10
MainFrame.BackgroundTransparency = 1  -- para animación de apertura
corner(MainFrame, THEME.Radius)
new("UIStroke", {Color = THEME.Border, Thickness = 1, Transparency = 0.4}, MainFrame)

-- TitleBar
local TitleBar = frame(MainFrame, UDim2.new(1,0,0,38), UDim2.new(), THEME.Secondary, 1 - THEME.Alpha)
corner(TitleBar, THEME.Radius)

local TitleLabel = label(TitleBar, "Scripted Memories | Main Menu", UDim2.new(1,-38,1,0), THEME.Text, THEME.FontBold, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center)
TitleLabel.TextSize = THEME.TitleSize

local CloseButton = button(TitleBar, "X", UDim2.new(0,38,0,38), UDim2.new(1,-38,0,0), THEME.Tertiary, function() Menu:Toggle(false) end)
CloseButton.TextSize = 20
hoverColor(CloseButton, THEME.Tertiary, THEME.Red)

-- TabBar
local TabBar = frame(MainFrame, UDim2.new(1,0,0,34), UDim2.new(0,0,0,38), THEME.Secondary, 1 - THEME.Alpha)
local TabScroller = new("ScrollingFrame", {
    Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,6,0,0), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(0,0,0,34),
    ScrollingDirection = Enum.ScrollingDirection.X, VerticalScrollBarInset = Enum.ScrollBarInset.None,
}, TabBar)
local TabContainer = new("Frame", {Size = UDim2.new(0,0,1,0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1}, TabScroller)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4)}, TabContainer)

-- ContentFrame con transición
local ContentFrame = new("ScrollingFrame", {
    Size = UDim2.new(1,-12,1,-84), Position = UDim2.new(0,6,0,78), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 4, CanvasSize = UDim2.new(0,0,0,0),
    ScrollingDirection = Enum.ScrollingDirection.Y, VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
}, MainFrame)
new("UIListLayout", {Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder}, ContentFrame)

local function updateCanvas()
    task.wait(0.05)
    local visible
    for _, child in ipairs(ContentFrame:GetChildren()) do
        if child:IsA("Frame") and child.Visible then visible = child break end
    end
    local h = visible and (visible.AbsoluteSize.Y + 10) or ContentFrame.AbsoluteSize.Y
    ContentFrame.CanvasSize = UDim2.new(0, ContentFrame.AbsoluteSize.X, 0, math.max(h, ContentFrame.AbsoluteSize.Y))
end
Menu.UpdateCanvas = updateCanvas

function Menu:Toggle(state)
    if state == nil then state = not self.Visible end
    self.Visible = state
    MainFrame.Visible = true
    Overlay.Visible = true

    if state then
        -- Apertura: fade in y escala
        MainFrame.BackgroundTransparency = 1
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        local tweenInfo = TweenInfo.new(THEME.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        TS:Create(MainFrame, tweenInfo, {
            Size = UDim2.new(0, THEME.Width, 0, THEME.Height),
            Position = UDim2.new(0.5, -THEME.Width/2, 0.5, -THEME.Height/2),
            BackgroundTransparency = 1 - THEME.Alpha
        }):Play()
        -- Overlay fade
        TS:Create(Overlay, TweenInfo.new(THEME.Speed), {BackgroundTransparency = 0.4}):Play()
        updateCanvas()
        -- Animación de páginas (slide up)
        for _, page in ipairs(self.Pages) do
            if page.Frame.Visible then
                page.Frame.Position = UDim2.new(0, 0, 0, 20)
                page.Frame.BackgroundTransparency = 1
                TS:Create(page.Frame, TweenInfo.new(THEME.Speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 0
                }):Play()
            end
        end
    else
        -- Cierre: fade out y escala
        local tweenInfo = TweenInfo.new(THEME.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        TS:Create(MainFrame, tweenInfo, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        }):Play()
        TS:Create(Overlay, TweenInfo.new(THEME.Speed), {BackgroundTransparency = 1}):Play()
        task.wait(THEME.Speed)
        MainFrame.Visible = false
        Overlay.Visible = false
    end
end

function Menu:Notify(text, kind)
    local colors = {info = THEME.Accent, success = THEME.Green, error = THEME.Red}
    local f = frame(MainFrame, UDim2.new(1,-24,0,38), UDim2.new(0,12,1,-48), THEME.Secondary, 0.2)
    corner(f)
    f.BackgroundTransparency = 1
    label(f, text, UDim2.new(1,-50,1,0), colors[kind or "info"] or THEME.Text, THEME.Font).Position = UDim2.new(0,8,0,0)
    local close = new("TextButton", {
        Text = "✕", Size = UDim2.new(0,28,0,28), Position = UDim2.new(1,-34,0,5),
        BackgroundTransparency = 1, TextColor3 = THEME.TextDim, Font = THEME.FontBold,
        TextSize = 14, BorderSizePixel = 0,
    }, f)
    close.MouseButton1Click:Connect(function() 
        TS:Create(f, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        task.wait(0.2)
        f:Destroy() 
    end)
    -- Fade in
    TS:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 0.2}):Play()
    task.wait(3.5)
    TS:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.3)
    f:Destroy()
end

function Menu:RegisterPage(name, icon)
    icon = icon or ""
    local page = {Name = name, Icon = icon, Elements = {}}
    local btn = button(TabContainer, icon.." "..name, UDim2.new(0,0,1,0), UDim2.new(), THEME.Tertiary)
    btn.AutomaticSize, btn.TextColor3, btn.Font, btn.TextSize = Enum.AutomaticSize.X, THEME.TextDim, THEME.Font, THEME.SmallSize
    hoverColor(btn, THEME.Tertiary, THEME.Hover)

    local f = new("Frame", {Size = UDim2.new(1,-4,0,10), BackgroundTransparency = 1, Visible = false}, ContentFrame)
    new("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder}, f)
    page.Frame, page.Button = f, btn

    btn.MouseButton1Click:Connect(function() self:SwitchPage(page) end)
    table.insert(self.Pages, page)
    if not self.ActivePage then self:SwitchPage(page) end
    TabScroller.CanvasSize = UDim2.new(0, TabContainer.AbsoluteSize.X, 0, 34)
    return page
end

function Menu:SwitchPage(page)
    if self.ActivePage == page then return end
    if self.ActivePage then
        local old = self.ActivePage
        old.Frame.Visible = false
        TS:Create(old.Button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Tertiary, TextColor3 = THEME.TextDim}):Play()
    end
    page.Frame.Visible = true
    page.Frame.Position = UDim2.new(0, 0, 0, 20)
    page.Frame.BackgroundTransparency = 1
    TS:Create(page.Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0
    }):Play()
    TS:Create(page.Button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.Hover, TextColor3 = THEME.Text}):Play()
    self.ActivePage = page
    updateCanvas()
end

function Menu:AddComponent(page, builder)
    local comp = builder()
    comp.Parent = page.Frame
    table.insert(page.Elements, comp)
    updateCanvas()
    return comp
end

-- ===== COMPONENTES MEJORADOS CON ANIMACIONES =====

function Menu:AddToggle(page, id, text, default)
    default = (self.Settings[id] ~= nil) and self.Settings[id] or default
    return self:AddComponent(page, function()
        local c = frame(nil, UDim2.new(1,0,0,40), UDim2.new(), THEME.Secondary, 0.3)
        corner(c)
        local lbl = label(c, text, UDim2.new(0.65,0,1,0), THEME.Text, THEME.Font, Enum.TextXAlignment.Left)
        lbl.Position = UDim2.new(0,8,0,0)

        -- Switch container
        local sw = frame(c, UDim2.new(0,50,0,28), UDim2.new(0.75,0,0.5,-14), default and THEME.Green or THEME.Red, 0)
        corner(sw, 14)
        local knob = frame(sw, UDim2.new(0,22,0,22), UDim2.new(default and 1 or 0, default and -22 or 2, 0.5, -11), THEME.Text, 0)
        corner(knob, 11)

        local state = default
        local function updateSwitch()
            local targetColor = state and THEME.Green or THEME.Red
            local targetPos = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
            TS:Create(sw, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            TS:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        end
        updateSwitch()

        local btn = new("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""}, c)
        btn.MouseButton1Click:Connect(function()
            state = not state
            self.Settings[id] = state
            saveSettings()
            updateSwitch()
        end)
        return c
    end)
end

function Menu:AddSlider(page, id, text, min, max, default)
    default = (self.Settings[id] ~= nil) and self.Settings[id] or default
    return self:AddComponent(page, function()
        local c = frame(nil, UDim2.new(1,0,0,70), UDim2.new(), THEME.Secondary, 0.3)
        corner(c)
        local lbl = label(c, text..": "..tostring(default), UDim2.new(1,-16,0,22))
        lbl.Position = UDim2.new(0,8,0,2)

        -- Barra y asa
        local track = frame(c, UDim2.new(0.9,0,0,6), UDim2.new(0.05,0,0,40), THEME.Tertiary, 0)
        corner(track, 3)
        local fill = frame(track, UDim2.new((default-min)/(max-min),0,1,0), UDim2.new(), THEME.Accent, 0)
        corner(fill, 3)

        local handle = new("TextButton", {Size = UDim2.new(0,18,0,18), Position = UDim2.new((default-min)/(max-min), -9, 0.5, -9), BackgroundColor3 = THEME.Accent, Text = "", BorderSizePixel = 0}, c)
        corner(handle, 9)
        hoverColor(handle, THEME.Accent, THEME.Hover)

        local dragging = false
        local function updateValue(posX)
            local rel = (posX - track.AbsolutePosition.X) / track.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            local val = min + (max - min) * rel
            val = math.round(val)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            handle.Position = UDim2.new(rel, -9, 0.5, -9)
            lbl.Text = text..": "..tostring(val)
            self.Settings[id] = val
            saveSettings()
        end

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        handle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateValue(input.Position.X)
            end
        end)
        -- Click en track
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateValue(input.Position.X)
            end
        end)
        return c
    end)
end

function Menu:AddDropdown(page, id, text, options, defaultIndex)
    defaultIndex = (self.Settings[id] ~= nil) and self.Settings[id] or defaultIndex
    if defaultIndex < 1 or defaultIndex > #options then defaultIndex = 1 end
    return self:AddComponent(page, function()
        local c = frame(nil, UDim2.new(1,0,0,40), UDim2.new(), THEME.Secondary, 0.3)
        corner(c)
        local btn = button(c, text..": "..options[defaultIndex], UDim2.new(0.9,0,0,30), UDim2.new(0.05,0,0.5,-15), THEME.Tertiary)
        btn.Font, btn.TextColor3 = THEME.Font, THEME.Text
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Padding = UDim.new(0, 8)
        hoverColor(btn, THEME.Tertiary, THEME.Hover)

        local current = defaultIndex
        local isOpen = false
        local listFrame = frame(c, UDim2.new(0.9,0,0,0), UDim2.new(0.05,0,0,40), THEME.Tertiary, 0.9)
        corner(listFrame, 4)
        listFrame.Visible = false
        local listLayout = new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,2)}, listFrame)

        local function buildList()
            for _, child in ipairs(listFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            for i, opt in ipairs(options) do
                local optBtn = new("TextButton", {
                    Text = opt, Size = UDim2.new(1,0,0,26), BackgroundTransparency = 1,
                    TextColor3 = (i == current) and THEME.Accent or THEME.Text,
                    Font = THEME.Font, TextSize = THEME.SmallSize, BorderSizePixel = 0,
                    TextXAlignment = Enum.TextXAlignment.Left, Padding = UDim.new(0, 8)
                }, listFrame)
                optBtn.MouseButton1Click:Connect(function()
                    current = i
                    btn.Text = text..": "..opt
                    self.Settings[id] = i
                    saveSettings()
                    closeList()
                end)
                hoverColor(optBtn, Color3.fromRGB(0,0,0), THEME.Hover)
            end
        end
        buildList()

        local function openList()
            if isOpen then return end
            isOpen = true
            listFrame.Visible = true
            local height = #options * 28 + 8
            listFrame.Size = UDim2.new(0.9,0,0,0)
            TS:Create(listFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.9,0,0,height)}):Play()
        end
        local function closeList()
            if not isOpen then return end
            isOpen = false
            TS:Create(listFrame, TweenInfo.new(0.2), {Size = UDim2.new(0.9,0,0,0)}):Play()
            task.wait(0.2)
            listFrame.Visible = false
        end

        btn.MouseButton1Click:Connect(function()
            if isOpen then closeList() else openList() end
        end)
        -- Cerrar al hacer clic fuera (opcional)
        return c
    end)
end

function Menu:AddButton(page, text, callback)
    return self:AddComponent(page, function()
        local c = frame(nil, UDim2.new(1,0,0,38), UDim2.new(), THEME.Background, 1)
        local btn = button(c, text, UDim2.new(1,0,1,0), UDim2.new(), THEME.Tertiary, callback)
        btn.Font, btn.TextColor3 = THEME.FontBold, THEME.Text
        hoverColor(btn, THEME.Tertiary, THEME.Hover)
        -- Efecto de pulsación
        btn.MouseButton1Down:Connect(function()
            TS:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98,0,0.95,0)}):Play()
        end)
        btn.MouseButton1Up:Connect(function()
            TS:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,1,0)}):Play()
        end)
        return c
    end)
end

function Menu:AddLabel(page, text)
    return self:AddComponent(page, function()
        return new("TextLabel", {
            Text = text, Size = UDim2.new(1,0,0,24), BackgroundTransparency = 1,
            TextColor3 = THEME.TextDim, Font = THEME.Font, TextSize = THEME.SmallSize,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
    end)
end

-- ===== FUNCIONES DE RESET (con animaciones) =====
function Menu:RegisterDefault(page, key, defaultValue)
    page.Defaults = page.Defaults or {}
    for _, entry in ipairs(page.Defaults) do
        if entry.Key == key then
            entry.Default = defaultValue
            if page.RefreshResetButton then page.RefreshResetButton() end
            return
        end
    end
    table.insert(page.Defaults, { Key = key, Default = defaultValue })
    if page.RefreshResetButton then page.RefreshResetButton() end
end

function Menu:CreateResetButton(page, parent)
    local T = self.THEME
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0, 150, 0, 30)
    resetBtn.Position = UDim2.new(1, -150, 0, 0)
    resetBtn.BorderSizePixel = 0
    resetBtn.Font = T.FontBold
    resetBtn.TextSize = 12
    resetBtn.AutoButtonColor = false
    resetBtn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, T.Radius or 6)
    corner.Parent = resetBtn

    local menuRef = self

    function page.RefreshResetButton()
        local hasChanges = false
        for _, entry in ipairs(page.Defaults or {}) do
            if menuRef.Settings[entry.Key] ~= entry.Default then
                hasChanges = true
                break
            end
        end
        if hasChanges then
            resetBtn.Active = true
            resetBtn.BackgroundColor3 = T.Accent
            resetBtn.TextColor3 = T.Text
            resetBtn.Text = "↺ Predeterminado"
        else
            resetBtn.Active = false
            resetBtn.BackgroundColor3 = T.Tertiary
            resetBtn.TextColor3 = T.TextDim
            resetBtn.Text = "✓ Predeterminado"
        end
    end

    resetBtn.MouseEnter:Connect(function()
        if resetBtn.Active then
            TS:Create(resetBtn, TweenInfo.new(0.15), { BackgroundColor3 = T.Hover }):Play()
        end
    end)
    resetBtn.MouseLeave:Connect(function()
        if resetBtn.Active then
            TS:Create(resetBtn, TweenInfo.new(0.15), { BackgroundColor3 = T.Accent }):Play()
        end
    end)

    resetBtn.MouseButton1Click:Connect(function()
        if not resetBtn.Active then return end
        resetBtn.Active = false
        resetBtn.BackgroundColor3 = T.Tertiary
        resetBtn.TextColor3 = T.TextDim
        resetBtn.Text = "Restaurando..."

        for _, entry in ipairs(page.Defaults or {}) do
            menuRef.Settings[entry.Key] = entry.Default
        end
        if menuRef.SaveSettings then menuRef.SaveSettings() end

        for _, fn in ipairs(menuRef.ResetCallbacks or {}) do
            pcall(fn)
        end

        task.wait(0.3)

        if menuRef.Notify then
            menuRef:Notify("Ajustes restaurados a valores predeterminados.", "success")
        end

        page.RefreshResetButton()
    end)

    page.RefreshResetButton()
    return resetBtn
end

-- ===== DRAG =====
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, input.Position, MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

local dragConn = UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Menu:LoadRemoteModule("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/MainMenu/Loader.lua?v=" .. tostring(os.time()))

local function getKey(settingName, default)
    return Enum.KeyCode[Menu.Settings[settingName] or default] or Enum.KeyCode[default]
end

local lastToggle = 0
Menu._capturingKey = false

local toggleConn
toggleConn = UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or Menu._capturingKey then return end
    if input.KeyCode == getKey("menu_keybind", "M") or input.KeyCode == getKey("menu_controller_keybind", "ButtonL3") then
        local now = tick()
        if now - lastToggle < 1 then return end
        lastToggle = now
        Menu:Toggle()
    end
end)

ScreenGui.Destroying:Connect(function()
    dragConn:Disconnect()
    toggleConn:Disconnect()
end)

if Menu.Settings.menu_autostart then
    task.wait(0.5)
    Menu:Toggle(true)
end

updateCanvas()