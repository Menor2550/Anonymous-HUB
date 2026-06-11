local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ENABLE_KEY = Enum.KeyCode.F
local MENU_KEY = Enum.KeyCode.K
local AIM_STRENGTH = 0.16
local MAX_DISTANCE = 150

local isLocked = false
local targetPlayer = nil
local isMenuOpen = true
local ESPEnabled = false
local ESPObjects = {}
local noclipEnabled = false

local function removeESP(p)
	if ESPObjects[p] then
		if ESPObjects[p].Highlight and ESPObjects[p].Highlight.Parent then
			ESPObjects[p].Highlight:Destroy()
		end
		ESPObjects[p] = nil
	end
end

local function addESP(p)
	if p == LocalPlayer or not ESPEnabled then return end
	if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
		removeESP(p)
		local h = Instance.new("Highlight")
		h.FillTransparency = 0.5
		h.OutlineColor = Color3.fromRGB(0, 255, 170)
		h.FillColor = Color3.fromRGB(0, 255, 170)
		h.Parent = p.Character
		ESPObjects[p] = { Highlight = h }
	end
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "AdvancedCheatGUI"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 360)
Main.Position = UDim2.new(0, 200, 0, 100)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.BorderSizePixel = 0
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(55, 55, 55)
MainStroke.Thickness = 1
MainStroke.Parent = Main

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)
local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 10)
TopFix.Position = UDim2.new(0, 0, 1, 0)
TopFix.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -44, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "Anynomus HUB - Zenn"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -34, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(170, 170, 170)
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseEnter:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false isMenuOpen = false end)

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -16, 0, 1)
Separator.Position = UDim2.new(0, 8, 0, 40)
Separator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Separator.BorderSizePixel = 0
Separator.Parent = Main

local TabFrame = Instance.new("Frame")
TabFrame.BackgroundTransparency = 1
TabFrame.Size = UDim2.new(1, -16, 0, 30)
TabFrame.Position = UDim2.new(0, 8, 0, 46)
TabFrame.Parent = Main

local allTabs = {}
local allPages = {}

local function makeTabBtn(name, posX, active)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.333, -3, 0, 26)
	btn.Position = posX
	btn.BackgroundColor3 = active and Color3.fromRGB(42, 42, 42) or Color3.fromRGB(32, 32, 32)
	btn.BorderSizePixel = 0
	btn.Text = name
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 12
	btn.TextColor3 = active and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(150, 150, 150)
	btn.AutoButtonColor = false
	btn.Parent = TabFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local homeTab = makeTabBtn("Home", UDim2.new(0, 0, 0, 0), true)
local aimTab = makeTabBtn("Aim Assist", UDim2.new(0.333, 2, 0, 0), false)
local espTab = makeTabBtn("ESP / Visuals", UDim2.new(0.666, 4, 0, 0), false)

local Content = Instance.new("Frame")
Content.BackgroundTransparency = 1
Content.Size = UDim2.new(1, -16, 1, -84)
Content.Position = UDim2.new(0, 8, 0, 82)
Content.ClipsDescendants = true
Content.Parent = Main

local function makePage()
	local page = Instance.new("ScrollingFrame")
	page.BackgroundTransparency = 1
	page.Size = UDim2.new(1, 0, 1, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
	page.Visible = false
	page.Parent = Content
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, 4)
	p.PaddingBottom = UDim.new(0, 4)
	p.Parent = page
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, 6)
	l.Parent = page
	return page
end

local homePage = makePage()
homePage.Visible = true
local aimPage = makePage()
local espPage = makePage()

allTabs = {homeTab, aimTab, espTab}
allPages = {homePage, aimPage, espPage}

local function switchTab(activeIdx)
	for i, tab in ipairs(allTabs) do
		local isActive = i == activeIdx
		tab.BackgroundColor3 = isActive and Color3.fromRGB(42, 42, 42) or Color3.fromRGB(32, 32, 32)
		tab.TextColor3 = isActive and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(150, 150, 150)
		allPages[i].Visible = isActive
	end
end

homeTab.MouseButton1Click:Connect(function() switchTab(1) end)
aimTab.MouseButton1Click:Connect(function() switchTab(2) end)
espTab.MouseButton1Click:Connect(function() switchTab(3) end)

local homeTitle = Instance.new("TextLabel")
homeTitle.BackgroundTransparency = 1
homeTitle.Size = UDim2.new(1, 0, 0, 30)
homeTitle.Text = "-- Commands --"
homeTitle.Font = Enum.Font.GothamBold
homeTitle.TextSize = 14
homeTitle.TextColor3 = Color3.fromRGB(0, 255, 170)
homeTitle.Parent = homePage

