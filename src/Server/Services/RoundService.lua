-- Round Service
-- MrAsync
-- June 8, 2020



local RoundService = {Client = {}}


--//Api

--//Services
local Players = game:GetService("Players")

--//Classes
local RoundClass

--//Controllers

--//Locals
local CurrentRound


function RoundService:Start()
    while true do
        local self = RoundClass.new()
        CurrentRound = self
    
        --//Wait for proper player count
        repeat
            self:WaitForPlayers()
        until self:IsReady()

        --//Initialize the round
        self:Initialize()

        --//Continue with rounds until all numbers have been called
        repeat
            self:SetupRound()
            self:StartRound()
        until self:GameOver()
    end
end


function RoundService:Init()
    --//Api
    
    --//Services
    
    --//Classes
    RoundClass = self.Modules.Classes.Round

    --//Controllers
    
    --//Locals
    
end


return RoundService