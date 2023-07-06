
function myReturn = STEP5_ERPanalysis_plotChannelsbyIndividual(save_path,subject_list,conditions,streams,epoch_min,epoch_max,chan_of_interest);
myReturn='';

% ---------------------------------------------------------------------------------------------------
% STEP 5: plot avg ERPs per participant (for channels of interest)
%---------------------------------------------------------------------------------------------------

% Path to the parent folder, which contains the data folders for all subjects
home_path  = [save_path '\AfterStep5_ERPAnalysis\'];
fig_path = [save_path '\Figures\ERP_analysis\']; mkdir(fig_path);
ind_fig_path = [fig_path '\Individual\']; mkdir(ind_fig_path);

%Loop through all subjects
for s=1:length(subject_list)

    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
    data_path  = [home_path subject_list{s} '\'];

    for count = 1:length(conditions)
        % separating epochs
        myFileName = [data_path subject_list{s} '_' char(streams(count)) '_std.set'];
        % value of 2 indicates file exists at this location
        if exist(myFileName, 'file')==2
            EEG = pop_loadset('filename',[subject_list{s} '_' char(streams(count)) '_std.set'], 'filepath', data_path);
            for chan_count = 1:length(chan_of_interest)
                
                chan = char(chan_of_interest(chan_count));
                chan_loc = struct2table(EEG.chanlocs).labels;
                
                index = find(ismember(chan_loc,chan));
                if ~isempty(index)

                    chan_number = EEG.chanlocs(index).urchan;

                    myChan=EEG.data(chan_number,:,:);
                    avg_ofchan = mean(myChan,3);

                    time_ms = epoch_min:(epoch_max-epoch_min)/length(avg_ofchan):epoch_max-(epoch_max-epoch_min)/length(avg_ofchan);
                    avg_ofchan=vertcat(avg_ofchan,time_ms);
                    x_time=avg_ofchan(2,:);
                    y_amp=avg_ofchan(1,:);

                    plot(x_time,y_amp);title([chan ' Average ERP for Subject: ' subject_list{s}]); xline(0,'--k');
                    print([ind_fig_path 'ERPs_' chan '_' char(streams(count)) 'Hz_std_' subject_list{s}], '-dpng' ,'-r300');
                    close all
                end
                
                % PLOT average ERPs of all channels for each individual subject
                %pop_timtopo(EEG, [epoch_min+20 epoch_max-20], [ERP_top_ref], 'ERP data and scalp maps of BDF file resampled pruned with ICA');
                %print([ind_fig_path 'ERPs_allchannels_' char(streams(count)) 'Hz_std_' subject_list{s}], '-dpng' ,'-r300');
                %close all

            end
        end

    end
end

