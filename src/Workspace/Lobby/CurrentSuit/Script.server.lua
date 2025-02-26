game:GetService("TweenService"):Create(script.Parent, TweenInfo.new(
	1,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.InOut,
	-1,
	false,
	0
), { CFrame = CFrame.new(script.Parent.Position) * CFrame.Angles(math.rad(0), math.rad(360), math.rad(0)) }):Play()