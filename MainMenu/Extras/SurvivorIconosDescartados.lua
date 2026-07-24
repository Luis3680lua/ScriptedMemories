local Menu = _G.Menu
if not Menu then return end

local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local HttpGet = game.HttpGet

local FOLDER = "ScriptedMemories/cache"
if makefolder and isfolder and not isfolder(FOLDER) then
	pcall(makefolder, FOLDER)
end

local function getOrDownloadAsset(url, filename)
	if isfile and getcustomasset and isfile(filename) then
		return getcustomasset(filename)
	end
	if writefile and getcustomasset then
		local ok, data = pcall(HttpGet, game, url)
		if ok and data then
			writefile(filename, data)
			return getcustomasset(filename)
		end
	end
	return nil
end

local customIcons = {
	amy = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Amy.png", file = "Amy.png" },
	blaze = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Blaze.png", file = "Blaze.png" },
	cream = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Cream.png", file = "Cream.png" },
	eggman = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Eggman.png", file = "Eggman.png" },
	knuckles = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Knuckles.png", file = "Knuckles.png" },
	metalsonic = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/MetalSonic.png", file = "MetalSonic.png" },
	silver = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Silver.png", file = "Silver.png" },
	sonic = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Sonic.png", file = "Sonic.png" },
	tails = { url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Tails.png", file = "Tails.png" }
}

local CACHED_ICONS = {}
for name, data in pairs(customIcons) do
	local path = FOLDER .. "/" .. data.file
	local asset = getOrDownloadAsset(data.url, path)
	if asset then
		CACHED_ICONS[name] = asset
	end
end

local iconConnection = nil

if not Menu.Settings.shop_custom_icons_enabled then
	Menu.Settings.shop_custom_icons_enabled = false
end

local function applyCustomIcons(enabled)
	if iconConnection then
		iconConnection:Disconnect()
		iconConnection = nil
	end

	local function replaceIconsInContainer(container)
		local name = container.Name:lower()
		if customIcons[name] then
			local icon = CACHED_ICONS[name]
			if icon then
				for _, child in ipairs(container:GetDescendants()) do
					if child:IsA("ImageLabel") or child:IsA("ImageButton") then
						local existing = child:FindFirstChild("CustomShopIcon")
						if existing then existing:Destroy() end
						local img = Instance.new("ImageLabel")
						img.Name = "CustomShopIcon"
						img.BackgroundTransparency = 1
						img.Image = icon
						img.Size = UDim2.fromScale(1, 1)
						img.Position = UDim2.fromScale(0, 0)
						img.ScaleType = Enum.ScaleType.Stretch
						img.ZIndex = 999999
						img.Parent = child
					end
				end
			end
		end
	end

	if enabled then
		local function scan()
			local charSelection = PlayerGui:FindFirstChild("CharSelection", true)
			if charSelection then
				for _, obj in ipairs(charSelection:GetDescendants()) do
					if obj:IsA("Frame") or obj:IsA("ImageButton") then
						replaceIconsInContainer(obj)
					end
				end
			end
		end
		scan()

		iconConnection = PlayerGui.DescendantAdded:Connect(function(obj)
			if obj:IsA("Frame") or obj:IsA("ImageButton") then
				replaceIconsInContainer(obj)
			end
		end)
	else
		for _, obj in ipairs(PlayerGui:GetDescendants()) do
			local icon = obj:FindFirstChild("CustomShopIcon")
			if icon then
				icon:Destroy()
			end
		end
	end
end

if Menu.Settings.shop_custom_icons_enabled then
	applyCustomIcons(true)
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

local iconsSubFrame = Instance.new("Frame")
iconsSubFrame.Size = UDim2.new(1, 0, 0, 0)
iconsSubFrame.BackgroundTransparency = 1
iconsSubFrame.AutomaticSize = Enum.AutomaticSize.Y
iconsSubFrame.Parent = mainContainer

local iconsSubLayout = Instance.new("UIListLayout")
iconsSubLayout.Padding = UDim.new(0, 4)
iconsSubLayout.SortOrder = Enum.SortOrder.LayoutOrder
iconsSubLayout.Parent = iconsSubFrame

local iconsSubHeader = Instance.new("TextLabel")
iconsSubHeader.Size = UDim2.new(1, 0, 0, 18)
iconsSubHeader.BackgroundTransparency = 1
iconsSubHeader.Font = T.FontBold
iconsSubHeader.TextSize = 14
iconsSubHeader.TextColor3 = T.TextDim
iconsSubHeader.TextXAlignment = Enum.TextXAlignment.Left
iconsSubHeader.Text = "Restaurar iconos beta"
iconsSubHeader.Parent = iconsSubFrame

local iconsEnabled = Menu.Settings.shop_custom_icons_enabled

local iconsToggleFrame = Instance.new("Frame")
iconsToggleFrame.Size = UDim2.new(1, 0, 0, 50)
iconsToggleFrame.BackgroundColor3 = T.Tertiary
iconsToggleFrame.BackgroundTransparency = 0.3
iconsToggleFrame.BorderSizePixel = 0
roundFrame(iconsToggleFrame, 6)
iconsToggleFrame.Parent = iconsSubFrame

local iconsLabel = Instance.new("TextLabel")
iconsLabel.Size = UDim2.new(0, 200, 0, 26)
iconsLabel.Position = UDim2.new(0, 12, 0, 12)
iconsLabel.BackgroundTransparency = 1
iconsLabel.TextColor3 = T.Text
iconsLabel.Font = T.Font
iconsLabel.TextSize = 14
iconsLabel.Text = "Activar iconos beta"
iconsLabel.Parent = iconsToggleFrame

local iconsToggleBg = Instance.new("Frame")
iconsToggleBg.Size = UDim2.new(0, 44, 0, 22)
iconsToggleBg.Position = UDim2.new(1, -56, 0, 14)
iconsToggleBg.BackgroundColor3 = iconsEnabled and T.Green or T.Red
iconsToggleBg.BorderSizePixel = 0
roundFrame(iconsToggleBg, 11)
iconsToggleBg.Parent = iconsToggleFrame

local iconsToggleKnob = Instance.new("Frame")
iconsToggleKnob.Size = UDim2.new(0, 18, 0, 18)
iconsToggleKnob.Position = iconsEnabled and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
iconsToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
iconsToggleKnob.BorderSizePixel = 0
roundFrame(iconsToggleKnob, 9)
iconsToggleKnob.Parent = iconsToggleBg

local function updateIconsVisual(state)
	iconsToggleBg.BackgroundColor3 = state and T.Green or T.Red
	local targetX = state and 24 or 2
	iconsToggleKnob:TweenPosition(UDim2.new(0, targetX, 0, 2), "Out", "Quad", 0.2, true)
end

iconsToggleBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local newState = not Menu.Settings.shop_custom_icons_enabled
		Menu.Settings.shop_custom_icons_enabled = newState
		updateIconsVisual(newState)
		if Menu.SaveSettings then Menu.SaveSettings() end
		applyCustomIcons(newState)
	end
end)

task.wait(0.1)
if Menu.UpdateCanvas then
	Menu.UpdateCanvas()
end