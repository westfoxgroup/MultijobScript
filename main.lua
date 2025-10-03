local Menu = exports.vorp_menu:GetMenuData() 


RegisterCommand(Config.MultiJobCommand, function()
    TriggerServerEvent("multijob:getJobs")
end)


RegisterNetEvent("multijob:receiveJobs")
AddEventHandler("multijob:receiveJobs", function(jobs)

    Menu.CloseAll()

    local MenuElements = {}

    if jobs and #jobs > 0 then
        for _, job in ipairs(jobs) do
            table.insert(MenuElements, {
                label = job.job_name .. " - Rank " .. job.rank,
                value = { job_name = job.job_name, rank = job.rank },
                desc = "Definir este emprego como ativo"
            })
        end
    else
        table.insert(MenuElements, {
            label = "Nenhum emprego disponível",
            value = "close",
            desc = "Nenhum emprego registrado"
        })
    end

    table.insert(MenuElements, {
        label = "Fechar",
        value = "close",
        desc = "Fechar o menu"
    })


    Menu.Open("default", GetCurrentResourceName(), "multijob_menu", {
        title = Config.MenuTitle,
        subtext = "Selecione o emprego que deseja ativar",
        align = "top-left",
        elements = MenuElements
    }, function(data, menu)

        if data.current.value == "close" then
            menu.close()
        else
            local selectedJob = data.current.value

            TriggerServerEvent("multijob:setJob", selectedJob.job_name, selectedJob.rank)
            TriggerEvent("vorp:TipBottom", "Emprego definido como: " .. selectedJob.job_name, 5000)
            TriggerServerEvent("syn_society:checkjob")
            menu.close()
        end
    end, function(data, menu)

        menu.close()
        
    end)
end)
