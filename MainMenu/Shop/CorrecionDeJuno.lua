local CONFIG = {
    Name = "Créditos de Juno!",
    Description = "Corrige los créditos originales de las canciones de Juno! en la tienda",
    SettingKey = "shop_credit_correction_enabled",
    Default = false,
    SoundPath = { "ClientAssets", "Sounds", "mus", "Menu", "ShopMus" },
    Corrections = {
        { Match = "Of Another Dream", NewTitle = "Of Another Dream v1 by Juno!" },
        { Match = "Dissonance", NewTitle = "Dissonance by Juno!" },
    }
}

local Menu = _G.Menu
if not Menu then return end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

local T = Menu.THEME
local RADIUS = T.Radius or 6
local PADDING = 12
local SWITCH_WIDTH = 36
local SWITCH_HEIGHT = 20
local KNOB_SIZE = 14
local KNOB_OFFSET = 2

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
    padding.PaddingTop = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 6)
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

if Menu.Settings[CONFIG.SettingKey] == nil then
    Menu.Settings[CONFIG.SettingKey] = CONFIG.Default
end

local creditCorrectionConn = nil
local originalCredits = {}

local function getShopMusFolder()
    local current = ReplicatedStorage
    for _, name in ipairs(CONFIG.SoundPath) do
        current = current:WaitForChild(name, 10)
        if not current then return nil end
    end
    return current
end

local function correctShopMus(shopMus, enabled)
    if not shopMus then return end
    for _, correction in ipairs(CONFIG.Corrections) do
        local lower = correction.Match:lower()
        for _, s in ipairs(shopMus:GetChildren()) do
            if s:IsA("Sound") then
                local titulo = (s:GetAttribute("Title") or ""):lower()
                local nombre = s.Name:lower()
                if (titulo:find(lower, 1, true) or nombre:find(lower, 1, true)) and not titulo:find("v2", 1, true) then
                    if enabled then
                        if not originalCredits[s] then
                            originalCredits[s] = s:GetAttribute("Title")
                        end
                        s:SetAttribute("Title", correction.NewTitle)
                    else
                        local original = originalCredits[s]
                        if original then
                            s:SetAttribute("Title", original)
                            originalCredits[s] = nil
                        end
                    end
                end
            end
        end
    end
end

local function applyCreditCorrection(enabled)
    if creditCorrectionConn then
        creditCorrectionConn:Disconnect()
        creditCorrectionConn = nil
    end

    local shopMus = getShopMusFolder()
    correctShopMus(shopMus, enabled)

    if enabled then
        creditCorrectionConn = PlayerGui.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "ShopMus" and not descendant:IsA("Sound") then
                task.wait(0.1)
                correctShopMus(descendant, true)
            end
        end)
    end
end

if Menu.Settings[CONFIG.SettingKey] then
    task.spawn(applyCreditCorrection, true)
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
textFrame.Size = UDim2.new(1, -(SWITCH_WIDTH + 10), 0, 0)
textFrame.AutomaticSize = Enum.AutomaticSize.Y
textFrame.BackgroundTransparency = 1
textFrame.Parent = optionFrame

local textLayout = Instance.new("UIListLayout")
textLayout.Padding = UDim.new(0, 2)
textLayout.SortOrder = Enum.SortOrder.LayoutOrder
textLayout.Parent = textFrame

infoText(textFrame, CONFIG.Name, T.FontBold, 14, T.Text)
infoText(textFrame, CONFIG.Description, T.Font, 12, T.TextDim)

local creditsEnabled = Menu.Settings[CONFIG.SettingKey]

local switchFrame = Instance.new("Frame")
switchFrame.Size = UDim2.new(0, SWITCH_WIDTH, 0, SWITCH_HEIGHT)
switchFrame.BackgroundColor3 = creditsEnabled and T.Green or T.Red
switchFrame.BorderSizePixel = 0
switchFrame.Parent = optionFrame
roundFrame(switchFrame, SWITCH_HEIGHT / 2)

local switchKnob = Instance.new("Frame")
switchKnob.Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE)
switchKnob.Position = creditsEnabled and
    UDim2.new(0, SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET, 0, KNOB_OFFSET) or
    UDim2.new(0, KNOB_OFFSET, 0, KNOB_OFFSET)
switchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
switchKnob.BorderSizePixel = 0
switchKnob.Parent = switchFrame
roundFrame(switchKnob, KNOB_SIZE / 2)

local function updateCreditsVisual(state)
    switchFrame.BackgroundColor3 = state and T.Green or T.Red
    local targetX = state and SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET or KNOB_OFFSET
    TweenService:Create(switchKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0, targetX, 0, KNOB_OFFSET)
    }):Play()
end

switchFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local newState = not Menu.Settings[CONFIG.SettingKey]
        Menu.Settings[CONFIG.SettingKey] = newState
        updateCreditsVisual(newState)
        if Menu.SaveSettings then Menu.SaveSettings() end
        applyCreditCorrection(newState)
    end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
    Menu.UpdateCanvas()
end