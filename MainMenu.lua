local UIS=game:GetService("UserInputService")
local PG=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local URL="https://raw.githubusercontent.com/Luis3680lua/ScriptedMemories/main/Scripts/Menu/%s.lua"
local Cache={}

local function LoadModule(Name)
	if Cache[Name] then return Cache[Name] end
	local ok,src=pcall(game.HttpGet,game,URL:format(Name))
	if not ok then return end
	local chunk=loadstring(src)
	if not chunk then return end
	local ok2,mod=pcall(chunk)
	if ok2 and type(mod)=="table" then
		Cache[Name]=mod
		return mod
	end
end

-- Nueva función para ejecutar scripts sin estructura de módulo
local function RunScript(Name)
	local ok,src=pcall(game.HttpGet,game,URL:format(Name))
	if ok then
		local f=loadstring(src)
		if f then f() end
	end
end

local Old=PG:FindFirstChild("ScriptedMemoriesMenu")
if Old then Old:Destroy() end

local Gui=Instance.new("ScreenGui",PG)
Gui.Name="ScriptedMemoriesMenu"
Gui.ResetOnSpawn=false

local Main=Instance.new("Frame",Gui)
Main.AnchorPoint=Vector2.new(.5,.5)
Main.Position=UDim2.fromScale(.5,.5)
Main.Size=UDim2.fromOffset(900,520)
Main.Visible=false
Main.BackgroundColor3=Color3.fromRGB(18,18,18)
Main.BackgroundTransparency=.15
Main.BorderColor3=Color3.fromRGB(120,25,25)
Main.BorderSizePixel=2
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,10)

local Side=Instance.new("Frame",Main)
Side.Size=UDim2.fromOffset(180,520)
Side.BackgroundColor3=Color3.fromRGB(26,26,26)
Side.BackgroundTransparency=.2
Side.BorderColor3=Color3.fromRGB(120,25,25)
Side.BorderSizePixel=2
Instance.new("UICorner",Side).CornerRadius=UDim.new(0,10)

local List=Instance.new("UIListLayout",Side)
List.Padding=UDim.new(0,8)
List.HorizontalAlignment=Enum.HorizontalAlignment.Center

local Title=Instance.new("TextLabel",Side)
Title.LayoutOrder=-1
Title.Size=UDim2.new(1,0,0,60)
Title.BackgroundTransparency=1
Title.Font=Enum.Font.GothamBold
Title.TextWrapped=true
Title.TextSize=17
Title.TextColor3=Color3.new(1,1,1)
Title.Text="Scripted Memories | Main Menu"

local Content=Instance.new("Frame",Main)
Content.Position=UDim2.new(0,190,0,10)
Content.Size=UDim2.new(1,-200,1,-20)
Content.BackgroundColor3=Color3.fromRGB(22,22,22)
Content.BackgroundTransparency=.15
Content.BorderColor3=Color3.fromRGB(120,25,25)
Content.BorderSizePixel=2
Instance.new("UICorner",Content).CornerRadius=UDim.new(0,8)

local Selected

local function Select(B)
	if Selected then
		Selected.BackgroundColor3=Color3.fromRGB(45,20,20)
	end
	Selected=B
	B.BackgroundColor3=Color3.fromRGB(120,30,30)
end

local function Info()
	Content:ClearAllChildren()

	local function L(text,size,y,font)
		local T=Instance.new("TextLabel",Content)
		T.BackgroundTransparency=1
		T.Position=UDim2.fromOffset(20,y)
		T.Size=UDim2.new(1,-40,0,size+10)
		T.Font=font
		T.Text=text
		T.TextSize=size
		T.TextColor3=Color3.new(1,1,1)
		T.TextXAlignment=Enum.TextXAlignment.Left
	end

	L("Placeholder",30,20,Enum.Font.GothamBold)
	L("Placeholder",20,70,Enum.Font.GothamMedium)

	local D=Instance.new("TextLabel",Content)
	D.BackgroundTransparency=1
	D.Position=UDim2.fromOffset(20,110)
	D.Size=UDim2.new(1,-40,1,-130)
	D.Font=Enum.Font.Gotham
	D.TextWrapped=true
	D.TextXAlignment=Enum.TextXAlignment.Left
	D.TextYAlignment=Enum.TextYAlignment.Top
	D.TextSize=15
	D.TextColor3=Color3.new(1,1,1)
	D.Text="Placeholder"
end

local function Characters()
	Content:ClearAllChildren()
	local M=LoadModule("Characters")
	if M and M.Open then
		M.Open(Content)
	end
end

-- Nueva función para la sección Sonic
local function SonicSection()
	Content:ClearAllChildren()
	-- Llama al script de Sonic (ejecuta directamente, no espera tabla)
	RunScript("Sonic")
end

local function Button(Name,Callback)
	local B=Instance.new("TextButton",Side)
	B.Size=UDim2.new(1,-20,0,40)
	B.BackgroundColor3=Color3.fromRGB(45,20,20)
	B.BorderColor3=Color3.fromRGB(120,25,25)
	B.Font=Enum.Font.GothamBold
	B.TextColor3=Color3.new(1,1,1)
	B.TextSize=15
	B.Text=Name
	Instance.new("UICorner",B).CornerRadius=UDim.new(0,6)
	B.MouseButton1Click:Connect(function()
		Select(B)
		Callback()
	end)
	return B
end

local B=Button("Info",Info)
Button("Characters",Characters)
Button("Sonic",SonicSection)   -- <-- Botón añadido
Select(B)
Info()

UIS.InputBegan:Connect(function(i,g)
	if not g and i.KeyCode==Enum.KeyCode.RightShift then
		Main.Visible=not Main.Visible
	end
end)