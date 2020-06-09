-- Gui Controller
-- MrAsync
-- June 9, 2020



local GuiController = {}


--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--//Locals
local NumberPicked
local SendNumber
local NumberGui
local PickedGui
local CoreGui

local ourNumber

local teamNames = {
    ["TeamA"] = "Apples",
    ["TeamB"] = "Bananas"
}

function GuiController:Start()
    local PlayerGui = self.Player:WaitForChild("PlayerGui")
    CoreGui = PlayerGui:WaitForChild("Core")
    NumberGui = CoreGui:WaitForChild("WhatsMyNumber")
    PickedGui = CoreGui:WaitForChild("NumberPicked")

    NumberPicked.OnClientEvent:Connect(function(number)
        if (ourNumber and ourNumber == number) then
            PickedGui.Background.ImageColor3 = Color3.fromRGB(88, 214, 141)
            PickedGui.Title.Text = "You've been picked!"
        else
            PickedGui.Background.ImageColor3 = Color3.fromRGB(93, 173, 226)
            PickedGui.Title.Text = "has been picked!"
        end

        PickedGui.Number.Text = number

        PickedGui.Position = UDim2.new(0.5, 0, 0.5, 0)
        PickedGui.Size = UDim2.new(0, 0, 0, 0)
        PickedGui.Visible = true

        PickedGui:TweenSize(UDim2.new(0.25, 0,0.3, 0), "Out", "Quint", 0.25, true, function()
            wait(1)
            
            PickedGui:TweenSizeAndPosition(UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 1, 0), "Out", "Quint", 0.25, true)
        end)
    end)

    SendNumber.OnClientEvent:Connect(function(number, team)
        ourNumber = number

        NumberGui.Position = UDim2.new(0.5, 0, 0.5, 0)
        NumberGui.Size = UDim2.new(0, 0, 0, 0)
        NumberGui.Visible = true

        NumberGui.Number.Text = teamNames[team] .. "#" .. number

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
    NumberPicked = ReplicatedStorage.NumberPicked
end


return GuiController