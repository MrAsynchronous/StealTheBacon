-- Team
-- MrAsync
-- June 17, 2020



local Team = {}
Team.__index = Team

--//Api

--//Services
local RoundService

--//Classes
local MaidClass

--//Controllers

--//Locals



function Team.new(teamName)
    local self = setmetatable({
        Name = teamName,

        Players = {},
        PlayerData = {},

        _Maid = MaidClass.new()
    }, Team)
    
    return self
end


function Team:GetDataForPlayer(player)
    return self.PlayerData[player]
end


--//Returns the player found at the index Number
function Team:CallNumber(number)
    return self.Players[number]
end

--//Anchor's all players in team and teleports them to their respective locations
function Team:Freeze()
    for _, player in pairs(self.Players) do
        local character = (player.Character or player.CharacterAdded:Wait())

        character.PrimaryPart.Anchored = true
        character:SetPrimaryPartCFrame(self.PlayerData[player].SpawnPosition)
    end
end


--//Adds a player to the teams index, 
function Team:AddPlayer(player, spawnPosition)
    table.insert(self.Players, player)

    self.PlayerData[player] = {
        IsReady = (player.Character and true or false),
        Number = #self.Players,
        SpawnPosition = spawnPosition
    }

    RoundService:FireClient("NumberGiven", player, self.PlayerData[player].Number, self.Name)

    self._Maid:GiveTask(player.CharacterAdded:Connect(function()
        wait(1)

        self.PlayerData[player].IsReady = true
    end))

    self._Maid:GiveTask(player.CharacterRemoving:Connect(function()
        self.PlayerData[player].IsReady = false
    end))
end


--//Returns true if all player's in team have a valid character
function Team:IsReady()
    local teamReady = true

    for _, player in pairs(self.Players) do
        teamReady = teamReady and self.PlayerData[player].IsReady
    end

    print(self.Name, teamReady)

    return teamReady
end


--//Returns true if player is in team, returns false otherwise
function Team:FindPlayer(player)
    return (table.find(self.Players, player) == nil and false or true)
end


function Team:Init()
    --//Api
    
    --//Services
    RoundService = self.Services.RoundService
    
    --//Classes
    MaidClass = self.Shared.Maid
    
    --//Controllers
    
    --//Locals
    
end

return Team