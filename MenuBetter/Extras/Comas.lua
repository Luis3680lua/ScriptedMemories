local Menu = _G.Menu
if not Menu then return end

local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local formatConnection = nil

if not Menu.Settings.shop_number_format_enabled then
	Menu.Settings.shop_number_format_enabled = false
end

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

if Menu.Settings.shop_number_format_enabled then
	applyNumberFormat(true)
end

local page = Menu.Pages[#Menu.Pages]
if not page then return end

local T = {
	Bg = Color3.fromRGB(20, 20, 25),
	Secondary = Color3.fromRGB(30, 30, 38),
	Tertiary = Color3.fromRGB(42, 42, 50),
	Hover = Color3.fromRGB(55, 55, 65),
	Text = Color3.fromRGB(240, 240, 245),
	TextDim = Color3.fromRGB(180, 180, 195),
	Accent = Color3.fromRGB(70, 150, 255),
	Green = Color3.fromRGB(70, 210, 110),
	Red = Color3.fromRGB(220, 80, 80),
	Border = Color3.fromRGB(60, 60, 75),
	Font = Enum.Font.Gotham,
	FontBold = Enum.Font.GothamBold,
}

local function roundFrame(frame, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = frame
end

local mainContainer = page.Frame:FindFirstChildWhichIsA("Frame") or page.Frame

local formatSubFrame = Instance.new("Frame")
formatSubFrame.Size = UDim2.new(1, 0, 0, 0)
formatSubFrame.BackgroundTransparency = 1
formatSubFrame.AutomaticSize = Enum.AutomaticSize.Y
formatSubFrame.Parent = mainContainer

local formatSubLayout = Instance.new("UIListLayout")
formatSubLayout.Padding = UDim.new(0, 4)
formatSubLayout.SortOrder = Enum.SortOrder.LayoutOrder
formatSubLayout.Parent = formatSubFrame

local formatSubHeader = Instance.new("TextLabel")
formatSubHeader.Size = UDim2.new(1, 0, 0, 18)
formatSubHeader.BackgroundTransparency = 1
formatSubHeader.Font = T.FontBold
formatSubHeader.TextSize = 14
formatSubHeader.TextColor3 = T.TextDim
formatSubHeader.TextXAlignment = Enum.TextXAlignment.Left
formatSubHeader.Text = "Separadores de miles"
formatSubHeader.Parent = formatSubFrame

local formatEnabled = Menu.Settings.shop_number_format_enabled

local formatToggleFrame = Instance.new("Frame")
formatToggleFrame.Size = UDim2.new(1, 0, 0, 50)
formatToggleFrame.BackgroundColor3 = T.Tertiary
formatToggleFrame.BackgroundTransparency = 0.3
formatToggleFrame.BorderSizePixel = 0
roundFrame(formatToggleFrame, 6)
formatToggleFrame.Parent = formatSubFrame

local formatLabel = Instance.new("TextLabel")
formatLabel.Size = UDim2.new(0, 200, 0, 26)
formatLabel.Position = UDim2.new(0, 12, 0, 12)
formatLabel.BackgroundTransparency = 1
formatLabel.TextColor3 = T.Text
formatLabel.Font = T.Font
formatLabel.TextSize = 14
formatLabel.Text = "Separadores de miles"
formatLabel.Parent = formatToggleFrame

local formatToggleBg = Instance.new("Frame")
formatToggleBg.Size = UDim2.new(0, 44, 0, 22)
formatToggleBg.Position = UDim2.new(1, -56, 0, 14)
formatToggleBg.BackgroundColor3 = formatEnabled and T.Green or T.Red
formatToggleBg.BorderSizePixel = 0
roundFrame(formatToggleBg, 11)
formatToggleBg.Parent = formatToggleFrame

local formatToggleKnob = Instance.new("Frame")
formatToggleKnob.Size = UDim2.new(0, 18, 0, 18)
formatToggleKnob.Position = formatEnabled and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
formatToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
formatToggleKnob.BorderSizePixel = 0
roundFrame(formatToggleKnob, 9)
formatToggleKnob.Parent = formatToggleBg

local function updateFormatVisual(state)
	formatToggleBg.BackgroundColor3 = state and T.Green or T.Red
	local targetX = state and 24 or 2
	formatToggleKnob:TweenPosition(UDim2.new(0, targetX, 0, 2), "Out", "Quad", 0.2, true)
end

formatToggleBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local newState = not Menu.Settings.shop_number_format_enabled
		Menu.Settings.shop_number_format_enabled = newState
		updateFormatVisual(newState)
		if Menu.SaveSettings then Menu.SaveSettings() end
		applyNumberFormat(newState)
	end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end