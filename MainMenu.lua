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
			pcall(writefile, path, body)
		end
		local ok, asset = pcall(function() return getAsset(path) end)
		if ok and asset then
			cache[name] = asset
			return asset
		end
		return nil
	end

	local Survivors = {"Sonic", "Tails", "Knuckles", "Amy", "Cream", "Blaze", "Silver", "Eggman", "MetalSonic"}
	local Killers = {"2011x", "Kolossos", "Tripwire", "Fleetway"}

	local tagColors = {
		Official = Color3.fromRGB(80, 200, 120),
		Fanmade = Color3.fromRGB(70, 130, 255),
		UST = Color3.fromRGB(255, 205, 50),
		Unused = Color3.fromRGB(255, 80, 80)
	}

	local HttpService = game:GetService("HttpService")
	local SETTINGS_PATH = FOLDER .. "/lms_settings.json"

	local function loadSettings()
		if not isfile(SETTINGS_PATH) then return {} end
		local ok, data = pcall(function() return readfile(SETTINGS_PATH) end)
		if ok and data then
			local decoded = HttpService:JSONDecode(data)
			return type(decoded) == "table" and decoded or {}
		end
		return {}
	end

	local function saveSettings(settings)
		local json = HttpService:JSONEncode(settings)
		pcall(writefile, SETTINGS_PATH, json)
	end

	local sonicLms = nil
	local function ensureSonicLms()
		if sonicLms then return sonicLms end
		local ok, code = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/sections/SonicLMS.lua") end)
		if ok and code then
			local func, err = loadstring(code)
			if func then
				local mod = func()
				if type(mod) == "table" and mod.Apply then
					sonicLms = mod
					return sonicLms
				end
			end
		end
		return nil
	end

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

	local currentGroup = "Survivors"

	local function clearContent()
		for _, child in ipairs(contentArea:GetChildren()) do
			child:Destroy()
		end
	end

	local function showList(group)
		topBar.Visible = true
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
			local charName = name  -- 🔥 CORRECCIÓN: capturar valor actual

			local card = Instance.new("TextButton")
			card.Size = UDim2.fromOffset(160, 200)
			card.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			card.Text = ""
			card.Parent = listFrame
			Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

			local img = Instance.new("ImageLabel")
			img.Size = UDim2.new(0, 120, 0, 120)
			img.Position = UDim2.new(0.5, -60, 0, 15)
			img.BackgroundTransparency = 1
			img.ScaleType = Enum.ScaleType.Fit
			local icon = getIcon(charName)
			img.Image = icon or getIcon("sonic") or ""
			img.Parent = card

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(1, 0, 0, 30)
			nameLabel.Position = UDim2.new(0, 0, 0, 150)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = charName
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextSize = 14
			nameLabel.TextColor3 = Color3.new(1, 1, 1)
			nameLabel.Parent = card

			card.MouseButton1Click:Connect(function()
				showCharacterDetail(charName)  -- usa charName
			end)
		end

		listFrame.CanvasSize = UDim2.fromOffset(gridLayout.AbsoluteContentSize.X + 20, gridLayout.AbsoluteContentSize.Y + 20)
		gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			listFrame.CanvasSize = UDim2.fromOffset(gridLayout.AbsoluteContentSize.X + 20, gridLayout.AbsoluteContentSize.Y + 20)
		end)
	end

	local function showCharacterDetail(name)
		topBar.Visible = false
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
		img.Size = UDim2.new(0, 180, 0, 180)
		img.Position = UDim2.new(0, 20, 0, 50)
		img.BackgroundTransparency = 1
		img.ScaleType = Enum.ScaleType.Fit
		local icon = getIcon(name)
		img.Image = icon or getIcon("sonic") or ""
		img.Parent = detailFrame

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0, 200, 0, 30)
		nameLabel.Position = UDim2.new(0, 210, 0, 100)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = name
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 24
		nameLabel.TextColor3 = Color3.new(1, 1, 1)
		nameLabel.Parent = detailFrame

		if name == "Sonic" then
			pcall(function()
				local lmsLabel = Instance.new("TextLabel")
				lmsLabel.Size = UDim2.new(1, -10, 0, 25)
				lmsLabel.Position = UDim2.new(0, 10, 0, 250)
				lmsLabel.BackgroundTransparency = 1
				lmsLabel.Text = "Last Man Standing"
				lmsLabel.TextXAlignment = Enum.TextXAlignment.Left
				lmsLabel.Font = Enum.Font.GothamBold
				lmsLabel.TextSize = 16
				lmsLabel.TextColor3 = Color3.new(1, 1, 1)
				lmsLabel.Parent = detailFrame

				local lmsScroll = Instance.new("ScrollingFrame")
				lmsScroll.Size = UDim2.new(1, -20, 1, -320)
				lmsScroll.Position = UDim2.new(0, 10, 0, 280)
				lmsScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				lmsScroll.BackgroundTransparency = 0.5
				lmsScroll.BorderSizePixel = 0
				lmsScroll.ScrollBarThickness = 4
				lmsScroll.Parent = detailFrame
				Instance.new("UICorner", lmsScroll).CornerRadius = UDim.new(0, 8)

				local lmsLayout = Instance.new("UIListLayout")
				lmsLayout.SortOrder = Enum.SortOrder.LayoutOrder
				lmsLayout.Padding = UDim.new(0, 5)
				lmsLayout.Parent = lmsScroll

				local selectedLms = nil
				local lmsCards = {}
				local settings = loadSettings()
				local savedOption = settings["Sonic"]

				local function deselectAll()
					for _, card in ipairs(lmsCards) do
						card.indicator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
						card.indicator.Text = ""
					end
				end

				local lmsMod = ensureSonicLms()
				local options = lmsMod and lmsMod.Options or {}

				for _, opt in ipairs(options) do
					local option = opt  -- 🔥 CORRECCIÓN: capturar valor actual

					local card = Instance.new("TextButton")
					card.Size = UDim2.new(1, -10, 0, 70)
					card.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
					card.Text = ""
					card.Parent = lmsScroll
					Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

					local optImg = Instance.new("ImageLabel")
					optImg.Size = UDim2.new(0, 50, 0, 50)
					optImg.Position = UDim2.new(0, 10, 0.5, -25)
					optImg.BackgroundTransparency = 1
					optImg.ScaleType = Enum.ScaleType.Fit
					optImg.Image = getIcon("sonic") or ""
					optImg.Parent = card

					local optName = Instance.new("TextLabel")
					optName.Size = UDim2.new(0, 180, 0, 20)
					optName.Position = UDim2.new(0, 70, 0, 8)
					optName.BackgroundTransparency = 1
					optName.Text = option.name
					optName.TextXAlignment = Enum.TextXAlignment.Left
					optName.Font = Enum.Font.GothamBold
					optName.TextSize = 14
					optName.TextColor3 = Color3.new(1, 1, 1)
					optName.Parent = card

					local credsLabel = Instance.new("TextLabel")
					credsLabel.Size = UDim2.new(0, 180, 0, 15)
					credsLabel.Position = UDim2.new(0, 70, 0, 28)
					credsLabel.BackgroundTransparency = 1
					credsLabel.Text = "by " .. (option.credits or "Unknown")
					credsLabel.TextXAlignment = Enum.TextXAlignment.Left
					credsLabel.Font = Enum.Font.Gotham
					credsLabel.TextSize = 11
					credsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
					credsLabel.Parent = card

					local tagLabel = Instance.new("TextLabel")
					tagLabel.Size = UDim2.new(0, 60, 0, 18)
					tagLabel.Position = UDim2.new(0, 260, 0, 8)
					tagLabel.BackgroundColor3 = tagColors["Official"] or Color3.fromRGB(150, 150, 150)
					tagLabel.Text = "Official"
					tagLabel.Font = Enum.Font.GothamBold
					tagLabel.TextSize = 10
					tagLabel.TextColor3 = Color3.new(1, 1, 1)
					tagLabel.BackgroundTransparency = 0.3
					tagLabel.Parent = card
					Instance.new("UICorner", tagLabel).CornerRadius = UDim.new(0, 4)

					local indicator = Instance.new("TextButton")
					indicator.Size = UDim2.new(0, 30, 0, 30)
					indicator.Position = UDim2.new(1, -40, 0.5, -15)
					indicator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
					indicator.Text = ""
					indicator.Font = Enum.Font.GothamBold
					indicator.TextSize = 18
					indicator.TextColor3 = Color3.new(1, 1, 1)
					indicator.Parent = card
					Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

					card.indicator = indicator
					card.data = option  -- usa option

					if savedOption and option.name == savedOption then
						indicator.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
						indicator.Text = "✓"
						selectedLms = option
					end

					card.MouseButton1Click:Connect(function()
						deselectAll()
						indicator.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
						indicator.Text = "✓"
						selectedLms = option
					end)

					table.insert(lmsCards, card)
				end

				local acceptBtn = Instance.new("TextButton")
				acceptBtn.Size = UDim2.new(0, 100, 0, 35)
				acceptBtn.Position = UDim2.new(0, 10, 1, -45)
				acceptBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
				acceptBtn.Text = "Accept"
				acceptBtn.TextColor3 = Color3.new(1, 1, 1)
				acceptBtn.Font = Enum.Font.GothamBold
				acceptBtn.TextSize = 14
				acceptBtn.Parent = detailFrame
				Instance.new("UICorner", acceptBtn).CornerRadius = UDim.new(0, 6)
				acceptBtn.MouseButton1Click:Connect(function()
					if selectedLms then
						local settings = loadSettings()
						settings["Sonic"] = selectedLms.name
						saveSettings(settings)
						local mod = ensureSonicLms()
						if mod then mod.Apply("Sonic", selectedLms.name) end
					end
				end)

				local rejectBtn = Instance.new("TextButton")
				rejectBtn.Size = UDim2.new(0, 100, 0, 35)
				rejectBtn.Position = UDim2.new(0, 120, 1, -45)
				rejectBtn.BackgroundColor3 = Color3.fromRGB(170, 60, 60)
				rejectBtn.Text = "Reject"
				rejectBtn.TextColor3 = Color3.new(1, 1, 1)
				rejectBtn.Font = Enum.Font.GothamBold
				rejectBtn.TextSize = 14
				rejectBtn.Parent = detailFrame
				Instance.new("UICorner", rejectBtn).CornerRadius = UDim.new(0, 6)
				rejectBtn.MouseButton1Click:Connect(function()
					selectedLms = nil
					deselectAll()
				end)

				lmsScroll.CanvasSize = UDim2.fromOffset(0, lmsLayout.AbsoluteContentSize.Y + 10)
				lmsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					lmsScroll.CanvasSize = UDim2.fromOffset(0, lmsLayout.AbsoluteContentSize.Y + 10)
				end)
			end)
		end
	end

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