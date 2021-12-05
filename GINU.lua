-- GINU 12/4/21

local Module = {}
local TweenService = game:GetService("TweenService")

--[[
	Utility for creating a Bezier Curve with limitless control points
	
	local api = LimitlessBezier(ControlPoints:table<CFrame/Vector3>) > obj
	^ (Any Vector3s will be converted to CFrames anyways so don't worry about it)
	api.SmoothTravel(object,tweenspeed,stepspeed)
	api.Travel(object,stepspeed)
]]

function it_bez(control_points,t) -- Get curve at t%
	while #control_points > 1 do
		local newPoints = {}
		for i = 1, #control_points - 1 do
			newPoints[i] = control_points[i]:Lerp(control_points[i + 1], t)
		end
		control_points = newPoints
	end
	return control_points[1]
end

Module.LimitlessBezier = function(control_points)
	local newapi = {}
	newapi.points = control_points
	assert(typeof(control_points)=="table","Control points must be a table")
	for index, point in pairs(control_points) do
		assert(typeof(point)=="Vector3" or typeof(point)=="CFrame","Control Point table is populated with unsupported types, please check internal documentation")
		if typeof(point)=="Vector3" then
			newapi.points[index] = CFrame.new(point)
		end
	end
	
	newapi.SmoothTravel = function(Object,TweenSpeed,StepSpeed)
		assert(StepSpeed>=1 and StepSpeed<=100,"StepSpeed must be between 1 and 100")
		spawn(function()
			for point = 0,1,StepSpeed/100 do
				TweenService:Create(Object,TweenInfo.new(TweenSpeed,Enum.EasingStyle.Linear),{CFrame = it_bez(newapi.points,point)}):Play()
				wait(0.1)
			end
			Object.CFrame = newapi.points[#newapi.points]
		end)
	end
	
	newapi.Travel = function(Object,StepSpeed)
		assert(StepSpeed>=1 and StepSpeed<=100,"StepSpeed must be between 1 and 100")
		spawn(function()
			for point = 0,1,StepSpeed/100 do
				Object.CFrame = it_bez(newapi.points,point)
				wait(0.1)
			end
			Object.CFrame = newapi.points[#newapi.points]
		end)
	end
	
	return newapi
end

return Module
