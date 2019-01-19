Vehicles = {}
IDs = {}

function Load()
    if GlobalConfig.DatabaseType == "File" then
        local IDsFile = LoadResourceFile(GetCurrentResourceName(), "./IDs.json")
        local VehiclesFile = LoadResourceFile(GetCurrentResourceName(), "./Vehicles.json")
        IDs = IDsFile and json.decode(IDsFile) or {}
        Vehicles = VehiclesFile and json.decode(VehiclesFile) or {}
        Citizen.CreateThread(AutoSave)
    end
end

function AutoSave()
    while true do
        Citizen.Wait(GlobalConfig.AutosaveTime * 1000)
        SaveResourceFile(GetCurrentResourceName(), "./IDs.json", json.encode(IDs))
        SaveResourceFile(GetCurrentResourceName(), "./Vehicles.json", json.encode(Vehicles))
        if GlobalConfig.AnounceSaveConsole then Citizen.Trace("RPHelper saved!\n") end
    end
end

Citizen.CreateThread(Load)

RegisterServerEvent("storeVehicleDetails")
AddEventHandler("storeVehicleDetails", function(owner, plate, insured, flags)
    if GlobalConfig.UseDatabase and GlobalConfig.DatabaseType == "MySQL" then
        MySQL.Async.execute("INSERT INTO `Vehicles` (`Plate`, `Owner`, `Insured`, `Flags`) VALUES (@Plate, @Owner, @Insured, @Flags) " ..
            "ON DUPLICATE KEY UPDATE `Owner` = @Owner, `Insured` = @Insured, `Flags` = @Flags", {
                ["@Owner"] = owner,
                ["@Plate"] = plate,
                ["@Insured"] = insured and 1 or 0,
                ["@Flags"] = flags
            }, function() end)
    else
        Vehicles[plate] = {Owner = owner, Plate = plate, Insured = not not insured, Flags = flags}
    end
end)

RegisterServerEvent("storeIDDetails")
AddEventHandler("storeIDDetails", function(FirstName, LastName, DOB, Flags)
    if GlobalConfig.UseDatabase and GlobalConfig.DatabaseType == "MySQL" then
        MySQL.Async.execute("INSERT INTO `IDs` (`FirstName`, `LastName`, `DOB`, `Flags`) VALUES (@FirstName, @LastName, @DOB, @Flags) " ..
            "ON DUPLICATE KEY UPDATE `FirstName` = @FirstName, `LastName` = @LastName, `DOB` = @DOB, `Flags` = @Flags", {
                ["@FirstName"] = FirstName,
                ["@LastName"] = LastName,
                ["@DOB"] = DOB,
                ["@Flags"] = Flags
            }, function() end)
    else
        IDs[FirstName .. " " .. LastName] = {FirstName = FirstName, LastName = LastName, DOB = DOB, Flags = Flags}
    end
end)

function GetVehicles(cb)
    if GlobalConfig.UseDatabase and GlobalConfig.DatabaseType == "MySQL" then
        CB = cb
        MySQL.Async.fetchAll("SELECT * FROM `Vehicles`", {}, function(result)
            local VehList = {}
            for k, p in pairs(result) do
                VehList[p.Plate] = {Owner = p.Owner, Plate = p.Plate, Insured = (tonumber(p.Insured) == 1) and true or false, Flags = p.Flags}
            end
            CB(VehList)
        end)
    else
        cb(Vehicles)
    end
end

function GetIds(cb)
    if GlobalConfig.UseDatabase and GlobalConfig.DatabaseType == "MySQL" then
        CB = cb
        MySQL.Async.fetchAll("SELECT * FROM `IDs`", {}, function(result)
            local IDList = {}
            for k, p in pairs(result) do
                IDList[p.FirstName .. " " .. p.LastName] = {FirstName = p.FirstName, LastName = p.LastName, DOB = p.DOB, Flags = p.Flags}
            end
            CB(IDList)
        end)
    else
        cb(IDs)
    end
end

RegisterCommand("vehcheck", function(source, args, raw)
    if #args < 1 then
        TriggerClientEvent("chat:addMessage", source, {args = {"^1SYSTEM^0:^8 Usage: /vehcheck <plate>"}})
        return
    end
    
    GetVehicles(function(VehList)
        veh = VehList[string.lower(args[1])]
        
        if veh == nil then
            TriggerClientEvent("chat:addMessage", source, {args = {"^8MDT^0: ^8Vehicle is not registered!"}})
            return
        end
        
        TriggerClientEvent("chat:addMessage", source, {
            multiline = true,
            args = {
                "^2MDT^0: Vehicles Details: \n" ..
                "^5Plate^0: " .. string.upper(veh.Plate) .. "\n" ..
                "^4Owner^0: " .. veh.Owner .. "\n" ..
                "^3Insured^0: " .. ((veh.Insured) and "^2" or "^8") .. tostring(veh.Insured) .. "\n" ..
                "^2Flags^0: " .. veh.Flags
            }
        })
    end)
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
    
    GetIds(function(IDList)
        NameMatches = 0
        
        ID = nil
        for k, p in pairs(IDList) do
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
    end)
end, false)


function LowerComparison(str1, str2)
    return string.lower(tostring(str1)) == string.lower(tostring(str2))
end