local function createToggle(parent, text, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 42)
	frame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -56, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.Text = text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextColor3 = Color3.fromRGB(210, 210, 210)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local state = default
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 40, 0, 22)
	toggle.Position = UDim2.new(1, -50, 0.5, -11)
	toggle.BackgroundColor3 = state and Color3.fromRGB(0, 170, 120) or Color3.fromRGB(65, 65, 65)
	toggle.BorderSizePixel = 0
	toggle.Text = ""
	toggle.AutoButtonColor = false
	toggle.Parent = frame
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = toggle
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	toggle.MouseButton1Click:Connect(function()
		state = not state
		toggle.BackgroundColor3 = state and Color3.fromRGB(0, 170, 120) or Color3.fromRGB(65, 65, 65)
		knob.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		if callback then callback(state) end
	end)
end

local function createCheckbox(parent, text, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 36)
	frame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

	local state = default
	local box = Instance.new("TextButton")
	box.Size = UDim2.new(0, 20, 0, 20)
	box.Position = UDim2.new(1, -30, 0.5, -10)
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	box.BorderSizePixel = 0
	box.Text = state and "?" or ""
	box.Font = Enum.Font.GothamBold
	box.TextSize = 14
	box.TextColor3 = Color3.fromRGB(0, 255, 170)
	box.AutoButtonColor = false
	box.Parent = frame
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -40, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.Text = text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextColor3 = Color3.fromRGB(210, 210, 210)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	box.MouseButton1Click:Connect(function()
		state = not state
		box.Text = state and "?" or ""
		box.BackgroundColor3 = state and Color3.fromRGB(0, 170, 120) or Color3.fromRGB(50, 50, 50)
		if callback then callback(state) end
	end)
end

createCheckbox(homePage, "Noclip", false, function(s)
	noclipEnabled = s
end)

createToggle(aimPage, "Enable Aim Assist (F)", false, function(s)
	if s then isLocked = false targetPlayer = nil end
end)

createToggle(espPage, "Enable ESP (Highlight)", false, function(s)
	ESPEnabled = s
	if not s then
		for p, _ in pairs(ESPObjects) do removeESP(p) end
	else
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then addESP(p) end
		end
	end
end)

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

TopBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.TouchMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local d = input.Position - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)

local function getNearestPlayer()
	local nearest, nearestDist = nil, MAX_DISTANCE
	local center = Camera.ViewportSize / 2
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local head = p.Character:FindFirstChild("Head")
			if head then
				local sp, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local d = (center - Vector2.new(sp.X, sp.Y)).Magnitude
					if d < nearestDist then nearestDist = d nearest = p end
				end
			end
		end
	end
	return nearest
end

local function lockOn()
	if not isLocked or not targetPlayer or not targetPlayer.Character then return end
	local head = targetPlayer.Character:FindFirstChild("Head")
	if not head or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
	Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, head.Position), AIM_STRENGTH)
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == MENU_KEY then
		isMenuOpen = not isMenuOpen
		Main.Visible = isMenuOpen
	elseif input.KeyCode == ENABLE_KEY then
		if isLocked then
			isLocked = false
			targetPlayer = nil
		else
			targetPlayer = getNearestPlayer()
			isLocked = targetPlayer ~= nil
		end
	end
end)

Players.PlayerAdded:Connect(addESP)
Players.PlayerRemoving:Connect(removeESP)

LocalPlayer.CharacterAdded:Connect(function()
	isLocked = false
	targetPlayer = nil
end)

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then addESP(p) end
end

RunService.Stepped:Connect(function()
	if noclipEnabled and LocalPlayer.Character then
		for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if isLocked and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
		lockOn()
	end
	if not ESPEnabled then
		for p, _ in pairs(ESPObjects) do removeESP(p) end
		return
	end
	for p, d in pairs(ESPObjects) do
		if not p or not p.Parent or not d.Highlight or not d.Highlight.Parent or d.Highlight.Parent ~= p.Character or (p.Character and not p.Character:FindFirstChild("HumanoidRootPart")) then
			removeESP(p)
			if p and p.Parent and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then addESP(p) end
		end
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and (not ESPObjects[p] or not ESPObjects[p].Highlight or not ESPObjects[p].Highlight.Parent or ESPObjects[p].Highlight.Parent ~= p.Character) then
			addESP(p)
		end
	end
end)