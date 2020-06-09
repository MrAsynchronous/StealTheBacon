-- Round Class
-- MrAsync
-- June 8, 2020



local RoundClass = {}
RoundClass.__index = RoundClass

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunSevice = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

--//Classes
local MaidClass

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

        PlayersInRound = {},
        NumbersCalled = {},
        RoundOver = false,

        _Maid = MaidClass.new()
    }, RoundClass)



    return self
end


function RoundClass:EndRound()
    self.RoundOver = true

    self._Maid:DoCleaning()
end


function RoundClass:StartRound()
    --Clone the bacon
    self.Bacon = BaconModel:Clone()
    self.Bacon.Parent = Workspace
    self.Bacon.Position = CenterPosition + Vector3.new(0, 3, 0)
    self.Bacon.Anchored = true

    self._Maid:GiveTask(self.Bacon)

    --Move the Players
    for _, playerTable in pairs(self.Players) do
        playerTable.Character.PrimaryPart.Anchored = true
        playerTable.Character:SetPrimaryPartCFrame(playerTable.IdlePosition)
    end

    --Countdown for player call
    for i=3, 1, -1 do
        print(i)
    end

    --Call random number, if number has already been called, continue creating random numbers until a non-called number has been called
    local RandomObject = Random.new(tick())
    local randomNumber
    repeat
        randomNumber = RandomObject:NextInteger(1, #self.RawPlayers / 2)
    until (not table.find(self.NumbersCalled, randomNumber))

    table.insert(self.NumbersCalled, randomNumber)

    --Find players
    table.insert(self.PlayersInRound, self.TeamA[randomNumber])
    table.insert(self.PlayersInRound, self.TeamB[randomNumber])

    --Allow players to move
    for _, player in pairs(self.PlayersInRound) do
        local playerTable = self.Players[player]

        playerTable.Character.PrimaryPart.Anchored = false
    end

    --Start listening for bacon collections
    self._Maid:GiveTask(self.Bacon.Touched:Connect(function(hitPart)
        local character = hitPart:FindFirstAncestorOfClass("Model")
        if (not character) then return end

        local player = Players:GetPlayerFromCharacter(character)
        if (not player) then return end
        if (not table.find(self.RawPlayers, player) or not table.find(self.PlayersInRound, player)) then return end
        
        local playerTable = self.Players[player]

        print(player.Name, "has collected the bacon!")

        --Position bacon on head of player
        self.Bacon.Position = character.PriamryPart.CFrame + Vector3.new(0, 3, 0)

        --Weld bacon to player
        self.Weld = Instance.new("WeldConstraint")
        self.Weld.Part0 = self.Bacon
        self.Weld.Part1 = character.PrimaryPart

        self._Maid:GiveTask(RunSevice.Stepped:Connect(function()
            local currentPosition = character.PrimaryPart.Position

            --If player returns to their "home", they win
            if ((currentPosition - playerTable.IdlePosition).magnitude <= 5) then
                print(player.Name, "has won the round!")

                self:EndRound()
            end
        end))

        self._Maid:GiveTask(character:FindFirstHumanoidOfClass("Humanoid").Touched:Connect(function(hitPart, hitPosition)
            local otherCharacter = hitPart:FindFirstAncestorOfClass("Model")
            if (not character) then return end
    
            local otherPlayer = Players:GetPlayerFromCharacter(character)
            if (not player) then return end
            
            print(otherPlayer.Name, "has tagged", player.Name)

            --Kill player with Bacon
            character:FindFirstHumanoidOfClass("Humanoid").Health = 0
            
            --End round
            self:EndRound()
        end))
    end))

    print(randomNumber, "has been called!")

    local timeElapsed = 0

    repeat
        wait(1)

        timeElapsed = timeElapsed + 1
        print(60 - timeElapsed, "seconds remaining!")
    until (timeElapsed >= 60 or self.RoundOver)
end


function RoundClass:Initialize()
    self.RawPlayers = Players:GetPlayers()
    local angleBetween = (math.pi * 2) / #self.RawPlayers

    for i, player in pairs(self.RawPlayers) do
        local team = (#self.TeamA < #self.TeamB and "TeamA" or "TeamB")
        table.insert(self[team], player)

        local playerTable = {}
        table.insert(self.Players, playerTable)

        --Tell player their number
        print(player.Name, "is on", team, "with the number", #self[team])

        --Save player and character
        playerTable.Player = player
        playerTable.Character = (player.Character or player.CharacterAdded:Wait())

        --Calculate position around the centre
        playerTable.IdlePosition = CFrame.new(
            Vector3.new(math.sin(angleBetween * i) * 50, 10, math.cos(angleBetween * i) * 50) + CenterPosition,
            CenterPosition
        )
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


--//Called until game is over
function RoundClass:GameOver()
    return (#self.NumbersCalled >= (#self.RawPlayers / 2))
end


function RoundClass:Start()
    BaconModel = ReplicatedStorage:WaitForChild("Bacon")
end


function RoundClass:Init()
    --//Services

    --//Classes
    MaidClass = self.Shared.Maid
end


return RoundClass