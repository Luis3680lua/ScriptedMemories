local CONFIG = {
    Name = "Restablecer ajustes",
    Description = "Borra todos los ajustes guardados y reinstala el menú con los valores por defecto.",
    ConfirmSeconds = 5,
    ButtonWidth = 160,
    ButtonHeight = 40
}

local Menu = _G.Menu
if not Menu then return end

local TweenService = game:GetService("TweenService")

local T = Menu.THEME
local RADIUS = T.Radius or 6
local PADDING = 12

local function roundFrame(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or RADIUS)
    corner.Parent = frame
    return corner
end

local function card(parent)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 0)
    f.BackgroundColor3 = T.Secondary
    f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0
    f.AutomaticSize = Enum.AutomaticSize.Y
    f.Parent = parent
    roundFrame(f, RADIUS)

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, PADDING)
    padding.PaddingRight = UDim.new(0, PADDING)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = f

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = f

    return f
end

local function infoText(parent, text, font, size, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 0)
    l.AutomaticSize = Enum.AutomaticSize.Y
    l.BackgroundTransparency = 1
    l.Font = font or T.Font
    l.TextSize = size or 14
    l.TextColor3 = color or T.Text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.Text = text
    l.Parent = parent
    return l
end

local function softResetMenu()
    local ok = pcall(function()
        local BASE_URL = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/"
        local V = tostring(os.time())

        local themeOk, themeModule = pcall(function()
            return loadstring(game:HttpGet(BASE_URL .. "ThemeConfig.lua?v=" .. V))()
        end)
        if themeOk and type(themeModule) == "table" then
            _G.MenuThemeModule = themeModule
        end

        loadstring(game:HttpGet(BASE_URL .. "MainMenu.lua?v=" .. V))()
    end)
    return ok
end

local page = Menu.Pages[#Menu.Pages]
if not page then return end

local sectionFrame = card(page.Frame)

local optionFrame = Instance.new("Frame")
optionFrame.Size = UDim2.new(1, 0, 0, 0)
optionFrame.AutomaticSize = Enum.AutomaticSize.Y
optionFrame.BackgroundTransparency = 1
optionFrame.Parent = sectionFrame

local optionLayout = Instance.new("UIListLayout")
optionLayout.FillDirection = Enum.FillDirection.Horizontal
optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
optionLayout.Padding = UDim.new(0, 10)
optionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
optionLayout.Parent = optionFrame

local textFrame = Instance.new("Frame")
textFrame.Size = UDim2.new(1, -(CONFIG.ButtonWidth + 10), 0, 0)
textFrame.AutomaticSize = Enum.AutomaticSize.Y
textFrame.BackgroundTransparency = 1
textFrame.Parent = optionFrame

local textLayout = Instance.new("UIListLayout")
textLayout.Padding = UDim.new(0, 2)
textLayout.SortOrder = Enum.SortOrder.LayoutOrder
textLayout.Parent = textFrame

infoText(textFrame, CONFIG.Name, T.FontBold, 14, T.Text)
infoText(textFrame, CONFIG.Description, T.Font, 12, T.TextDim)

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0, CONFIG.ButtonWidth, 0, CONFIG.ButtonHeight)
resetBtn.BackgroundColor3 = T.Tertiary
resetBtn.BorderSizePixel = 0
resetBtn.AutoButtonColor = false
resetBtn.Font = T.FontBold
resetBtn.TextSize = 14
resetBtn.TextColor3 = T.Text
resetBtn.Parent = optionFrame
roundFrame(resetBtn, RADIUS)

local isArmed = false
local isBusy = false
local countdownTask = nil

local function hasSettingsToReset()
    return next(Menu.Settings) ~= nil
end

local function setIdleVisual()
    local hasSettings = hasSettingsToReset()
    if hasSettings then
        resetBtn.Text = "🗑️ Restablecer"
        resetBtn.TextColor3 = T.Text
        resetBtn.BackgroundColor3 = T.Tertiary
        resetBtn.Active = true
    else
        resetBtn.Text = "Sin cambios"
        resetBtn.TextColor3 = T.TextDim
        resetBtn.BackgroundColor3 = T.Tertiary
        resetBtn.Active = false
    end
end

local function cancelArm()
    isArmed = false
    if countdownTask then
        task.cancel(countdownTask)
        countdownTask = nil
    end
    setIdleVisual()
end

local function armReset()
    isArmed = true
    resetBtn.BackgroundColor3 = T.Red
    resetBtn.TextColor3 = T.Text

    countdownTask = task.spawn(function()
        local remaining = CONFIG.ConfirmSeconds
        while remaining > 0 and isArmed do
            resetBtn.Text = "¿Confirmar? (" .. remaining .. "s)"
            task.wait(1)
            remaining -= 1
        end
        if isArmed then
            cancelArm()
        end
    end)
end

local function performReset()
    isBusy = true
    isArmed = false
    if countdownTask then
        task.cancel(countdownTask)
        countdownTask = nil
    end

    for key in pairs(Menu.Settings) do
        Menu.Settings[key] = nil
    end
    if Menu.SaveSettings then Menu.SaveSettings() end

    resetBtn.Text = "🔄 Reinstalando..."
    resetBtn.BackgroundColor3 = T.Green
    resetBtn.Active = false

    if Menu.Notify then
        Menu:Notify("Ajustes restablecidos. Reinstalando el menú...", "success")
    end

    task.wait(0.6)
    local ok = softResetMenu()
    if not ok and Menu.Notify then
        Menu:Notify("No se pudo reinstalar automáticamente. Ejecuta el script de nuevo.", "error")
        isBusy = false
        setIdleVisual()
    end
end

resetBtn.MouseButton1Down:Connect(function()
    if isBusy then return end

    if not hasSettingsToReset() and not isArmed then
        return
    end

    if isArmed then
        performReset()
    else
        armReset()
    end
end)

resetBtn.MouseEnter:Connect(function()
    if isBusy or isArmed then return end
    if hasSettingsToReset() then
        TweenService:Create(resetBtn, TweenInfo.new(0.15), {BackgroundColor3 = T.Hover}):Play()
    end
end)
resetBtn.MouseLeave:Connect(function()
    if isBusy or isArmed then return end
    setIdleVisual()
end)

setIdleVisual()

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end