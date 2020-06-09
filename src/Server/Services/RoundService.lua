-- Round Service
-- MrAsync
-- June 8, 2020



local RoundService = {Client = {}}

--//Services

--//Classes
local RoundClass

function RoundService:Start()
    while true do
        local self = RoundClass.new()

        repeat
            self:WaitForPlayers()
        until (self:IsReady())

        --Initialize game
        self:Initialize()
        
        --Intermission to wait for all players to be IsReady
        self:RunIntermission()

    end
end


function RoundService:Init()
    --//Services

    --//Classes
    RoundClass = self.Modules.Classes.RoundClass
end


return RoundService