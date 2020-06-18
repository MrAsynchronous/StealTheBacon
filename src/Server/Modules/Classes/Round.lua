-- Round
-- MrAsync
-- June 17, 2020



local Round = {}
Round.__index = Round


--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

--//Classes
local BaconClass
local TeamClass
local MaidClass

--//Controllers

--//Locals
local MINIMUM_PLAYERS = 8

function Round.new()
    local self = setmetatable({
        PlayersInGame = {},

        TeamA = TeamClass.new("Apples"),
        TeamB = TeamClass.new("Bananas"),

        NumbersToCall = {},
        NumbersCalled = {},

        _Maid = MaidClass.new()
    }, Round)

    return self
end


function Round:StartRound()
    local number = table.remove(self.NumbersToCall, math.random(#self.NumbersToCall))
    table.insert(self.NumbersCalled, number)

    local applePlayer = self.TeamA:CallNumber(number)
    local bananaPlayer = self.TeamB:CallNumber(number)

    applePlayer.Character.PrimaryPart.Anchored = false
    bananaPlayer.Character.PrimaryPart.Anchored = false

    for i=45, 1, -1 do
        wait(1)
    end
end


--//Setups up a roud, does not start a round
function Round:SetupRound()
    repeat wait() until (self.TeamA:IsReady() and self.TeamB:IsReady())
    print("Teams Ready!", "Freezing teams!")

    self.TeamA:Freeze()
    self.TeamB:Freeze()

    self.BaconObject:Setup()
end


--//Initializes teams, does not affect anything physical
function Round:Initialize()
    self.PlayersInGame = Players:GetPlayers()

    --Handle unexpected joins and leaves
    self._Maid:GiveTask(Players.PlayerAdded:Connect(function(player)
        print(player.Name, "has joined during a game.  This player must be put into spectating mode")
    end))

    self._Maid:GiveTask(Players.PlayerRemoving:Connect(function(player)
        print(player.Name, "has left during a game.  What shall we do!")
    end))

    --Shuffle Players
    for index, player in pairs(self.PlayersInGame) do
        local randomIndex = math.random(1, #self.PlayersInGame)
        local randomPlayer = self.PlayersInGame[randomIndex]

        self.PlayersInGame[randomIndex] = player
        self.PlayersInGame[index] = randomPlayer
    end

    --Populate numbers to call with numbers
    for i=1, #self.PlayersInGame / 2 do
        table.insert(self.NumbersToCall, i)
    end

    --Assign players teams, calculate spawn position3
    for i, player in pairs(self.PlayersInGame) do
        --Assign player a position around the map
        local angle = (math.pi * 2) / #self.PlayersInGame
        local spawnPosition  = CFrame.new(
            Vector3.new(math.sin(angle * i) * 50, 5, math.cos(angle * i) * 50) + Workspace.MapMiddle.Position,
            Workspace.MapMiddle.Position
        )

        local team = (#self.TeamA.Players > #self.TeamB.Players and self.TeamB or self.TeamA)
        team:AddPlayer(player, spawnPosition)
    end

    --Create Bacon 
    self.BaconObject = BaconClass.new()
    self._Maid:GiveTask(self.BaconObject.PlayerCollected:Connect(function(player)
        self.BaconObject.Model.CFrame = player.Character.PrimaryPart.CFrame + Vector3.new(0, 5 ,0)

        local newWeld = Instance.new("WeldConstraint")
        newWeld.Parent = player.Character.PrimaryPart
        newWeld.Part0 = player.Character.PrimaryPart
        newWeld.Part1 = self.BaconObject.Model
    end))
end


--//Yields if minimum players are not met
function Round:WaitForPlayers()
    return (#Players:GetPlayers() < MINIMUM_PLAYERS and wait(1))
end


--//Returns boolean reflecting if minimum players are met
function Round:IsReady()
    return (#Players:GetPlayers() >= MINIMUM_PLAYERS and #Players:GetPlayers() % 2 == 0)
end


function Round:GameOver()
    return #self.NumbersToCall == 0
end


function Round:Init()
    --//Api
    
    --//Services
    
    --//Classes
    BaconClass = self.Modules.Classes.Bacon
    TeamClass = self.Modules.Classes.Team
    MaidClass = self.Shared.Maid
    
    --//Controllers
    
    --//Locals
    
end


return Round