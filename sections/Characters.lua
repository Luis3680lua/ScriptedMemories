_G.OutcomeSections.Characters = function(ControlsFrame)
	local FOLDER = ".cache"
	if makefolder and not isfolder(FOLDER) then pcall(makefolder, FOLDER) end
	local getAsset = getsynasset or getcustomasset or function() return "" end

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

	local cache = {}
	local function getIcon(name)
		name = string.lower(name)
		if cache[name] then return cache[name] end
		local data = customIcons[name]
		if not data then return nil end
		local path = FOLDER .. "/" .. data.file
		if not isfile(path) then
			local ok, body = pcall(function() return game:HttpGet(data.url .. "?t=" .. tick()) end)
			if not (ok and body and #body > 100) then return nil end
			writefile(path, body)
		end
		local ok, asset = pcall(function() return getAsset(path) end)
		if ok and asset then
			cache[name] = asset
			return asset
		end
		return nil
	end

	local Survivors = {"Sonic", "Tails", "Knuckles", "Amy", "Cream", "Blaze", "Silver"}
	local Killers = {"MetalSonic", "Shadow", "Rouge", "Eggman"}

	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundTransparency = 1
	mainFrame.Parent = ControlsFrame

	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 40)
	topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	topBar.Parent = mainFrame

	local survivorsBtn = Instance.new("TextButton")
	survivorsBtn.Size = UDim2.new(0, 120, 1, -10)
	survivorsBtn.Position = UDim2.new(0, 5, 0, 5)
	survivorsBtn.BackgroundTransparency = 1
	survivorsBtn.Text = "Survivors"
	survivorsBtn.TextColor3 = Color3.new(1, 1, 1)
	survivorsBtn.Font = Enum.Font.GothamBold
	survivorsBtn.TextSize = 14
	survivorsBtn.Parent = topBar

	local killersBtn = Instance.new("TextButton")
	killersBtn.Size = UDim2.new(0, 120, 1, -10)
	killersBtn.Position = UDim2.new(0, 130, 0, 5)
	killersBtn.BackgroundTransparency = 1
	killersBtn.Text = "Killers"
	killersBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	killersBtn.Font = Enum.Font.GothamBold
	killersBtn.TextSize = 14
	killersBtn.Parent = topBar

	local contentArea = Instance.new("Frame")
	contentArea.Size = UDim2.new(1, 0, 1, -45)
	contentArea.Position = UDim2.new(0, 0, 0, 45)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = mainFrame

	local function clearContent()
		for _, child in ipairs(contentArea:GetChildren()) do
			child:Destroy()
		end
	end

	local function showCharacterDetail(name)
		clearContent()
		local detailFrame = Instance.new("Frame")
		detailFrame.Size = UDim2.new(1, 0, 1, 0)
		detailFrame.BackgroundTransparency = 1
		detailFrame.Parent = contentArea

		local backBtn = Instance.new("TextButton")
		backBtn.Size = UDim2.new(0, 100, 0, 30)
		backBtn.Position = UDim2.new(0, 10, 0, 10)
		backBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		backBtn.Text = "< Back"
		backBtn.TextColor3 = Color3.new(1, 1, 1)
		backBtn.Font = Enum.Font.Gotham
		backBtn.TextSize = 12
		backBtn.Parent = detailFrame
		Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 6)
		backBtn.MouseButton1Click:Connect(function()
			showList(currentGroup)
		end)

		local img = Instance.new("ImageLabel")
		img.Size = UDim2.new(0, 120, 0, 120)
		img.Position = UDim2.new(0, 20, 0, 50)
		img.BackgroundTransparency = 1
		img.ScaleType = Enum.ScaleType.Fit
		local icon = getIcon(name)
		if icon then
			img.Image = icon
		else
			img.Image = getIcon("sonic") or ""
		end
		img.Parent = detailFrame

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0, 200, 0, 30)
		nameLabel.Position = UDim2.new(0, 150, 0, 80)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = name
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 22
		nameLabel.TextColor3 = Color3.new(1, 1, 1)
		nameLabel.Parent = detailFrame

		local subOptions = {"Overview", "LMS", "Skins", "Voices", "Animations", "Effects", "Advanced"}
		local subFrame = Instance.new("ScrollingFrame")
		subFrame.Size = UDim2.new(1, -20, 0.5, -160)
		subFrame.Position = UDim2.new(0, 10, 0, 200)
		subFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		subFrame.BackgroundTransparency = 0.5
		subFrame.BorderSizePixel = 0
		subFrame.ScrollBarThickness = 4
		subFrame.Parent = detailFrame
		Instance.new("UICorner", subFrame).CornerRadius = UDim.new(0, 8)

		local subLayout = Instance.new("UIListLayout")
		subLayout.SortOrder = Enum.SortOrder.LayoutOrder
		subLayout.Padding = UDim.new(0, 5)
		subLayout.Parent = subFrame

		for _, opt in ipairs(subOptions) do
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -10, 0, 35)
			btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			btn.Text = opt
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 12
			btn.Parent = subFrame
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
			btn.MouseButton1Click:Connect(function()
				btn.Text = "Selected"
				task.wait(0.5)
				btn.Text = opt
			end)
		end
		subFrame.CanvasSize = UDim2.fromOffset(0, subLayout.AbsoluteContentSize.Y + 10)
		subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			subFrame.CanvasSize = UDim2.fromOffset(0, subLayout.AbsoluteContentSize.Y + 10)
		end)
	end

	local function showList(group)
		clearContent()
		local listFrame = Instance.new("ScrollingFrame")
		listFrame.Size = UDim2.new(1, 0, 1, 0)
		listFrame.BackgroundTransparency = 1
		listFrame.BorderSizePixel = 0
		listFrame.ScrollBarThickness = 4
		listFrame.Parent = contentArea

		local gridLayout = Instance.new("UIGridLayout")
		gridLayout.CellSize = UDim2.fromOffset(160, 200)
		gridLayout.CellPadding = UDim2.fromOffset(10, 10)
		gridLayout.FillDirection = Enum.FillDirection.Horizontal
		gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		gridLayout.StartCorner = Enum.StartCorner.TopLeft
		gridLayout.Parent = listFrame

		local charList = group == "Survivors" and Survivors or Killers
		for _, name in ipairs(charList) do
			local card = Instance.new("TextButton")
			card.Size = UDim2.fromOffset(160, 200)
			card.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			card.Text = ""
			card.Parent = listFrame
			Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

			local img = Instance.new("ImageLabel")
			img.Size = UDim2.new(0, 100, 0, 100)
			img.Position = UDim2.new(0.5, -50, 0, 20)
			img.BackgroundTransparency = 1
			img.ScaleType = Enum.ScaleType.Fit
			local icon = getIcon(name)
			if icon then
				img.Image = icon
			else
				img.Image = getIcon("sonic") or ""
			end
			img.Parent = card

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(1, 0, 0, 30)
			nameLabel.Position = UDim2.new(0, 0, 0, 140)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = name
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextSize = 14
			nameLabel.TextColor3 = Color3.new(1, 1, 1)
			nameLabel.Parent = card

			card.MouseButton1Click:Connect(function()
				showCharacterDetail(name)
			end)
		end

		listFrame.CanvasSize = UDim2.fromOffset(gridLayout.AbsoluteContentSize.X + 20, gridLayout.AbsoluteContentSize.Y + 20)
		gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			listFrame.CanvasSize = UDim2.fromOffset(gridLayout.AbsoluteContentSize.X + 20, gridLayout.AbsoluteContentSize.Y + 20)
		end)
	end

	local currentGroup = "Survivors"
	local function setGroup(group)
		currentGroup = group
		if group == "Survivors" then
			survivorsBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			survivorsBtn.BackgroundTransparency = 0.5
			survivorsBtn.TextColor3 = Color3.new(1, 1, 1)
			killersBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			killersBtn.BackgroundTransparency = 1
			killersBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		else
			killersBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
			killersBtn.BackgroundTransparency = 0.5
			killersBtn.TextColor3 = Color3.new(1, 1, 1)
			survivorsBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			survivorsBtn.BackgroundTransparency = 1
			survivorsBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
		showList(group)
	end

	survivorsBtn.MouseButton1Click:Connect(function() setGroup("Survivors") end)
	killersBtn.MouseButton1Click:Connect(function() setGroup("Killers") end)

	setGroup("Survivors")
end