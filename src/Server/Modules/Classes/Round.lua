-- Round
-- MrAsync
-- June 17, 2020



local Round = {}
Round.__index = Round


--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local RoundService

--//Classes
local ThreadClass
local BaconClass
local TeamClass
local MaidClass

--//Controllers

--//Locals
local MINIMUM_PLAYERS = 2

function Round.new()
    local self = setmetatable({
        PlayersInGame = {},
        PlayerTeams = {},

        TeamA = TeamClass.new("Apples"),
        TeamB = TeamClass.new("Bananas"),

        NumbersToCall = {},
        NumbersCalled = {},

        _Maid = MaidClass.new(),
        _BaconMaid = MaidClass.new()
    }, Round)

    return self
end


function Round:NumberCountdown(time)
    --Begin counting down
    local timeElapsed = 0
    repeat
        ReplicatedStorage.GameInfo.Timer.Value = time - timeElapsed

        timeElapsed = timeElapsed + 1
        wait(1)
    until (timeElapsed >= time or  self.StopTimer)
end


function Round:StartRound()
    repeat wait() until (self.TeamA:IsReady() and self.TeamB:IsReady())

    --Freezed teams
    self.TeamA:Freeze()
    self.TeamB:Freeze()

    --Set game state
    ReplicatedStorage.GameInfo.GameState.Value = "Picking number!"

    --Begin counting down
    self:NumberCountdown(5)

    --Choose a random number
    local number = table.remove(self.NumbersToCall, math.random(#self.NumbersToCall))
    table.insert(self.NumbersCalled, number)

    --Set game state
    ReplicatedStorage.GameInfo.GameState.Value = "In-Round"
    RoundService:FireAllClients("NumberPicked", number)

    --Get players from both teams
    local applePlayer = self.TeamA:CallNumber(number)
    local bananaPlayer = self.TeamB:CallNumber(number)

    --ALlow them to move
    applePlayer.Character.PrimaryPart.Anchored = false
    bananaPlayer.Character.PrimaryPart.Anchored = false

    --Begin counting down
    self:NumberCountdown(45)
end


--//Setups up a roud, does not start a round
function Round:SetupRound()
    repeat wait() until (self.TeamA:IsReady() and self.TeamB:IsReady())
    print("Teams Ready!", "Freezing teams!")

    --Freeze both teams
    self.TeamA:Freeze()
    self.TeamB:Freeze()

    --Reset locals
    self.StopTimer = false

    --Listen for the event
    self._BaconMaid:GiveTask(self.BaconObject.PlayerCollected:Connect(function(defensivePlayer)
        if (self.BaconStole) then return end
        if (self.PlayerTeams[defensivePlayer] == nil) then return end

        --Localize the team of the player with the bacon
        local defensiveTeam = self.PlayerTeams[defensivePlayer]
        RoundService:FireAllClients("Notification", defensivePlayer.Name .. " has collected the bacon!")

        self.BaconObject.Model.CFrame = defensivePlayer.Character.PrimaryPart.CFrame + Vector3.new(0, 5 ,0)
        self.BaconStole = true

        local newWeld = Instance.new("WeldConstraint")
        newWeld.Parent = defensivePlayer.Character.PrimaryPart
        newWeld.Part0 = defensivePlayer.Character.PrimaryPart
        newWeld.Part1 = self.BaconObject.Model
        self._BaconMaid:GiveTask(newWeld)

        self._BaconMaid:GiveTask(defensivePlayer.Character.Humanoid.Touched:Connect(function(hitPart)
            if (defensivePlayer.Character.Humanoid.Health < 100) then return end

            local model = hitPart:FindFirstAncestorOfClass("Model")

            if (model) then
                local offensivePlayer = Players:GetPlayerFromCharacter(model)
                if (self.PlayerTeams[offensivePlayer] == nil) then return end

                if (offensivePlayer and offensivePlayer ~= defensivePlayer) then
                    local offsensiveTeam = self.PlayerTeams[offensivePlayer]

                    RoundService:FireAllClients("Notification", offensivePlayer.Name .. " tagged " .. defensivePlayer.Name .. "!")
                    ReplicatedStorage.GameInfo:FindFirstChild(offsensiveTeam.Name).Value += 0.5
                    defensivePlayer.Character.Humanoid.Health = -5

                    defensivePlayer.CharacterRemoving:Wait()

                    self.StopTimer = true
                    self:Reset()
                end
            end
        end))

        self._BaconMaid:GiveTask(RunService.Stepped:Connect(function()
            local defensivePlayerData = defensiveTeam:GetDataForPlayer(defensivePlayer)
            local distance = (defensivePlayer.Character.PrimaryPart.Position - defensivePlayerData.SpawnPosition.Position).magnitude

            if (distance <= 5) then
                ReplicatedStorage.GameInfo:FindFirstChild(defensiveTeam.Name).Value += 1
                RoundService:FireAllClients("Notification", defensivePlayer.Name .. " has cooked the bacon!")

                self.StopTimer = true
                self:Reset()
            end
        end))
    end))
end


--//Initializes teams, does not affect anything physical
function Round:Initialize()   
    self.PlayersInGame = Players:GetPlayers()

    self:NumberCountdown(5)

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

        --make a new ball
        local ball = Instance.new("Part")
        ball.Size = Vector3.new(3,3,3)
        ball.Color = Color3.fromRGB(255, 255, 255)
        ball.Shape = "Ball"
        ball.Anchored = true
        ball.Parent = workspace.Balls
        ball.CFrame = spawnPosition - Vector3.new(0, 3, 0)

        RoundService:FireClient("MyBall", player, ball)

        --Pick a team 
        local team = (#self.TeamA.Players > #self.TeamB.Players and self.TeamB or self.TeamA)
        team:AddPlayer(player, spawnPosition)

        --Cache team
        self.PlayerTeams[player] = team
    end

    --Create Bacon 
    self.BaconObject = BaconClass.new()
    self.BaconObject:Setup()
end


--//Soft resets the round
--//Called when a round is over, before a new round starts
function Round:Reset()
    self._BaconMaid:DoCleaning()
    self.BaconObject:Reset()
    self.BaconStole = false

    if (self.RoundOverQueue) then
        self.RoundOverQueue:Disconnect()
    end
end


--//Fully removes all remnents of this round
--//Called when the game is over
function Round:Destroy()
    local winningTeam = (ReplicatedStorage.GameInfo.Apples.Value > ReplicatedStorage.GameInfo.Bananas.Value and self.TeamA or self.TeamB)
    if (not winningTeam) then
        RoundService:FireAllClients("Notification", "Game Tie!")
    else
        RoundService:FireAllClients("Notification", winningTeam.Name .. " have won!")
    end

    self:NumberCountdown(3)

    self._Maid:Destroy()
    self._BaconMaid:Destroy()
    self.BaconObject:Destroy()
    workspace.Balls:ClearAllChildren()

    ReplicatedStorage.GameInfo.Apples.Value = 0
    ReplicatedStorage.GameInfo.Bananas.Value = 0
end


--//Yields if minimum players are not met
function Round:WaitForPlayers()
    return #Players:GetPlayers() < MINIMUM_PLAYERS
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
    RoundService = self.Services.RoundService
    
    --//Classes
    ThreadClass = self.Shared.Thread
    BaconClass = self.Modules.Classes.Bacon
    TeamClass = self.Modules.Classes.Team
    MaidClass = self.Shared.Maid
    
    --//Controllers
    
    --//Locals
    
end


return Round