-- Round Class
-- MrAsync
-- June 8, 2020



local RoundClass = {}
RoundClass.__index = RoundClass

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

--//Classes

--//Locals
local CenterPosition = Vector3.new(0, 0, 0)
local BaconModel

local MINIMUM_PLAYERS = 2


function RoundClass.new()
    local self = setmetatable({
        TeamA = {},
        TeamB = {},

        Players = {},
        RawPlayers = {},

        RoundOver = false,
    }, RoundClass)



    return self
end


function RoundClass:StartRound()
    --Clone the bacon
    self.Bacon = BaconModel:Clone()
    self.Bacon.Parent = Workspace
    self.Bacon.Position = CenterPosition + Vector3.new(0, 3, 0)
    self.Bacon.Anchored = true

    --Move the Players
    for _, playerTable in pairs(self.Players) do
        playerTable.Character.PrimaryPart.Anchored = true
        playerTable.Character:SetPrimaryPartCFrame(playerTable.IdlePosition)
    end

    --Countdown for player call
    for i=3, 1, -1 do
        print(i)
    end

    --Call random number
    local 
end


function RoundClass:Initialize()
    self.RawPlayers = Players:GetPlayers()
    local angleBetween = 360 / #self.RawPlayers

    for i, player in pairs(self.RawPlayers) do
        local team = (#self.TeamA < #self.TeamB and "TeamA" or "TeamB")
        table.insert(self[team], player)

        local playerTable = {}
        table.insert(self.Players, playerTable)

        playerTable.Player = player
        playerTable.Character = (player.Character or player.CharacterAdded:Wait())

        --Calculate position around the centre
        playerTable.IdlePosition = CFrame.new(
            Vector3.new(math.sin(angleBetween * i) * 50, 10, math.cos(angleBetween * i) * 50) + CenterPosition,
            CenterPosition
        )

        print(player.Name, "is on", team)
    end
end

--//Called after self:Initialize.  Just to make sure all player are rady
function RoundClass:RunIntermission()
    for i=1, 20 do
        wait(1)

        print(20 - i, "seconds of intermission remaining!")
    end

    return true
end

--//Called until all minimum players are in game
function RoundClass:WaitForPlayers()
    if (#Players:GetPlayers() >= MINIMUM_PLAYERS and (#Players:GetPlayers() % 2 == 0)) then
        return true
    else
        wait(1)

        print("Waiting for players!")
    end
end

--//Called until minimum players are in game
function RoundClass:IsReady()
    return (#Players:GetPlayers() >= MINIMUM_PLAYERS)
end


function RoundClass:Start()
    BaconModel = ReplicatedStorage:WaitForChild("Bacon")
end


return RoundClass