local HS = game:GetService("HttpService")
local PS = game:GetService("Players")
local SS = game:GetService("ServerStorage")
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")

local modules = SS.Modules
local config = require(modules.Config)
local profileService = require(modules.ProfileService)
local replicaService = require(SSS.ReplicaService)

local utils = require(RS.Modules.Utils)

-- get instance by name of item in particular config on server
local dataProfileStore = profileService.GetProfileStore("Data", {
	["Backpack"] = {
		["Block"] = {
			Price = 0,
			Color = {
				R = 170,
				G = 85,
				B = 0,
			},
			IsEquipped = true,
			IsGamepass = false,
		},
		["Sphere"] = {
			Price = 0,
			Color = {
				R = 255,
				G = 85,
				B = 255,
			},
			IsEquipped = true,
			IsGamepass = false,
		},
		["Cylinder"] = {
			Price = 0,
			Color = {
				R = 130,
				G = 130,
				B = 130,
			},
			IsEquipped = true,
			IsGamepass = false,
		},	
	}
})
local profiles = {}
local dataReplicas = {}
local module = {}


function module:GetEquipped(player)
	local playerProfile = self:GetData(player)
	if not playerProfile then
		return
	end
	
	local backpack = playerProfile.Data.Backpack
	local answer = {}
	for key, value in pairs(backpack) do
		if not value.IsEquipped then
			continue
		end

		table.insert(answer, key)
	end

	return {
		["Array"] = answer,
		["Length"] = #utils:Keys(answer),
	}
end

function module:GetData(player)
	local playerProfile = profiles[player]
	
	if not playerProfile then
		warn("[DataManager] > Cannot get data from "..player.Name..".")
		return
	end
	
	return playerProfile
end

function module:SetData(player, key, value)
	local playerProfile = self:GetData(player)
	local dataReplica = dataReplicas[player]

	if not playerProfile or not dataReplica then
		return
	end
	
	local oldData = playerProfile.Data[key]
	if typeof(oldData) ~= typeof(value) then
		return
	end
	
	playerProfile.Data[key] = value 
	dataReplica:SetValue({key}, value) -- heres key not cash
end

function module:onPlayerAdded(player)
	local playerProfile = dataProfileStore:LoadProfileAsync("user_"..player.UserId, "ForceLoad")

	if playerProfile == nil then
		player:Kick("Unable to load your data. Please rejoin.")
		return
	end

	playerProfile:ListenToRelease(function()
		profiles[player] = nil
		dataReplicas[player]:Destroy()
		dataReplicas[player] = nil
	end)

	if not player:IsDescendantOf(PS) then
		playerProfile:Release()
		return
	end
	
	profiles[player] = playerProfile
	
	local dataReplica = replicaService.NewReplica({
		["ClassToken"] = replicaService.NewClassToken("token_"..player.UserId),
		["Data"] = playerProfile.Data,
		Replication = player
	})
	dataReplicas[player] = dataReplica
end

function module:onPlayerRemoved(player)
	local playerProfile = profiles[player]

	if not playerProfile then
		return
	end

	playerProfile:Release()
end

return module
