--==================================================
-- NOXYLON Private Script
-- UI UNCHANGED | FULL LOGIC FIX
--==================================================

repeat task.wait() until game:IsLoaded()

--================ SERVICES ========================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = workspace.CurrentCamera
local GuiInset = GuiService:GetGuiInset()

--================ CONFIG ==========================
local Config = {
	Aimbot = false,
	ESP = false,
	FOV = 200,
	Smoothing = 0.15,
	AimPart = "Head",
	ShowFOV = false,
	TeamCheck = false,
	WallCheck = false
}

--================ GUI ROOT ========================
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "NOXYLON_GUI"
ScreenGui.ResetOnSpawn = false

--================ MAIN ============================
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,600,0,360)
Main.Position = UDim2.new(0.5,-300,0.5,-180)
Main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner",Main)

--================ HEADER ==========================
local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1,0,0,40)
Header.BackgroundTransparency = 1
Header.Text = "NOXYLON"
Header.Font = Enum.Font.GothamBold
Header.TextSize = 22
Header.TextColor3 = Color3.fromRGB(0,170,255)

--================ SIDEBAR =========================
local Sidebar = Instance.new("Frame", Main)
Sidebar.Position = UDim2.new(0,0,0,40)
Sidebar.Size = UDim2.new(0,150,1,-40)
Sidebar.BackgroundColor3 = Color3.fromRGB(14,14,14)

local function SideButton(text,y)
	local b = Instance.new("TextButton", Sidebar)
	b.Size = UDim2.new(1,0,0,40)
	b.Position = UDim2.new(0,0,0,y)
	b.Text = "  "..text
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(200,200,200)
	b.BackgroundTransparency = 1
	return b
end

local BtnAimbot = SideButton("Aimbot",10)
local BtnESP = SideButton("Player ESP",55)
local BtnMisc = SideButton("Misc",100)

--================ CONTENT =========================
local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0,160,0,50)
Content.Size = UDim2.new(1,-170,1,-60)
Content.BackgroundTransparency = 1

local Pages = {}
local function NewPage()
	local f = Instance.new("Frame", Content)
	f.Size = UDim2.new(1,0,1,0)
	f.BackgroundTransparency = 1
	f.Visible = false
	return f
end

Pages.Aimbot = NewPage()
Pages.ESP = NewPage()
Pages.Misc = NewPage()

Pages.Aimbot.Visible = true

local function Show(page)
	for _,p in pairs(Pages) do p.Visible = false end
	Pages[page].Visible = true
end

BtnAimbot.MouseButton1Click:Connect(function() Show("Aimbot") end)
BtnESP.MouseButton1Click:Connect(function() Show("ESP") end)
BtnMisc.MouseButton1Click:Connect(function() Show("Misc") end)

--================ UI HELPERS ======================
local function Toggle(parent,text,y,cb)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0,260,0,40)
	b.Position = UDim2.new(0,0,0,y)
	b.BackgroundColor3 = Color3.fromRGB(35,35,35)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(230,230,230)
	Instance.new("UICorner",b)

	local state = false
	b.Text = text..": OFF"

	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = text..(state and ": ON" or ": OFF")
		cb(state)
	end)
end

local function Slider(parent,text,y,min,max,val,cb)
	local lbl = Instance.new("TextLabel",parent)
	lbl.Position = UDim2.new(0,0,0,y)
	lbl.Size = UDim2.new(0,260,0,20)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 14
	lbl.TextColor3 = Color3.fromRGB(200,200,200)

	local bar = Instance.new("Frame",parent)
	bar.Position = UDim2.new(0,0,0,y+24)
	bar.Size = UDim2.new(0,260,0,8)
	bar.BackgroundColor3 = Color3.fromRGB(40,40,40)
	Instance.new("UICorner",bar)

	local fill = Instance.new("Frame",bar)
	fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
	Instance.new("UICorner",fill)

	local function set(v)
		v = math.clamp(v,min,max)
		fill.Size = UDim2.new((v-min)/(max-min),0,1,0)
		lbl.Text = text..": "..string.format("%.2f",v)
	end

	set(val)

	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			local pct = math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
			val = min + (max-min)*pct
			set(val)
			cb(val)
		end
	end)
end

--================ AIMBOT UI ======================
Toggle(Pages.Aimbot,"Enable Aimbot",10,function(v) Config.Aimbot=v end)
Toggle(Pages.Aimbot,"Show FOV",60,function(v) Config.ShowFOV=v end)
Slider(Pages.Aimbot,"FOV",110,50,400,Config.FOV,function(v) Config.FOV=v end)
Slider(Pages.Aimbot,"Smoothing",170,0.05,0.5,Config.Smoothing,function(v) Config.Smoothing=v end)

--================ FOV CIRCLE =====================
local FOVCircle = Instance.new("Frame", ScreenGui)
FOVCircle.BackgroundTransparency = 1
local stroke = Instance.new("UIStroke",FOVCircle)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0,170,255)
Instance.new("UICorner",FOVCircle).CornerRadius = UDim.new(1,0)

RunService.RenderStepped:Connect(function()
	if not Config.ShowFOV then
		FOVCircle.Visible = false
		return
	end
	local m = UIS:GetMouseLocation()
	FOVCircle.Visible = true
	FOVCircle.Size = UDim2.fromOffset(Config.FOV*2,Config.FOV*2)
	FOVCircle.Position = UDim2.fromOffset(m.X-Config.FOV,m.Y-Config.FOV-GuiInset.Y)
end)

--================ AIMBOT =========================
local function GetTarget()
	local best,dist=nil,Config.FOV
	for _,p in pairs(Players:GetPlayers()) do
		if p~=LocalPlayer and p.Character then
			local part=p.Character:FindFirstChild(Config.AimPart)
			if part then
				local pos,on=Camera:WorldToViewportPoint(part.Position)
				if on then
					local d=(Vector2.new(pos.X,pos.Y)-UIS:GetMouseLocation()).Magnitude
					if d<dist then
						dist=d
						best=part
					end
				end
			end
		end
	end
	return best
end

RunService.RenderStepped:Connect(function()
	if Config.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local t=GetTarget()
		if t then
			Camera.CFrame=Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position,t.Position),Config.Smoothing)
		end
	end
end)

--================ ESP =============================
Toggle(Pages.ESP,"Glow ESP",10,function(v)
	Config.ESP=v
	for _,h in pairs(ScreenGui:GetChildren()) do
		if h:IsA("Highlight") then h:Destroy() end
	end
	if v then
		for _,p in pairs(Players:GetPlayers()) do
			if p~=LocalPlayer and p.Character then
				local h=Instance.new("Highlight")
				h.Adornee=p.Character
				h.FillTransparency=1
				h.OutlineColor=Color3.fromRGB(0,170,255)
				h.Parent=ScreenGui
			end
		end
	end
end)

--================ MISC ============================
local misc = Instance.new("TextLabel",Pages.Misc)
misc.Size = UDim2.new(1,0,0,40)
misc.Position = UDim2.new(0,0,0,10)
misc.BackgroundTransparency = 1
misc.Font = Enum.Font.Gotham
misc.TextSize = 14
misc.TextColor3 = Color3.fromRGB(180,180,180)
misc.Text = "NOXYLON Private Script"

--================ TOGGLE GUI =====================
UIS.InputBegan:Connect(function(i,gp)
	if not gp and i.KeyCode==Enum.KeyCode.Insert then
		Main.Visible=not Main.Visible
	end
end)

warn("[NOXYLON] main.lua loaded")
