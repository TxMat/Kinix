-- Fission Reactor Simulator
-- PID Controller for Mekanism Fission Reactor
-- Author: Tx Mat
local CR = math.random(1, 100)
local TR = math.random(1, 100)


-- Constantes PID (vous pouvez ajuster ces valeurs)
local kp = 0.2  -- Terme proportionnel
local ki = 0.000 -- Terme intégral
local kd = 0.08 -- Terme dérivé
local deadband = 0.01 -- Plage d'erreur acceptable autour de la valeur cible

-- Variables
local targetEfficiency = 100.0 -- Valeur cible d'efficacité
local integral = 0.0 -- Variable pour la composante intégrale
local lastError = 0.0 -- Variable pour stocker la dernière erreur

local sign = 1
local lastEfficiency = 0.0
local currentEfficiency = 0.0

local allgood = false

function getcurrentEfficiency()
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
    lastEfficiency = currentEfficiency
    currentEfficiency = getcurrentEfficiency()
    local error = targetEfficiency - currentEfficiency -- Calcul de l'erreur
    if math.abs(error) > deadband then

        if allgood then
            integral = 0.0 -- Variable pour la composante intégrale
            lastError = 0.0 -- Variable pour stocker la dernière erreur

            sign = 1
            currentEfficiency = getcurrentEfficiency()
            lastEfficiency = 0.0
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
        print("##############################################")

        -- Répétez le contrôle à intervalles réguliers
        sleep(1) -- 1 seconde
    else
        if not allgood then
            print("# Current Reactivity Stabilized !#")
            allgood = true
            sleep(2)
            TR = math.random(1, 100)
        else
            sleep(1)
        end
    end
end

-- Boucle de contrôle principale
while true do
    pidControl()
end
