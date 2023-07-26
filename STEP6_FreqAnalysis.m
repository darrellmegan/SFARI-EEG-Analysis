
function myReturn = STEP6_FreqAnalysis(save_path,subject_list,conditions,streams,epoch_min,epoch_max,chan_of_interest,...
    max_pwelch_freq,time_freq_frequencies_range,baseline_start,baseline_end,paradigm);
myReturn='';

%% ---------------------------------------------------------------------------------------------------
% STEP 6: Frequency Analysis

% plot FFT by individual (for channels of interest)
% plot FFT by group (for channels of interest)
% plot Welch freq by group (for channels of interest)
%---------------------------------------------------------------------------------------------------

% Path to the parent folder, which contains the data folders for all subjects
home_path  = [save_path '\AfterStep5_ERPAnalysis\'];
fig_path = [save_path '\Figures\Freq_analysis\']; mkdir(fig_path);
ind_fig_path = [fig_path '\Individual\']; mkdir(ind_fig_path);
group_fig_path = [fig_path '\Group\']; mkdir(group_fig_path);
mat_path = [save_path '\AfterStep6_Freq_analysis\']; mkdir(mat_path);


% for every channel
for chan_count = 1:length(chan_of_interest)
    
    % initialize group arrays
    concat_40_ASD = [];concat_27_ASD = [];
    concat_40_control = [];concat_27_control = [];
    power_27_log_control = []; power_40_log_control = [];
    power_27_log_ASD = []; power_40_log_ASD = [];


    chan = char(chan_of_interest(chan_count));

    % for every subject
    for s=1:length(subject_list)

        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        data_path  = [home_path subject_list{s} '\'];
        
        % for every condition
        for condition_count = 1:length(conditions)
            tmp_mat_path = [mat_path '\' char(streams(condition_count)) 'Hz\' chan '\']; mkdir(tmp_mat_path);
            tmp_mat_path_bands = [mat_path 'freq-bands\' char(streams(condition_count)) 'Hz\' chan '\']; mkdir(tmp_mat_path_bands);
            % separating epochs
            myFileName = [data_path subject_list{s} '_' char(streams(condition_count)) '_std.set'];
            % value of 2 indicates file exists at this location
            if exist(myFileName, 'file')==2
                EEG = pop_loadset('filename',[subject_list{s} '_' char(streams(condition_count)) '_std.set'], 'filepath', data_path);
                chan_loc = struct2table(EEG.chanlocs).labels;
                
                % if channel was not removed
                index = find(ismember(chan_loc,chan));
                if ~isempty(index)

                    chan_number = EEG.chanlocs(index).urchan;
                    % pwelch settings
                    Fs   = EEG.srate; % sampling rate, amount of samples per unit time

                    if strcmp(subject_list{s}(1:2),'10')
                        % patient is a control
                        if strcmp(char(streams(condition_count)),'40')
                            % add subject data to the group matrix for the 40 Hz condition
                            [power_40_subj(:,:),f] = plotPwelch(EEG.data(chan_number,:,:),[],[],max_pwelch_freq,Fs,subject_list{s},chan);
                            power_40_log_control(:,:,s)=10*log10(power_40_subj);
                            subj_power = power_40_subj(:,:);
                            concat_40_control = cat(3, concat_40_control, EEG.data(chan_number,:,:));%data for newtimef function (time freq)

                        else
                            % add subject data to the group matrix for the 27 Hz condition
                            [power_27_subj(:,:),f] = plotPwelch(EEG.data(chan_number,:,:),[],[],max_pwelch_freq,Fs,subject_list{s},chan);
                            power_27_log_control(:,:,s)=10*log10(power_27_subj);
                            subj_power = power_27_subj(:,:);
                            concat_27_control = cat(3, concat_27_control, EEG.data(chan_number,:,:));%data for newtimef function (time freq)
                        end
                    else
                        % patient is not a control
                        
                        if strcmp(char(streams(condition_count)),'40')
                            % add subject data to the group matrix for the 40 Hz condition
                            [power_40_subj(:,:),f] = plotPwelch(EEG.data(chan_number,:,:),[],[],max_pwelch_freq,Fs,subject_list{s},chan);
                            power_40_log_ASD(:,:,s)=10*log10(power_40_subj);
                            subj_power = power_40_subj(:,:);
                            concat_40_ASD = cat(3, concat_40_ASD, EEG.data(chan_number,:,:));%data for newtimef function (time freq)

                        else
                            % add subject data to the group matrix for the 27 Hz condition
                            [power_27_subj(:,:),f] = plotPwelch(EEG.data(chan_number,:,:),[],[],max_pwelch_freq,Fs,subject_list{s},chan);
                            power_27_log_ASD(:,:,s)=10*log10(power_27_subj);
                            subj_power = power_27_subj(:,:);
                            concat_27_ASD = cat(3, concat_27_ASD, EEG.data(chan_number,:,:));%data for newtimef function (time freq)
                        end
                    end
                    

                    % time-freq plots for individual (per chan, condition)
                    figure; [ersp,itc,powbaseCommon,times_mat,freqs_mat,erspboot,itcboot, tfdata] =pop_newtimef( EEG, ...
                        1, ...% 0 if use ICA data, 1 if raw
                        chan_number, ...
                        [epoch_min  epoch_max], ...
                        [3        13] , ...% cycles
                        'topovec', 1, 'elocs', EEG.chanlocs, ...
                        'chaninfo', EEG.chaninfo,...
                        'baseline',[baseline_start baseline_end], ...
                        'freqs', time_freq_frequencies_range,...
                        'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
                        'mcorrect', 'fdr',... %correcting for multiple comparisons
                        'pcontour', 'off',... % puts a contour around the plot for what is significant
                        'ntimesout', 400,... % amount of datapoints
                        'title', ['Subject: ' subject_list{s} ' (Channel ' chan ' at ' char(streams(condition_count)) 'Hz)']);

                    

                    % min_range = [0.5,4,8,13,30,22,35];
                    % max_range = [4,7,12,30,max_pwelch_freq,32,45];
                    % range_names = ["delta","theta","alpha","beta","gamma","twentysevenHz","fortyHz"];
                    min_range = [13,30,22,35];
                    max_range = [30,max_pwelch_freq,32,45];
                    range_names = ["beta","gamma","twentysevenHz","fortyHz"];

                    time_min_range = [-200,0,200,400,600];
                    time_max_range = [0,200,400,600,800];
                    
                    % for all of the frequency bands of interest
                    for myCount = 1:length(min_range)
                       
                        min_range_val = min_range(myCount);
                        max_range_val = max_range(myCount);
                        range_name = range_names(myCount);

                        % export subj matrix with the power feature for the
                        % entire epoch length (at bands of interest)
                        tmp_power_mat = vertcat(subj_power(find(f==min_range_val):find(f==max_range_val)),f(find(f==min_range_val):find(f==max_range_val)));
                        tmp_tmp_mat_path_bands = [tmp_mat_path_bands char(range_name) '\'];mkdir(tmp_tmp_mat_path_bands);
                        writematrix(tmp_power_mat,[tmp_tmp_mat_path_bands char(range_name) '_' subject_list{s} '_' chan '_' char(streams(condition_count)) 'Hz.txt'])
                

                        % for all of the time windows of interest
                        for time_count = 1:length(time_min_range)

                            min_time_val = time_min_range(time_count);
                            max_time_val = time_max_range(time_count);

                            [ d, min_ind ] = min( abs(freqs_mat-min_range_val) );
                            min_range_val = freqs_mat(min_ind);
                            [ d, max_ind ] = min( abs(freqs_mat-max_range_val) );
                            max_range_val = freqs_mat(max_ind);

                            [ d, min_time_ind ] = min( abs(times_mat-min_time_val) );
                            min_time_val = times_mat(min_time_ind);
                            [ d, max_time_ind ] = min( abs(times_mat-max_time_val) );
                            max_time_val = times_mat(max_time_ind);

                            % export subj matrix with the power feature for
                            % the time window of interest
                            tmp_power_time_mat = ersp(min_ind:max_ind,min_time_ind:max_time_ind);
                            tmp_tmp_mat_path_bands_time = [tmp_tmp_mat_path_bands 'time_window\' char(num2str(min_time_val)) '-' char(num2str(max_time_val)) '\'];mkdir(tmp_tmp_mat_path_bands_time);
                            writematrix(tmp_power_time_mat,[tmp_tmp_mat_path_bands_time char(range_name) '_' subject_list{s} '_' chan '_' char(streams(condition_count))...
                                '_' char(num2str(min_time_val)) '-' char(num2str(max_time_val)) ...
                                '_timewindow.txt'])
                        end

                    end


                    print([ind_fig_path 'freq-time_' chan '_' char(streams(condition_count)) 'Hz_std_' subject_list{s}], '-dpng' ,'-r300');
                    save([tmp_mat_path 'TFmatrix_' subject_list{s} '_' chan '_' char(streams(condition_count)) 'Hz.mat'], 'tfdata', 'times_mat', 'freqs_mat',  '-v7.3')

 
                    close all
                end

            end
        end

    end

    % after running through every subject for every condition, we want to
    % plot the grand average time-freq plots by group

    groups = {'ASD','control'};
    for grp_count =1:length(groups)
        myGrp = groups(grp_count);
        if strcmp(myGrp, 'ASD')
            power_40_log = power_40_log_ASD;
            power_27_log = power_27_log_ASD;
            concat_40 = concat_40_ASD;
            concat_27 = concat_27_ASD;
        else
            power_40_log = power_40_log_control;
            power_27_log = power_27_log_control;
            concat_40 = concat_40_control;
            concat_27 = concat_27_control;
        end


        % averaging the log of the power, so we can plot it
        grand_avg_log_40= mean(power_40_log(:,:,:),3);
        grand_avg_log_27= mean(power_27_log(:,:,:),3);

        % plot freq-power matrix for groups
        figure();

        colors = [0.5883    0.5229    0.7612];
        plot(f, grand_avg_log_40,'Color',colors,'LineWidth',2);
        hold on;
        colors = colors*0.5; %darker
        plot(f, grand_avg_log_27,'Color',colors,'LineWidth',2);

        title(['50 trials time-frequency conversion with Welch (' char(myGrp) ')']);
        xlabel('Frequency (Hz)');
        ylabel('Magnitude (dB)');
        set(gca,'fontsize', 8);
        ylim([-20 20]);
        legend('40 Hz','27 Hz');

        print([group_fig_path 'freq-time-WELCH_' char(myGrp) '_' chan], '-dpng' ,'-r300');
        close all
%% 


        % time frequency analysis for the 40 Hz condition
        figure; [ersp,itc,powbaseCommon,times_mat,freqs_mat,erspboot,itcboot, tfdata] = newtimef(concat_40(1,:,:), ...
            size(concat_27,2),...
            [epoch_min  epoch_max], ...
            Fs,...
            'cycles',[3 0.5] , ...% cycles
            'baseline',[baseline_start baseline_end], ...
            'freqs', time_freq_frequencies_range,...
            'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
            'mcorrect', 'fdr',... %correcting for multiple comparisons
            'pcontour', 'off',... % puts a contour around the plot for what is significant
            'ntimesout', 400,... % amount of datapoints
            'title', ['Time-freq analysis: ' char(myGrp) '(40 Hz - Channel ' chan ')']);%

        % for frequency bands of interest
        for myCount = 1:length(min_range)
            min_range_val = min_range(myCount);
            max_range_val = max_range(myCount);
            range_name = range_names(myCount);

            % for time windows of interest
            for time_count = 1:length(time_min_range)

                min_time_val = time_min_range(time_count);
                max_time_val = time_max_range(time_count);

                [ d, min_ind ] = min( abs(freqs_mat-min_range_val) );
                min_range_val = freqs_mat(min_ind);
                [ d, max_ind ] = min( abs(freqs_mat-max_range_val) );
                max_range_val = freqs_mat(max_ind);

                [ d, min_time_ind ] = min( abs(times_mat-min_time_val) );
                min_time_val = times_mat(min_time_ind);
                [ d, max_time_ind ] = min( abs(times_mat-max_time_val) );
                max_time_val = times_mat(max_time_ind);

                tmp_power_time_mat = ersp(min_ind:max_ind,min_time_ind:max_time_ind);
                
                % export group matrix for time windows & bands of interest for statistical analysis 
                tmp_mat_path_bands = [mat_path 'freq-bands\40Hz\' chan '\']; mkdir(tmp_mat_path_bands);
                tmp_tmp_mat_path_bands = [tmp_mat_path_bands char(range_name) '\group_time_window\'...
                    char(num2str(min_time_val)) '-' char(num2str(max_time_val)) '\'];mkdir(tmp_tmp_mat_path_bands);
                writematrix(tmp_power_time_mat,[tmp_tmp_mat_path_bands char(range_name) '_' char(myGrp) '_' chan '_40Hz_'...
                    char(num2str(min_time_val)) '-' char(num2str(max_time_val)) ...
                    '_timewindow.txt'])
            end

        end


        print([group_fig_path 'freq-time-analysis_40Hz_' char(myGrp) '_' chan], '-dpng' ,'-r300');
        close all

        % time frequency analysis for 27 Hz condition
        figure; [ersp,itc,powbaseCommon,times_mat,freqs_mat,erspboot,itcboot, tfdata] = newtimef(concat_27(1,:,:), ...
            size(concat_27,2),...
            [epoch_min  epoch_max], ...
            Fs,...
            'cycles',[3 0.5] , ...% cycles
            'baseline',[baseline_start baseline_end], ...
            'freqs', time_freq_frequencies_range,...
            'alpha', 0.05,...%If non-0, compute two-tailed permutation significance probability level. Show non-signif. output values as green.                            {default: 0}
            'mcorrect', 'fdr',... %correcting for multiple comparisons
            'pcontour', 'off',... % puts a contour around the plot for what is significant
            'ntimesout', 400,... % amount of datapoints
            'title', ['Time-freq analysis: ' char(myGrp) ' (27 Hz - Channel ' chan ')']);



        for myCount = 1:length(min_range)
            min_range_val = min_range(myCount);
            max_range_val = max_range(myCount);
            range_name = range_names(myCount);

            for time_count = 1:length(time_min_range)

                min_time_val = time_min_range(time_count);
                max_time_val = time_max_range(time_count);

                [ d, min_ind ] = min( abs(freqs_mat-min_range_val) );
                min_range_val = freqs_mat(min_ind);
                [ d, max_ind ] = min( abs(freqs_mat-max_range_val) );
                max_range_val = freqs_mat(max_ind);

                [ d, min_time_ind ] = min( abs(times_mat-min_time_val) );
                min_time_val = times_mat(min_time_ind);
                [ d, max_time_ind ] = min( abs(times_mat-max_time_val) );
                max_time_val = times_mat(max_time_ind);

                % export group matrix for time windows & bands of interest for statistical analysis
                tmp_mat_path_bands = [mat_path 'freq-bands\27Hz\' chan '\']; mkdir(tmp_mat_path_bands);
                tmp_tmp_mat_path_bands = [tmp_mat_path_bands char(range_name) '\group_time_window\'...
                    char(num2str(min_time_val)) '-' char(num2str(max_time_val)) '\'];mkdir(tmp_tmp_mat_path_bands);
                writematrix(tmp_power_time_mat,[tmp_tmp_mat_path_bands char(range_name) '_' char(myGrp) '_' chan '_27Hz_'...
                    char(num2str(min_time_val)) '-' char(num2str(max_time_val)) ...
                    '_timewindow.txt'])
            end

        end


        print([group_fig_path 'freq-time-analysis_27Hz_' char(myGrp) '_' chan], '-dpng' ,'-r300');
        close all
    end

end
