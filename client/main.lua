RegisterCommand("veh", function(source, args, raw)
    if #args < 4 then
        TriggerEvent("chat:addMessage", {args = {"^1SERVER^0:^8 Usage: /veh <owner first name> <owner last name> <plate> <insured> [any other flags]"}})
        return
    end
    owner = args[1] .. " " .. args[2]
    plate = string.lower(args[3]) -- get the plate from the command
    if #plate > 9 then -- the GTA license plate only can display 9 chars
        TriggerEvent("chat:addMessage", {args = {"^1SERVER^0:^3 The vehicle plate must be less than 9 chars!"}})
        return
    end
    insured = string.lower(args[4]) -- get the insured state from the plate
    insured = (insured == "1" or insured == "yes" or insured == "true") and true or false -- convert to boolean
    flags = ""
    if #args > 4 then -- if there is flags gived with the command
        for i=5, #args, 1 do
            flags = flags .. args[i] .. ","
        end
        flags = flags:sub(1, #flags - 1):gsub(",,", ",")
    end

    TriggerServerEvent("storeVehicleDetails", owner, plate, insured, flags)

    if IsPedInAnyVehicle(PlayerPedId(), true) then
        vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
        SetVehicleNumberPlateText(vehicle, plate)
    end

    TriggerEvent("chat:addMessage", {
        multiline = true,
        args = {
            "^2MDT^0: Vehicle registered with details: \n" ..
            "^5Plate^0: " .. string.upper(plate) .. "\n" ..
            "^4Owner^0: " .. owner .. "\n" ..
            "^3Insured^0: " .. ((insured) and "^2" or "^8") .. tostring(insured) .. "\n" ..
            "^2Flags^0: " .. flags
        }
    })
end, false)

RegisterCommand("id", function(source, args, raw)
    if #args < 3 then
        TriggerEvent("chat:addMessage", {args = {"^1SERVER^0:^8 Usage: /id <first name> <last name> <DOB> [any other flags]"}})
        return
    end

    FirstName = args[1]
    LastName = args[2]
    DOB = args[3]
    Flags = ""
    if #args > 3 then
        for i=4, #args, 1 do
            Flags = Flags .. args[i] .. ","
        end
        Flags = Flags:sub(1, #Flags - 1):gsub(",,", ",")
    end

    TriggerServerEvent("storeIDDetails", FirstName, LastName, DOB, Flags)

    TriggerEvent("chat:addMessage", {
        multiline = true,
        args = {
            "^2SYSTEM^0: Person registered with details: \n" ..
            "^5Name^0: " .. FirstName .. " " .. LastName .. "\n" ..
            "^4DOB^0: " .. DOB .. "\n" ..
            "^2Flags^0: " .. Flags
        }
    })
end, false)

Citizen.CreateThread(function()
    TriggerEvent("chat:addSuggestion", "/veh", "Register your vehicle", {
        {name = "First Name", help = "Your character's first name"},
        {name = "Last Name", help = "Your character's last name"},
        {name = "Plate", help = "Your vehicle's plate. Max 9 character!"},
        {name = "Insured Status", help = "Your vehicle's insured status. Use Yes or No"},
        {name = "Vehicle Flags", help = "Any other flags on your vehicle"}
    })
    TriggerEvent("chat:addSuggestion", "/vehcheck", "Check a license plate", {
        {name = "Plate", help = "Plate to be checked"}
    })
    TriggerEvent("chat:addSuggestion", "/id", "Register your character", {
        {name = "First Name", help = "Your character's first name"},
        {name = "Last Name", help = "Your character's last name"},
        {name = "DOB", help = "Your character's DOB"},
        {name = "Flags", help = "Any other flags on your character"}
    })
    TriggerEvent("chat:addSuggestion", "/idcheck", "Check a name", {
        {name = "First Name", help = "First name of the person"},
        {name = "Last Name", help = "Last name of the person"},
        {name = "DOB", help = "DOB of the person (not required)"},
    })
    Citizen.Trace("RPHelper script made by @GNG2017")
end)

