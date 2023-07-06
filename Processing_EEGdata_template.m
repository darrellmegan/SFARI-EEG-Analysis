% -------------------------------------------------------------------------
% Name: Megan Darrell
% Email: megan.darrell@einsteinmed.edu
% Last Updated: 06/23/2023
% -------------------------------------------------------------------------

%---------------------------------------------------------------------------------------------------
% TO DO BEFORE RUNNING
%---------------------------------------------------------------------------------------------------
% NEED ERPLAB PLUGIN: download erplab from github & move to eeglab > plugins folder
% NEED STATS & ML ADD-ON: Home > Add-Ons > Statistics & Machine Learning
% NEED SIGNAL PROCESSING ADD-ON: Home > Add-Ons > Signal Processing
% Add binlist.txt file to your paradigm folder
% Save the following to scripts folder:
    %   set_variables.m
    %   define_subjects.m
    %   STEP1_2_Merge_RejectChan.m
    %   plotPwelch.m
    %   pop_timtopo.m 


% Manually edit the following three lines to define your file paths
my_data_path= '\\data2.einsteinmed.edu\home\cnl-interns-lab\';
my_eeglab_path = 'C:\Program Files\MATLAB\R2023a\toolbox\shared\eeglab_current\eeglab2023.0';
my_scripts_path =  '\\data2.einsteinmed.edu\home\cnl-interns-lab\Interns\darrellm\EEG Processing\SFARI\Scripts';

% Start eeglab
cd(my_eeglab_path);  addpath(my_eeglab_path);  eeglab;

% Add scripts to your path
addpath(my_scripts_path); cd(my_scripts_path);

% Upload table with variable values for each paradigm
filename = [my_scripts_path '\variables_per_paradigm.xlsx'];
opts = detectImportOptions(filename);
opts = setvartype(opts,'char');  % or 'string'
myVar_tab = readtable(filename,opts);

paradigm_loop = {'ASSR_oddball'};
for n=1:length(paradigm_loop)
    
    paradigm = char(paradigm_loop(n));

    %% ---------------------------------------------------------------------------------------------------
    % SET VARIABLES!
    %---------------------------------------------------------------------------------------------------
    
    [load_path,save_path,binlist_location,pts_to_exclude,rem_intervals,downsampling_rate,...
        high_pass_filter,low_pass_filter,rem_channels_manually,channels_to_rem,rej_high_SD,...
        rej_low_SD,refchan_bin,refchan,volt_thresh,buffer,epoch_min,epoch_max,baseline_min,baseline_max,...
        n_bins,max_pwelch_freq,time_freq_frequencies_range,stream1,stream2,streams,conditions,...
        highpass_filter_stream2,lowpass_filter_stream2,highpass_filter_stream1,lowpass_filter_stream1,...
        trials_num_reduced,ERP_top_ref,pwelch_epoch_start,pwelch_epoch_end,chan_of_interest,grp_controls,baseline_start,baseline_end] = set_variables( paradigm, my_data_path, myVar_tab);
    

    %% ---------------------------------------------------------------------------------------------------
    % DEFINE SUBJECTS
    %---------------------------------------------------------------------------------------------------

    subject_list = define_subjects(load_path,pts_to_exclude);
    grp_ASD = setdiff(subject_list, grp_controls);

    %% ---------------------------------------------------------------------------------------------------
    % STEP 1: Set channel locations & merge datasets (if >1 bdf file)
    % STEP 2: Automatically reject channel locations
    %---------------------------------------------------------------------------------------------------

    STEP1_2_Merge_RejectChan(subject_list,load_path,save_path,rem_intervals,...
        high_pass_filter,low_pass_filter,rem_channels_manually,channels_to_rem,downsampling_rate,rej_low_SD,rej_high_SD);

    %% ---------------------------------------------------------------------------------------------------
    % STEP 3: ICA (runica)
    %---------------------------------------------------------------------------------------------------
    
    STEP3_ICA(save_path,subject_list,paradigm,refchan);
   
    %% ---------------------------------------------------------------------------------------------------
    % STEP 4: Delete noisy epochs, create ERPs, record how much data was
    % deleted
    %---------------------------------------------------------------------------------------------------

    STEP4_EPOCHING(save_path,subject_list,paradigm,epoch_min,epoch_max,baseline_min,baseline_max,...
        n_bins,binlist_location,volt_thresh);

    %% ---------------------------------------------------------------------------------------------------
    % STEP 5: Analysis of ERPs

    % plot avg ERPs between groups (for channels of interest)
    %---------------------------------------------------------------------------------------------------

    % create EEGLAB structures with epochs of one type
    % reduce # of trials to be same for everyone (by randomly deleting)
    STEP5_ERPanalysis_createERPdatasets(save_path,subject_list,paradigm,volt_thresh,conditions,...
        trials_num_reduced,streams);

    % make txt files required to plot avg ERPs per group (for channels of interest)
    STEP5_ERPanalysis_make_groupERP_matrix(save_path,grp_controls,grp_ASD,...
        streams,conditions,chan_of_interest,epoch_min,epoch_max,downsampling_rate);
    
    % plot avg ERPs per group (for channels of interest)
    plotInd = 1;
    STEP5_ERPanalysis_plotChannelsbyGroup(save_path,epoch_min,epoch_max,plotInd);

    % plot avg ERPs per participant (for channels of interest)
    STEP5_ERPanalysis_plotChannelsbyIndividual(save_path,subject_list,conditions,streams,epoch_min,epoch_max,chan_of_interest);


    %% ---------------------------------------------------------------------------------------------------
    % STEP 6: Frequency Analysis
    
    % plot FFT by individual (for channels of interest)
    % plot FFT by group (for channels of interest)
    % plot Welch freq by group (for channels of interest)
    %---------------------------------------------------------------------------------------------------

    STEP6_FreqAnalysis_plotChannelsbyIndividual(save_path,subject_list,conditions,streams,epoch_min,epoch_max,chan_of_interest,...
        max_pwelch_freq,time_freq_frequencies_range,baseline_start,baseline_end);

end





