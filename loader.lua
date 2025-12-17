--==================================================
-- NOXYLON Loader | KeyAuth API 1.1 (OFFICIAL STYLE)
--==================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer or Players.PlayerAdded:Wait()

--================ APP INFO (MUSÍ SEDĚT!) ===========
local Name = "NOXYLON"          -- Application Name
local Ownerid = "3OwFa1bM69"    -- OwnerID
local AppVersion = "1.0"        -- Version (musí sedět v dashboardu)

--================ SETTINGS =========================
local KEY_FILE = "noxylon_key.txt"
local MAIN_SCRIPT_URL = "https://pastebin.com/raw/vH9dRdhm"

local sessionid = nil

--================ NOTIFY ==========================
local function notify(txt)
	StarterGui:SetCore("SendNotification", {
		Title = "NOXYLON Loader",
		Text = txt,
		Duration = 4
	})
end

--================ INIT =============================
notify("Initializing KeyAuth...")

local initUrl =
	"https://keyauth.win/api/1.1/?" ..
	"name=" .. Name ..
	"&ownerid=" .. Ownerid ..
	"&type=init" ..
	"&ver=" .. AppVersion

local req = game:HttpGet(initUrl)

if req == "KeyAuth_Invalid" then
	notify("Application not found")
	return
end

local data = HttpService:JSONDecode(req)

if not data.success then
	notify("Init error: " .. tostring(data.message))
	return
end

sessionid = data.sessionid
notify("KeyAuth initialized")

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

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "NOXYLON Loader"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(0,170,255)

local box = Instance.new("TextBox", frame)
box.Position = UDim2.fromOffset(20,70)
box.Size = UDim2.new(1,-40,0,40)
box.PlaceholderText = "Enter license key"
box.Font = Enum.Font.Gotham
box.TextSize = 14
box.BackgroundColor3 = Color3.fromRGB(35,35,35)
box.TextColor3 = Color3.fromRGB(230,230,230)
Instance.new("UICorner", box)

local status = Instance.new("TextLabel", frame)
status.Position = UDim2.fromOffset(20,120)
status.Size = UDim2.new(1,-40,0,20)
status.BackgroundTransparency = 1
status.Text = "Waiting..."
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextColor3 = Color3.fromRGB(180,180,180)

local btn = Instance.new("TextButton", frame)
btn.Position = UDim2.fromOffset(20,150)
btn.Size = UDim2.new(1,-40,0,40)
btn.Text = "VERIFY & LOAD"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
btn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", btn)

-- load saved key
if isfile and readfile and isfile(KEY_FILE) then
	box.Text = readfile(KEY_FILE)
end

--================ BUTTON ===========================
btn.MouseButton1Click:Connect(function()
	if box.Text == "" then
		status.Text = "Enter license key"
		return
	end

	status.Text = "Verifying license..."

	local licUrl =
		"https://keyauth.win/api/1.1/?" ..
		"name=" .. Name ..
		"&ownerid=" .. Ownerid ..
		"&type=license" ..
		"&key=" .. box.Text ..
		"&ver=" .. AppVersion ..
		"&sessionid=" .. sessionid

	local licReq = game:HttpGet(licUrl)
	local licData = HttpService:JSONDecode(licReq)

	if not licData.success then
		status.Text = "Invalid license"
		return
	end

	if writefile then
		writefile(KEY_FILE, box.Text)
	end

	status.Text = "Loading script..."

	local src = game:HttpGet(MAIN_SCRIPT_URL)
	gui:Destroy()
	loadstring(src)()
end)
