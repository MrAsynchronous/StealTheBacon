-- Round Service
-- MrAsync
-- June 8, 2020



local RoundService = {Client = {}}

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//Classes
local RoundClass

function RoundService:Start()
    wait(20)

    while true do
        local self = RoundClass.new()
        local TeamScores = {
            TeamA = 0,
            TeamB = 0
        }

        ReplicatedStorage.GameState.Value = "Waiting for players"

        repeat
            self:WaitForPlayers()
        until (self:IsReady())

        --Initialize game
        ReplicatedStorage.GameState.Value = "Initializing"
        self:Initialize()
        
        --Intermission to wait for all players to be IsReady
        ReplicatedStorage.GameState.Value = "Intermission"
        self:RunIntermission()

        --RoundService
        repeat
            ReplicatedStorage.GameState.Value = "In-Round"
            local winningTeam, otherTeam = self:StartRound()

            if (not winningTeam and not otherTeam) then
                print("TIE!")
            elseif (not winningTeam and otherTeam) then
                TeamScores[otherTeam] = TeamScores[otherTeam] + 0.5

                print(otherTeam, "neautralized the other team!")
            elseif (winningTeam) then
                TeamScores[winningTeam] = TeamScores[winningTeam] + 1

                print(winningTeam, "has won!")
            end

            print("TeamA:" .. TeamScores.TeamA, "TeamB:" .. TeamScores.TeamB)
            ReplicatedStorage.TeamA.Value = TeamScores.TeamA
            ReplicatedStorage.TeamB.Value = TeamScores.TeamB

            ReplicatedStorage.GameState.Value = "Intermission"

            self:RunIntermission()
        until (self:GameOver())

        self:Destroy()
        self = nil
    end
end


function RoundService:Init()
    --//Services

    --//Classes
    RoundClass = self.Modules.Classes.RoundClass
end


return RoundService