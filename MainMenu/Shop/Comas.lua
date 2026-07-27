local OPTION_NAME = "Formato con Comas"
local OPTION_DESCRIPTION = "Añade separadores de miles a los precios y a la cantidad de Rings que tengas."
local SETTING_KEY = "shop_number_format_enabled"
local DEFAULT_VALUE = false

local Menu = _G.Menu
if not Menu then return end

local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

if not Menu.Settings[SETTING_KEY] then
	Menu.Settings[SETTING_KEY] = DEFAULT_VALUE
end

local formatConnection = nil

local function applyNumberFormat(enabled)
	if enabled then
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
		local gameUI = PlayerGui:WaitForChild("GameUI", 10)
		if gameUI then
			for _, child in ipairs(gameUI:GetChildren()) do
				if isShopContainer(child) then
					hookShopContainer(child)
				end
			end
			formatConnection = gameUI.ChildAdded:Connect(function(child)
				if isShopContainer(child) then
					hookShopContainer(child)
				end
			end)
		end
	else
		if formatConnection then
			formatConnection:Disconnect()
			formatConnection = nil
		end
	end
end

if Menu.Settings[SETTING_KEY] then
	applyNumberFormat(true)
end

local page = Menu.Pages[#Menu.Pages]
if not page then return end

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
	l:SetAttribute("SM_Protected", true)
	l.Parent = parent
	return l
end

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

infoText(textFrame, OPTION_NAME, T.FontBold, 14, T.Text)
infoText(textFrame, OPTION_DESCRIPTION, T.Font, 12, T.TextDim)

local formatEnabled = Menu.Settings[SETTING_KEY]

local switchFrame = Instance.new("Frame")
switchFrame.Size = UDim2.new(0, SWITCH_WIDTH, 0, SWITCH_HEIGHT)
switchFrame.BackgroundColor3 = formatEnabled and T.Green or T.Red
switchFrame.BorderSizePixel = 0
switchFrame.Parent = optionFrame
roundFrame(switchFrame, SWITCH_HEIGHT / 2)

local switchKnob = Instance.new("Frame")
switchKnob.Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE)
switchKnob.Position = formatEnabled and
	UDim2.new(0, SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET, 0, KNOB_OFFSET) or
	UDim2.new(0, KNOB_OFFSET, 0, KNOB_OFFSET)
switchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
switchKnob.BorderSizePixel = 0
switchKnob.Parent = switchFrame
roundFrame(switchKnob, KNOB_SIZE / 2)

local function updateFormatVisual(state)
	switchFrame.BackgroundColor3 = state and T.Green or T.Red
	local targetX = state and SWITCH_WIDTH - KNOB_SIZE - KNOB_OFFSET or KNOB_OFFSET
	TweenService:Create(switchKnob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
		Position = UDim2.new(0, targetX, 0, KNOB_OFFSET)
	}):Play()
end

switchFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local newState = not Menu.Settings[SETTING_KEY]
		Menu.Settings[SETTING_KEY] = newState
		updateFormatVisual(newState)
		if Menu.SaveSettings then Menu.SaveSettings() end
		applyNumberFormat(newState)
	end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end