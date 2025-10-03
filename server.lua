local VORP =  exports.vorp_core:GetCore()

RegisterCommand(Config.StaffCommand, function(source, args, rawCommand)
    local _source = source 
    local targetSource = tonumber(args[1]) 
    local jobName = args[2]
    local rank = tonumber(args[3]) 

    local Character = VORP.getUser(_source).getUsedCharacter
    local group = Character.group

    if group ~= "admin" then
        TriggerClientEvent("vorp:TipRight", _source, "Você não tem permissão para usar este comando.", 5000)
        return
    end

    if not targetSource or not jobName or not rank then
        TriggerClientEvent("vorp:TipRight", _source, "Uso correto: /addmultijob [player_id] [emprego] [rank]", 5000)
        return
    end

    local TargetCharacter = VORP.getUser(targetSource).getUsedCharacter
    if not TargetCharacter then
        TriggerClientEvent("vorp:TipRight", _source, "Jogador não encontrado.", 5000)
        return
    end

    local identifier = TargetCharacter.charIdentifier 

    exports['oxmysql']:execute("SELECT COUNT(*) AS jobCount FROM multijobs WHERE identifier = ?", {identifier}, function(result)
        local jobCount = result[1] and result[1].jobCount or 0  

        if jobCount >= Config.MaxJobs then
            TriggerClientEvent("vorp:TipRight", _source, "Este jogador já possui o máximo de " .. Config.MaxJobs .. " empregos.", 5000)
        else
            exports['oxmysql']:execute("INSERT INTO multijobs (identifier, job_name, rank) VALUES (?, ?, ?)",
            {identifier, jobName, rank}, function(insertResult)
                if insertResult and type(insertResult) == 'table' then
                    local rowsChanged = insertResult.affectedRows or 0 
                    if rowsChanged > 0 then
                        TriggerClientEvent("vorp:TipRight", _source, "Emprego adicionado com sucesso ao jogador ID " .. targetSource .. "!", 5000)
                        TriggerClientEvent("vorp:TipRight", targetSource, "Um novo emprego foi adicionado para você: " .. jobName, 5000)
                    else
                        TriggerClientEvent("vorp:TipRight", _source, "Erro ao adicionar emprego.", 5000)
                    end
                else
                    TriggerClientEvent("vorp:TipRight", _source, "Erro ao adicionar emprego.", 5000)
                end
            end)
        end
    end)
end, true)


RegisterCommand(Config.StaffCommandRemove, function(source, args, rawCommand)
    local _source = source
    local Character = VORP.getUser(_source).getUsedCharacter
    local identifier = args[1] or Character.charIdentifier
    local jobName = args[2] 

    local group = Character.group 

    if group ~= "admin" then
        TriggerClientEvent("vorp:TipRight", _source, "Você não tem permissão para usar este comando.", 5000)
        return
    end

    if not jobName then
        TriggerClientEvent("vorp:TipRight", _source, "Uso correto: /removemultijob [ID FIXO] [emprego]", 5000)
        return
    end


    exports['oxmysql']:execute("DELETE FROM multijobs WHERE identifier = ? AND job_name = ?", {identifier, jobName}, function(result)
        if result and type(result) == 'table' then
            local rowsChanged = result.affectedRows or 0 
            if rowsChanged > 0 then
                TriggerClientEvent("vorp:TipRight", _source, "Emprego removido com sucesso!", 5000)
                print(("[LOG] Emprego removido: %s para RG: %s"):format(jobName, identifier))
            else
                TriggerClientEvent("vorp:TipRight", _source, "Emprego não encontrado.", 5000)
            end
        else
            TriggerClientEvent("vorp:TipRight", _source, "Erro ao remover o emprego.", 5000)
        end
    end)
end, true)

RegisterNetEvent("multijob:getJobs")
AddEventHandler("multijob:getJobs", function()
    local _source = source
    local Character = VORP.getUser(_source).getUsedCharacter
    local identifier = Character.charIdentifier
    

    exports['oxmysql']:execute("SELECT job_name, rank FROM multijobs WHERE identifier = ?", {identifier}, function(result)
        if result and #result > 0 then
            TriggerClientEvent("multijob:receiveJobs", _source, result) 
        else
            TriggerClientEvent("multijob:receiveJobs", _source, {}) 
        end
    end)
end)

RegisterServerEvent("multijob:setJob")
AddEventHandler("multijob:setJob", function(jobName, rank)
    local _source = source
    local User = VORP.getUser(_source)
    local Character = User.getUsedCharacter

    if jobName and rank then
        Character.setJob(jobName, false)      -- só o job
        Character.setJobGrade(rank, false)    -- o rank/grade
        Character.setJobLabel(jobName)        -- label = nome do job

        TriggerClientEvent("vorp:TipBottom", _source, "Emprego definido como: " .. jobName .. " (Rank: " .. rank .. ")", 5000)
    else
        TriggerClientEvent("vorp:TipRight", _source, "Erro ao definir o emprego.", 5000)
    end
end)

