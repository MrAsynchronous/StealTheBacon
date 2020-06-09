-- Gui Controller
-- MrAsync
-- June 9, 2020



local GuiController = {}


--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//Locals
local SendNumber
local NumberGui
local CoreGui

function GuiController:Start()
    local PlayerGui = self.Player:WaitForChild("PlayerGui")
    CoreGui = PlayerGui:WaitForChild("Core")
    NumberGui = CoreGui:WaitForChild("WhatsMyNumber")

    SendNumber.OnClientEvent:Connect(function(number)
        NumberGui.Position = UDim2.new(0.5, 0, 0.5, 0)
        NumberGui.Size = UDim2.new(0, 0, 0, 0)
        NumberGui.Visible = true

        NumberGui.Number.Text = "> " .. number .. " <"

        NumberGui:TweenSize(UDim2.new(0.25, 0,0.3, 0), "Out", "Quint", 0.25, true, function()
            wait(2)
            
            NumberGui:TweenSizeAndPosition(UDim2.new(0.14, 0,0.168, 0), UDim2.new(0.07, 0, 0.5, 0), "Out", "Quint", 0.25, true)
        end)
    end)

    CoreGui.Top.GameState.Text = ReplicatedStorage.GameState.Value
    ReplicatedStorage.GameState.Changed:Connect(function(newState)
       CoreGui.Top.GameState.Text = newState
    end)

    CoreGui.Top.TeamAScore.Text = ReplicatedStorage.TeamA.Value
    ReplicatedStorage.TeamA.Changed:Connect(function(newScore)
        CoreGui.Top.TeamAScore.Text = newScore
    end)

    CoreGui.Top.TeamBScore.Text = ReplicatedStorage.TeamB.Value
    ReplicatedStorage.TeamB.Changed:Connect(function(newScore)
        CoreGui.Top.TeamBScore.Text = newScore
    end)

    CoreGui.Top.Timer.Text = ReplicatedStorage.Timer.Value .. "s"
    ReplicatedStorage.Timer.Changed:Connect(function(newTime)
        CoreGui.Top.Timer.Text = newTime .. "s"
    end)
end


function GuiController:Init()
    SendNumber = ReplicatedStorage.GiveNumber
end


return GuiController