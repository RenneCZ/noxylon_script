--==================================================
-- NOXYLON Private Script
-- UI UNCHANGED | ESP LOGIC FIXED
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

--================ SAVE / LOAD =====================
local FILE = "NOXYLON_Config.json"

local function SaveConfig()
	if writefile then
		writefile(FILE, HttpService:JSONEncode(Config))
	end
end

local function LoadConfig()
	if readfile and isfile and isfile(FILE) then
		local data = HttpService:JSONDecode(readfile(FILE))
		for k,v in pairs(data) do
			Config[k] = v
		end
	end
end
LoadConfig()

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

local Buttons = {BtnAimbot,BtnESP,BtnMisc}
local function SetActive(btn)
	for _,b in pairs(Buttons) do
		b.TextColor3 = Color3.fromRGB(200,200,200)
	end
	btn.TextColor3 = Color3.fromRGB(0,170,255)
end

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
SetActive(BtnAimbot)

local function Show(page,btn)
	for _,p in pairs(Pages) do p.Visible = false end
	Pages[page].Visible = true
	SetActive(btn)
end

BtnAimbot.MouseButton1Click:Connect(function() Show("Aimbot",BtnAimbot) end)
BtnESP.MouseButton1Click:Connect(function() Show("ESP",BtnESP) end)
BtnMisc.MouseButton1Click:Connect(function() Show("Misc",BtnMisc) end)

--================ UI HELPERS ======================
local function Toggle(parent,text,y,cb)
	local state = false
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0,260,0,40)
	b.Position = UDim2.new(0,0,0,y)
	b.BackgroundColor3 = Color3.fromRGB(35,35,35)
	b.TextColor3 = Color3.fromRGB(230,230,230)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	Instance.new("UICorner",b)
	b.Text = text..": OFF"

	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = text..(state and ": ON" or ": OFF")
		cb(state)
		SaveConfig()
	end)
end

--================ AIMBOT UI ======================
Toggle(Pages.Aimbot,"Enable Aimbot",10,function(v) Config.Aimbot=v end)
Toggle(Pages.Aimbot,"Show FOV",60,function(v) Config.ShowFOV=v end)

--================ ESP UI =========================
Toggle(Pages.ESP,"Glow ESP",10,function(v)
	Config.ESP = v
	if v then
		-- apply immediately
		for _,p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				local h = Instance.new("Highlight")
				h.Adornee = p.Character
				h.FillTransparency = 1
				h.OutlineColor = Color3.fromRGB(0,170,255)
				h.Parent = ScreenGui
			end
		end
	else
		-- remove all highlights
		for _,h in pairs(ScreenGui:GetChildren()) do
			if h:IsA("Highlight") then
				h:Destroy()
			end
		end
	end
end)

Toggle(Pages.ESP,"Team Check",60,function(v) Config.TeamCheck=v end)
Toggle(Pages.ESP,"Wall Check",110,function(v) Config.WallCheck=v end)

--================ PLAYER HANDLERS ================
Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function(char)
		if Config.ESP and p ~= LocalPlayer then
			local h = Instance.new("Highlight")
			h.Adornee = char
			h.FillTransparency = 1
			h.OutlineColor = Color3.fromRGB(0,170,255)
			h.Parent = ScreenGui
		end
	end)
end)

--================ TOGGLE GUI =====================
UIS.InputBegan:Connect(function(i,gp)
	if not gp and i.KeyCode == Enum.KeyCode.Insert then
		Main.Visible = not Main.Visible
	end
end)

warn("[NOXYLON] main.lua loaded successfully")
