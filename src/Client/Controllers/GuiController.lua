-- Gui Controller
-- MrAsync
-- June 9, 2020



local GuiController = {}


--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundService

--//Locals
local NotificationGui
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
    NotificationGui = CoreGui:WaitForChild("Notification")

    RoundService.TeamWin:Connect(function()
        local newSound = Instance.new("Sound")
        newSound.SoundId = "rbxassetid://5153737200"
        newSound.Parent = self.Player.Character
        newSound.Ended:Connect(function()
            newSound:Destroy()
        end)

        newSound:Play()
    end)

    RoundService.BaconCollected:Connect(function()
        print("Event received!")

        local newSound = Instance.new("Sound")
        newSound.Parent = self.Player
        newSound.SoundId = "rbxassetid://4612375802"
        newSound.Ended:Connect(function()
            newSound:Destroy()
        end)

        newSound:Play()
    end)

    RoundService.Notification:Connect(function(eventText)
        NotificationGui.Sound:Play()

        local newNotif = NotificationGui.Template:Clone()
        newNotif.Name = "Notification"
        newNotif.Label.Text = eventText

        --Move all other notification up
        for _, notif in pairs(NotificationGui:GetChildren()) do
            if (not notif:IsA("Frame")) then continue end

            notif:TweenPosition(UDim2.new(notif.Position.X.Scale, 0, notif.Position.Y.Scale - (notif.Size.Y.Scale + 0.025), 0), "Out", "Quint", 0.25, true)
        end

        newNotif.Position = UDim2.new(1.5, 0, 1, 0)
        newNotif.Parent = NotificationGui
        newNotif.Visible = true
        newNotif:TweenPosition(UDim2.new(0.5, 0, 1, 0), "Out", "Quint", 0.25, true)

        coroutine.wrap(function()
            wait(5)

            newNotif:TweenPosition(UDim2.new(1.5, 0, newNotif.Position.Y.Scale, 0), "Out", "Quint", 0.25, true)
        end)()  
    end)

    RoundService.NumberPicked:Connect(function(number)
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

    RoundService.NumberGiven:Connect(function(number, team)
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
    --//Services
    RoundService = self.Services.RoundService
end


return GuiController