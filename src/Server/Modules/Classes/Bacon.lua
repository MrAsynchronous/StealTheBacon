-- Bacon
-- MrAsync
-- June 17, 2020



local Bacon = {}
Bacon.__index = Bacon


--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

--//Classes
local EventClass
local MaidClass

--//Controllers

--//Locals


function Bacon.new()
    local self = setmetatable({
        Collected = false,
        Owner = false,

        PlayerCollected = EventClass.new(),

        _Maid = MaidClass.new()
    }, Bacon)

    --Clone bacon model
    self.Model = ReplicatedStorage.Bacon:Clone()
    self.Model.Parent = workspace
    self.Model.CFrame = Workspace.MapMiddle.CFrame

    return self
end


function Bacon:Setup()
    --Listen for Touched event to fire PlayerCollected Event
    self._Maid:GiveTask(self.Model.Touched:Connect(function(hitPart)
        local model = hitPart:FindFirstAncestorOfClass("Model")

        if (model) then
            local player = Players:GetPlayerFromCharacter(model)

            if (player) then
                self.PlayerCollected:Fire(player)
            end
        end
    end))
end


function Bacon:Reset()
    self.Model.CFrame = Workspace.MapMiddle.CFrame
    self._Maid:DoCleaning()
end


function Bacon:Cleanup()
    self.Model:Destroy()
    self._Maid:Destroy()
end


function Bacon:Init()
    --//Api
    
    --//Services
    
    --//Classes
    EventClass = self.Shared.Event
    MaidClass = self.Shared.Maid

    --//Controllers
    
    --//Locals
    
end

return Bacon