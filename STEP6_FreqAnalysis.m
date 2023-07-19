
function myReturn = STEP6_FreqAnalysis(save_path,subject_list,conditions,streams,epoch_min,epoch_max,chan_of_interest,...
    max_pwelch_freq,time_freq_frequencies_range,baseline_start,baseline_end);
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


%Loop through all subjects

for chan_count = 1:length(chan_of_interest)

    concat_40_ASD = [];concat_27_ASD = [];
    concat_40_control = [];concat_27_control = [];
    power_27_log_control = []; power_40_log_control = [];
    power_27_log_ASD = []; power_40_log_ASD = [];


    chan = char(chan_of_interest(chan_count));

    for s=1:length(subject_list)

        fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});
        data_path  = [home_path subject_list{s} '\'];

        for condition_count = 1:length(conditions)
            tmp_mat_path = [mat_path '\' char(streams(condition_count)) 'Hz\' chan '\']; mkdir(tmp_mat_path);
            tmp_mat_path_bands = [mat_path 'freq-bands\' char(streams(condition_count)) 'Hz\' chan '\']; mkdir(tmp_mat_path_bands);
            % separating epochs
            myFileName = [data_path subject_list{s} '_' char(streams(condition_count)) '_std.set'];
            % value of 2 indicates file exists at this location
            if exist(myFileName, 'file')==2
                EEG = pop_loadset('filename',[subject_list{s} '_' char(streams(condition_count)) '_std.set'], 'filepath', data_path);
                chan_loc = struct2table(EEG.chanlocs).labels;

                index = find(ismember(chan_loc,chan));
                if ~isempty(index)

                    chan_number = EEG.chanlocs(index).urchan;
                    % pwelch settings
                    Fs   = EEG.srate; % sampling rate, amount of samples per unit time

                    if strcmp(subject_list{s}(1:2),'10')
                        % patient is a control
                        if strcmp(char(streams(condition_count)),'40')
                            [power_40_subj(:,:),f] = plotPwelch(EEG.data(chan_number,:,:),[],[],max_pwelch_freq,Fs,subject_list{s},chan);
                            power_40_log_control(:,:,s)=10*log10(power_40_subj);
                            subj_power = power_40_subj(:,:);
                            concat_40_control = cat(3, concat_40_control, EEG.data(chan_number,:,:));%data for newtimef function (time freq)

                        else


                            [power_27_subj(:,:),f] = plotPwelch(EEG.data(chan_number,:,:),[],[],max_pwelch_freq,Fs,subject_list{s},chan);
                            power_27_log_control(:,:,s)=10*log10(power_27_subj);
                            subj_power = power_27_subj(:,:);
                            concat_27_control = cat(3, concat_27_control, EEG.data(chan_number,:,:));%data for newtimef function (time freq)
                        end
                    else
                        if strcmp(char(streams(condition_count)),'40')
                            [power_40_subj(:,:),f] = plotPwelch(EEG.data(chan_number,:,:),[],[],max_pwelch_freq,Fs,subject_list{s},chan);
                            power_40_log_ASD(:,:,s)=10*log10(power_40_subj);
                            subj_power = power_40_subj(:,:);
                            concat_40_ASD = cat(3, concat_40_ASD, EEG.data(chan_number,:,:));%data for newtimef function (time freq)

                        else
                            [power_27_subj(:,:),f] = plotPwelch(EEG.data(chan_number,:,:),[],[],max_pwelch_freq,Fs,subject_list{s},chan);
                            power_27_log_ASD(:,:,s)=10*log10(power_27_subj);
                            subj_power = power_27_subj(:,:);
                            concat_27_ASD = cat(3, concat_27_ASD, EEG.data(chan_number,:,:));%data for newtimef function (time freq)
                        end
                    end
                    
                    delta = vertcat(subj_power(find(f==0.5):find(f==4)),f(find(f==0.5):find(f==4)));
                    theta = vertcat(subj_power(find(f==4):find(f==7)),f(find(f==4):find(f==7)));
                    alpha = vertcat(subj_power(find(f==8):find(f==12)),f(find(f==8):find(f==12)));
                    beta = vertcat(subj_power(find(f==13):find(f==30)),f(find(f==13):find(f==30)));
                    gamma = vertcat(subj_power(find(f==30):find(f==max_pwelch_freq)),f(find(f==30):find(f==max_pwelch_freq)));
                    
                    tmp_tmp_mat_path_bands = [tmp_mat_path_bands '\delta\'];mkdir(tmp_tmp_mat_path_bands);
                    writematrix(delta,[tmp_tmp_mat_path_bands 'delta_' subject_list{s} '_' chan '_' char(streams(condition_count)) 'Hz.txt'])
                    tmp_tmp_mat_path_bands = [tmp_mat_path_bands '\theta\'];mkdir(tmp_tmp_mat_path_bands);
                    writematrix(theta,[tmp_tmp_mat_path_bands 'theta_' subject_list{s} '_' chan '_' char(streams(condition_count)) 'Hz.txt'])
                    tmp_tmp_mat_path_bands = [tmp_mat_path_bands '\alpha\'];mkdir(tmp_tmp_mat_path_bands);
                    writematrix(alpha,[tmp_tmp_mat_path_bands 'alpha_' subject_list{s} '_' chan '_' char(streams(condition_count)) 'Hz.txt'])
                    tmp_tmp_mat_path_bands = [tmp_mat_path_bands '\beta\'];mkdir(tmp_tmp_mat_path_bands);
                    writematrix(beta,[tmp_tmp_mat_path_bands 'beta_' subject_list{s} '_' chan '_' char(streams(condition_count)) 'Hz.txt'])
                    tmp_tmp_mat_path_bands = [tmp_mat_path_bands '\gamma\'];mkdir(tmp_tmp_mat_path_bands);
                    writematrix(gamma,[tmp_tmp_mat_path_bands 'gamma_' subject_list{s} '_' chan '_' char(streams(condition_count)) 'Hz.txt'])

                    figure; [ersp,itc,powbaseCommon,times,freqs,erspboot,itcboot, tfdata] =pop_newtimef( EEG, ...
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

                    print([ind_fig_path 'freq-time_' chan '_' char(streams(condition_count)) 'Hz_std_' subject_list{s}], '-dpng' ,'-r300');
                    save([tmp_mat_path 'TFmatrix_' subject_list{s} '_' chan '_' char(streams(condition_count)) 'Hz.mat'], 'tfdata', 'times', 'freqs',  '-v7.3')

 
                    close all
                end

            end
        end

    end

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

        % ploting like SB's but using pwelch as previously setup
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


        % time frequency analysis
        figure; newtimef(concat_40(1,:,:), ...
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

        print([group_fig_path 'freq-time-analysis_40Hz_' char(myGrp) '_' chan], '-dpng' ,'-r300');
        close all
%% 

        % time frequency analysis
        figure; newtimef(concat_27(1,:,:), ...
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

        print([group_fig_path 'freq-time-analysis_27Hz_' char(myGrp) '_' chan], '-dpng' ,'-r300');
        close all
    end

end
