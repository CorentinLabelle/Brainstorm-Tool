function ViewComponents(sFiles)
    for i = 1:length(sFiles)
        timeseries = view_timeseries(sFiles(i).FileName);
        panel_ssp_selection('OpenRaw');
        waitfor(msgbox("Click when you are done choosing. It will skip to the next study."));
        close(timeseries);
    end