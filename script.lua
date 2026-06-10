local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TextService = game:GetService("TextService")

local ENABLE_KEY = Enum.KeyCode.F
local MENU_KEY = Enum.KeyCode.K
local AIM_STRENGTH = 0.15
local MAX_DISTANCE = 150

local isLocked = false
local targetPlayer = nil
local isMenuOpen = true

local ESPEnabled = false
local ESPSettings = {
	Highlight = false,
	Name = false
}

local ESPObjects = {}
local verifiedTitleObject = nil
local isVerifiedTitleEnabled = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedCheatGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local NotificationFrame = Instance.new("Frame")
NotificationFrame.Size = UDim2.new(0, 400, 0, 400)
NotificationFrame.Position = UDim2.new(0, 200, 0, 100)
NotificationFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
NotificationFrame.BorderSizePixel = 0
NotificationFrame.Visible = false
NotificationFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = NotificationFrame

local BorderFrame = Instance.new("Frame")
BorderFrame.Name = "Border"
BorderFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
BorderFrame.BorderSizePixel = 0
BorderFrame.Position = UDim2.new(0, 0, 0, 0)
BorderFrame.Size = UDim2.new(1, 0, 1, 0)
BorderFrame.ZIndex = 0
BorderFrame.Parent = NotificationFrame

local BorderCorner = Instance.new("UICorner")
BorderCorner.CornerRadius = UDim.new(0, 12)
BorderCorner.Parent = BorderFrame

local BorderGradient = Instance.new("UIGradient")
BorderGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 170)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 100, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 100))
})
BorderGradient.Parent = BorderFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ContentFrame.BorderSizePixel = 0
ContentFrame.Position = UDim2.new(0, 3, 0, 3)
ContentFrame.Size = UDim2.new(1, -6, 1, -6)
ContentFrame.Parent = NotificationFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = ContentFrame

local DragHandle = Instance.new("Frame")
DragHandle.BackgroundTransparency = 1
DragHandle.Size = UDim2.new(1, 0, 0, 50)
DragHandle.Position = UDim2.new(0, 0, 0, 0)
DragHandle.Parent = ContentFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Text = "CHEAT SYSTEM"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 22
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = DragHandle

local TabContainer = Instance.new("Frame")
TabContainer.BackgroundTransparency = 1
TabContainer.Size = UDim2.new(1, 0, 0, 40)
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.Parent = ContentFrame

local MainContainer = Instance.new("Frame")
MainContainer.BackgroundTransparency = 1
MainContainer.Size = UDim2.new(1, 0, 1, -90)
MainContainer.Position = UDim2.new(0, 0, 0, 90)
MainContainer.Parent = ContentFrame

local function createTabButton(tabName, isLeft, isActive)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.5, -5, 0, 30)
	if isLeft then
		btn.Position = UDim2.new(0, 0, 0, 0)
	else
		btn.Position = UDim2.new(0.5, 5, 0, 0)
	end

	local bgColor = Color3.fromRGB(30, 30, 30)
	local textColor = Color3.fromRGB(200, 200, 200)

	if isActive then
		bgColor = Color3.fromRGB(40, 40, 40)
		textColor = Color3.fromRGB(0, 255, 170)
	end

	btn.BackgroundColor3 = bgColor
	btn.BorderSizePixel = 0
	btn.Text = tabName
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 14
	btn.TextColor3 = textColor
	btn.Parent = TabContainer

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	return btn
end

local aimTabBtn = createTabButton("Aim Assist", true, true)
local espTabBtn = createTabButton("ESP / Visuals", false, false)

local aimFrame = Instance.new("ScrollingFrame")
aimFrame.BackgroundTransparency = 1
aimFrame.Size = UDim2.new(1, 0, 1, 0)
aimFrame.Position = UDim2.new(0, 0, 0, 0)
aimFrame.Visible = true
aimFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
aimFrame.ScrollBarThickness = 0
aimFrame.Parent = MainContainer

