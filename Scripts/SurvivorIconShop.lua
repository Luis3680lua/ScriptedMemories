local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local FOLDER = ".cache"
if makefolder and not isfolder(FOLDER) then
	pcall(makefolder, FOLDER)
end

local getAsset = getsynasset or getcustomasset or function() end

local customIcons = {
	amy = {
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Amy.png",
		file = "Amy.png"
	},
	blaze = {
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Blaze.png",
		file = "Blaze.png"
	},
	cream = {
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Cream.png",
		file = "Cream.png"
	},
	eggman = {
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Eggman.png",
		file = "Eggman.png"
	},
	knuckles = {
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Knuckles.png",
		file = "Knuckles.png"
	},
	metalsonic = {
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/MetalSonic.png",
		file = "MetalSonic.png"
	},
	silver = {
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Silver.png",
		file = "Silver.png"
	},
	sonic = {
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Sonic.png",
		file = "Sonic.png"
	},
	tails = {
		url = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Shop/Icons/Tails.png",
		file = "Tails.png"
	}
}

local cache = {}

local function getIcon(name)
	name = string.lower(name)
	if cache[name] then
		return cache[name]
	end

	local data = customIcons[name]
	if not data then return nil end

	local path = FOLDER .. "/" .. data.file
	if not isfile(path) then
		local ok, body = pcall(function()
			return game:HttpGet(data.url .. "?t=" .. tick())
		end)
		if not (ok and body and #body > 100) then return nil end
		writefile(path, body)
	end

	local ok, asset = pcall(function()
		return getAsset(path)
	end)
	if ok and asset then
		cache[name] = asset
		return asset
	end
	return nil
end

local function applyButton(button)
	local key = string.lower(button.Name)
	local icon = getIcon(key)
	if not icon then return end

	local old = button:FindFirstChild("CustomShopIcon")
	if old then old:Destroy() end

	for _, v in ipairs(button:GetDescendants()) do
		if v:IsA("ImageLabel") or v:IsA("ImageButton") then
			v.ImageTransparency = 1
		end
	end

	local img = Instance.new("ImageLabel")
	img.Name = "CustomShopIcon"
	img.BackgroundTransparency = 1
	img.Image = icon
	img.Size = UDim2.fromScale(1.5, 1.25)
	img.Position = UDim2.fromScale(-0.20, -0.25)
	img.AnchorPoint = Vector2.zero
	img.ScaleType = Enum.ScaleType.Stretch
	img.ZIndex = 999999
	img.Parent = button
end

local function processObject(obj)
	local key = string.lower(obj.Name)
	if customIcons[key] and (obj:IsA("ImageButton") or obj:IsA("ImageLabel")) then
		applyButton(obj)
	end
end

local function scan()
	local charSelection = PlayerGui:FindFirstChild("CharSelection", true)
	if not charSelection then return end
	for _, obj in ipairs(charSelection:GetDescendants()) do
		processObject(obj)
	end
end

scan()

PlayerGui.DescendantAdded:Connect(function(obj)
	task.defer(processObject, obj)
end)