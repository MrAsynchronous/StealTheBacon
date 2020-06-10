-- Round Service
-- MrAsync
-- June 8, 2020



local RoundService = {Client = {}}

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//Classes
local RoundClass

--//Locals

function RoundService:Start()
    wait(10)

    while true do
        local self = RoundClass.new()
        local TeamScores = {
            TeamA = 0,
            TeamB = 0
        }

        ReplicatedStorage.GameState.Value = "Waiting for players"
        ReplicatedStorage.TeamA.Value = 0
        ReplicatedStorage.TeamB.Value = 0

        workspace.Sounds.Intermission:Play()
        
        repeat
            self:WaitForPlayers()
        until (self:IsReady())

        --Initialize game
        ReplicatedStorage.GameState.Value = "Initializing"
        self:Initialize()
        
        --Intermission to wait for all players to be IsReady
        ReplicatedStorage.GameState.Value = "Intermission"
        self:RunIntermission()

        --Run rounds
        workspace.Sounds.Intermission:Stop()
        workspace.Sounds.Ingame:Play()
        repeat
            ReplicatedStorage.GameState.Value = "In-Round"
            local winningTeam, otherTeam = self:StartRound()

            if (not winningTeam and not otherTeam) then
                RoundService:FireAllClientsEvent("Notification", "Draw")
            elseif (winningTeam and otherTeam) then
                TeamScores[winningTeam] = TeamScores[winningTeam] + 0.5
            elseif (winningTeam and not otherTeam) then
                TeamScores[winningTeam] = TeamScores[winningTeam] + 1
            end

            ReplicatedStorage.TeamA.Value = TeamScores.TeamA
            ReplicatedStorage.TeamB.Value = TeamScores.TeamB

            ReplicatedStorage.GameState.Value = "Intermission"

            self:RunIntermission()
        until (self:GameOver())

        RoundService:FireAllClients("Notification", (TeamScores.TeamA > TeamScores.TeamB and "Apples" or "Bananas") .. " has won the game!")
        self:RunIntermission()

        self:Destroy()
        self = nil
    end
end


function RoundService:Init()
    --//Services

    --//Classes
    RoundClass = self.Modules.Classes.RoundClass

    --//Locals
    self:RegisterClientEvent("BaconCollected")
    self:RegisterClientEvent("NumberGiven")
    self:RegisterClientEvent("NumberPicked")
    self:RegisterClientEvent("Notification")
    self:RegisterClientEvent("BaconCooked")
    self:RegisterClientEvent("BaconBurnt")
    self:RegisterClientEvent("TeamWin")
    self:RegisterClientEvent("TeamLoss")

end


return RoundService