local espFrame = Instance.new("ScrollingFrame")
espFrame.BackgroundTransparency = 1
espFrame.Size = UDim2.new(1, 0, 1, 0)
espFrame.Position = UDim2.new(0, 0, 0, 0)
espFrame.Visible = false
espFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
espFrame.ScrollBarThickness = 0
espFrame.Parent = MainContainer

local function createToggle(parent, text, yPos, defaultState, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -20, 0, 40)
	frame.Position = UDim2.new(0, 10, 0, yPos)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.Text = text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 14
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local currentState = defaultState

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 50, 0, 30)
	toggleBtn.Position = UDim2.new(1, -60, 0, 5)

	local function updateToggle()
		if currentState then
			toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
			toggleBtn.Text = "ON"
		else
			toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			toggleBtn.Text = "OFF"
		end
	end

	toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.TextSize = 12
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.Parent = frame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = toggleBtn

	updateToggle()

	toggleBtn.MouseButton1Click:Connect(function()
		currentState = not currentState
		updateToggle()
		if callback then
			callback(currentState)
		end
	end)
end

createToggle(aimFrame, "Enable Aim Assist (F)", 10, false, function(state)
	if state then
		isLocked = false
		targetPlayer = nil
	end
end)

createToggle(espFrame, "Enable ESP (Highlight)", 10, false, function(state)
	ESPEnabled = state
	if not state then
		for _, obj in pairs(ESPObjects) do
			pcall(function() if obj.Highlight then obj.Highlight:Destroy() end end)
			pcall(function() if obj.Billboard then obj.Billboard:Destroy() end end)
		end
		ESPObjects = {}
	else
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					if not ESPObjects[player] or not ESPObjects[player].Highlight or not ESPObjects[player].Highlight.Parent or ESPObjects[player].Highlight.Parent ~= player.Character then
						if ESPObjects[player] then
							if ESPObjects[player].Highlight then ESPObjects[player].Highlight:Destroy() end
							if ESPObjects[player].Billboard then ESPObjects[player].Billboard:Destroy() end
							ESPObjects[player] = nil
						end
						local highlight = Instance.new("Highlight")
						highlight.FillTransparency = 0.5
						highlight.OutlineColor = Color3.fromRGB(0, 255, 170)
						highlight.FillColor = Color3.fromRGB(0, 255, 170)
						highlight.Parent = player.Character
						ESPObjects[player] = { Highlight = highlight }
					end
				end
			end
		end
	end
end)

createToggle(espFrame, "Verified Title", 60, false, function(state)
	isVerifiedTitleEnabled = state
	if state then
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
			if not verifiedTitleObject then
				local billboard = Instance.new("BillboardGui")
				billboard.Name = "VerifiedTitle"
				billboard.Size = UDim2.new(0, 200, 0, 50)
				billboard.StudsOffset = Vector3.new(0, 3, 0)
				billboard.Adornee = LocalPlayer.Character:FindFirstChild("Head")
				billboard.Parent = LocalPlayer.Character:FindFirstChild("Head")

				local label = Instance.new("TextLabel")
				label.BackgroundTransparency = 1
				label.Size = UDim2.new(1, 0, 1, 0)
				label.Font = Enum.Font.GothamBold
				label.Text = " " .. LocalPlayer.Name
				label.TextColor3 = Color3.fromRGB(255, 255, 255)
				label.TextSize = 24
				label.TextStrokeTransparency = 0
				label.Parent = billboard

				verifiedTitleObject = billboard
			end
		end
	else
		if verifiedTitleObject then
			verifiedTitleObject:Destroy()
			verifiedTitleObject = nil
		end
	end
end)

