local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local function getAsset(url, path)
    local success, result = pcall(function()
        if isfile and isfile(path) then
            return getcustomasset(path)
        end
        if writefile and game and game.HttpGet then
            local data = game:HttpGet(url)
            writefile(path, data)
            if getcustomasset then
                return getcustomasset(path)
            end
        end
        error("")
    end)

    if success then
        return result
    else
        return url
    end
end

local folder = ".cache"

if delfolder and isfolder then
    pcall(delfolder, folder)
end
if makefolder then
    pcall(makefolder, folder)
end

local iconAsset, bannerAsset

pcall(function()
    iconAsset = getAsset(
        "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Icon.png",
        folder .. "/icon.png"
    )
    bannerAsset = getAsset(
        "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Banner.png",
        folder .. "/banner.png"
    )
end)

if not iconAsset then iconAsset = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Icon.png" end
if not bannerAsset then bannerAsset = "https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Banner.png" end

local funnyLines = {
	"You Should TRY HARDER.",
	"Let Me Show How to Scratch it!",
	"Can't you see?",
	"Let me show you.",
	"So many lights in the blur of the dark.",
	"Where's the sun? Where's the sky?",
	"Hehehehahahaha",
	"Do you want to play with me?",
	"So many souls to play with, so little time...",
	"NOW YOU DIE",
	"Keep up",
	"Ready or Not?! HERE I COME!",
	"Keep this interesting for me.",
	"Close your eyes. Let it happen.",
	"Better luck next time.",
	"You'll fall like the others. Not like it matters much, does it?",
	"Once you shed your gaze from the unknown, you're welcomed into a wonderful world.",
	"You won't sleep forever.",
	"Get a load of this.",
	"Full systems full power",
	"Slowest thing alive, aren't you?",
	"Too slow",
	"No matter what you look like, you're still that dumb rodent I have encountered.",
	"Man, you're worse than Labyrinth Zone.",
	"Now is not the time metal.",
	"Encore, Metal. Encore.",
	"Here it comes.",
	"Do you think this will stop me?",
	"Foolish attempt. Better luck next time.",
	"Get out of my face.",
	"More. More. hurt me more. It'll only make me stronger.",
	"Pathetic trick. I'll break you for that.",
	"That actually stung. I love it.",
	"Pathetic fools. Now prepare for my wrath.",
	"That's enough.",
	"Stand by.",
	"Hit him.",
	"Impact.",
	"Direct hit.",
	"Got it.",
	"Get out of here.",
	"Back off.",
	"Careful.",
	"Move.",
	"Burn.",
	"Cutting it close.",
	"I'm out of here,",
	"That's not me.",
	"I'm outta here.",
	"Please be okay out there.",
	"I hope this will heal your wounds.",
	"I wish you the best.",
	"Please get better.",
}

local currentNotification

function sendCustomNotification(title, text, duration)
    if currentNotification then
        currentNotification:Destroy()
        currentNotification = nil
    end

    local funnyText = funnyLines[math.random(#funnyLines)]

    local gui = Instance.new("ScreenGui")
    gui.Name = "CustomNotification"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 9999
    gui.Parent = PlayerGui

    local hiddenPos = UDim2.new(1, 40, 1, -110)
    local finalPos = UDim2.new(1, -360, 1, -110)

    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.ClipsDescendants = true
    frame.Size = UDim2.fromOffset(340, 94)
    frame.Position = hiddenPos
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local banner = Instance.new("ImageLabel")
    banner.BackgroundTransparency = 1
    banner.Image = bannerAsset
    banner.ScaleType = Enum.ScaleType.Crop
    banner.Size = UDim2.new(1, 40, 1, 40)
    banner.Position = UDim2.new(0, -20, 0, -20)
    banner.Parent = frame

    local overlay = Instance.new("Frame")
    overlay.BackgroundColor3 = Color3.new()
    overlay.BackgroundTransparency = 0.45
    overlay.BorderSizePixel = 0
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.Parent = frame

    local icon = Instance.new("ImageLabel")
    icon.BackgroundTransparency = 1
    icon.Image = iconAsset
    icon.Size = UDim2.fromOffset(50, 50)
    icon.Position = UDim2.new(0, 14, 0.5, -31)
    icon.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -85, 0, 24)
    titleLabel.Position = UDim2.fromOffset(74, 14)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, -85, 0, 18)
    textLabel.Position = UDim2.fromOffset(74, 39)
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.TextSize = 13
    textLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Text = text
    textLabel.Parent = frame

    local funnyLabel = Instance.new("TextLabel")
    funnyLabel.BackgroundTransparency = 1
    funnyLabel.Size = UDim2.new(1, -85, 0, 16)
    funnyLabel.Position = UDim2.fromOffset(74, 59)
    funnyLabel.Font = Enum.Font.Gotham
    funnyLabel.TextSize = 11
    funnyLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    funnyLabel.TextXAlignment = Enum.TextXAlignment.Left
    funnyLabel.Text = funnyText
    funnyLabel.Parent = frame

    local progressBg = Instance.new("Frame")
    progressBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    progressBg.BorderSizePixel = 0
    progressBg.Size = UDim2.new(1, 0, 0, 3)
    progressBg.Position = UDim2.new(0, 0, 1, -3)
    progressBg.Parent = frame

    local progress = Instance.new("Frame")
    progress.BackgroundColor3 = Color3.new(1, 1, 1)
    progress.BorderSizePixel = 0
    progress.Size = UDim2.new(0, 0, 1, 0)
    progress.Parent = progressBg

    currentNotification = gui

    local intro = TweenService:Create(
        frame,
        TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = finalPos}
    )

    local barTween = TweenService:Create(
        progress,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(1, 0, 1, 0)}
    )

    intro:Play()
    barTween:Play()

    delay(duration, function()
        if currentNotification ~= gui then return end

        local pop = TweenService:Create(
            frame,
            TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {
                Size = UDim2.fromOffset(320, 88),
                Position = UDim2.new(1, -350, 1, -107)
            }
        )
        pop:Play()
        pop.Completed:Wait()

        local outro = TweenService:Create(
            frame,
            TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {Position = hiddenPos}
        )
        outro:Play()
        outro.Completed:Wait()

        if currentNotification == gui then
            currentNotification = nil
            gui:Destroy()
        end
    end)
end

sendCustomNotification(
    "Restored Memories v0.2.0.",
    "✔️ Cargo correctamente.",
    4
)
