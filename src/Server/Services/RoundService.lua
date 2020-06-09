-- Round Service
-- MrAsync
-- June 8, 2020



local RoundService = {Client = {}}

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//Classes
local RoundClass

--//Locals
local Happened

function RoundService:Start()
    while true do
        local self = RoundClass.new()
        local TeamScores = {
            TeamA = 0,
            TeamB = 0
        }

        ReplicatedStorage.GameState.Value = "Waiting for players"
        ReplicatedStorage.TeamA.Value = 0
        ReplicatedStorage.TeamB.Value = 0
        
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
                Happened:FireAllClients("Draw!")
            elseif (winningTeam and otherTeam) then
                TeamScores[winningTeam] = TeamScores[winningTeam] + 0.5

            --    Happened:FireAllClients(winningTeam .. " has neutralized the " .. otherTeam .. "!")
            elseif (winningTeam and not otherTeam) then
                TeamScores[winningTeam] = TeamScores[winningTeam] + 1

            --    Happened:FireAllClients(winningTeam .. " has won the round!")
            end

            ReplicatedStorage.TeamA.Value = TeamScores.TeamA
            ReplicatedStorage.TeamB.Value = TeamScores.TeamB

            ReplicatedStorage.GameState.Value = "Intermission"

            self:RunIntermission()
        until (self:GameOver())

        Happened:FireAllClients((TeamScores.TeamA > TeamScores.TeamB and "Apples" or "Bananas") .. " has won the game!")
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
    Happened = ReplicatedStorage.Happened
end


return RoundService