aimTabBtn.MouseButton1Click:Connect(function()
	aimFrame.Visible = true
	espFrame.Visible = false
	aimTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	aimTabBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
	espTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	espTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

espTabBtn.MouseButton1Click:Connect(function()
	espFrame.Visible = true
	aimFrame.Visible = false
	espTabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	espTabBtn.TextColor3 = Color3.fromRGB(0, 255, 170)
	aimTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	aimTabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = ContentFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
	NotificationFrame.Visible = false
	isMenuOpen = false
end)

local function updateStatus(statusText, color)
	for _, child in ipairs(ContentFrame:GetChildren()) do
		if child:IsA("TextLabel") and child.Name ~= "TitleLabel" then
			child.Text = "Status: " .. statusText
			child.TextColor3 = color
		end
	end
end

local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

local function update(input)
	local delta = input.Position - dragStart
	NotificationFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

DragHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = NotificationFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

DragHandle.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.TouchMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

local function getNearestPlayer()
	local nearest = nil
	local nearestDistance = MAX_DISTANCE
	local mousePos = Camera.ViewportSize / 2
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local head = player.Character:FindFirstChild("Head")
			if head then
				local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local distance = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
					if distance < nearestDistance then
						nearestDistance = distance
						nearest = player
					end
				end
			end
		end
	end
	return nearest
end

local function lockOn()
	if not isLocked or not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then
		return
	end
	local head = targetPlayer.Character.Head
	local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end
	local targetPos = head.Position
	local currentCFrame = Camera.CFrame
	local lookAtCFrame = CFrame.new(currentCFrame.Position, targetPos)
	local smoothCFrame = currentCFrame:Lerp(lookAtCFrame, AIM_STRENGTH)
	Camera.CFrame = smoothCFrame
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == MENU_KEY then
		isMenuOpen = not isMenuOpen
		NotificationFrame.Visible = isMenuOpen
		return
	end
	if input.KeyCode == ENABLE_KEY then
		if isLocked then
			isLocked = false
			targetPlayer = nil
		else
			targetPlayer = getNearestPlayer()
			if targetPlayer then
				isLocked = true
			else
				isLocked = false
			end
		end
		return
	end
end)

local function removeESP(player)
	if ESPObjects[player] then
		if ESPObjects[player].Highlight then
			ESPObjects[player].Highlight:Destroy()
		end
		if ESPObjects[player].Billboard then
			ESPObjects[player].Billboard:Destroy()
		end
		ESPObjects[player] = nil
	end
end

local function addESP(player)
	if player == LocalPlayer or not ESPEnabled then return end

	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		removeESP(player)
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 0.5
		highlight.OutlineColor = Color3.fromRGB(0, 255, 170)
		highlight.FillColor = Color3.fromRGB(0, 255, 170)
		highlight.Parent = player.Character
		ESPObjects[player] = { Highlight = highlight }
	end
end

Players.PlayerAdded:Connect(function(player)
	addESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
	removeESP(player)
end)

-- Modern Fly System (LinearVelocity + AlignOrientation)
local isFlying = false
local flySpeed = 80
local flyAttachment = nil
local flyLinearVelocity = nil
local flyAlignOrientation = nil

local function setupFlyObjects(character)
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")

	-- Clean up existing
	cleanupFlyObjects()

	-- Create Attachment
	flyAttachment = Instance.new("Attachment")
	flyAttachment.Parent = hrp

	-- Create LinearVelocity
	flyLinearVelocity = Instance.new("LinearVelocity")
	flyLinearVelocity.Attachment0 = flyAttachment
	flyLinearVelocity.MaxForce = math.huge
	flyLinearVelocity.Enabled = false
	flyLinearVelocity.Parent = hrp

	-- Create AlignOrientation
	flyAlignOrientation = Instance.new("AlignOrientation")
	flyAlignOrientation.Attachment0 = flyAttachment
	flyAlignOrientation.MaxForce = math.huge
	flyAlignOrientation.Responsiveness = math.huge
	flyAlignOrientation.Parent = hrp
end

