-- PID Controller for Mekanism Fission Reactor
-- Author: Tx Mat

-- Reactor
local r = peripheral.wrap("back")

-- PID Constants (you can adjust these values)
local kp = 0.2  -- Proportional term
local ki = 0.000 -- Integral term (no overshoot so no need for integral)
local kd = 0.08 -- Derivative term
local deadband = 0.01 -- Acceptable error range around target value

-- Variables
local targetEfficiency = 100.0 -- Target efficiency value
local integral = 0.0 -- Variable for integral component
local lastError = 0.0 -- Variable to store last error

local sign = 1 -- Variable to store sign of the correction
local lastEfficiency = 0.0 -- Variable to store last efficiency
local currentEfficiency = 0.0 -- Variable to store current efficiency

local allgood = false -- Variable to store if the reactor is stable

function getCurrentEfficiency()
    return r.getEfficiency()
end


function addIncrement(inc)
    return r.adjustReactivity(inc)
end

-- PID Control Function
function pidControl()
    lastEfficiency = currentEfficiency
    currentEfficiency = getCurrentEfficiency()
    local error = targetEfficiency - currentEfficiency -- Calculate error
    if math.abs(error) > deadband then

        if allgood then
            -- Reset PID variables
            integral = 0.0
            lastError = 0.0

            sign = 1
            lastEfficiency = 0.0
            currentEfficiency = getCurrentEfficiency()
            print("# Target Reactivity Changed !#")
            allgood = false
        end

        -- Proportional term calculation
        local p = kp * error

        -- Integral term calculation
        integral = integral + ki * error

        -- Derivative term calculation
        local derivative = kd * (error - lastError)
        lastError = error

        -- Calculate control output
        local controlOutput = p + integral + derivative

        if currentEfficiency < lastEfficiency then
            -- If efficiency is decreasing, reverse the sign of the correction
            sign = sign * -1
        end

        controlOutput = sign * controlOutput

        -- Add correction to the reactor
        addIncrement(controlOutput)

        print("PID Control: " .. controlOutput .. " ERR: " .. error .. " IR: " .. integral .. " DR: " .. derivative)
        print("Current Efficiency: " .. currentEfficiency)

        -- Repeat control at regular intervals
        os.sleep(5) -- 5 seconds (don't go any lower or you'll be rate limited)
    else
        if not allgood then
            print("# Current Reactivity Stabilized !#")
            allgood = true
        else
            os.sleep(1)
        end
    end
end

-- Main loop
while true do
    pidControl()
end
