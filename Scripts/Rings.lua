local Players = game:GetService("Players")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local function addCommas(num)
	if #num < 4 then
		return num
	end

	return num:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function formatText(text)
	return text:gsub("%f[%w](%d+)(%a+)%f[^%w]", function(num, letters)
		if letters:lower() == "x" then
			return num .. letters
		end
		return addCommas(num) .. letters
	end):gsub("%f[%d](%d+)%f[^%w]", addCommas)
end

local function hookObject(obj)
	if not (obj:IsA("TextLabel") or obj:IsA("TextButton")) then
		return
	end

	local screenGui = obj:FindFirstAncestorWhichIsA("ScreenGui")
	if screenGui then
		local ignored = {
			RealStatsGuiLeft = true,
			LoadingScreen = true,
			CustomNotification = true,
		}

		if ignored[screenGui.Name] then
			return
		end
	end

	local function update()
		local formatted = formatText(obj.Text)
		if formatted ~= obj.Text then
			obj.Text = formatted
		end
	end

	update()
	obj:GetPropertyChangedSignal("Text"):Connect(update)
end

for _, obj in ipairs(PlayerGui:GetDescendants()) do
	hookObject(obj)
end

PlayerGui.DescendantAdded:Connect(hookObject)