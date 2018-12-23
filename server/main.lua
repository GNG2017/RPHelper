Vehicles = {}
IDs = {}

RegisterServerEvent("storeVehicleDetails")
AddEventHandler("storeVehicleDetails", function(owner, plate, insured, flags)
    Vehicles[plate] = {owner = owner, plate = plate, insured = not not insured, flags = flags}
end)

RegisterServerEvent("storeIDDetails")
AddEventHandler("storeIDDetails", function(FirstName, LastName, DOB, Flags)
    IDs[FirstName .. " " .. LastName] = {FirstName = FirstName, LastName = LastName, DOB = DOB, Flags = Flags}
end)

RegisterCommand("vehcheck", function(source, args, raw)
    if #args < 1 then
        TriggerClientEvent("chat:addMessage", source, {args = {"^1SYSTEM^0:^8 Usage: /vehcheck <plate>"}})
        return
    end

    veh = Vehicles[string.lower(table.remove(args))]

    if veh == nil then
        TriggerClientEvent("chat:addMessage", source, {args = {"^8MDT^0: ^8Vehicle is not registered!" }})
        return
    end

    TriggerClientEvent("chat:addMessage", source, {
        multiline = true,
        args = {
            "^2MDT^0: Vehicles Details: \n" ..
            "^5Plate^0: " .. string.upper(veh.plate) .. "\n" ..
            "^4Owner^0: " .. veh.owner .. "\n" ..
            "^3Insured^0: " .. ((veh.insured) and "^2" or "^8") .. tostring(veh.insured) .. "\n" ..
            "^2Flags^0: " .. veh.flags
        }
    })
end, false)

RegisterCommand("idcheck", function(source, args, raw)
    if #args < 1 then
        TriggerClientEvent("chat:addMessage", source, {args = {"^1SYSTEM^0:^8 Usage: /idcheck <first name> <last name> [DOB]"}})
        return
    end

    FirstName = args[1]
    LastName = args[2]
    DOB = nil
    if #args > 2 then
        DOB = args[3]
    end

    NameMatches = 0

    ID = nil
    for k, p in pairs(IDs) do
        if LowerComparison(p.FirstName, FirstName) and LowerComparison(p.LastName, LastName) then
            if DOB ~= nil then
                if LowerComparison(DOB, p.DOB) then
                    ID = p
                else
                    NameMatches = NameMatches + 1
                end
            else
                ID = p
                break
            end
        end
    end

    if ID == nil then
        if NameMatches > 0 then
            TriggerClientEvent("chat:addMessage", source, {args = {"^1SYSTEM^0:^3 ID with this name and DOB not found," .. 
            " however there was " .. tostring(NameMatches) .. " name match(es), you may try searching without a DOB."}})
            return
        else
            TriggerClientEvent("chat:addMessage", source, {args = {"^1SYSTEM^0:^8 ID with this name and DOB not found!"}})
            return
        end
    end

    TriggerClientEvent("chat:addMessage", source, {
        multiline = true,
        args = {
            "^2SYSTEM^0: Person Details: \n" ..
            "^5Name^0: " .. ID.FirstName .. " " .. ID.LastName .. "\n" ..
            "^4DOB^0: " .. ID.DOB .. "\n" ..
            "^2Flags^0: " .. ID.Flags
        }
    })
end, false)


function LowerComparison(str1, str2)
    return string.lower(tostring(str1)) == string.lower(tostring(str2))
end