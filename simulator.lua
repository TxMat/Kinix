-- Fission Reactor Simulator
-- PID Controller for Mekanism Fission Reactor
-- Author: Tx Mat
local CR = math.random(1, 100)
local TR = math.random(1, 100)


-- Constantes PID (vous pouvez ajuster ces valeurs)
local kp = 0.05  -- Terme proportionnel
local ki = 0.002 -- Terme intégral
local kd = 0.02 -- Terme dérivés
local deadband = 1.0 -- Plage d'erreur acceptable autour de la valeur cible

-- Variables
local targetReactivity = 100.0 -- Valeur cible d'efficacité
local integral = 0.0 -- Variable pour la composante intégrale
local lastError = 0.0 -- Variable pour stocker la dernière erreur

local sign = 1
local lastReactivity = 0.0
local currentReactivity = 0.0

function getCurrentReactivity()
    print("CR: " .. CR .. " TR: " .. TR)
    local efficiency = 100 - math.abs(CR - TR)
    return math.max(0, efficiency)
end


function addIncrement(inc)
    CR = CR + inc
    if CR < 0.0 then
       CR = 0.0
    end
    if CR > 100.0 then
       CR = 100.0
    end
end

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

-- Fonction de contrôle PID
function pidControl()
    lastReactivity = currentReactivity
    currentReactivity = getCurrentReactivity()
    local error = targetReactivity - currentReactivity -- Calcul de l'erreur
    -- if math.abs(error) > deadband then
        print(currentReactivity)

        -- Terme proportionnel
        local p = kp * error

        -- Terme intégral
        integral = integral + ki * error

        -- Terme dérivé
        local derivative = kd * (error - lastError)
        lastError = error

        -- Calcul de la commande totale
        local controlOutput = p + integral + derivative

        if currentReactivity < lastReactivity then
            sign = sign * -1
        end

        controlOutput = sign * controlOutput

        -- Utilisez la commande pour ajuster la Current Reactivity
        addIncrement(controlOutput)

        print("PID Control: " .. controlOutput .. " CR: " .. CR .. " TR: " .. TR .. " ER: " .. error .. " IR: " .. integral .. " DR: " .. derivative)

        -- Répétez le contrôle à intervalles réguliers
        sleep(1) -- Attendez 1 seconde avant la prochaine itération
    else
        TR = math.random(1, 100)
        local integral = 0.0 -- Variable pour la composante intégrale
        local lastError = 0.0 -- Variable pour stocker la dernière erreur

        local sign = 1
        local lastReactivity = 0.0
        local currentReactivity = 0.0
    end
end

-- Boucle de contrôle principale
while true do
    pidControl()
end