local function cleanupFlyObjects()
	if flyLinearVelocity then
		flyLinearVelocity:Destroy()
		flyLinearVelocity = nil
	end
	if flyAlignOrientation then
		flyAlignOrientation:Destroy()
		flyAlignOrientation = nil
	end
	if flyAttachment then
		flyAttachment:Destroy()
		flyAttachment = nil
	end
	isFlying = false
end

local function enableFly()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		if not flyLinearVelocity then
			setupFlyObjects(LocalPlayer.Character)
		end
		if flyLinearVelocity then
			flyLinearVelocity.Enabled = true
			isFlying = true
			if LocalPlayer.Character:FindFirstChild("Humanoid") then
				LocalPlayer.Character.Humanoid.Sit = true
			end
		end
	end
end

local function disableFly()
	cleanupFlyObjects()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.Sit = false
		LocalPlayer.Character.Humanoid.PlatformStand = false
	end
end

LocalPlayer.Chatted:Connect(function(message)
	local cmd = message:lower()
	if cmd == "/fly" then
		enableFly()
	elseif cmd == "/unfly" then
		disableFly()
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	isLocked = false
	targetPlayer = nil

	-- Reset fly state on respawn
	cleanupFlyObjects()

	-- Reset verified title
	if verifiedTitleObject then
		verifiedTitleObject:Destroy()
		verifiedTitleObject = nil
	end

	-- Re-apply verified title if enabled
	if isVerifiedTitleEnabled then
		wait()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
			local billboard = Instance.new("BillboardGui")
			billboard.Name = "VerifiedTitle"
			billboard.Size = UDim2.new(0, 200, 0, 50)
			billboard.StudsOffset = Vector3.new(0, 3, 0)
			billboard.Adornee = LocalPlayer.Character:FindFirstChild("Head")
			billboard.Parent = LocalPlayer.Character:FindFirstChild("Head")

			local label = Instance.new("TextLabel")
			label.BackgroundTransparency = 1
			label.Size = UDim2.new(1, 0, 1, 0)
			label.Font = Enum.Font.GothamBold
			label.Text = " " .. LocalPlayer.Name
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.TextSize = 24
			label.TextStrokeTransparency = 0
			label.Parent = billboard

			verifiedTitleObject = billboard
		end
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		addESP(player)
	end
end

local function updateESP()
	if not ESPEnabled then 
		for player, _ in pairs(ESPObjects) do
			removeESP(player)
		end
		return 
	end

	for player, espData in pairs(ESPObjects) do
		if not player or not player.Parent or not espData or not espData.Highlight or not espData.Highlight.Parent or espData.Highlight.Parent ~= player.Character or (player.Character and not player.Character:FindFirstChild("HumanoidRootPart")) then
			removeESP(player)
			if player and player.Parent and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				addESP(player)
			end
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if not ESPObjects[player] or not ESPObjects[player].Highlight or not ESPObjects[player].Highlight.Parent or ESPObjects[player].Highlight.Parent ~= player.Character then
				addESP(player)
			end
		end
	end
end

RunService.RenderStepped:Connect(function()
	if isLocked and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
		lockOn()
	end
	updateESP()

	if isFlying and flyLinearVelocity and flyAlignOrientation and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local moveDirection = Vector3.new(0, 0, 0)

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDirection = moveDirection + Camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDirection = moveDirection - Camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDirection = moveDirection - Camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDirection = moveDirection + Camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveDirection = moveDirection + Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
			moveDirection = moveDirection - Vector3.new(0, 1, 0)
		end

		if moveDirection.Magnitude > 0 then
			flyLinearVelocity.VectorVelocity = moveDirection.Unit * flySpeed
			flyAlignOrientation.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + Camera.CFrame.LookVector)
		else
			flyLinearVelocity.VectorVelocity = Vector3.new(0, 0, 0)
		end
	end
end)

if isMenuOpen then
	NotificationFrame.Visible = true
end
