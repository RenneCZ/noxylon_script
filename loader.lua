--==================================================
-- NOXYLON Loader | FINAL EXECUTION FIX
--==================================================

repeat task.wait() until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer or Players.PlayerAdded:Wait()

local Name = "NOXYLON"
local Ownerid = "3OwFa1bM69"
local AppVersion = "1.0"

local KEY_FILE = "noxylon_key.txt"
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/RenneCZ/noxylon_script/main/main.lua"

local sessionid

local function notify(t)
	StarterGui:SetCore("SendNotification", {
		Title = "NOXYLON Loader",
		Text = t,
		Duration = 4
	})
end


--============================--
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "NOXYLON Loader"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(0,170,255)
title.TextXAlignment = Enum.TextXAlignment.Center

--================ INIT =============================
local init = game:HttpGet(
	"https://keyauth.win/api/1.1/?" ..
	"name=" .. Name ..
	"&ownerid=" .. Ownerid ..
	"&type=init" ..
	"&ver=" .. AppVersion
)

if init == "KeyAuth_Invalid" then
	notify("KeyAuth app not found")
	return
end

local data = HttpService:JSONDecode(init)
if not data.success then
	notify("Init failed")
	return
end

sessionid = data.sessionid

--================ GUI ==============================
local gui = Instance.new("ScreenGui", LP.PlayerGui)
gui.Name = "NOXYLON_LOADER"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(420,240)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local box = Instance.new("TextBox", frame)
box.Position = UDim2.fromOffset(20,70)
box.Size = UDim2.new(1,-40,0,40)
box.PlaceholderText = "Enter license key"
box.BackgroundColor3 = Color3.fromRGB(35,35,35)
box.TextColor3 = Color3.fromRGB(230,230,230)
Instance.new("UICorner", box)

local status = Instance.new("TextLabel", frame)
status.Position = UDim2.fromOffset(20,120)
status.Size = UDim2.new(1,-40,0,20)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(180,180,180)
status.Text = "Waiting..."

local btn = Instance.new("TextButton", frame)
btn.Position = UDim2.fromOffset(20,150)
btn.Size = UDim2.new(1,-40,0,40)
btn.Text = "VERIFY & LOAD"
btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
btn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", btn)

if isfile and readfile and isfile(KEY_FILE) then
	box.Text = readfile(KEY_FILE)
end

--================ BUTTON ===========================
btn.MouseButton1Click:Connect(function()
	status.Text = "Verifying..."

	local lic = game:HttpGet(
		"https://keyauth.win/api/1.1/?" ..
		"name=" .. Name ..
		"&ownerid=" .. Ownerid ..
		"&type=license" ..
		"&key=" .. box.Text ..
		"&ver=" .. AppVersion ..
		"&sessionid=" .. sessionid
	)

	local res = HttpService:JSONDecode(lic)
	if not res.success then
		status.Text = "Invalid license"
		return
	end

	if writefile then
		writefile(KEY_FILE, box.Text)
	end

	status.Text = "Loading script..."

	local src = game:HttpGet(MAIN_SCRIPT_URL)

	if not src or #src < 100 then
		status.Text = "Script load failed"
		return
	end

	gui:Destroy()

	-- 🔥 DVOJITÝ EXEC FIX
	local f = loadstring(src)
	if type(f) == "function" then
		local r = f()
		if type(r) == "function" then
			r()
		end
	end
end)
