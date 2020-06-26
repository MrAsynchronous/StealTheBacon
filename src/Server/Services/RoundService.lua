-- Round Service
-- MrAsync
-- June 8, 2020



local RoundService = {Client = {}}


--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--//Classes
local RoundClass

--//Controllers

--//Locals
local CurrentRound
local GameState


function RoundService:Start()
    ReplicatedStorage.Reset.Event:Connect(function()
        if (CurrentRound) then
            CurrentRound:Destroy( )
        end
    end)

    while true do
        local self = RoundClass.new()
        CurrentRound = self

        GameState.Value = "Waiting for Players"
    
        --//Wait for proper player count
        repeat
            wait()
        until self:IsReady()

        RoundService:FireAllClients("Notification", "A new game is starting!")
        GameState.Value = "Game is Setting Up"

        --//Initialize the round
        self:Initialize()

        GameState.Value = "Game is starting!"

        --//Continue with rounds until all numbers have been called
        repeat
            GameState.Value = "Round is setting up!"

            self:SetupRound()

            GameState.Value = "In-Round"

            self:StartRound()

            GameState.Value = "Round cleanup"
        until self:GameOver()

        GameState.Value = "In-Round"

        self:Destroy()
    end
end


function RoundService:Init()
    --//Api
    
    --//Services
    
    --//Classes
    RoundClass = self.Modules.Classes.Round

    --//Controllers
    
    --//Locals
    GameState = ReplicatedStorage.GameInfo:WaitForChild("GameState")
    
    self:RegisterClientEvent("MyBall")
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