local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService)
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ENABLE_KEY = Enum.KeyCode.F
local MENU_KEY = Enum.KeyCode.K
local AIM_STRENGTH = 0.18
local MAX_DISTANCE = 150

local isLocked = false
local targetPlayer = nil
local isMenuOpen = true

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CoolNotificationSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local NotificationFrame = Instance.new("Frame")
NotificationFrame.Size = UDim2.new(0, 320, 0, 180)
NotificationFrame.Position = UDim2.new(0, 200, 0, 200)
NotificationFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
NotificationFrame.BorderSizePixel = 0
NotificationFrame.Visible = false
NotificationFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = NotificationFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10))
})
UIGradient.Parent = NotificationFrame

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
BorderGradient.Rotation = 45
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
TitleLabel.Text = "AIM ASSIST SYSTEM"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 22
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = DragHandle

local StatusLabel = Instance.new("TextLabel")
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 15, 0, 55)
StatusLabel.Text = "Status: Inactive"
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 14
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = ContentFrame

local InstructionLabel = Instance.new("TextLabel")
InstructionLabel.BackgroundTransparency = 1
InstructionLabel.Size = UDim2.new(1, 0, 0, 60)
InstructionLabel.Position = UDim2.new(0, 15, 0, 90)
InstructionLabel.Text = "Press [F] to toggle lock\nPress [K] to toggle menu"
InstructionLabel.Font = Enum.Font.Gotham
InstructionLabel.TextSize = 12
InstructionLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InstructionLabel.TextXAlignment = Enum.TextXAlignment.Left
InstructionLabel.TextYAlignment = Enum.TextYAlignment.Top
InstructionLabel.Parent = ContentFrame

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
	StatusLabel.Text = "Status: " .. statusText
	StatusLabel.TextColor3 = color
end

local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

local function update(input)
	local delta = input.Position - dragStart
	NotificationFrame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
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

	for _, player in ipairs(Players.GetPlayers(Players)) do
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
			updateStatus("Inactive", Color3.fromRGB(200, 200, 200))
		else
			targetPlayer = getNearestPlayer()
			if targetPlayer then
				isLocked = true
				updateStatus("Active - Locked", Color3.fromRGB(0, 255, 170))
			else
				updateStatus("No Target Found", Color3.fromRGB(255, 0, 0))
			end
		end
		return
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	isLocked = false
	targetPlayer = nil
	if isMenuOpen then
		updateStatus("Reset (Respawn)", Color3.fromRGB(255, 165, 0))
	end
end)

RunService.RenderStepped:Connect(function()
	if isLocked and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
		lockOn()
	end
end)

if isMenuOpen then
	NotificationFrame.Visible = true
	updateStatus("Ready", Color3.fromRGB(0, 255, 170))
end
