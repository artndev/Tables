local SS = game:GetService("ServerStorage")
local module = {}

module.DefaultDeck = {"Red", "Yellow", "Blue"}
module.StackLimit = 3 -- 3
module.DefaultHearts = 10 -- 50
module.DeckCards = 3
module.GameCards = 30
module.TurnLength = 10
module.Suits = {"Red", "Yellow", "Blue"}
module.Cards = {
	["Red"] = {
		Path = SS.Cards.Red,
		Color = Color3.fromRGB(200, 0, 0),
	},
	["Yellow"] = {
		Path = SS.Cards.Yellow,
		Color = Color3.fromRGB(200, 200, 50),
	},
	["Blue"] = {
		Path = SS.Cards.Blue,
		Color = Color3.fromRGB(0, 16, 176),
	}
}


--module.BackpackItemsOrigins = {
--	["Miku"] = {SS.BackpackItems.Miku},
--	["Furniture"] = {
--		SS.BackpackItems.Furniture.Table,
--		SS.BackpackItems.Furniture.Chair,
--		SS.BackpackItems.Furniture.Sofa,
--	},
--	["Block"] = {SS.BackpackItems.Block},
--	["Sphere"] = {SS.BackpackItems.Sphere},
--	["Cylinder"] = {SS.BackpackItems.Cylinder},
--}

module.BackpackItems = { 
	["Miku"] = {
		Price = math.huge,
		Color = {
			R = 0,
			G = 98,
			B = 143,
		},
		IsEquipped = false,
		IsGamepass = true,
		GamepassId = 1054871522,
	},
	["Furniture"] = {
		Price = math.huge,
		Color = {
			R = 145,
			G = 0,
			B = 0,
		},
		IsEquipped = false,
		IsGamepass = true,
		GamepassId = 1051868957,
	},
	["Block"] = {
		Price = 0,
		Color = {
			R = 170,
			G = 85,
			B = 0,
		},
		IsEquipped = false,
		IsGamepass = false,
	},
	["Sphere"] = {
		Price = 0,
		Color = {
			R = 255,
			G = 85,
			B = 255,
		},
		IsEquipped = false,
		IsGamepass = false,
	},
	["Cylinder"] = {
		Price = 0,
		Color = {
			R = 130,
			G = 130,
			B = 130,
		},
		IsEquipped = false,
		IsGamepass = false,
	},
}

return module
