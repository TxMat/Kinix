-- PID Controller for Mekanism Fission Reactor
-- Author: Tx Mat

-- Reactor
local r = peripheral.wrap("back")

-- Constantes PID (vous pouvez ajuster ces valeurs)
local kp = 0.05  -- Terme proportionnel
local ki = 0.002 -- Terme intégral
local kd = 0.02 -- Terme dérivés
local deadband = 1.0 -- Plage d'erreur acceptable autour de la valeur cible

-- Variables
local targetEfficiency = 100.0 -- Valeur cible d'efficacité
local integral = 0.0 -- Variable pour la composante intégrale
local lastError = 0.0 -- Variable pour stocker la dernière erreur

local sign = 1
local lastEfficiency = 0.0
local currentEfficiency = 0.0

local allgood = false

function getCurrentEfficiency()
    return r.getEfficiency()
end


function addIncrement(inc)
    return r.adjustReactivity(inc)
end

-- Fonction de contrôle PID
function pidControl()
    lastEfficiency = currentEfficiency
    currentEfficiency = getCurrentEfficiency()
    local error = targetEfficiency - currentEfficiency -- Calcul de l'erreur
    if math.abs(error) > deadband then

        if allgood then
            integral = 0.0 -- Variable pour la composante intégrale
            lastError = 0.0 -- Variable pour stocker la dernière erreur

            sign = 1
            lastEfficiency = 0.0
            currentEfficiency = 0.0
            print("# Target Reactivity Changed !#")
            allgood = false
        end

        -- Terme proportionnel
        local p = kp * error

        -- Terme intégral
        integral = integral + ki * error

        -- Terme dérivé
        local derivative = kd * (error - lastError)
        lastError = error

        -- Calcul de la commande totale
        local controlOutput = p + integral + derivative

        if currentEfficiency < lastEfficiency then
            sign = sign * -1
        end

        controlOutput = sign * controlOutput

        -- Utilisez la commande pour ajuster la Current Reactivity
        addIncrement(controlOutput)

        print("PID Control: " .. controlOutput .. " ERR: " .. error .. " IR: " .. integral .. " DR: " .. derivative)
        print("Current Efficiency: " .. currentEfficiency)

        -- Répétez le contrôle à intervalles réguliers
        os.sleep(5) -- 5 secondes
    else
        if not allgood then
            print("# Current Reactivity Stabilized !#")
            allgood = true
        else
            os.sleep(1)
        end
    end
end

-- Boucle de contrôle principale
while true do
    pidControl()
end
