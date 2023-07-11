

function myReturn = STEP8_plotERPs_byWindow(save_path,chan_of_interest,paradigm,baseline_min,baseline_max);
myReturn='';

data_path = [save_path,'\AfterStep7_BuildStudy\'];
fig_path = [save_path '\Figures\ERP_extracted\Group\']; mkdir(fig_path);

[STUDY ALLEEG] = pop_loadstudy('filename',[paradigm '_std.study'], 'filepath', data_path);

[STUDY, ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on','interp','on','recompute','on','erp','on','erpparams',{'rmbase',[baseline_min baseline_max] });
for chan_count = 1:length(chan_of_interest)

    chan = char(chan_of_interest(chan_count));
    std_erpplot(STUDY, ALLEEG, 'channels', {chan},'design', 1,'ylim',[-.1,.1]);

    % std_plotcurve(erptimes, erpdata,...
    %     'plotconditions','apart',...
    %     'plotgroups', 'apart',...
    %     'plotstderr', 'off',...
    %     'figure', 'on',...
    %     'legend','on',...
    %     'colors', {'r','b'});

    print([fig_path 'ERP_' chan], '-dpng' ,'-r300');

    close all
end