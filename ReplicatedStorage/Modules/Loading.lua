local PS = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local LG = game:GetService("Lighting")

local loadingGuiEvents = RS.Events.Guis.LoadingGui

local player = PS.LocalPlayer

local blur = LG.Blur

local playerGui = player:WaitForChild("PlayerGui")
local loadingGui = playerGui:WaitForChild("LoadingGui")

local subContainer = loadingGui.Container.SubContainer
local titleLabel = subContainer.TitleHandler.TitleLabel
local titleLabelRootPosition = titleLabel.Position

local squares = subContainer.Squares:GetChildren()
local squaresArray = {}

for _, value in ipairs(squares) do
	if not value:IsA("Frame") then
		continue
	end

	table.insert(squaresArray, value)
end

table.sort(squaresArray, function(a, b)
	return a.LayoutOrder < b.LayoutOrder
end)

local quotes = {
	"Yelling on crabs...",
	"Reading creepypastas. Pastas?..",
	"Scaring SCP characters...",
	"Waiting for milkman...",
	"Hiding in closet...",
	"Checking Backrooms...",
	"Working on freelance...",
	"Buying motors...",
	"Walking with ducks..."
}

local module = {}
module.__index = module

local function typeQuote()
	local quote = quotes[math.random(1, #quotes)]

	for i = titleLabel.Text:len(), 1, -1 do
		titleLabel.Text = string.sub(titleLabel.Text, 1, i)

		local tween = TS:Create(titleLabel, TweenInfo.new(
			.1,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.InOut,
			0,
			true,
			0
			), { Position = titleLabelRootPosition - UDim2.fromOffset(0, 5) })
		tween:Play()
		tween.Completed:Wait()
	end

	titleLabel.Text = ""

	for _, char in ipairs(quote:split("")) do
		titleLabel.Text = titleLabel.Text..char

		local tween = TS:Create(titleLabel, TweenInfo.new(
			.15,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.InOut,
			0,
			true,
			0
			), { Position = titleLabelRootPosition - UDim2.fromOffset(0, 5) })
		tween:Play()
		tween.Completed:Wait()
	end
end

local function moveSquares()
	for _, value in ipairs(squaresArray) do
		local tween = TS:Create(value.Frame, TweenInfo.new(
			.5,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.InOut,
			0,
			true,
			0
			), { Position = value.Frame.Position - UDim2.new(0, 0, 0, 10) })
		tween:Play()
		tween.Completed:Wait()	
	end
end


function module.new()
	local self = {}
	
	self.isActive = false
	self.isTyping = false
	
	return setmetatable(self, module)
end


function module:Start()
	if self.isActive then
		return
	end
	
	self:SizeBlur(100)
	
	self.isActive = true
	
	loadingGuiEvents.Open:Invoke()
	
	coroutine.wrap(function()
		repeat
			moveSquares()
		until not self.isTyping and not self.isActive
	end)()
	
	coroutine.wrap(function()
		repeat
			self.isTyping = true
			typeQuote()
			self.isTyping = false
		until not self.isActive
	end)()
end

function module:Stop()
	if not self.isActive then
		return
	end
	
	self.isActive = false
	
	repeat task.wait()
	until not self.isTyping
	
	task.wait(3)
	loadingGuiEvents.Close:Invoke()
	
	self:SizeBlur(0)
end

function module:SizeBlur(value)
	local tween = TS:Create(blur, TweenInfo.new(
		.5,
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.InOut,
		0,
		false,
		0
		), { Size = value })
	tween:Play()
	tween.Completed:Wait()
end

return module